import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/local_store.dart';
import '../services/wallet_service.dart';
import '../theme/app_theme.dart';

/// Gold Globio coin.
class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 18});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: GlobioColors.goldGradient,
          border: Border.all(color: const Color(0xFFE0A100), width: size / 14),
        ),
        child: Text('G',
            style: TextStyle(
                fontSize: size * 0.55, fontWeight: FontWeight.w800, color: GlobioColors.brand, height: 1)),
      );
}

/// Live coin balance pill (refreshes whenever coins change).
class CoinBalancePill extends StatefulWidget {
  const CoinBalancePill({super.key, this.onTap, this.dark = true});
  final VoidCallback? onTap;

  /// True on navy backgrounds.
  final bool dark;

  @override
  State<CoinBalancePill> createState() => _CoinBalancePillState();
}

class _CoinBalancePillState extends State<CoinBalancePill> {
  int? _balance;

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
    if (email == null) return;
    final b = await Wallet.balance(email);
    if (mounted) setState(() => _balance = b);
  }

  @override
  Widget build(BuildContext context) => Semantics(
        button: widget.onTap != null,
        label: '${_balance ?? 0} coins',
        child: MouseRegion(
          cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
              decoration: BoxDecoration(
                color: widget.dark ? Colors.white.withValues(alpha: 0.1) : GlobioColors.secondarySoft,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                    color: widget.dark ? Colors.white.withValues(alpha: 0.25) : GlobioColors.secondary.withValues(alpha: 0.6)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const CoinIcon(size: 22),
                const SizedBox(width: 8),
                Text('${_balance ?? '–'}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: widget.dark ? Colors.white : GlobioColors.foreground,
                    )),
              ]),
            ),
          ),
        ),
      );
}
