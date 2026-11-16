import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The white Globio wordmark (same asset as globio.ai's navbar).
class GlobioLogo extends StatelessWidget {
  const GlobioLogo({super.key, this.height = 30});
  final double height;

  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/images/globio_logo.png',
        height: height,
        filterQuality: FilterQuality.high,
        semanticLabel: 'Globio',
      );
}

/// Text painted with the site's gold gradient (used for "Germany" on globio.ai).
class GoldGradientText extends StatelessWidget {
  const GoldGradientText(this.text, {super.key, required this.style, this.textAlign});
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => GlobioColors.goldGradient.createShader(r),
        child: Text(text, style: style, textAlign: textAlign),
      );
}

enum PillVariant { gold, outlineLight, primary, outlineDark }

/// Rounded-full buttons matching globio.ai ("Sign up" gold, "Log in" outline).
class PillButton extends StatefulWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PillVariant.gold,
    this.large = false,
    this.icon,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final PillVariant variant;
  final bool large;
  final IconData? icon;
  final bool expand;

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    late Color bg, fg, border;
    switch (widget.variant) {
      case PillVariant.gold:
        bg = _hover ? const Color(0xFFFFCB52) : GlobioColors.secondary;
        fg = GlobioColors.foreground;
        border = Colors.transparent;
      case PillVariant.outlineLight:
        bg = _hover ? Colors.white.withValues(alpha: 0.10) : Colors.transparent;
        fg = Colors.white;
        border = GlobioColors.border;
      case PillVariant.primary:
        bg = _hover ? GlobioColors.brand : GlobioColors.primary;
        fg = Colors.white;
        border = Colors.transparent;
      case PillVariant.outlineDark:
        bg = _hover ? GlobioColors.muted : Colors.white;
        fg = GlobioColors.primary;
        border = GlobioColors.border;
    }
    final disabled = widget.onPressed == null;
    final pad = widget.large
        ? const EdgeInsets.symmetric(horizontal: 28, vertical: 16)
        : const EdgeInsets.symmetric(horizontal: 18, vertical: 9);

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: pad,
      decoration: BoxDecoration(
        color: disabled ? bg.withValues(alpha: 0.6) : bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1),
        boxShadow: widget.variant == PillVariant.gold && widget.large
            ? [
                BoxShadow(
                  color: GlobioColors.secondary.withValues(alpha: _hover ? 0.45 : 0.25),
                  blurRadius: _hover ? 22 : 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              color: fg,
              fontSize: widget.large ? 16 : 14,
              fontWeight: widget.variant == PillVariant.gold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          if (widget.icon != null) ...[
            const SizedBox(width: 8),
            Icon(widget.icon, color: fg, size: widget.large ? 20 : 16),
          ],
        ],
      ),
    );

    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(onTap: widget.onPressed, child: child),
    );
  }
}

/// Faint dot grid that sits on top of the hero gradient (as on globio.ai).
class DotPattern extends StatelessWidget {
  const DotPattern({super.key, this.opacity = 0.10, this.spacing = 22});
  final double opacity;
  final double spacing;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: CustomPaint(painter: _DotPainter(opacity, spacing), size: Size.infinite),
      );
}

class _DotPainter extends CustomPainter {
  _DotPainter(this.opacity, this.spacing);
  final double opacity;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withValues(alpha: opacity);
    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotPainter old) =>
      old.opacity != opacity || old.spacing != spacing;
}

/// Small uppercase, letter-spaced section label ("OUR PROGRAMS" on globio.ai).
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color = GlobioColors.primary});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      );
}
