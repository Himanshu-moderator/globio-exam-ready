import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/attempt.dart';
import '../models/quiz.dart';
import '../services/readiness.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/app_header.dart';
import '../widgets/brand_widgets.dart';
import '../widgets/verdict_style.dart';
import 'exam_select_screen.dart';
import 'history_screen.dart';

/// Analysis dashboard for one finished attempt.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.exam, required this.attempt, this.justFinished = false});
  final ExamInfo exam;
  final Attempt attempt;

  /// True right after submitting: closing goes to the history list.
  final bool justFinished;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final AttemptResult r = Readiness.evaluate(widget.exam, widget.attempt);
  bool _mistakesOnly = true;

  void _close() {
    if (widget.justFinished) {
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const HistoryScreen()));
    } else {
      Navigator.of(context).pop();
    }
  }

  void _newMock() {
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const ExamSelectScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final mistakes = r.reviews.where((x) => !x.isCorrect).length;
    final shown = _mistakesOnly ? r.reviews.where((x) => !x.isCorrect).toList() : r.reviews;
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: GlobioColors.muted,
      body: Column(children: [
        AppHeader(
          onBack: _close,
          backIcon: Icons.close_rounded,
          title: 'Your analysis · ${widget.exam.title}',
          actions: [
            if (w >= 480)
              PillButton(
                label: 'All my results',
                variant: PillVariant.outlineLight,
                onPressed: _close,
              ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(children: [
              _Hero(r: r),
              PageBody(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SectionTitle('Skill breakdown',
                      subtitle: 'The marker on each bar is the real exam\'s pass mark (${widget.exam.passPct}%).'),
                  _ResponsiveGrid(children: [
                    for (final s in Skill.values) _SkillCard(score: r.skills[s]!, passPct: widget.exam.passPct),
                  ]),
                  const SizedBox(height: 40),
                  SectionTitle('Practise before you book',
                      subtitle: r.focusAreas.isEmpty
                          ? null
                          : 'Your ${r.focusAreas.length == 1 ? 'top focus area' : '${r.focusAreas.length} focus areas'}, based on where you lost the most points.'),
                  if (r.focusAreas.isEmpty)
                    const Panel(
                      child: Row(children: [
                        Icon(Icons.emoji_events_outlined, color: GlobioColors.success, size: 28),
                        SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'No mistakes in this mock. Keep your level up with timed practice papers, and train listening and speaking — they are not covered here.',
                            style: TextStyle(fontSize: 14.5, height: 1.55),
                          ),
                        ),
                      ]),
                    )
                  else
                    _ResponsiveGrid(children: [
                      for (var i = 0; i < r.focusAreas.length; i++) _FocusCard(n: i + 1, f: r.focusAreas[i]),
                    ]),
                  const SizedBox(height: 40),
                  const SectionTitle('Question by question',
                      subtitle: 'See what you answered, the correct answer, and why.'),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _FilterChip(
                      label: 'Mistakes ($mistakes)',
                      selected: _mistakesOnly,
                      onTap: () => setState(() => _mistakesOnly = true),
                    ),
                    _FilterChip(
                      label: 'All questions (${r.reviews.length})',
                      selected: !_mistakesOnly,
                      onTap: () => setState(() => _mistakesOnly = false),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  if (shown.isEmpty)
                    const Panel(child: Text('No mistakes to review — well done!', style: TextStyle(fontSize: 14.5)))
                  else
                    for (final rv in shown)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _ReviewCard(n: r.reviews.indexOf(rv) + 1, rv: rv),
                      ),
                  const SizedBox(height: 40),
                  SectionTitle('Tips for the ${widget.exam.title}'),
                  Panel(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _TipRow(icon: Icons.flag_outlined, text: 'How it is passed: ${widget.exam.passRule}', bold: true),
                      for (final t in widget.exam.tips) _TipRow(icon: Icons.lightbulb_outline_rounded, text: t),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Panel(
                    color: GlobioColors.secondarySoft,
                    borderColor: GlobioColors.secondary.withValues(alpha: 0.5),
                    child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.info_outline_rounded, color: GlobioColors.foreground),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This mock checks vocabulary, grammar and reading. The real exam also tests listening, '
                          'writing and speaking, so practise those separately before you book.',
                          style: TextStyle(fontSize: 14, height: 1.55),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 32),
                  Wrap(spacing: 12, runSpacing: 12, children: [
                    PillButton(label: 'Take a new mock', icon: Icons.refresh_rounded, large: true, onPressed: _newMock),
                    PillButton(label: 'See all my results', variant: PillVariant.outlineDark, large: true, onPressed: _close),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ───────────────────────────── Hero ─────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.r});
  final AttemptResult r;

  @override
  Widget build(BuildContext context) {
    final st = VerdictStyle.of(r.verdict);
    final a = r.attempt;
    final used = (a.submittedAt ?? a.deadline).difference(a.startedAt);
    final w = MediaQuery.sizeOf(context).width;
    final wide = w >= 820;

    final text = Column(
      crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text('${r.exam.fullName} · ${formatDateTime(a.submittedAt ?? a.startedAt)}',
            textAlign: wide ? TextAlign.start : TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(color: st.soft, borderRadius: BorderRadius.circular(999)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(st.icon, size: 18, color: st.onSoft),
            const SizedBox(width: 6),
            Text(r.verdict.title, style: TextStyle(color: st.onSoft, fontWeight: FontWeight.w700, fontSize: 14)),
          ]),
        ),
        const SizedBox(height: 14),
        Text(
          r.verdict == Verdict.ready
              ? 'You are exam-ready.'
              : (r.verdict == Verdict.almost ? 'You are close.' : 'Not yet — but you know what to fix.'),
          textAlign: wide ? TextAlign.start : TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: w < 600 ? 26 : 34, fontWeight: FontWeight.w700, height: 1.2),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(r.verdict.message,
              textAlign: wide ? TextAlign.start : TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15.5, height: 1.6)),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: wide ? WrapAlignment.start : WrapAlignment.center,
          children: [
            _HeroStat(label: 'Score', value: '${r.correct}/${r.total} · ${r.overallPct}%'),
            _HeroStat(label: 'Pass mark', value: '${r.exam.passPct}%'),
            _HeroStat(label: 'Time used', value: formatDuration(used)),
            if (a.autoSubmitted) const _HeroStat(label: 'Submitted', value: 'automatically'),
          ],
        ),
      ],
    );

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: GlobioColors.heroGradient),
      child: Stack(children: [
        const Positioned.fill(child: DotPattern(opacity: 0.08)),
        PageBody(
          child: wide
              ? Row(children: [
                  Expanded(child: text),
                  const SizedBox(width: 40),
                  _ReadinessRing(score: r.readinessScore, color: st.color),
                ])
              : Column(children: [
                  _ReadinessRing(score: r.readinessScore, color: st.color),
                  const SizedBox(height: 24),
                  text,
                ]),
        ),
      ]),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: RichText(
          text: TextSpan(style: const TextStyle(fontFamily: GlobioTheme.fontFamily, fontSize: 13), children: [
            TextSpan(text: '$label  ', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
            TextSpan(text: value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}

class _ReadinessRing extends StatelessWidget {
  const _ReadinessRing({required this.score, required this.color});
  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: score / 100),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (_, v, __) => SizedBox(
          width: 190,
          height: 190,
          child: CustomPaint(
            painter: _RingPainter(v, color),
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${(v * 100).round()}%',
                    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800)),
                Text('READINESS',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
      );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.v, this.color);
  final double v;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 10;
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..color = Colors.white.withValues(alpha: 0.15);
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawCircle(c, r, bg);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2, 2 * math.pi * v, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.v != v || old.color != color;
}

// ───────────────────────────── Sections ─────────────────────────────

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final cols = c.maxWidth >= 900 ? 3 : (c.maxWidth >= 600 ? 2 : 1);
        const gap = 16.0;
        final width = (c.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(spacing: gap, runSpacing: gap, children: [
          for (final ch in children) SizedBox(width: width, child: ch),
        ]);
      });
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({required this.score, required this.passPct});
  final SkillScore score;
  final int passPct;

  @override
  Widget build(BuildContext context) {
    final status = Readiness.skillStatus(score.pct, passPct);
    final color = VerdictStyle.statusColor(status);
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(score.skill.label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              Text(score.skill.german, style: const TextStyle(fontSize: 12.5, color: GlobioColors.mutedForeground)),
            ]),
          ),
          Chip2(status.label, bg: VerdictStyle.statusSoft(status), fg: color),
        ]),
        const SizedBox(height: 16),
        Text('${score.pct}%', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: color)),
        Text('${score.correct} of ${score.total} correct',
            style: const TextStyle(fontSize: 13, color: GlobioColors.mutedForeground)),
        const SizedBox(height: 14),
        LayoutBuilder(builder: (context, c) {
          return SizedBox(
            height: 14,
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned.fill(
                top: 3,
                bottom: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: score.pct / 100),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v,
                      backgroundColor: GlobioColors.muted,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ),
              ),
              // Pass-mark marker.
              Positioned(
                left: (c.maxWidth * passPct / 100) - 1,
                top: 0,
                bottom: 0,
                child: Container(width: 2, color: GlobioColors.foreground.withValues(alpha: 0.6)),
              ),
            ]),
          );
        }),
      ]),
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({required this.n, required this.f});
  final int n;
  final FocusArea f;

  @override
  Widget build(BuildContext context) => Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: GlobioColors.secondary, shape: BoxShape.circle),
              child: Text('$n', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(f.guide.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 6, children: [
            Chip2(f.skill.label, bg: GlobioColors.primary.withValues(alpha: 0.08), fg: GlobioColors.primary),
            Chip2('${f.misses} mistake${f.misses == 1 ? '' : 's'}',
                bg: GlobioColors.destructiveSoft, fg: GlobioColors.destructive),
          ]),
          const SizedBox(height: 16),
          const _Label('Quick fix'),
          Text(f.guide.fix, style: const TextStyle(fontSize: 14, height: 1.55)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GlobioColors.muted,
              borderRadius: BorderRadius.circular(GlobioTheme.radius - 4),
            ),
            child: Text(f.guide.example,
                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, height: 1.5, color: GlobioColors.brand)),
          ),
          const SizedBox(height: 12),
          const _Label('How to practise'),
          Text(f.guide.practise, style: const TextStyle(fontSize: 14, height: 1.55, color: GlobioColors.mutedForeground)),
        ]),
      );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text.toUpperCase(),
            style: const TextStyle(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700, color: GlobioColors.primary)),
      );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? GlobioColors.brand : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: selected ? GlobioColors.brand : GlobioColors.border),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : GlobioColors.foreground)),
          ),
        ),
      );
}

