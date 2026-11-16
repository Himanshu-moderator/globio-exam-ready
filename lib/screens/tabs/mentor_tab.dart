import 'package:flutter/material.dart';

import '../../data/exams.dart';
import '../../models/attempt.dart';
import '../../services/attempt_store.dart';
import '../../services/auth_service.dart';
import '../../services/local_store.dart';
import '../../services/mentor_service.dart';
import '../../services/readiness.dart';
import '../../services/wallet_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../utils/ist.dart';
import '../../widgets/app_header.dart';
import '../../widgets/brand_widgets.dart';
import '../../widgets/coin_widgets.dart';

class MentorTab extends StatefulWidget {
  const MentorTab({super.key, this.preselectAttemptId});

  /// Opens the form with a mock pre-selected for post-exam analysis.
  final String? preselectAttemptId;

  /// Set by the analysis page ("Book a mentor for this mock") before switching tab.
  static String? pendingAttemptId;

  @override
  State<MentorTab> createState() => _MentorTabState();
}

class _MentorTabState extends State<MentorTab> {
  bool _loading = true;
  int _balance = 0;
  List<MentorBooking> _bookings = [];
  List<Attempt> _attempts = [];

  String _topic = MentorService.topics.first;
  String? _attemptId;
  DateTime? _day;
  DateTime? _slot;
  final _note = TextEditingController();
  bool _busy = false;

  String get _email => AuthService.instance.currentUser!.email;

  @override
  void initState() {
    super.initState();
    _attemptId = widget.preselectAttemptId ?? MentorTab.pendingAttemptId;
    MentorTab.pendingAttemptId = null;
    AppEvents.instance.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    AppEvents.instance.removeListener(_load);
    _note.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final email = AuthService.instance.currentUser?.email;
    if (email == null) return;
    final balance = await Wallet.balance(email);
    final bookings = await MentorService.bookings(email);
    final attempts = await AttemptStore.instance.history(email);
    if (!mounted) return;
    setState(() {
      _balance = balance;
      _bookings = bookings;
      _attempts = attempts;
      _attemptId ??= attempts.firstOrNull?.id;
      _loading = false;
    });
  }

