import 'package:flutter/material.dart';

import '../../data/exams.dart';
import '../../models/attempt.dart';
import '../../models/quiz.dart';
import '../../services/attempt_store.dart';
import '../../services/auth_service.dart';
import '../../services/local_store.dart';
import '../../services/mock_access.dart';
import '../../services/readiness.dart';
import '../../services/wallet_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../utils/ist.dart';
import '../../widgets/app_header.dart';
import '../../widgets/brand_widgets.dart';
import '../../widgets/coin_widgets.dart';
import '../../widgets/mock_launcher.dart';
import '../../widgets/verdict_style.dart';

class MocksTab extends StatefulWidget {
  const MocksTab({super.key});

  @override
  State<MocksTab> createState() => _MocksTabState();
}

class _MocksTabState extends State<MocksTab> {
  bool _loading = true;
  Attempt? _active;
  List<Attempt> _history = [];
  FreeStatus? _free;
  int _balance = 0;

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
    final store = AttemptStore.instance;
    await store.finalizeIfExpired(email);
    var active = await store.active(email);
    if (active != null && examById(active.examId) == null) {
      await store.clearActive(email);
      active = null;
    }
    final history = await store.history(email);
    final free = await MockAccess.freeStatus(email);
    final balance = await Wallet.balance(email);
    if (!mounted) return;
    setState(() {
      _active = active;
      _history = history;
      _free = free;
      _balance = balance;
      _loading = false;
    });
  }

  AttemptResult? _lastFor(ExamInfo e) {
    for (final a in _history) {
      if (a.examId == e.id) return Readiness.evaluate(e, a);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: GlobioColors.primary));
    final w = MediaQuery.sizeOf(context).width;
    return SingleChildScrollView(
      child: PageBody(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Choose your mock exam', style: TextStyle(fontSize: w < 600 ? 24 : 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            'Each mock draws 15 questions from that exam\'s own bank, at that exam\'s level — a different mix every time.',
            style: TextStyle(fontSize: 14.5, color: GlobioColors.mutedForeground, height: 1.55),
          ),
          const SizedBox(height: 20),
          _AccessBar(free: _free!, balance: _balance),
          const SizedBox(height: 20),
          if (_active != null) ...[
            _Running(attempt: _active!, onResume: () => MockLauncher.resumeActive(context)),
            const SizedBox(height: 20),
          ],
          LayoutBuilder(builder: (context, c) {
            final cols = c.maxWidth >= 820 ? 2 : 1;
            const gap = 16.0;
            final cw = (c.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(spacing: gap, runSpacing: gap, children: [
              for (final e in exams)
                SizedBox(
                  width: cw,
                  child: _ExamCard(
                    exam: e,
                    last: _lastFor(e),
                    attempts: _history.where((a) => a.examId == e.id).length,
                    locked: _active != null,
                    free: _free!.available,
                    balance: _balance,
                    onStart: () => MockLauncher.start(context, e),
                  ),
                ),
            ]);
          }),
        ]),
      ),
    );
  }
}

class _AccessBar extends StatelessWidget {
  const _AccessBar({required this.free, required this.balance});
  final FreeStatus free;
  final int balance;

  @override
  Widget build(BuildContext context) {
    final text = free.available
        ? 'Your free mock is open until ${Ist.label(free.open!.end)} — pick any exam below.'
        : 'Next free mock: ${Ist.label(free.next.start)}. Purchased mocks (${Wallet.mockPrice} coins) are available any time.';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: free.available ? GlobioColors.successSoft : Colors.white,
        borderRadius: BorderRadius.circular(GlobioTheme.radius),
        border: Border.all(color: free.available ? GlobioColors.success.withValues(alpha: 0.4) : GlobioColors.border),
      ),
      child: Row(children: [
        Icon(free.available ? Icons.card_giftcard_rounded : Icons.event_outlined,
            color: free.available ? GlobioColors.success : GlobioColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13.5, height: 1.45))),
        const SizedBox(width: 12),
        const CoinIcon(size: 18),
        const SizedBox(width: 6),
        Text('$balance', style: const TextStyle(fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _Running extends StatelessWidget {
  const _Running({required this.attempt, required this.onResume});
  final Attempt attempt;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final exam = examById(attempt.examId)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: GlobioColors.ctaGradient, borderRadius: BorderRadius.circular(GlobioTheme.radius + 4)),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text('Your ${exam.title} mock is still running',
                style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700)),
            Text('${attempt.answeredCount} of ${attempt.items.length} answered · ${formatClock(attempt.deadline.difference(DateTime.now()))} left',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
          ]),
          PillButton(label: 'Continue exam', icon: Icons.arrow_forward_rounded, onPressed: onResume),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({
    required this.exam,
    required this.last,
    required this.attempts,
    required this.locked,
    required this.free,
    required this.balance,
    required this.onStart,
  });
  final ExamInfo exam;
  final AttemptResult? last;
  final int attempts;
  final bool locked;
  final bool free;
  final int balance;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final style = last == null ? null : VerdictStyle.of(last!.verdict);
    final affordable = free || balance >= Wallet.mockPrice;
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: exam.provider == 'ÖSD' ? GlobioColors.accent : GlobioColors.primary,
              borderRadius: BorderRadius.circular(GlobioTheme.radius),
            ),
            child: Text(exam.level, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(exam.provider.toUpperCase(),
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: GlobioColors.primary)),
              Text(exam.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              if (exam.subtitle != exam.level)
                Text(exam.subtitle, style: const TextStyle(fontSize: 12.5, color: GlobioColors.mutedForeground)),
            ]),
          ),
          free
              ? const Chip2('FREE NOW', bg: GlobioColors.successSoft, fg: GlobioColors.success)
              : Container(
                  padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
                  decoration: BoxDecoration(color: GlobioColors.secondarySoft, borderRadius: BorderRadius.circular(999)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    CoinIcon(size: 18),
                    SizedBox(width: 6),
                    Text('${Wallet.mockPrice}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  ]),
                ),
        ]),
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 8, children: [
          Chip2('${exam.totalQuestions} questions', icon: Icons.quiz_outlined),
          Chip2('${exam.minutes} min', icon: Icons.timer_outlined),
          Chip2('Pass mark ${exam.passPct}%', icon: Icons.flag_outlined),
        ]),
        const SizedBox(height: 12),
        Text(exam.passRule, style: const TextStyle(fontSize: 13, color: GlobioColors.mutedForeground, height: 1.55)),
        const SizedBox(height: 14),
        if (last != null)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(color: style!.soft, borderRadius: BorderRadius.circular(GlobioTheme.radius - 4)),
            child: Row(children: [
              Icon(style.icon, size: 17, color: style.onSoft),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Last mock: ${last!.overallPct}% · ${last!.verdict.title}${attempts > 1 ? ' · $attempts attempts' : ''}',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: style.onSoft),
                ),
              ),
            ]),
          ),
        PillButton(
          label: locked
              ? 'Finish your running mock first'
              : (!affordable ? 'Need ${Wallet.mockPrice} coins' : (free ? 'Start free mock' : 'Start mock · ${Wallet.mockPrice} coins')),
          variant: PillVariant.primary,
          expand: true,
          onPressed: locked || !affordable ? null : onStart,
        ),
      ]),
    );
  }
}
