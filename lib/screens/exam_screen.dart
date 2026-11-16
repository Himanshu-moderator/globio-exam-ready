import 'dart:async';

import 'package:flutter/material.dart';

import '../data/exams.dart';
import '../models/attempt.dart';
import '../models/quiz.dart';
import '../services/attempt_store.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/app_header.dart';
import '../widgets/brand_widgets.dart';
import 'result_screen.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key, required this.exam, required this.attempt, required this.email});
  final ExamInfo exam;
  final Attempt attempt;
  final String email;

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final _store = AttemptStore.instance;
  late final List<Question?> _questions =
      widget.attempt.items.map((i) => questionById(widget.exam, i.questionId)).toList();
  int _index = 0;
  Timer? _timer;
  Duration _left = Duration.zero;
  bool _submitting = false;

  Attempt get _a => widget.attempt;

  @override
  void initState() {
    super.initState();
    // Start on the first unanswered question when resuming.
    final firstOpen = _a.items.indexWhere((i) => i.chosen == null);
    _index = firstOpen < 0 ? 0 : firstOpen;
    _left = _a.deadline.difference(DateTime.now());
    if (_left <= Duration.zero) {
      // Resumed after the deadline: submit once the first frame is up.
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => _submit(auto: true, reason: 'Time is up — your answers were submitted.'));
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    final left = _a.deadline.difference(DateTime.now());
    if (left <= Duration.zero) {
      _submit(auto: true, reason: 'Time is up — your answers were submitted.');
      return;
    }
    if (mounted) setState(() => _left = left);
  }

  void _choose(int originalIndex) {
    if (_submitting) return;
    setState(() => _a.items[_index].chosen = originalIndex);
    _store.saveActive(widget.email, _a);
  }

  void _go(int i) {
    if (i < 0 || i >= _a.items.length) return;
    setState(() => _index = i);
  }

  Future<void> _submit({required bool auto, String? reason}) async {
    if (_submitting) return;
    _submitting = true;
    _timer?.cancel();
    final ok = await _store.submit(widget.email, _a, auto: auto);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => ResultScreen(exam: widget.exam, attempt: _a, justFinished: true),
    ));
    if (!ok) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Your result could not be saved because browser storage is blocked.'),
      ));
    } else if (reason != null) {
      messenger.showSnackBar(SnackBar(content: Text(reason)));
    }
  }

  Future<void> _confirmSubmit() async {
    final open = _a.items.length - _a.answeredCount;
    final go = await _confirm(
      title: 'Submit your exam?',
      body: open == 0
          ? 'You have answered all ${_a.items.length} questions. After submitting, your result is final.'
          : 'You have $open unanswered question${open == 1 ? '' : 's'}. Unanswered questions count as wrong. '
              'After submitting, your result is final.',
      confirm: 'Submit exam',
      cancel: open == 0 ? 'Check again' : 'Keep answering',
    );
    if (go == true) _submit(auto: false);
  }

  Future<void> _confirmLeave() async {
    if (_submitting) return;
    final go = await _confirm(
      title: 'Leave the exam?',
      body: 'Leaving submits your exam now with the answers you have given. '
          'Unanswered questions count as wrong and the result is final.',
      confirm: 'Submit and leave',
      cancel: 'Keep going',
    );
    if (go == true) _submit(auto: true, reason: 'You left the exam, so it was submitted.');
  }

  Future<bool?> _confirm({
    required String title,
    required String body,
    required String confirm,
    required String cancel,
  }) =>
      showDialog<bool>(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Text(body, style: const TextStyle(fontSize: 14.5, height: 1.55, color: GlobioColors.mutedForeground)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(alignment: WrapAlignment.end, spacing: 10, runSpacing: 10, children: [
                    PillButton(label: cancel, variant: PillVariant.outlineDark, onPressed: () => Navigator.of(ctx).pop(false)),
                    PillButton(label: confirm, variant: PillVariant.primary, onPressed: () => Navigator.of(ctx).pop(true)),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final q = _questions[_index];
    final item = _a.items[_index];
    final last = _index == _a.items.length - 1;
    final w = MediaQuery.sizeOf(context).width;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        backgroundColor: GlobioColors.muted,
        body: Column(children: [
          AppHeader(
            onBack: _confirmLeave,
            backIcon: Icons.close_rounded,
            title: widget.exam.fullName,
            actions: [_TimerPill(left: _left)],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: PageBody(
                maxWidth: 860,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Progress
                  Row(children: [
                    Expanded(
                      child: Wrap(spacing: 10, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                        Text('Question ${_index + 1} of ${_a.items.length}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        if (q != null)
                          Chip2(q.skill.label, bg: GlobioColors.primary.withValues(alpha: 0.08), fg: GlobioColors.primary),
                      ]),
                    ),
                    Text('${_a.answeredCount}/${_a.items.length} answered',
                        style: const TextStyle(fontSize: 13, color: GlobioColors.mutedForeground)),
                  ]),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: _a.answeredCount / _a.items.length,
                      minHeight: 6,
                      backgroundColor: GlobioColors.border,
                      valueColor: const AlwaysStoppedAnimation(GlobioColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Navigator(items: _a.items, current: _index, onTap: _go),
                  const SizedBox(height: 20),
                  Panel(
                    padding: EdgeInsets.all(w < 600 ? 20 : 28),
                    child: q == null
                        ? const Text('This question is no longer available. Please move to the next one.')
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: Column(
                              key: ValueKey(_index),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (q.passage != null) ...[
                                  _Passage(label: q.passageLabel, text: q.passage!),
                                  const SizedBox(height: 20),
                                ],
                                Text(q.prompt,
                                    style: TextStyle(fontSize: w < 600 ? 18 : 20, fontWeight: FontWeight.w700, height: 1.4)),
                                if (!q.shuffleOptions)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Text('Richtig oder falsch?',
                                        style: TextStyle(fontSize: 13, color: GlobioColors.mutedForeground)),
                                  ),
                                const SizedBox(height: 20),
                                for (var k = 0; k < item.order.length; k++)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _OptionTile(
                                      letter: String.fromCharCode(65 + k),
                                      text: q.options[item.order[k]],
                                      selected: item.chosen == item.order[k],
                                      onTap: () => _choose(item.order[k]),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    if (_index > 0)
                      PillButton(
                        label: 'Previous',
                        variant: PillVariant.outlineDark,
                        onPressed: () => _go(_index - 1),
                      ),
                    const Spacer(),
                    if (!last)
                      PillButton(
                        label: 'Next',
                        icon: Icons.arrow_forward_rounded,
                        variant: PillVariant.primary,
                        onPressed: () => _go(_index + 1),
                      )
                    else
                      PillButton(label: 'Submit exam', icon: Icons.check_rounded, onPressed: _confirmSubmit),
                  ]),
                  if (!last) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: _confirmSubmit,
                        child: const Text('Finish and submit now',
                            style: TextStyle(color: GlobioColors.mutedForeground, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _TimerPill extends StatelessWidget {
  const _TimerPill({required this.left});
  final Duration left;

  @override
  Widget build(BuildContext context) {
    final urgent = left.inSeconds <= 60;
    final warn = left.inSeconds <= 120;
    final bg = urgent ? GlobioColors.destructive : (warn ? GlobioColors.secondary : Colors.white.withValues(alpha: 0.12));
    final fg = warn && !urgent ? GlobioColors.foreground : Colors.white;
    return Semantics(
      label: 'Time left ${formatClock(left)}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.timer_outlined, size: 18, color: fg),
          const SizedBox(width: 6),
          Text(formatClock(left),
              style: TextStyle(
                  color: fg, fontSize: 15, fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()])),
        ]),
      ),
    );
  }
}

class _Navigator extends StatelessWidget {
  const _Navigator({required this.items, required this.current, required this.onTap});
  final List<AttemptItem> items;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < items.length; i++)
            Semantics(
              button: true,
              label: 'Question ${i + 1}${items[i].chosen != null ? ', answered' : ''}',
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: items[i].chosen != null ? GlobioColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: i == current ? GlobioColors.secondary : GlobioColors.border,
                        width: i == current ? 2.5 : 1,
                      ),
                    ),
                    child: Text('${i + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: items[i].chosen != null ? Colors.white : GlobioColors.foreground,
                        )),
                  ),
                ),
              ),
            ),
        ],
      );
}