  Future<void> _book() async {
    final slot = _slot;
    if (slot == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Request this session?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('${Ist.label(slot)}\n$_topic\n\n${Wallet.mentorPrice} coins will be used '
            '(balance $_balance › ${_balance - Wallet.mentorPrice}). You can cancel up to 24 hours before for a full refund.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Back')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: GlobioColors.primary),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Request session'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    final err = await MentorService.book(
      _email,
      topic: _topic,
      slot: slot,
      attemptId: _topic == MentorService.topics.first ? _attemptId : null,
      note: _note.text,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (err == null) {
        _slot = null;
        _note.clear();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(err ?? 'Session requested! A Globio mentor will confirm it with you.'),
    ));
  }

  Future<void> _cancel(MentorBooking b) async {
    final err = await MentorService.cancel(_email, b.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(err ?? 'Session cancelled — ${Wallet.mentorPrice} coins refunded.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: GlobioColors.primary));
    final w = MediaQuery.sizeOf(context).width;
    final enough = _balance >= Wallet.mentorPrice;
    final slots = MentorService.slots();
    final days = <DateTime>[];
    for (final s in slots) {
      final key = Ist.dayKey(s);
      if (!days.any((d) => Ist.dayKey(d) == key)) days.add(s);
    }
    final daySlots = _day == null ? <DateTime>[] : slots.where((s) => Ist.dayKey(s) == Ist.dayKey(_day!)).toList();

    final form = Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Book a session', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('30 minutes, one-to-one, by video call. Times are in IST.',
            style: TextStyle(fontSize: 13, color: GlobioColors.mutedForeground)),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          value: _topic,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'What do you need help with?'),
          items: [for (final t in MentorService.topics) DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis))],
          onChanged: (v) => setState(() => _topic = v ?? _topic),
        ),
        if (_topic == MentorService.topics.first) ...[
          const SizedBox(height: 14),
          DropdownButtonFormField<String?>(
            value: _attempts.any((a) => a.id == _attemptId) ? _attemptId : null,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Mock to review'),
            items: [
              if (_attempts.isEmpty) const DropdownMenuItem<String?>(value: null, child: Text('No mocks yet')),
              for (final a in _attempts.take(20))
                DropdownMenuItem<String?>(
                  value: a.id,
                  child: Text(
                    '${examById(a.examId)?.title ?? a.examId} · ${formatShortDate(a.submittedAt!)} · '
                    '${examById(a.examId) == null ? '' : '${Readiness.evaluate(examById(a.examId)!, a).overallPct}%'}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (v) => setState(() => _attemptId = v),
          ),
        ],
        const SizedBox(height: 18),
        const Text('Day', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 62,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final d = days[i];
              final wd = Ist.wall(d);
              final sel = _day != null && Ist.dayKey(_day!) == Ist.dayKey(d);
              return _SlotChip(
                top: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][wd.weekday - 1],
                bottom: '${wd.day}',
                selected: sel,
                onTap: () => setState(() {
                  _day = d;
                  _slot = null;
                }),
              );
            },
          ),
        ),
        if (_day != null) ...[
          const SizedBox(height: 14),
          const Text('Time (IST)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final s in daySlots)
              _TimeChip(
                label: Ist.label(s).split(', ').last.replaceAll(' IST', ''),
                selected: _slot == s,
                taken: _bookings.any((b) => b.status == BookingStatus.requested && b.slot == s),
                onTap: () => setState(() => _slot = s),
              ),
          ]),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _note,
          maxLength: MentorService.noteMax,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Anything the mentor should know? (optional)'),
        ),
        const SizedBox(height: 8),
        Row(children: [
          const CoinIcon(size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              enough
                  ? '${Wallet.mentorPrice} coins · you have $_balance'
                  : 'You need ${Wallet.mentorPrice} coins (you have $_balance). Earn with mocks and the daily question.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: enough ? GlobioColors.foreground : GlobioColors.destructive),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        PillButton(
          label: _busy ? 'Requesting…' : (_slot == null ? 'Pick a day and time' : 'Request session'),
          variant: PillVariant.primary,
          expand: true,
          onPressed: (!enough || _slot == null || _busy) ? null : _book,
        ),
      ]),
    );

    final side = Column(children: [
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('How it works', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          for (final (i, t) in const [
            (Icons.toll_outlined, 'A session costs 200 coins — the same as two full-marks mocks.'),
            (Icons.event_available_outlined, 'Pick a slot: weekdays 7–9 PM, weekends 10–11 AM and 4–5 PM IST.'),
            (Icons.mark_email_read_outlined, 'Your request goes to a Globio mentor, who confirms it with you.'),
            (Icons.undo_rounded, 'Cancel up to 24 hours before for a full refund.'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(i, size: 19, color: GlobioColors.primary),
                const SizedBox(width: 10),
                Expanded(child: Text(t, style: const TextStyle(fontSize: 13.5, height: 1.5))),
              ]),
            ),
        ]),
      ),
      const SizedBox(height: 16),
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('My sessions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          if (_bookings.isEmpty)
            const Text('No sessions yet.', style: TextStyle(fontSize: 13.5, color: GlobioColors.mutedForeground))
          else
            for (final b in _bookings)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BookingRow(b: b, onCancel: MentorService.canCancel(b) ? () => _cancel(b) : null),
              ),
        ]),
      ),
    ]);

    return SingleChildScrollView(
      child: PageBody(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Mentor session', style: TextStyle(fontSize: w < 600 ? 24 : 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Go through a mock with a Globio mentor: what went wrong, what to fix, and when to book your exam.',
              style: TextStyle(fontSize: 14.5, color: GlobioColors.mutedForeground, height: 1.55)),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (context, c) {
            if (c.maxWidth < 860) return Column(children: [form, const SizedBox(height: 16), side]);
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 3, child: form),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: side),
            ]);
          }),
        ]),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({required this.top, required this.bottom, required this.selected, required this.onTap});
  final String top;
  final String bottom;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 54,
            decoration: BoxDecoration(
              color: selected ? GlobioColors.brand : Colors.white,
              borderRadius: BorderRadius.circular(GlobioTheme.radius),
              border: Border.all(color: selected ? GlobioColors.brand : GlobioColors.border),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(top, style: TextStyle(fontSize: 11.5, color: selected ? Colors.white70 : GlobioColors.mutedForeground)),
              Text(bottom,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: selected ? Colors.white : GlobioColors.foreground)),
            ]),
          ),
        ),
      );
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label, required this.selected, required this.taken, required this.onTap});
  final String label;
  final bool selected;
  final bool taken;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: taken ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: GestureDetector(
          onTap: taken ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: taken ? GlobioColors.muted : (selected ? GlobioColors.primary : Colors.white),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: selected ? GlobioColors.primary : GlobioColors.border),
            ),
            child: Text(taken ? '$label · booked' : label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: taken ? GlobioColors.mutedForeground : (selected ? Colors.white : GlobioColors.foreground),
                )),
          ),
        ),
      );
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({required this.b, this.onCancel});
  final MentorBooking b;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final past = b.slot.isBefore(DateTime.now());
    final (label, bg, fg) = b.status == BookingStatus.cancelled
        ? ('Cancelled', GlobioColors.muted, GlobioColors.mutedForeground)
        : (past ? ('Completed', GlobioColors.muted, GlobioColors.mutedForeground) : ('Requested', GlobioColors.secondarySoft, GlobioColors.foreground));
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: GlobioColors.border), borderRadius: BorderRadius.circular(GlobioTheme.radius)),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(Ist.label(b.slot), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
            Text(b.topic, style: const TextStyle(fontSize: 12.5, color: GlobioColors.mutedForeground)),
            const SizedBox(height: 6),
            Chip2(label, bg: bg, fg: fg),
          ]),
        ),
        if (onCancel != null) TextButton(onPressed: onCancel, child: const Text('Cancel')),
      ]),
    );
  }
}
