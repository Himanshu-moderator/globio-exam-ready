import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_widgets.dart';
import 'auth_screen.dart';
import 'app_shell.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  final _howKey = GlobalKey();
  final _skillsKey = GlobalKey();
  final _whyKey = GlobalKey();
  late final AnimationController _enter =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);
    }
  }

  Future<bool> _openAuth(AuthMode mode) async {
    final ok = await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => AuthScreen(initialMode: mode),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      ),
    );
    if (ok == true && mounted) {
      final name = AuthService.instance.currentUser?.firstName ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome, $name! You are signed in.')),
      );
      _openApp();
    }
    return ok == true;
  }

  /// Signed-in area (dashboard with tabs).
  void _openApp() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => const AppShell(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      ),
      (_) => false,
    );
  }

  Future<void> _startCheck() async {
    if (!AuthService.instance.isSignedIn) {
      await _openAuth(AuthMode.signUp);
      return;
    }
    _openApp();
  }

  void _openResults() => _openApp();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (context, _) => Scaffold(
        body: Column(
          children: [
            _NavBar(
              onHow: () => _scrollTo(_howKey),
              onSkills: () => _scrollTo(_skillsKey),
              onWhy: () => _scrollTo(_whyKey),
              onLogin: () => _openAuth(AuthMode.logIn),
              onSignup: () => _openAuth(AuthMode.signUp),
              onResults: _openResults,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _Hero(enter: _enter, onStart: _startCheck, onHow: () => _scrollTo(_howKey)),
                    _WhySection(key: _whyKey),
                    _HowSection(key: _howKey),
                    _SkillsSection(key: _skillsKey),
                    _CtaBand(onStart: _startCheck),
                    const _Footer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────── Layout helpers ─────────────────────────────

const _maxWidth = 1200.0;

class _Section extends StatelessWidget {
  const _Section({required this.child, this.color, this.vertical = 88});
  final Widget child;
  final Color? color;
  final double vertical;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Container(
      width: double.infinity,
      color: color,
      padding: EdgeInsets.symmetric(horizontal: w < 600 ? 16 : 32, vertical: w < 600 ? 56 : vertical),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: child,
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.eyebrow, required this.title, this.subtitle});
  final String eyebrow;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Column(
      children: [
        Eyebrow(eyebrow),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: w < 600 ? 26 : 34,
            fontWeight: FontWeight.w700,
            color: GlobioColors.foreground,
            height: 1.2,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: GlobioColors.mutedForeground, height: 1.6),
            ),
          ),
        ],
        const SizedBox(height: 48),
      ],
    );
  }
}

/// Lays children out in [columns] equal columns on wide screens, stacked on narrow.
class _ResponsiveRow extends StatelessWidget {
  const _ResponsiveRow({required this.children});
  final List<Widget> children;
  static const breakpoint = 860.0;
  static const gap = 24.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        if (c.maxWidth < breakpoint) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: gap),
                children[i],
              ],
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(width: gap),
                Expanded(child: children[i]),
              ],
            ],
          ),
        );
      });
}

class _Card extends StatefulWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _hover ? -4 : 0, 0),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(GlobioTheme.radius + 4),
            border: Border.all(color: GlobioColors.border),
            boxShadow: [
              BoxShadow(
                color: GlobioColors.brand.withValues(alpha: _hover ? 0.10 : 0.04),
                blurRadius: _hover ? 30 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: widget.child,
        ),
      );
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.bg, required this.fg});
  final IconData icon;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(GlobioTheme.radius)),
        child: Icon(icon, color: fg, size: 24),
      );
}

