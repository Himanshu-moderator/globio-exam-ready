import 'package:flutter/material.dart';

import '../../data/exams.dart';
import '../../models/attempt.dart';
import '../../models/quiz.dart';
import '../../services/attempt_store.dart';
import '../../services/auth_service.dart';
import '../../services/local_store.dart';
import '../../services/profile_service.dart';
import '../../services/readiness.dart';
import '../../services/real_result_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_header.dart';
import '../../widgets/brand_widgets.dart';
import '../../widgets/verdict_style.dart';
import '../app_shell.dart';
import '../result_screen.dart';

class ResultsTab extends StatefulWidget {
  const ResultsTab({super.key});

  @override
  State<ResultsTab> createState() => _ResultsTabState();
}

class _ResultsTabState extends State<ResultsTab> {
  bool _loading = true;
  List<AttemptResult> _results = [];
  List<RealResult> _real = [];
  String? _filter;
  String _targetExam = '';

  String get _email => AuthService.instance.currentUser!.email;

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
    final list = await store.history(email);
    final real = await RealResultService.all(email);
    final profile = await ProfileService.ensure(email);
    final results = <AttemptResult>[];
    for (final a in list) {
      final exam = examById(a.examId);
      if (exam != null) results.add(Readiness.evaluate(exam, a));
    }
    if (!mounted) return;
    setState(() {
      _results = results;
      _real = real;
      _targetExam = profile.targetExam;
      _loading = false;
    });
  }

  AttemptResult? _byAttemptId(String? id) {
    if (id == null) return null;
    for (final r in _results) {
      if (r.attempt.id == id) return r;
    }
    return null;
  }

  Future<void> _report() async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _ReportDialog(
        email: _email,
        attempts: _results.map((r) => r.attempt).toList(),
        defaultExam: examById(_targetExam)?.id ?? (_results.firstOrNull?.exam.id ?? exams.first.id),
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks! Your real result is saved.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: GlobioColors.primary));
    final w = MediaQuery.sizeOf(context).width;
    final taken = exams.where((e) => _results.any((r) => r.exam.id == e.id)).toList();
    final shown = _filter == null ? _results : _results.where((r) => r.exam.id == _filter).toList();

    return SingleChildScrollView(
      child: PageBody(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('My results', style: TextStyle(fontSize: w < 600 ? 24 : 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Every submitted mock is saved here and cannot be changed. Open any one for its full analysis.',
              style: TextStyle(fontSize: 14.5, color: GlobioColors.mutedForeground, height: 1.55)),
          const SizedBox(height: 24),
          if (_results.isEmpty)
            Panel(
              padding: const EdgeInsets.all(32),
              child: Column(children: [
                const Icon(Icons.insights_outlined, size: 44, color: GlobioColors.primary),
                const SizedBox(height: 12),
                const Text('No results yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text('Take your first mock to see how ready you are.',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: GlobioColors.mutedForeground)),
                const SizedBox(height: 18),
                PillButton(
                  label: 'Choose a mock',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => ShellScope.of(context).goTo(ShellTab.mocks),
                ),
              ]),
            )
          else ...[
            const SectionTitle('Progress by exam'),
            LayoutBuilder(builder: (context, c) {
              final cols = c.maxWidth >= 900 ? 3 : (c.maxWidth >= 560 ? 2 : 1);
              const gap = 16.0;
              final cw = (c.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(spacing: gap, runSpacing: gap, children: [
                for (final e in taken)
                  SizedBox(width: cw, child: _ExamSummary(exam: e, results: _results.where((r) => r.exam.id == e.id).toList())),
              ]);
            }),
          ],
          const SizedBox(height: 32),
          // Real exam results
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Expanded(
              child: SectionTitle('Real exam results',
                  subtitle: 'Took the real Goethe or ÖSD exam? Add your result — it is linked to your latest mock, '
                      'so you can see whether the prediction was right.'),
            ),
            const SizedBox(width: 12),
            PillButton(label: 'Add result', icon: Icons.add_rounded, variant: PillVariant.outlineDark, onPressed: _report),
          ]),
          if (_real.isEmpty)
            const Panel(
              child: Text('No real exam results yet.', style: TextStyle(fontSize: 14, color: GlobioColors.mutedForeground)),
            )
          else
            for (final r in _real)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RealTile(
                  real: r,
                  predicted: _byAttemptId(r.linkedAttemptId),
                  onDelete: () => RealResultService.remove(_email, r.id),
                ),
              ),
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 32),
            const SectionTitle('All mock attempts'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _Filter(label: 'All (${_results.length})', selected: _filter == null, onTap: () => setState(() => _filter = null)),
              for (final e in taken)
                _Filter(
                  label: '${e.title} (${_results.where((r) => r.exam.id == e.id).length})',
                  selected: _filter == e.id,
                  onTap: () => setState(() => _filter = e.id),
                ),
            ]),
            const SizedBox(height: 14),
            for (final r in shown)
              Padding(padding: const EdgeInsets.only(bottom: 10), child: _AttemptTile(r: r)),
          ],
        ]),
      ),
    );
  }
}

