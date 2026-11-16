import 'package:flutter/material.dart';

import '../data/exams.dart';
import '../models/attempt.dart';
import '../models/quiz.dart';
import '../services/attempt_store.dart';
import '../services/auth_service.dart';
import '../services/quiz_engine.dart';
import '../services/readiness.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/app_header.dart';
import '../widgets/brand_widgets.dart';
import '../widgets/verdict_style.dart';
import 'exam_screen.dart';
import 'history_screen.dart';
import 'result_screen.dart';

class ExamSelectScreen extends StatefulWidget {
  const ExamSelectScreen({super.key});

  @override
  State<ExamSelectScreen> createState() => _ExamSelectScreenState();
}

class _ExamSelectScreenState extends State<ExamSelectScreen> {
  final _store = AttemptStore.instance;
  bool _loading = true;
  Attempt? _active;
  List<Attempt> _history = [];

  String? get _email => AuthService.instance.currentUser?.email;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final email = _email;
    if (email == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    final expired = await _store.finalizeIfExpired(email);
    var active = await _store.active(email);
    if (active != null && examById(active.examId) == null) {
      await _store.clearActive(email); // unknown exam (stale/tampered data)
      active = null;
    }
    final history = await _store.history(email);
    if (!mounted) return;
    setState(() {
      _active = active;
      _history = history;
      _loading = false;
    });
    if (expired != null) {
      final exam = examById(expired.examId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Time ran out on your ${exam?.title ?? ''} mock, so it was submitted.'),
        action: exam == null
            ? null
            : SnackBarAction(
                label: 'View result',
                textColor: GlobioColors.secondary,
                onPressed: () => _openResult(expired),
              ),
      ));
    }
  }

  void _openResult(Attempt a) {
    final exam = examById(a.examId);
    if (exam == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ResultScreen(exam: exam, attempt: a),
    ));
  }

  Future<void> _resume() async {
    final a = _active;
    final email = _email;
    if (a == null || email == null) return;
    final exam = examById(a.examId);
    if (exam == null) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ExamScreen(exam: exam, attempt: a, email: email),
    ));
    if (mounted) _load();
  }

  Future<void> _start(ExamInfo exam) async {
    final email = _email;
    if (email == null || _active != null) return;
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => _RulesDialog(exam: exam),
    );
    if (go != true || !mounted) return;
    final attempt = QuizEngine.create(exam, history: _history);
    final saved = await _store.saveActive(email, attempt);
    if (!mounted) return;
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AuthService.storageUnavailable)),
      );
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ExamScreen(exam: exam, attempt: attempt, email: email),
    ));
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: GlobioColors.muted,
      body: Column(children: [
        AppHeader(
          onBack: () => Navigator.of(context).pop(),
          title: 'Mock exams',
          actions: [
            PillButton(
              label: 'My results',
              variant: PillVariant.outlineLight,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
              ).then((_) => _load()),
            ),
          ],
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: GlobioColors.primary))
              : SingleChildScrollView(
                  child: PageBody(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Eyebrow('Am I exam-ready?'),
                        const SizedBox(height: 10),
                        Text('Choose your mock exam',
                            style: TextStyle(fontSize: w < 600 ? 26 : 32, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        const Text(
                          'Each mock draws 15 questions from that exam\'s own bank, at that exam\'s level. '
                          'Every attempt gets a different mix, in a different order.',
                          style: TextStyle(fontSize: 15, color: GlobioColors.mutedForeground, height: 1.6),
                        ),
                        const SizedBox(height: 28),
                        if (_active != null) ...[
                          _ResumeBanner(attempt: _active!, onResume: _resume),
                          const SizedBox(height: 24),
                        ],
                        LayoutBuilder(builder: (context, c) {
                          final cols = c.maxWidth >= 860 ? 2 : 1;
                          const gap = 20.0;
                          final cardW = (c.maxWidth - gap * (cols - 1)) / cols;
                          return Wrap(
                            spacing: gap,
                            runSpacing: gap,
                            children: [
                              for (final e in exams)
                                SizedBox(
                                  width: cardW,
                                  child: _ExamCard(
                                    exam: e,
                                    last: _lastFor(e),
                                    attempts: _history.where((a) => a.examId == e.id).length,
                                    locked: _active != null,
                                    onStart: () => _start(e),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
        ),
      ]),
    );
  }

  AttemptResult? _lastFor(ExamInfo e) {
    for (final a in _history) {
      if (a.examId == e.id) return Readiness.evaluate(e, a);
    }
    return null;
  }
}

class _ResumeBanner extends StatelessWidget {
  const _ResumeBanner({required this.attempt, required this.onResume});
  final Attempt attempt;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final exam = examById(attempt.examId)!;
    final left = attempt.deadline.difference(DateTime.now());
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: GlobioColors.ctaGradient,
        borderRadius: BorderRadius.circular(GlobioTheme.radius + 4),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.timer_outlined, color: GlobioColors.secondary),
            const SizedBox(width: 12),
            Flexible(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Your ${exam.title} mock is still running',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                Text('${attempt.answeredCount} of ${attempt.items.length} answered · ${formatClock(left)} left',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
              ]),
            ),
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
    required this.onStart,
  });
  final ExamInfo exam;
  final AttemptResult? last;
  final int attempts;
  final bool locked;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final style = last == null ? null : VerdictStyle.of(last!.verdict);
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: exam.provider == 'ÖSD' ? GlobioColors.accent : GlobioColors.primary,
              borderRadius: BorderRadius.circular(GlobioTheme.radius),
            ),
            child: Text(exam.level,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(exam.provider.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: GlobioColors.primary)),
              Text(exam.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
              if (exam.subtitle != exam.level)
                Text(exam.subtitle, style: const TextStyle(fontSize: 13, color: GlobioColors.mutedForeground)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [
          Chip2('${exam.totalQuestions} questions', icon: Icons.quiz_outlined),
          Chip2('${exam.minutes} min', icon: Icons.timer_outlined),
          Chip2('Pass mark ${exam.passPct}%', icon: Icons.flag_outlined),
        ]),
        const SizedBox(height: 14),
        Text(exam.passRule,
            style: const TextStyle(fontSize: 13, color: GlobioColors.mutedForeground, height: 1.55)),
        const SizedBox(height: 16),
        if (last != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: style!.soft,
              borderRadius: BorderRadius.circular(GlobioTheme.radius - 4),
            ),
            child: Row(children: [
              Icon(style.icon, size: 18, color: style.onSoft),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Last mock: ${last!.overallPct}% · ${last!.verdict.title}'
                  '${attempts > 1 ? ' · $attempts attempts' : ''}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: style.onSoft),
                ),
              ),
            ]),
          ),
        PillButton(
          label: locked ? 'Finish your running mock first' : (last == null ? 'Start mock' : 'Start a new mock'),
          variant: PillVariant.primary,
          expand: true,
          onPressed: locked ? null : onStart,
        ),
      ]),
    );
  }
}

class _RulesDialog extends StatelessWidget {
  const _RulesDialog({required this.exam});
  final ExamInfo exam;

  @override
  Widget build(BuildContext context) {
    final rules = [
      (Icons.quiz_outlined, '${exam.totalQuestions} questions: ${exam.perSkill} vocabulary, ${exam.perSkill} grammar, ${exam.perSkill} reading — in mixed order.'),
      (Icons.timer_outlined, 'You have ${exam.minutes} minutes. When time is up, your answers are submitted automatically.'),
      (Icons.swap_horiz_rounded, 'You can move between questions and change answers until you submit.'),
      (Icons.lock_outline_rounded, 'Once submitted, the result is final and saved to your history. Leaving the exam also submits it.'),
    ];
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Eyebrow('Before you start'),
            const SizedBox(height: 8),
            Text(exam.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            for (final (icon, text) in rules)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(icon, size: 20, color: GlobioColors.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text(text, style: const TextStyle(fontSize: 14, height: 1.5))),
                ]),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: Wrap(alignment: WrapAlignment.end, spacing: 10, runSpacing: 10, children: [
                PillButton(
                  label: 'Not now',
                  variant: PillVariant.outlineDark,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                PillButton(
                  label: 'Start exam',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
