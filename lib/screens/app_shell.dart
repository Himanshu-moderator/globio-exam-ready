import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/wallet_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_widgets.dart';
import '../widgets/coin_widgets.dart';
import 'tabs/home_tab.dart';
import 'tabs/mentor_tab.dart';
import 'tabs/mocks_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/results_tab.dart';

enum ShellTab { home, mocks, results, mentor, profile }

extension ShellTabInfo on ShellTab {
  String get label => switch (this) {
        ShellTab.home => 'Home',
        ShellTab.mocks => 'Mock exams',
        ShellTab.results => 'My results',
        ShellTab.mentor => 'Mentor',
        ShellTab.profile => 'Profile',
      };

  String get shortLabel => switch (this) {
        ShellTab.mocks => 'Mocks',
        ShellTab.results => 'Results',
        _ => label,
      };

  IconData get icon => switch (this) {
        ShellTab.home => Icons.space_dashboard_outlined,
        ShellTab.mocks => Icons.assignment_outlined,
        ShellTab.results => Icons.insights_outlined,
        ShellTab.mentor => Icons.support_agent_outlined,
        ShellTab.profile => Icons.person_outline_rounded,
      };

  IconData get activeIcon => switch (this) {
        ShellTab.home => Icons.space_dashboard_rounded,
        ShellTab.mocks => Icons.assignment_rounded,
        ShellTab.results => Icons.insights_rounded,
        ShellTab.mentor => Icons.support_agent_rounded,
        ShellTab.profile => Icons.person_rounded,
      };
}

/// Global tab controller, so screens pushed on top of the shell (e.g. the
/// analysis) can send the learner to a tab: `ShellNav.open(context, tab)`.
class ShellNav {
  ShellNav._();
  static final tab = ValueNotifier<ShellTab>(ShellTab.home);

  /// Closes pushed screens and shows [t].
  static void open(BuildContext context, ShellTab t) {
    tab.value = t;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }
}

/// Lets any tab switch to another tab.
class ShellScope extends InheritedWidget {
  const ShellScope({super.key, required this.goTo, required super.child});
  final void Function(ShellTab tab) goTo;

  static ShellScope of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ShellScope>()!;

  @override
  bool updateShouldNotify(ShellScope oldWidget) => false;
}

/// Signed-in area of the app.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  ShellTab get _tab => ShellNav.tab.value;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    ShellNav.tab.value = ShellTab.home;
    ShellNav.tab.addListener(_onTab);
    _setup();
  }

  @override
  void dispose() {
    ShellNav.tab.removeListener(_onTab);
    super.dispose();
  }

  void _onTab() {
    if (mounted) setState(() {});
  }

  Future<void> _setup() async {
    final email = AuthService.instance.currentUser?.email;
    if (email != null) {
      await ProfileService.ensure(email); // personal student ID
      await Wallet.ensureWelcome(email); // 100 welcome coins, once
    }
    if (mounted) setState(() => _ready = true);
  }

  void _goTo(ShellTab t) => ShellNav.tab.value = t;

  Widget _page() => switch (_tab) {
        ShellTab.home => const HomeTab(),
        ShellTab.mocks => const MocksTab(),
        ShellTab.results => const ResultsTab(),
        ShellTab.mentor => const MentorTab(),
        ShellTab.profile => const ProfileTab(),
      };

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 960;
    final content = !_ready
        ? const Center(child: CircularProgressIndicator(color: GlobioColors.primary))
        : AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: KeyedSubtree(key: ValueKey(_tab), child: _page()),
          );

    return ShellScope(
      goTo: _goTo,
      child: Scaffold(
        backgroundColor: GlobioColors.muted,
        body: wide
            ? Row(children: [
                _Sidebar(current: _tab, onSelect: _goTo),
                Expanded(
                  child: Column(children: [
                    _DesktopTopBar(title: _tab.label, onCoins: () => _goTo(ShellTab.profile)),
                    Expanded(child: content),
                  ]),
                ),
              ])
            : Column(children: [
                _MobileTopBar(onCoins: () => _goTo(ShellTab.profile)),
                Expanded(child: content),
              ]),
        bottomNavigationBar: wide ? null : _BottomNav(current: _tab, onSelect: _goTo),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.current, required this.onSelect});
  final ShellTab current;
  final ValueChanged<ShellTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    return Container(
      width: 248,
      color: GlobioColors.brand,
      child: Stack(children: [
        const Positioned.fill(child: DotPattern(opacity: 0.05)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(padding: EdgeInsets.only(left: 10), child: GlobioLogo(height: 28)),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text('Am I exam-ready?',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 30),
            for (final t in ShellTab.values)
              _SideItem(tab: t, selected: t == current, onTap: () => onSelect(t)),
            const Spacer(),
            if (user != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(GlobioTheme.radius),
                ),
                child: Row(children: [
                  _Avatar(name: user.name, size: 34),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(user.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
                      Text(user.email,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 11.5)),
                    ]),
                  ),
                ]),
              ),
          ]),
        ),
      ]),
    );
  }
}