// ───────────────────────────── Real results ─────────────────────────────

class _RealTile extends StatelessWidget {
  const _RealTile({required this.real, required this.predicted, required this.onDelete});
  final RealResult real;
  final AttemptResult? predicted;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final exam = examById(real.examId);
    final p = predicted;
    // Did the mock's verdict match reality?
    final String match;
    final Color matchColor;
    if (p == null) {
      match = 'No mock linked';
      matchColor = GlobioColors.mutedForeground;
    } else if (p.verdict == Verdict.almost) {
      match = 'Prediction was borderline';
      matchColor = const Color(0xFFB7791F);
    } else if ((p.verdict == Verdict.ready) == real.passed) {
      match = 'Prediction matched';
      matchColor = GlobioColors.success;
    } else {
      match = 'Prediction missed';
      matchColor = GlobioColors.destructive;
    }
    return Panel(
      padding: const EdgeInsets.all(18),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: real.passed ? GlobioColors.successSoft : GlobioColors.destructiveSoft,
            borderRadius: BorderRadius.circular(GlobioTheme.radius),
          ),
          child: Icon(real.passed ? Icons.workspace_premium_rounded : Icons.replay_rounded,
              color: real.passed ? GlobioColors.success : GlobioColors.destructive),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${exam?.fullName ?? real.examId} · real exam',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(
              '${formatShortDate(real.date)} ${real.date.year} · ${real.passed ? 'Passed' : 'Not passed'}${real.score != null ? ' · ${real.score}/100' : ''}',
              style: const TextStyle(fontSize: 13, color: GlobioColors.mutedForeground),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [
              if (p != null) Chip2('Mock said: ${p.verdict.title} (${p.readinessScore}%)'),
              Chip2(match, bg: matchColor.withValues(alpha: 0.1), fg: matchColor),
            ]),
          ]),
        ),
        IconButton(
          tooltip: 'Remove',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline_rounded, color: GlobioColors.mutedForeground),
        ),
      ]),
    );
  }
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog({required this.email, required this.attempts, required this.defaultExam});
  final String email;
  final List<Attempt> attempts;
  final String defaultExam;

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  late String _exam = widget.defaultExam;
  DateTime _date = DateTime.now();
  bool _passed = true;
  final _score = TextEditingController();
  String? _linked; // attempt id or null
  bool _linkTouched = false;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _autoLink();
  }

  @override
  void dispose() {
    _score.dispose();
    super.dispose();
  }

  void _autoLink() {
    if (_linkTouched) return;
    _linked = RealResultService.autoLink(widget.attempts, _exam, _date)?.id;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
    );
    if (d != null) {
      setState(() {
        _date = d;
        _autoLink();
      });
    }
  }

  Future<void> _save() async {
    final raw = _score.text.trim();
    final score = raw.isEmpty ? null : int.tryParse(raw);
    if (raw.isNotEmpty && (score == null || score < 0 || score > 100)) {
      setState(() => _error = 'Score must be a number from 0 to 100 (or leave it empty).');
      return;
    }
    setState(() => _busy = true);
    final err = await RealResultService.add(widget.email,
        examId: _exam, date: _date, passed: _passed, score: score, linkedAttemptId: _linked);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _busy = false;
        _error = err;
      });
    } else {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mocks = widget.attempts.where((a) => a.examId == _exam).toList();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(26),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Eyebrow('Real exam result'),
            const SizedBox(height: 8),
            const Text('How did your exam go?', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Results come from the Goethe/ÖSD portal, so please enter them here. It stays on this device.',
                style: TextStyle(fontSize: 13, color: GlobioColors.mutedForeground, height: 1.5)),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: _exam,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Exam'),
              items: [for (final e in exams) DropdownMenuItem(value: e.id, child: Text(e.fullName, overflow: TextOverflow.ellipsis))],
              onChanged: (v) => setState(() {
                _exam = v ?? _exam;
                _linkTouched = false;
                _autoLink();
              }),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(GlobioTheme.radius - 4),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Exam date', suffixIcon: Icon(Icons.calendar_today_outlined, size: 18)),
                child: Text('${formatShortDate(_date)} ${_date.year}'),
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _Choice(label: 'Passed', selected: _passed, onTap: () => setState(() => _passed = true))),
              const SizedBox(width: 10),
              Expanded(child: _Choice(label: 'Not passed', selected: !_passed, onTap: () => setState(() => _passed = false))),
            ]),
            const SizedBox(height: 14),
            TextField(
              controller: _score,
              keyboardType: TextInputType.number,
              maxLength: 3,
              decoration: const InputDecoration(labelText: 'Score out of 100 (optional)', counterText: ''),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String?>(
              value: _linked,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Compare with mock'),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('No mock')),
                for (final a in mocks)
                  DropdownMenuItem<String?>(
                    value: a.id,
                    child: Text('${formatDateTime(a.submittedAt!)} · ${Readiness.evaluate(examById(a.examId)!, a).overallPct}%',
                        overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() {
                _linked = v;
                _linkTouched = true;
              }),
            ),
            const SizedBox(height: 6),
            const Text('Picked automatically: your latest mock for this exam before the exam date.',
                style: TextStyle(fontSize: 12, color: GlobioColors.mutedForeground)),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: GlobioColors.destructive, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Wrap(alignment: WrapAlignment.end, spacing: 10, runSpacing: 10, children: [
                PillButton(label: 'Cancel', variant: PillVariant.outlineDark, onPressed: () => Navigator.of(context).pop(false)),
                PillButton(label: _busy ? 'Saving…' : 'Save result', variant: PillVariant.primary, onPressed: _busy ? null : _save),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? GlobioColors.brand : Colors.white,
              borderRadius: BorderRadius.circular(GlobioTheme.radius - 4),
              border: Border.all(color: selected ? GlobioColors.brand : GlobioColors.border),
            ),
            child: Text(label,
                style: TextStyle(fontWeight: FontWeight.w600, color: selected ? Colors.white : GlobioColors.foreground)),
          ),
        ),
      );
}

