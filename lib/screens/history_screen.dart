import 'package:flutter/material.dart';

import '../data/exams.dart';
import '../models/quiz.dart';
import '../services/attempt_store.dart';
import '../services/auth_service.dart';
import '../services/readiness.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/app_header.dart';
import '../widgets/brand_widgets.dart';
import '../widgets/verdict_style.dart';
import 'exam_select_screen.dart';
import 'result_screen.dart';

/// All finished mocks for the signed-in learner, newest first.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _loading = true;
  List<AttemptResult> _results = [];
  String? _filter; // exam id, null = all

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final email = AuthService.instance.currentUser?.email;
    if (email == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    final store = AttemptStore.instance;
    await store.finalizeIfExpired(email);
    final list = await store.history(email);
    final results = <AttemptResult>[];
    for (final a in list) {
      final exam = examById(a.examId);
      if (exam != null) results.add(Readiness.evaluate(exam, a));
    }
    if (!mounted) return;
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  void _open(AttemptResult r) => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => ResultScreen(exam: r.exam, attempt: r.attempt),
      ));

  void _newMock() => Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const ExamSelectScreen()),
      );

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final taken = exams.where((e) => _results.any((r) => r.exam.id == e.id)).toList();
    final shown = _filter == null ? _results : _results.where((r) => r.exam.id == _filter).toList();

    return Scaffold(
      backgroundColor: GlobioColors.muted,
      body: Column(children: [
        AppHeader(
          onBack: () => Navigator.of(context).pop(),
          title: 'My results',
          actions: [
            PillButton(label: 'New mock', variant: PillVariant.gold, onPressed: _newMock),
          ],
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: GlobioColors.primary))
              : SingleChildScrollView(
                  child: PageBody(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Eyebrow('Your history'),
                      const SizedBox(height: 10),
                      Text('My results', style: TextStyle(fontSize: w < 600 ? 26 : 32, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      const Text(
                        'Every submitted mock is saved here and cannot be changed. Open any one to see its full analysis.',
                        style: TextStyle(fontSize: 15, color: GlobioColors.mutedForeground, height: 1.6),
                      ),
                      const SizedBox(height: 28),
                      if (_results.isEmpty)
                        Panel(
                          padding: const EdgeInsets.all(36),
                          child: Column(children: [
                            const Icon(Icons.assignment_outlined, size: 44, color: GlobioColors.primary),
                            const SizedBox(height: 14),
                            const Text('No results yet', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            const Text('Take your first mock to see how ready you are.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: GlobioColors.mutedForeground)),
                            const SizedBox(height: 20),
                            PillButton(label: 'Choose a mock exam', icon: Icons.arrow_forward_rounded, onPressed: _newMock),
                          ]),
                        )
                      else ...[
                        const SectionTitle('Progress by exam'),
                        LayoutBuilder(builder: (context, c) {
                          final cols = c.maxWidth >= 900 ? 3 : (c.maxWidth >= 600 ? 2 : 1);
                          const gap = 16.0;
                          final cw = (c.maxWidth - gap * (cols - 1)) / cols;
                          return Wrap(spacing: gap, runSpacing: gap, children: [
                            for (final e in taken)
                              SizedBox(
                                width: cw,
                                child: _ExamSummary(
                                  exam: e,
                                  results: _results.where((r) => r.exam.id == e.id).toList(),
                                ),
                              ),
                          ]);
                        }),
                        const SizedBox(height: 36),
                        const SectionTitle('All attempts'),
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          _Filter(label: 'All (${_results.length})', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                          for (final e in taken)
                            _Filter(
                              label: '${e.title} (${_results.where((r) => r.exam.id == e.id).length})',
                              selected: _filter == e.id,
                              onTap: () => setState(() => _filter = e.id),
                            ),
                        ]),
                        const SizedBox(height: 16),
                        for (final r in shown)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _AttemptTile(r: r, onTap: () => _open(r)),
                          ),
                      ],
                    ]),
                  ),
                ),
        ),
      ]),
    );
  }
}

class _ExamSummary extends StatelessWidget {
  const _ExamSummary({required this.exam, required this.results});
  final ExamInfo exam;