class _ReviewCard extends StatefulWidget {
  const _ReviewCard({required this.n, required this.rv});
  final int n;
  final QuestionReview rv;

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _showText = false;

  @override
  Widget build(BuildContext context) {
    final rv = widget.rv;
    final q = rv.question;
    final statusColor = rv.isCorrect ? GlobioColors.success : GlobioColors.destructive;
    return Panel(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Icon(rv.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded, color: statusColor, size: 22),
          Text('Question ${widget.n}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          Chip2(q.skill.label),
          if (rv.unanswered) Chip2('Not answered', bg: GlobioColors.destructiveSoft, fg: GlobioColors.destructive),
        ]),
        if (q.passage != null) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _showText = !_showText),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_showText ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    size: 18, color: GlobioColors.primary),
                Text(_showText ? 'Hide the text' : 'Show the text (${q.passageLabel ?? 'Text'})',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlobioColors.primary)),
              ]),
            ),
          ),
          if (_showText)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: GlobioColors.muted,
                borderRadius: BorderRadius.circular(GlobioTheme.radius - 4),
              ),
              child: Text(q.passage!, style: const TextStyle(fontSize: 14, height: 1.55)),
            ),
        ],
        const SizedBox(height: 12),
        Text(q.prompt, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.45)),
        const SizedBox(height: 12),
        for (final i in rv.order)
          _ReviewOption(
            text: q.options[i],
            isCorrect: i == q.answer,
            isChosenWrong: rv.chosen == i && i != q.answer,
          ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: GlobioColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(GlobioTheme.radius - 4),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.lightbulb_outline_rounded, size: 18, color: GlobioColors.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(q.explanation, style: const TextStyle(fontSize: 13.5, height: 1.55))),
          ]),
        ),
      ]),
    );
  }
}