class _SideItem extends StatefulWidget {
  const _SideItem({required this.tab, required this.selected, required this.onTap});
  final ShellTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SideItem> createState() => _SideItemState();
}

class _SideItemState extends State<_SideItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    return Semantics(
      button: true,
      selected: sel,
      label: widget.tab.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: sel
                  ? Colors.white.withValues(alpha: 0.12)
                  : (_hover ? Colors.white.withValues(alpha: 0.06) : Colors.transparent),
              borderRadius: BorderRadius.circular(GlobioTheme.radius),
            ),
            child: Row(children: [
              Icon(sel ? widget.tab.activeIcon : widget.tab.icon,
                  size: 21, color: sel ? GlobioColors.secondary : Colors.white.withValues(alpha: 0.75)),
              const SizedBox(width: 12),
              Text(widget.tab.label,
                  style: TextStyle(
                    color: sel ? Colors.white : Colors.white.withValues(alpha: 0.75),
                    fontSize: 14,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                  )),
            ]),
          ),
        ),
      ),
    );
  }
}

class _DesktopTopBar extends StatelessWidget {
  const _DesktopTopBar({required this.title, required this.onCoins});
  final String title;
  final VoidCallback onCoins;

  @override
  Widget build(BuildContext context) => Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: GlobioColors.border)),
        ),
        child: Row(children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const Spacer(),
          CoinBalancePill(dark: false, onTap: onCoins),
        ]),
      );
}

class _MobileTopBar extends StatelessWidget {
  const _MobileTopBar({required this.onCoins});
  final VoidCallback onCoins;

  @override
  Widget build(BuildContext context) => Container(
        color: GlobioColors.brand,
        padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 10, 16, 10),
        child: Row(children: [
          const GlobioLogo(height: 24),
          const Spacer(),
          CoinBalancePill(onTap: onCoins),
        ]),
      );
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.current, required this.onSelect});
  final ShellTab current;
  final ValueChanged<ShellTab> onSelect;

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: GlobioColors.border)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        child: Row(children: [
          for (final t in ShellTab.values)
            Expanded(
              child: Semantics(
                button: true,
                selected: t == current,
                label: t.label,
                child: InkWell(
                  onTap: () => onSelect(t),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: t == current ? GlobioColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Icon(t == current ? t.activeIcon : t.icon,
                            size: 22, color: t == current ? GlobioColors.primary : GlobioColors.mutedForeground),
                      ),
                      const SizedBox(height: 3),
                      Text(t.shortLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: t == current ? FontWeight.w700 : FontWeight.w500,
                            color: t == current ? GlobioColors.primary : GlobioColors.mutedForeground,
                          )),
                    ]),
                  ),
                ),
              ),
            ),
        ]),
      );
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.size = 40});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final initials = parts.isEmpty ? '?' : (parts.first[0] + (parts.length > 1 ? parts.last[0] : '')).toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: GlobioColors.goldGradient),
      child: Text(initials,
          style: TextStyle(fontSize: size * 0.38, fontWeight: FontWeight.w700, color: GlobioColors.brand)),
    );
  }
}

/// Public avatar for other screens.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, this.size = 40});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) => _Avatar(name: name, size: size);
}