  /// Newest first.
  final List<AttemptResult> results;

  @override
  Widget build(BuildContext context) {
    final latest = results.first;
    final best = results.map((r) => r.overallPct).reduce((a, b) => a > b ? a : b);
    final st = VerdictStyle.of(latest.verdict);
    final series = results.reversed.map((r) => r.overallPct).toList();
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(exam.provider.toUpperCase(),
            style: const TextStyle(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700, color: GlobioColors.primary)),
        Text(exam.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(children: [
          _Stat(label: 'Latest', value: '${latest.overallPct}%'),
          _Stat(label: 'Best', value: '$best%'),
          _Stat(label: 'Attempts', value: '${results.length}'),
        ]),
        const SizedBox(height: 14),
        SizedBox(
          height: 56,
          width: double.infinity,
          child: CustomPaint(painter: _Sparkline(series, exam.passPct)),
        ),
        const SizedBox(height: 4),
        Text('Score per attempt · line = ${exam.passPct}% pass mark',
            style: const TextStyle(fontSize: 11.5, color: GlobioColors.mutedForeground)),
        const SizedBox(height: 12),
        Chip2(latest.verdict.title, bg: st.soft, fg: st.onSoft, icon: st.icon),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(fontSize: 12, color: GlobioColors.mutedForeground)),
        ]),
      );
}

class _Sparkline extends CustomPainter {
  _Sparkline(this.values, this.passPct);
  final List<int> values;
  final int passPct;

  @override
  void paint(Canvas canvas, Size size) {
    double y(num v) => size.height - (v / 100) * size.height;
    // Pass line (dashed).
    final dash = Paint()
      ..color = GlobioColors.mutedForeground.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, y(passPct)), Offset(x + 4, y(passPct)), dash);
    }
    if (values.isEmpty) return;
    final dx = values.length == 1 ? 0.0 : size.width / (values.length - 1);
    final pts = [
      for (var i = 0; i < values.length; i++)
        Offset(values.length == 1 ? size.width / 2 : i * dx, y(values[i])),
    ];
    if (pts.length > 1) {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final p in pts.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = GlobioColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round,
      );
    }
    for (var i = 0; i < pts.length; i++) {
      canvas.drawCircle(pts[i], 4, Paint()..color = Colors.white);
      canvas.drawCircle(
        pts[i],
        4,
        Paint()
          ..color = values[i] >= passPct ? GlobioColors.success : GlobioColors.destructive
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _Sparkline old) => old.values != values || old.passPct != passPct;
}

class _Filter extends StatelessWidget {
  const _Filter({required this.label, required this.selected, required this.onTap});
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? GlobioColors.brand : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: selected ? GlobioColors.brand : GlobioColors.border),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : GlobioColors.foreground)),
          ),
        ),
      );
}

class _AttemptTile extends StatefulWidget {
  const _AttemptTile({required this.r, required this.onTap});
  final AttemptResult r;
  final VoidCallback onTap;

  @override
  State<_AttemptTile> createState() => _AttemptTileState();
}

class _AttemptTileState extends State<_AttemptTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    final st = VerdictStyle.of(r.verdict);
    final a = r.attempt;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(GlobioTheme.radius + 4),
            border: Border.all(color: _hover ? GlobioColors.primary : GlobioColors.border),
          ),
          child: Row(children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: st.soft, borderRadius: BorderRadius.circular(GlobioTheme.radius)),
              child: Text('${r.overallPct}%',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: st.onSoft)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.exam.fullName, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${formatDateTime(a.submittedAt!)} · ${r.correct}/${r.total} correct',
                    style: const TextStyle(fontSize: 13, color: GlobioColors.mutedForeground)),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  Chip2(r.verdict.title, bg: st.soft, fg: st.onSoft, icon: st.icon),
                  for (final s in Skill.values)
                    Chip2('${s.label} ${r.skills[s]!.pct}%'),
                  if (a.autoSubmitted) const Chip2('Auto-submitted', icon: Icons.timer_off_outlined),
                ]),
              ]),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: GlobioColors.mutedForeground),
          ]),
        ),
      ),
    );
  }
}