// ───────────────────────────── Nav bar ─────────────────────────────

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.onHow,
    required this.onSkills,
    required this.onWhy,
    required this.onLogin,
    required this.onSignup,
    required this.onResults,
  });
  final VoidCallback onHow, onSkills, onWhy, onLogin, onSignup, onResults;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final user = AuthService.instance.currentUser;
    return Container(
      decoration: const BoxDecoration(
        color: GlobioColors.brand,
        border: Border(bottom: BorderSide(color: GlobioColors.border, width: 0.8)),
      ),
      padding: EdgeInsets.symmetric(horizontal: w < 600 ? 16 : 32),
      height: 64,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Row(
            children: [
              GlobioLogo(height: w < 600 ? 24 : 30),
              const Spacer(),
              if (w >= 860) ...[
                _NavLink('How it works', onHow),
                _NavLink('Skills', onSkills),
                _NavLink('Why it matters', onWhy),
                const Spacer(),
              ],
              if (user == null) ...[
                PillButton(label: 'Log in', variant: PillVariant.outlineLight, onPressed: onLogin),
                const SizedBox(width: 10),
                PillButton(label: 'Sign up', variant: PillVariant.gold, onPressed: onSignup),
              ] else ...[
                if (w >= 600)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text('Hi, ${user.firstName}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                PillButton(label: 'Dashboard', variant: PillVariant.gold, onPressed: onResults),
                const SizedBox(width: 10),
                PillButton(
                  label: 'Log out',
                  variant: PillVariant.outlineLight,
                  onPressed: () => AuthService.instance.logOut(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.label,
              style: TextStyle(
                color: _hover ? GlobioColors.secondary : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
}

// ───────────────────────────── Hero ─────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.enter, required this.onStart, required this.onHow});
  final AnimationController enter;
  final VoidCallback onStart;
  final VoidCallback onHow;

  Widget _fadeUp(double from, double to, Widget child) {
    final a = CurvedAnimation(parent: enter, curve: Interval(from, to, curve: Curves.easeOutCubic));
    return AnimatedBuilder(
      animation: a,
      builder: (_, c) => Opacity(
        opacity: a.value,
        child: Transform.translate(offset: Offset(0, 24 * (1 - a.value)), child: c),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final wide = w >= 960;
    final h1 = w < 600 ? 38.0 : 56.0;

    final copy = Column(
      crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        _fadeUp(0, 0.5, const _HeroBadge()),
        const SizedBox(height: 24),
        _fadeUp(
          0.1,
          0.6,
          Column(
            crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Text('Am I',
                  style: TextStyle(
                      color: Colors.white, fontSize: h1, fontWeight: FontWeight.w700, height: 1.15)),
              GoldGradientText('exam-ready?',
                  style: TextStyle(fontSize: h1, fontWeight: FontWeight.w700, height: 1.15)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _fadeUp(
          0.2,
          0.7,
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            // Plain text only: every character here exists in Poppins, so the
            // engine never needs to fetch a fallback font.
            child: Text(
              'Finished A1 German and thinking of booking your Goethe or ÖSD exam? '
              'Take a short check of 16 questions across listening, reading, grammar and vocabulary. '
              'See how ready you are in each skill — and the 2–3 things to practise before you book.',
              textAlign: wide ? TextAlign.start : TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: w < 600 ? 15 : 17,
                height: 1.65,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        _fadeUp(
          0.3,
          0.8,
          Wrap(
            spacing: 14,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              PillButton(
                label: 'Take the free check',
                large: true,
                icon: Icons.arrow_forward_rounded,
                onPressed: onStart,
              ),
              PillButton(
                label: 'How it works',
                large: true,
                variant: PillVariant.outlineLight,
                onPressed: onHow,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _fadeUp(
          0.4,
          0.9,
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _StatChip(icon: Icons.quiz_outlined, value: '16', label: 'Questions'),
              _StatChip(icon: Icons.layers_outlined, value: '3', label: 'Skills checked'),
              _StatChip(icon: Icons.bolt_outlined, value: 'Instant', label: 'Result'),
            ],
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: GlobioColors.heroGradient),
      child: Stack(
        children: [
          const Positioned.fill(child: DotPattern(opacity: 0.08)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w < 600 ? 16 : 32, vertical: w < 600 ? 48 : 88),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxWidth),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 11, child: copy),
                          const SizedBox(width: 48),
                          Expanded(flex: 9, child: _fadeUp(0.35, 1, const _SampleReportCard())),
                        ],
                      )
                    : Column(children: [
                        copy,
                        const SizedBox(height: 48),
                        _fadeUp(0.35, 1, const _SampleReportCard()),
                      ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: GlobioColors.secondary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: GlobioColors.secondary.withValues(alpha: 0.7), blurRadius: 8),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Goethe A1–B1 · ÖSD A1 — check before you book',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: GlobioColors.secondary, size: 16),
          const SizedBox(width: 8),
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
        ]),
      );
}

/// White card on the hero, like the "Book your seat" card on globio.ai.
/// Clearly marked as an example of what the result will look like.
class _SampleReportCard extends StatelessWidget {
  const _SampleReportCard();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Your readiness report',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: GlobioColors.muted,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('Example',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: GlobioColors.mutedForeground)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Goethe-Zertifikat A1 · Start Deutsch 1',
                style: TextStyle(fontSize: 13, color: GlobioColors.mutedForeground)),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GlobioColors.muted,
                borderRadius: BorderRadius.circular(GlobioTheme.radius),
              ),
              child: const Column(children: [
                Text('OVERALL',
                    style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: GlobioColors.mutedForeground)),
                SizedBox(height: 4),
                Text('Almost ready',
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w700, color: GlobioColors.primary)),
              ]),
            ),
            const SizedBox(height: 20),
            // Example numbers a 16-question mock can really produce (4 per skill).
            // Overall 75%, but grammar is below the 60% pass mark › "Almost ready".
            const _SkillBar(label: 'Listening', value: 0.75, color: GlobioColors.brand),
            const SizedBox(height: 14),
            const _SkillBar(label: 'Reading', value: 0.75, color: GlobioColors.accent),
            const SizedBox(height: 14),
            const _SkillBar(label: 'Grammar', value: 0.5, color: GlobioColors.secondary),
            const SizedBox(height: 14),
            const _SkillBar(label: 'Vocabulary', value: 1.0, color: GlobioColors.primary),
            const SizedBox(height: 20),
            const Text('Practise before you book',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const _Bullet('Verb in second position'),
            const _Bullet('Accusative articles (den, einen)'),
          ],
        ),
      ),
    );
  }
}

class _SkillBar extends StatelessWidget {
  const _SkillBar({required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('${(value * 100).round()}%',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 8,
                backgroundColor: GlobioColors.muted,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ],
      );
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(children: [
          const Icon(Icons.check_circle_rounded, size: 16, color: GlobioColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13, color: GlobioColors.mutedForeground)),
          ),
        ]),
      );
}

// ───────────────────────────── Why it matters ─────────────────────────────

class _WhySection extends StatelessWidget {
  const _WhySection({super.key});

  @override
  Widget build(BuildContext context) {
    return _Section(
      color: GlobioColors.muted,
      child: Column(children: [
        const _SectionHeading(
          eyebrow: 'Why it matters',
          title: 'A failed exam costs more than the fee',
          subtitle:
              'Many learners finish A1 and book the exam without knowing if they are ready. '
              'Some fail and lose both the fee and precious time on their journey abroad.',
        ),
        _ResponsiveRow(children: const [
          _FactCard(
            icon: Icons.rule_rounded,
            tileBg: GlobioColors.primary,
            tileFg: Colors.white,
            title: 'All-or-nothing at A1',
            body: 'Goethe A1 needs at least 60 of 100 points with every part passed — '
                'and A1 can only be retaken as a whole exam.',
            source: 'Goethe-Institut India, exam FAQ',
          ),
          _FactCard(
            icon: Icons.currency_rupee_rounded,
            tileBg: GlobioColors.secondary,
            tileFg: GlobioColors.foreground,
            title: '≈ ₹9,400 per attempt',
            body: 'A fail means paying the full Goethe A1 fee again — and waiting '
                'for another exam slot, which can take months to get.',
            source: 'Goethe exam fee guide for India, 2026',
          ),
          _FactCard(
            icon: Icons.insights_rounded,
            tileBg: GlobioColors.accent,
            tileFg: Colors.white,
            title: 'One weak skill is enough',
            body: 'Learners who fail often say they understood most of it — but one '
                'skill they never checked let them down on the day.',
            source: 'Learner reports, r/German & r/goetheinstitut',
          ),
        ]),
      ]),
    );
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({
    required this.icon,
    required this.tileBg,
    required this.tileFg,
    required this.title,
    required this.body,
    required this.source,
  });
  final IconData icon;
  final Color tileBg, tileFg;
  final String title, body, source;

  @override
  Widget build(BuildContext context) => _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconTile(icon: icon, bg: tileBg, fg: tileFg),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text(body,
                style: const TextStyle(
                    fontSize: 14.5, color: GlobioColors.mutedForeground, height: 1.6)),
            const SizedBox(height: 16),
            Text('Source: $source',
                style: TextStyle(
                    fontSize: 11.5,
                    color: GlobioColors.mutedForeground.withValues(alpha: 0.85),
                    fontStyle: FontStyle.italic)),
          ],
        ),
      );
}