class _ReviewOption extends StatelessWidget {
  const _ReviewOption({required this.text, required this.isCorrect, required this.isChosenWrong});
  final String text;
  final bool isCorrect;
  final bool isChosenWrong;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect
        ? GlobioColors.success
        : (isChosenWrong ? GlobioColors.destructive : GlobioColors.mutedForeground);
    final bg = isCorrect
        ? GlobioColors.successSoft
        : (isChosenWrong ? GlobioColors.destructiveSoft : Colors.transparent);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(GlobioTheme.radius - 4)),
      child: Row(children: [
        Icon(
          isCorrect ? Icons.check_rounded : (isChosenWrong ? Icons.close_rounded : Icons.circle_outlined),
          size: isCorrect || isChosenWrong ? 18 : 12,
          color: color,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  fontSize: 14,
                  color: isCorrect || isChosenWrong ? GlobioColors.foreground : GlobioColors.mutedForeground,
                  fontWeight: isCorrect ? FontWeight.w600 : FontWeight.w400)),
        ),
        if (isCorrect) Text('Correct', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        if (isChosenWrong) Text('Your answer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.icon, required this.text, this.bold = false});
  final IconData icon;
  final String text;
  final bool bold;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 19, color: GlobioColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 14, height: 1.55, fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
          ),
        ]),
      );
}