// ───────────────────────────── Mock history ─────────────────────────────

class _ExamSummary extends StatelessWidget {
  const _ExamSummary({required this.exam, required this.results});
  final ExamInfo exam;
  final List<AttemptResult> results; // newest first

  @override
  Widget build(BuildContext context) {
    final latest = results.first;
    final best = results.map((r) => r.overallPct).reduce((a, b) => a > b ? a : b);
    final st = VerdictStyle.of(latest.verdict);
    final series = results.reversed.map((r) => r.overallPct).toList();
    return Panel(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(exam.provider.toUpperCase(),
            style: const TextStyle(fontSize: 10.5, letterSpacing: 1.5, fontWeight: FontWeight.w700, color: GlobioColors.primary)),
        Text(exam.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(children: [
          _Stat(label: 'Latest', value: '${latest.overallPct}%'),
          _Stat(label: 'Best', value: '$best%'),
          _Stat(label: 'Attempts', value: '${results.length}'),
        ]),
        const SizedBox(height: 12),
        SizedBox(height: 52, width: double.infinity, child: CustomPaint(painter: _Sparkline(series, exam.passPct))),
        const SizedBox(height: 4),
        Text('Score per attempt · dashed = ${exam.passPct}% pass mark',
            style: const TextStyle(fontSize: 11.5, color: GlobioColors.mutedForeground)),
        const SizedBox(height: 10),
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
          Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(fontSize: 11.5, color: GlobioColors.mutedForeground)),
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
    final dash = Paint()
      ..color = GlobioColors.mutedForeground.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, y(passPct)), Offset(x + 4, y(passPct)), dash);
    }
    if (values.isEmpty) return;
    final dx = values.length == 1 ? 0.0 : size.width / (values.length - 1);
    final pts = [
      for (var i = 0; i < values.length; i++) Offset(values.length == 1 ? size.width / 2 : i * dx, y(values[i])),
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
            ..strokeJoin = StrokeJoin.round);
    }
    for (var i = 0; i < pts.length; i++) {
      canvas.drawCircle(pts[i], 4, Paint()..color = Colors.white);
      canvas.drawCircle(
          pts[i],
          4,
          Paint()
            ..color = values[i] >= passPct ? GlobioColors.success : GlobioColors.destructive
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5);
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
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : GlobioColors.foreground)),
          ),
        ),
      );
}

class _AttemptTile extends StatelessWidget {
  const _AttemptTile({required this.r});
  final AttemptResult r;

  @override
  Widget build(BuildContext context) {
    final st = VerdictStyle.of(r.verdict);
    final a = r.attempt;
    return InkWell(
      borderRadius: BorderRadius.circular(GlobioTheme.radius + 4),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ResultScreen(exam: r.exam, attempt: a))),
      child: Panel(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: st.soft, borderRadius: BorderRadius.circular(GlobioTheme.radius)),
            child: Text('${r.overallPct}%', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: st.onSoft)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.exam.fullName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('${formatDateTime(a.submittedAt!)} · ${r.correct}/${r.total} correct',
                  style: const TextStyle(fontSize: 12.5, color: GlobioColors.mutedForeground)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: [
                Chip2(r.verdict.title, bg: st.soft, fg: st.onSoft, icon: st.icon),
                for (final s in Skill.values)
                  if (r.skills[s]!.total > 0) Chip2('${s.label} ${r.skills[s]!.pct}%'),
                if (a.wasFree) const Chip2('Free mock', icon: Icons.card_giftcard_rounded),
                if (a.autoSubmitted) const Chip2('Auto-submitted', icon: Icons.timer_off_outlined),
              ]),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: GlobioColors.mutedForeground),
        ]),
      ),
    );
  }
}