// ───────────────────────────── How it works ─────────────────────────────

class _HowSection extends StatelessWidget {
  const _HowSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _Section(
      child: Column(children: [
        const _SectionHeading(eyebrow: 'How it works', title: 'Three steps to exam-ready'),
        _ResponsiveRow(children: const [
          _StepCard(
            step: '01',
            title: 'Take the check',
            body: '16 short questions in the style of the real exam: listening with audio, '
                'reading, grammar and vocabulary.',
          ),
          _StepCard(
            step: '02',
            title: 'See your readiness',
            body: 'Get an overall readiness level plus a score for each skill, so you know '
                'exactly where you stand.',
          ),
          _StepCard(
            step: '03',
            title: 'Practise, then book',
            body: 'Work on the 2–3 things that matter most for you — then book your Goethe '
                'or ÖSD exam with confidence.',
          ),
        ]),
      ]),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step, required this.title, required this.body});
  final String step, title, body;

  @override
  Widget build(BuildContext context) => _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step $step',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: GlobioColors.primary)),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text(body,
                style: const TextStyle(
                    fontSize: 14.5, color: GlobioColors.mutedForeground, height: 1.6)),
          ],
        ),
      );
}

// ───────────────────────────── Skills ─────────────────────────────

class _SkillsSection extends StatelessWidget {
  const _SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _Section(
      color: GlobioColors.muted,
      child: Column(children: [
        const _SectionHeading(
          eyebrow: 'What we check',
          title: 'The four skills that decide your result',
          subtitle: 'Each question is tagged to one skill, so your result tells you '
              'what to practise — not just a single number.',
        ),
        _ResponsiveRow(children: const [
          _SkillCard(
            icon: Icons.headphones_rounded,
            tileBg: GlobioColors.brand,
            tileFg: Colors.white,
            name: 'Listening',
            german: 'Hören',
            topics: ['Short everyday dialogues', 'Announcements, played once', 'Phone messages'],
          ),
          _SkillCard(
            icon: Icons.translate_rounded,
            tileBg: GlobioColors.primary,
            tileFg: Colors.white,
            name: 'Vocabulary',
            german: 'Wortschatz',
            topics: ['Family & introductions', 'Food, shopping & prices', 'Numbers, days & time'],
          ),
          _SkillCard(
            icon: Icons.account_tree_outlined,
            tileBg: GlobioColors.secondary,
            tileFg: GlobioColors.foreground,
            name: 'Grammar',
            german: 'Grammatik',
            topics: ['Verb position', 'Articles & accusative', 'Modal verbs & questions'],
          ),
          _SkillCard(
            icon: Icons.chrome_reader_mode_outlined,
            tileBg: GlobioColors.accent,
            tileFg: Colors.white,
            name: 'Reading',
            german: 'Lesen',
            topics: ['Short notes & messages', 'Signs & adverts', 'Simple emails'],
          ),
        ]),
      ]),
    );
  }
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({
    required this.icon,
    required this.tileBg,
    required this.tileFg,
    required this.name,
    required this.german,
    required this.topics,
  });
  final IconData icon;
  final Color tileBg, tileFg;
  final String name, german;
  final List<String> topics;

  @override
  Widget build(BuildContext context) => _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _IconTile(icon: icon, bg: tileBg, fg: tileFg),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                Text(german,
                    style: const TextStyle(fontSize: 13, color: GlobioColors.mutedForeground)),
              ]),
            ]),
            const SizedBox(height: 18),
            for (final t in topics) _Bullet(t),
          ],
        ),
      );
}

