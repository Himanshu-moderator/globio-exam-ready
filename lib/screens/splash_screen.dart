import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_widgets.dart';
import 'app_shell.dart';
import 'landing_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Intro timeline: logo › tagline › loader.
  late final AnimationController _intro =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  // Progress bar fill.
  late final AnimationController _progress =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
  // Looping ambient motion (rings, orbs, shimmer).
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
  // Exit fade.
  late final AnimationController _exit =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 450));

  static const _steps = [
    'Loading vocabulary',
    'Loading grammar',
    'Loading reading',
    'Almost ready',
  ];

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    // init() never throws, but never let the splash hang on it either.
    final authReady = AuthService.instance
        .init()
        .timeout(const Duration(seconds: 5), onTimeout: () {})
        .catchError((Object _) {});
    await _intro.forward();
    await Future.wait([_progress.forward(), authReady]);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    await _exit.forward();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) =>
            AuthService.instance.isSignedIn ? const AppShell() : const LandingScreen(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _progress.dispose();
    _loop.dispose();
    _exit.dispose();
    super.dispose();
  }

  Animation<double> _interval(double a, double b, [Curve c = Curves.easeOutCubic]) =>
      CurvedAnimation(parent: _intro, curve: Interval(a, b, curve: c));

  @override
  Widget build(BuildContext context) {
    final logoIn = _interval(0.0, 0.55, Curves.easeOutBack);
    final taglineIn = _interval(0.35, 0.8);
    final loaderIn = _interval(0.6, 1.0);
    final w = MediaQuery.sizeOf(context).width;
    final logoH = w < 500 ? 46.0 : 60.0;

    return Scaffold(
      backgroundColor: GlobioColors.brand,
      body: FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0).animate(_exit),
        child: Container(
          decoration: const BoxDecoration(gradient: GlobioColors.heroGradient),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DotPattern(opacity: 0.08),
              // Drifting glow orbs.
              AnimatedBuilder(
                animation: _loop,
                builder: (_, __) {
                  final t = _loop.value * 2 * math.pi;
                  return Stack(children: [
                    _Orb(
                      color: GlobioColors.secondary.withValues(alpha: 0.22),
                      size: 380,
                      alignment: Alignment(-0.9 + 0.08 * math.sin(t), 0.95 + 0.05 * math.cos(t)),
                    ),
                    _Orb(
                      color: GlobioColors.accent.withValues(alpha: 0.45),
                      size: 460,
                      alignment: Alignment(0.95 + 0.06 * math.cos(t), -0.9 + 0.06 * math.sin(t)),
                    ),
                  ]);
                },
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo with pulsing rings.
                      SizedBox(
                        height: 220,
                        width: 300,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: Listenable.merge([_loop, logoIn]),
                              builder: (_, __) => CustomPaint(
                                size: const Size(300, 220),
                                painter: _RingsPainter(_loop.value, logoIn.value.clamp(0, 1)),
                              ),
                            ),
                            AnimatedBuilder(
                              animation: logoIn,
                              builder: (_, child) => Opacity(
                                opacity: logoIn.value.clamp(0, 1),
                                child: Transform.scale(scale: 0.6 + 0.4 * logoIn.value, child: child),
                              ),
                              child: GlobioLogo(height: logoH),
                            ),
                          ],
                        ),
                      ),
                      _SlideFade(
                        animation: taglineIn,
                        child: Column(children: [
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              Text('Am I ',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: w < 500 ? 26 : 34,
                                      fontWeight: FontWeight.w700)),
                              GoldGradientText('exam-ready?',
                                  style: TextStyle(
                                      fontSize: w < 500 ? 26 : 34, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Goethe & ÖSD mock exams',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 40),
                      _SlideFade(
                        animation: loaderIn,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_progress, _loop]),
                          builder: (_, __) => _LoaderBar(
                            value: Curves.easeInOutCubic.transform(_progress.value),
                            shimmer: _loop.value,
                            label: _steps[(_progress.value * (_steps.length - 0.001)).floor()],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideFade extends StatelessWidget {
  const _SlideFade({required this.animation, required this.child});
  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: animation,
        builder: (_, c) => Opacity(
          opacity: animation.value.clamp(0, 1),
          child: Transform.translate(offset: Offset(0, 18 * (1 - animation.value)), child: c),
        ),
        child: child,
      );
}

class _Orb extends StatelessWidget {
  const _Orb({required this.color, required this.size, required this.alignment});
  final Color color;
  final double size;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => Align(
        alignment: alignment,
        child: IgnorePointer(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
            ),
          ),
        ),
      );
}

/// Three rings expanding outward from the logo, fading as they grow.
class _RingsPainter extends CustomPainter {
  _RingsPainter(this.t, this.intro);
  final double t;
  final double intro;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (var i = 0; i < 3; i++) {
      final p = (t + i / 3) % 1.0;
      final r = 60 + 90 * p;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = (i == 0 ? GlobioColors.secondary : Colors.white)
            .withValues(alpha: (1 - p) * 0.35 * intro);
      canvas.drawCircle(c, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) => old.t != t || old.intro != intro;
}

class _LoaderBar extends StatelessWidget {
  const _LoaderBar({required this.value, required this.shimmer, required this.label});
  final double value;
  final double shimmer;
  final String label;

  @override
  Widget build(BuildContext context) {
    const width = 260.0;
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Container(
            height: 6,
            width: width,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.centerLeft,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                width: width * value,
                height: 6,
                child: Stack(fit: StackFit.expand, children: [
                  const DecoratedBox(decoration: BoxDecoration(gradient: GlobioColors.goldGradient)),
                  // Moving highlight.
                  FractionalTranslation(
                    translation: Offset(-1 + 2 * shimmer, 0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(alpha: 0.6),
                          Colors.white.withValues(alpha: 0),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$label…',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              Text('${(value * 100).round()}%',
                  style: const TextStyle(
                      color: GlobioColors.secondary, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