class _Passage extends StatelessWidget {
  const _Passage({required this.label, required this.text});
  final String? label;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: GlobioColors.muted,
          borderRadius: BorderRadius.circular(GlobioTheme.radius),
          border: const Border(left: BorderSide(color: GlobioColors.primary, width: 4)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (label != null) ...[
            Text(label!.toUpperCase(),
                style: const TextStyle(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700, color: GlobioColors.primary)),
            const SizedBox(height: 8),
          ],
          Text(text, style: const TextStyle(fontSize: 15.5, height: 1.6)),
        ]),
      );
}

class _OptionTile extends StatefulWidget {
  const _OptionTile({required this.letter, required this.text, required this.selected, required this.onTap});
  final String letter;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    return Semantics(
      selected: sel,
      button: true,
      label: widget.text,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: sel ? GlobioColors.primary.withValues(alpha: 0.07) : (_hover ? GlobioColors.muted : Colors.white),
              borderRadius: BorderRadius.circular(GlobioTheme.radius),
              border: Border.all(color: sel ? GlobioColors.primary : GlobioColors.border, width: sel ? 2 : 1),
            ),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? GlobioColors.primary : GlobioColors.muted,
                  shape: BoxShape.circle,
                ),
                child: Text(widget.letter,
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: sel ? Colors.white : GlobioColors.mutedForeground)),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(widget.text, style: const TextStyle(fontSize: 15.5, height: 1.4))),
            ]),
          ),
        ),
      ),
    );
  }
}