// ───────────────────────────── CTA + footer ─────────────────────────────

class _CtaBand extends StatelessWidget {
  const _CtaBand({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return _Section(
      vertical: 72,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: GlobioColors.ctaGradient,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(children: [
          const Positioned.fill(child: DotPattern(opacity: 0.08)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: w < 600 ? 40 : 56),
            child: Column(children: [
              Wrap(alignment: WrapAlignment.center, children: [
                Text('Know before ',
                    style: TextStyle(
                        color: Colors.white, fontSize: w < 600 ? 26 : 34, fontWeight: FontWeight.w700)),
                GoldGradientText('you book.',
                    style: TextStyle(fontSize: w < 600 ? 26 : 34, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 12),
              Text(
                'A few minutes now can save you an exam fee and months of waiting.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16),
              ),
              const SizedBox(height: 28),
              PillButton(
                label: 'Take the free check',
                large: true,
                icon: Icons.arrow_forward_rounded,
                onPressed: onStart,
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Container(
      width: double.infinity,
      color: GlobioColors.brand,
      padding: EdgeInsets.symmetric(horizontal: w < 600 ? 16 : 32, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 16,
            spacing: 24,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlobioLogo(height: 26),
                  SizedBox(height: 10),
                  Text('Language · Career · Immigration — all under one roof',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
              Text(
                '© ${DateTime.now().year} Globio · "Am I exam-ready?" readiness check',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
