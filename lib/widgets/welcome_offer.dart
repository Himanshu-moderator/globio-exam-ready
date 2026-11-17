import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/local_store.dart';
import '../services/offer_service.dart';
import '../services/wallet_service.dart';
import '../theme/app_theme.dart';
import 'brand_widgets.dart';
import 'coin_widgets.dart';

/// Welcome popup for a new account.
///
/// Front: welcome + "Claim 100 coins". After claiming, the card flips and
/// the back shows the limited launch offer (3 mocks for 100 coins,
/// 17–25 Nov 2026) while it runs. [show] with `offerOnly` opens straight on
/// the offer side (used by the offer banner).
class WelcomeOfferDialog extends StatefulWidget {
  const WelcomeOfferDialog._({required this.email, required this.offerOnly});
  final String email;
  final bool offerOnly;

  static Future<void> show(BuildContext context, {required String email, bool offerOnly = false}) => showDialog<void>(
    context: context,
    barrierDismissible: offerOnly, // the welcome coins must be claimed
    builder: (_) => WelcomeOfferDialog._(email: email, offerOnly: offerOnly),
  );

  @override
  State<WelcomeOfferDialog> createState() => _WelcomeOfferDialogState();
}

class _WelcomeOfferDialogState extends State<WelcomeOfferDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
    value: widget.offerOnly ? 1 : 0,
  );
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  void _close(String? message) {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    if (message != null) messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _claim() async {
    if (_busy) return;
    setState(() => _busy = true);
    await Wallet.ensureWelcome(widget.email);
    final offer = await LaunchOffer.canBuy(widget.email);
    if (!mounted) return;
    setState(() => _busy = false);
    if (offer) {
      await _flip.forward();
    } else {
      _close('100 coins added to your wallet.');
    }
  }

  Future<void> _buy() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await LaunchOffer.buy(widget.email);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _busy = false;
        _error = err;
      });
      return;
    }
    _close('${LaunchOffer.mocks} mocks added — start one from Mock exams.');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: AnimatedBuilder(
          animation: _flip,
          builder: (context, _) {
            final angle = Curves.easeInOutCubic.transform(_flip.value) * math.pi;
            final front = angle <= math.pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(angle),
              // Both sides are laid out so the card keeps one size while flipping.
              child: Stack(
                children: [
                  Visibility(
                    visible: front,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: _Front(busy: _busy, onClaim: _claim),
                  ),
                  Positioned.fill(
                    child: Visibility(
                      visible: !front,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: _Back(
                          busy: _busy,
                          error: _error,
                          onBuy: _buy,
                          onLater: () => _close('The offer stays on your Mock exams page until 25 Nov.'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Front extends StatelessWidget {
  const _Front({required this.busy, required this.onClaim});
  final bool busy;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final name = AuthService.instance.currentUser?.firstName ?? '';
    return Container(
      decoration: BoxDecoration(
        gradient: GlobioColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: GlobioColors.brand.withValues(alpha: 0.35), blurRadius: 40, offset: const Offset(0, 16)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            const Positioned.fill(child: DotPattern(opacity: 0.08)),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: GlobioColors.secondary.withValues(alpha: 0.55), blurRadius: 36)],
                    ),
                    child: const CoinIcon(size: 72),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    name.isEmpty ? 'Welcome to Globio!' : 'Welcome to Globio, $name!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your account is ready. Here is a gift to get you started — enough for your first mock exam.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15, height: 1.55),
                  ),
                  const SizedBox(height: 22),
                  const GoldGradientText(
                    '+${Wallet.welcomeBonus} coins',
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 24),
                  PillButton(
                    label: busy ? 'Adding…' : 'Claim ${Wallet.welcomeBonus} coins',
                    icon: Icons.redeem_rounded,
                    large: true,
                    expand: true,
                    onPressed: busy ? null : onClaim,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Back extends StatelessWidget {
  const _Back({required this.busy, required this.error, required this.onBuy, required this.onLater});
  final bool busy;
  final String? error;
  final VoidCallback onBuy;
  final VoidCallback onLater;

  String _endsIn() {
    final d = LaunchOffer.end.difference(DateTime.now());
    if (d.inDays >= 1) return 'ends in ${d.inDays} day${d.inDays == 1 ? '' : 's'}';
    final h = d.inHours.clamp(1, 24);
    return 'ends in $h hour${h == 1 ? '' : 's'}';
  }

  @override
  Widget build(BuildContext context) {
    const full = LaunchOffer.mocks * Wallet.mockPrice;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: GlobioColors.secondary, width: 2),
        boxShadow: [
          BoxShadow(color: GlobioColors.brand.withValues(alpha: 0.25), blurRadius: 40, offset: const Offset(0, 16)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 18),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: GlobioColors.goldGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'LIMITED LAUNCH OFFER',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: GlobioColors.foreground,
                    ),
                  ),
                ),
                Text(
                  _endsIn(),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GlobioColors.destructive),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              '${LaunchOffer.mocks} mocks for ${LaunchOffer.price} coins',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, height: 1.2),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  '$full coins',
                  style: TextStyle(
                    fontSize: 15,
                    color: GlobioColors.mutedForeground,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: GlobioColors.mutedForeground,
                  ),
                ),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CoinIcon(size: 18),
                    SizedBox(width: 4),
                    Text(
                      '${LaunchOffer.price}',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: GlobioColors.primary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: GlobioColors.successSoft, borderRadius: BorderRadius.circular(999)),
                  child: const Text(
                    'Save ${full - LaunchOffer.price}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GlobioColors.success),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final t in const [
              'Only from 17 to 25 November 2026',
              'Any exam: Goethe A1, A2, B1 or ÖSD A1',
              'Use them any time — they never expire',
              'Take two mocks of one exam to get a confirmed readiness result',
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 18, color: GlobioColors.primary),
                    const SizedBox(width: 10),
                    Expanded(child: Text(t, style: const TextStyle(fontSize: 14, height: 1.4))),
                  ],
                ),
              ),
            if (error != null) ...[
              const SizedBox(height: 4),
              Text(error!, style: const TextStyle(fontSize: 13, color: GlobioColors.destructive)),
            ],
            const SizedBox(height: 14),
            PillButton(
              label: busy ? 'Adding…' : 'Get ${LaunchOffer.mocks} mocks for ${LaunchOffer.price} coins',
              icon: Icons.local_offer_rounded,
              variant: PillVariant.primary,
              expand: true,
              onPressed: busy ? null : onBuy,
            ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: busy ? null : onLater,
                child: const Text(
                  'Maybe later',
                  style: TextStyle(color: GlobioColors.mutedForeground, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Banner shown on Home and Mock exams while the launch offer can be bought.
class LaunchOfferBanner extends StatefulWidget {
  const LaunchOfferBanner({super.key});

  @override
  State<LaunchOfferBanner> createState() => _LaunchOfferBannerState();
}

class _LaunchOfferBannerState extends State<LaunchOfferBanner> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    AppEvents.instance.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    AppEvents.instance.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final email = AuthService.instance.currentUser?.email;
    // Only after the welcome coins are claimed (the popup shows it first).
    final show = email != null && await Wallet.has(email, 'welcome') && await LaunchOffer.canBuy(email);
    if (mounted && show != _show) setState(() => _show = show);
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();
    final email = AuthService.instance.currentUser?.email;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: GlobioColors.heroGradient,
        borderRadius: BorderRadius.circular(GlobioTheme.radius),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_offer_rounded, color: GlobioColors.secondary),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Launch offer: ${LaunchOffer.mocks} mocks for ${LaunchOffer.price} coins',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    Text(
                      'Only until 25 Nov 2026 — save ${LaunchOffer.mocks * Wallet.mockPrice - LaunchOffer.price} coins.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          PillButton(
            label: 'See offer',
            onPressed: email == null ? null : () => WelcomeOfferDialog.show(context, email: email, offerOnly: true),
          ),
        ],
      ),
    );
  }
}
