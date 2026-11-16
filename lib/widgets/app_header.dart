import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'brand_widgets.dart';

/// Navy top bar used on the inner screens (same style as the landing navbar).
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, this.onBack, this.backIcon = Icons.arrow_back_rounded, this.title, this.actions = const []});

  final VoidCallback? onBack;
  final IconData backIcon;
  final String? title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Container(
      decoration: const BoxDecoration(
        color: GlobioColors.brand,
        border: Border(bottom: BorderSide(color: GlobioColors.border, width: 0.8)),
      ),
      padding: EdgeInsets.only(
        left: w < 600 ? 4 : 16,
        right: w < 600 ? 12 : 24,
        top: MediaQuery.paddingOf(context).top,
      ),
      height: 64 + MediaQuery.paddingOf(context).top,
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              tooltip: backIcon == Icons.close_rounded ? 'Close' : 'Back',
              icon: Icon(backIcon, color: Colors.white),
            )
          else
            const SizedBox(width: 12),
          GlobioLogo(height: w < 600 ? 22 : 26),
          if (title != null && w >= 700) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              width: 1,
              height: 22,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            Flexible(
              child: Text(
                title!,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          const Spacer(),
          ...actions,
        ],
      ),
    );
  }
}

/// Small rounded label.
class Chip2 extends StatelessWidget {
  const Chip2(this.text, {super.key, this.bg = GlobioColors.muted, this.fg = GlobioColors.mutedForeground, this.icon});
  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 13, color: fg), const SizedBox(width: 4)],
          Text(text, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: fg)),
        ]),
      );
}

/// Centered, width-limited page body.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.child, this.maxWidth = 1100});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w < 600 ? 16 : 32, vertical: w < 600 ? 24 : 40),
      child: Center(
        child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
      ),
    );
  }
}

/// White bordered card.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(24), this.color = Colors.white, this.borderColor = GlobioColors.border});
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(GlobioTheme.radius + 4),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(color: GlobioColors.brand.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: child,
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: const TextStyle(fontSize: 14, color: GlobioColors.mutedForeground, height: 1.5)),
          ],
        ]),
      );
}
