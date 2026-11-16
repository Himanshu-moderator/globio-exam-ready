import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/exams.dart';
import '../../models/attempt.dart';
import '../../models/quiz.dart';
import '../../services/attempt_store.dart';
import '../../services/auth_service.dart';
import '../../services/daily_service.dart';
import '../../services/local_store.dart';
import '../../services/mentor_service.dart';
import '../../services/mock_access.dart';
import '../../services/profile_service.dart';
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
import '../app_shell.dart';
import '../result_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _loading = true;
  Profile? _profile;
  int _balance = 0;
  int _streak = 0;
  DailyQuestion? _daily;
  FreeStatus? _free;
  Attempt? _active;
  List<AttemptResult> _recent = [];
  int _mockCount = 0;
  MentorBooking? _nextSession;
  Timer? _clock;

  String get _email => AuthService.instance.currentUser!.email;

  @override
  void initState() {
    super.initState();
    AppEvents.instance.addListener(_load);
    _load();
    // Keeps the free-mock countdown fresh.
    _clock = Timer.periodic(const Duration(seconds: 30), (_) => _load());
  }

  @override
  void dispose() {
    AppEvents.instance.removeListener(_load);
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final email = AuthService.instance.currentUser?.email;
    if (email == null) return;
    final store = AttemptStore.instance;
    await store.finalizeIfExpired(email);
    final results = await Future.wait([
      ProfileService.ensure(email),
      Wallet.balance(email),
      DailyService.streak(email),
      DailyService.today(email),
      MockAccess.freeStatus(email),
      store.active(email),
      store.history(email),
      MentorService.bookings(email),
    ]);
    final history = results[6] as List<Attempt>;
    final recent = <AttemptResult>[];
    for (final a in history.take(3)) {
      final e = examById(a.examId);
      if (e != null) recent.add(Readiness.evaluate(e, a));
    }
    final now = DateTime.now();
    final upcoming = (results[7] as List<MentorBooking>)
        .where((b) => b.status == BookingStatus.requested && b.slot.isAfter(now))
        .toList()
      ..sort((a, b) => a.slot.compareTo(b.slot));
    if (!mounted) return;
    setState(() {
      _profile = results[0] as Profile;
      _balance = results[1] as int;
      _streak = results[2] as int;
      _daily = results[3] as DailyQuestion;
      _free = results[4] as FreeStatus;
      _active = results[5] as Attempt?;
      _recent = recent;
      _mockCount = history.length;
      _nextSession = upcoming.firstOrNull;
      _loading = false;
    });
  }

  Future<void> _answer(int originalIndex) async {
    final d = await DailyService.answer(_email, originalIndex);
    if (!mounted) return;
    setState(() => _daily = d);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(d.correct ? 'Richtig! +${d.coins} coins' : 'Not quite — +${d.coins} coin for trying. See the explanation.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: GlobioColors.primary));
    final user = AuthService.instance.currentUser!;
    final w = MediaQuery.sizeOf(context).width;
    final shell = ShellScope.of(context);

    final left = Column(children: [
      _DailyCard(daily: _daily!, onAnswer: _answer),
    ]);
    final right = Column(children: [
      _FreeMockCard(status: _free!, onStart: () => shell.goTo(ShellTab.mocks)),
      const SizedBox(height: 16),
      _TargetCard(profile: _profile!, onEdit: () => shell.goTo(ShellTab.profile)),
      if (_nextSession != null) ...[
        const SizedBox(height: 16),
        _SessionCard(b: _nextSession!, onOpen: () => shell.goTo(ShellTab.mentor)),
      ],
    ]);

    return SingleChildScrollView(
      child: PageBody(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Greeting
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Hallo, ${user.firstName}!', style: TextStyle(fontSize: w < 600 ? 26 : 30, fontWeight: FontWeight.w700)),
              Chip2('ID ${_profile!.studentId}', icon: Icons.badge_outlined, bg: Colors.white, fg: GlobioColors.primary),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Practise a little every day and book your exam when you are ready.',
              style: TextStyle(fontSize: 15, color: GlobioColors.mutedForeground)),
          const SizedBox(height: 24),
          if (_active != null) ...[
            _RunningBanner(attempt: _active!, onResume: () => MockLauncher.resumeActive(context)),
            const SizedBox(height: 20),
          ],
          _StatsGrid(
            balance: _balance,
            streak: _streak,
            mocks: _mockCount,
            latest: _recent.firstOrNull,
          ),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (context, c) {
            if (c.maxWidth < 860) return Column(children: [left, const SizedBox(height: 16), right]);
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 3, child: left),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: right),
            ]);
          }),
          const SizedBox(height: 32),
          Row(children: [
            const Expanded(child: SectionTitle('Recent results')),
            if (_recent.isNotEmpty)
              TextButton(onPressed: () => shell.goTo(ShellTab.results), child: const Text('See all')),
          ]),
          if (_recent.isEmpty)
            Panel(
              child: Row(children: [
                const Icon(Icons.assignment_outlined, color: GlobioColors.primary, size: 28),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text('No mocks yet. Your 100 welcome coins cover your first one.',
                      style: TextStyle(fontSize: 14.5)),
                ),
                const SizedBox(width: 12),
                PillButton(label: 'Choose a mock', variant: PillVariant.primary, onPressed: () => shell.goTo(ShellTab.mocks)),
              ]),
            )
          else
            for (final r in _recent)
              Padding(padding: const EdgeInsets.only(bottom: 10), child: _RecentTile(r: r)),
          const SizedBox(height: 28),
          const SectionTitle('How coins work'),
          const _CoinGuide(),
        ]),
      ),
    );
  }
}

// ───────────────────────────── Pieces ─────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.balance, required this.streak, required this.mocks, required this.latest});
  final int balance;
  final int streak;
  final int mocks;
  final AttemptResult? latest;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _StatCard(
        label: 'Coins',
        value: '$balance',
        leading: const CoinIcon(size: 26),
        footer: _Progress(
          value: (balance / Wallet.mentorPrice).clamp(0, 1).toDouble(),
          text: balance >= Wallet.mentorPrice
              ? 'Enough for a mentor session'
              : (balance >= Wallet.mockPrice
                  ? '${Wallet.mentorPrice - balance} more for a mentor session'
                  : '${Wallet.mockPrice - balance} more for your next mock'),
        ),
      ),
      _StatCard(
        label: 'Daily streak',
        value: '$streak ${streak == 1 ? 'day' : 'days'}',
        leading: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF97316), size: 26),
        footer: const Text('Answer the daily question to keep it going',
            style: TextStyle(fontSize: 12, color: GlobioColors.mutedForeground)),
      ),
      _StatCard(
        label: 'Mocks taken',
        value: '$mocks',
        leading: const Icon(Icons.assignment_turned_in_outlined, color: GlobioColors.primary, size: 26),
        footer: const Text('Every result is saved in My results',
            style: TextStyle(fontSize: 12, color: GlobioColors.mutedForeground)),
      ),
      _StatCard(
        label: 'Latest readiness',
        value: latest == null ? '–' : '${latest!.readinessScore}%',
        leading: Icon(Icons.speed_rounded,
            color: latest == null ? GlobioColors.mutedForeground : VerdictStyle.of(latest!.verdict).color, size: 26),
        footer: Text(latest == null ? 'Take a mock to find out' : '${latest!.verdict.title} · ${latest!.exam.title}',
            style: const TextStyle(fontSize: 12, color: GlobioColors.mutedForeground)),
      ),
    ];
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 900 ? 4 : 2;
      const gap = 16.0;
      final cw = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(spacing: gap, runSpacing: gap, children: [for (final card in cards) SizedBox(width: cw, child: card)]);
    });
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.leading, required this.footer});
  final String label;
  final String value;
  final Widget leading;
  final Widget footer;

  @override
  Widget build(BuildContext context) => Panel(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            leading,
            const Spacer(),
            Text(label.toUpperCase(),
                style: const TextStyle(fontSize: 10.5, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: GlobioColors.mutedForeground)),
          ]),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 8),
          footer,
        ]),
      );
}

class _Progress extends StatelessWidget {
  const _Progress({required this.value, required this.text});
  final double value;
  final String text;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: GlobioColors.muted,
            valueColor: const AlwaysStoppedAnimation(GlobioColors.secondary),
          ),
        ),
        const SizedBox(height: 6),
        Text(text, style: const TextStyle(fontSize: 12, color: GlobioColors.mutedForeground)),
      ]);
}

class _RunningBanner extends StatelessWidget {
  const _RunningBanner({required this.attempt, required this.onResume});
  final Attempt attempt;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final exam = examById(attempt.examId);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: GlobioColors.ctaGradient, borderRadius: BorderRadius.circular(GlobioTheme.radius + 4)),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.timer_outlined, color: GlobioColors.secondary),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                '${exam?.title ?? 'Your'} mock is running · ${formatClock(attempt.deadline.difference(DateTime.now()))} left',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
          PillButton(label: 'Continue', icon: Icons.arrow_forward_rounded, onPressed: onResume),
        ],
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.daily, required this.onAnswer});
  final DailyQuestion daily;
  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context) {
    final q = daily.question;
    final nextIst = Ist.wall(DateTime.now());
    final midnight = DateTime.utc(nextIst.year, nextIst.month, nextIst.day).add(const Duration(days: 1));
    final untilNext = midnight.difference(nextIst);
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: GlobioColors.secondarySoft, borderRadius: BorderRadius.circular(GlobioTheme.radius)),
            child: const Icon(Icons.wb_sunny_outlined, color: Color(0xFFB7791F)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Daily question', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              Text('One question a day · coins for every answer',
                  style: TextStyle(fontSize: 12.5, color: GlobioColors.mutedForeground)),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 8, children: [
          Chip2(daily.difficulty.label, bg: GlobioColors.primary.withValues(alpha: 0.08), fg: GlobioColors.primary),
          Chip2('+${daily.difficulty.reward} if correct · +${Wallet.dailyWrong} if not', bg: GlobioColors.secondarySoft, fg: GlobioColors.foreground),
          Chip2(q.skill.label),
        ]),
        const SizedBox(height: 16),
        if (q.passage != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: GlobioColors.muted,
              borderRadius: BorderRadius.circular(GlobioTheme.radius - 2),
              border: const Border(left: BorderSide(color: GlobioColors.primary, width: 3)),
            ),
            child: Text(q.passage!, style: const TextStyle(fontSize: 14, height: 1.55)),
          ),
          const SizedBox(height: 14),
        ],
        Text(q.prompt, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, height: 1.4)),
        const SizedBox(height: 14),
        for (final i in daily.order)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _DailyOption(
              text: q.options[i],
              state: !daily.answered
                  ? _OptState.open
                  : (i == q.answer ? _OptState.correct : (i == daily.chosen ? _OptState.wrong : _OptState.dim)),
              onTap: daily.answered ? null : () => onAnswer(i),
            ),
          ),
        if (daily.answered) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GlobioColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(GlobioTheme.radius - 4),
            ),
            child: Text(q.explanation, style: const TextStyle(fontSize: 13.5, height: 1.5)),
          ),
          const SizedBox(height: 12),
          Row(children: [
            const CoinIcon(size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '+${daily.coins ?? 0} coins today · next question in ${untilNext.inHours} h ${untilNext.inMinutes % 60} min',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
        ],
      ]),
    );
  }
}

enum _OptState { open, correct, wrong, dim }

class _DailyOption extends StatelessWidget {
  const _DailyOption({required this.text, required this.state, this.onTap});
  final String text;
  final _OptState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, border, icon, color) = switch (state) {
      _OptState.open => (Colors.white, GlobioColors.border, Icons.radio_button_unchecked_rounded, GlobioColors.mutedForeground),
      _OptState.correct => (GlobioColors.successSoft, GlobioColors.success, Icons.check_circle_rounded, GlobioColors.success),
      _OptState.wrong => (GlobioColors.destructiveSoft, GlobioColors.destructive, Icons.cancel_rounded, GlobioColors.destructive),
      _OptState.dim => (Colors.white, GlobioColors.border, Icons.radio_button_unchecked_rounded, GlobioColors.border),
    };
    return Semantics(
      button: onTap != null,
      label: text,
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(GlobioTheme.radius - 2),
              border: Border.all(color: border),
            ),
            child: Row(children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 14.5))),
            ]),
          ),
        ),
      ),
    );
  }
}

class _FreeMockCard extends StatelessWidget {
  const _FreeMockCard({required this.status, required this.onStart});
  final FreeStatus status;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final open = status.open;
    final now = DateTime.now();
    String countdown(Duration d) {
      if (d.inDays >= 1) return '${d.inDays} d ${d.inHours % 24} h';
      return '${d.inHours} h ${d.inMinutes % 60} min';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: GlobioColors.heroGradient, borderRadius: BorderRadius.circular(GlobioTheme.radius + 4)),
      child: Stack(children: [
        const Positioned.fill(child: DotPattern(opacity: 0.07)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.card_giftcard_rounded, color: GlobioColors.secondary),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Free mock', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            ),
            if (status.available)
              const Chip2('OPEN NOW', bg: GlobioColors.secondary, fg: GlobioColors.foreground),
          ]),
          const SizedBox(height: 10),
          Text(
            status.available
                ? 'Your free mock is open. Ends in ${countdown(open!.end.difference(now))}.'
                : (open != null
                    ? 'You used this round\'s free mock. Next one: ${Ist.label(status.next.start)}.'
                    : 'Every other Friday, 6 PM to Saturday 6 PM IST. Next: ${Ist.label(status.next.start)} (in ${countdown(status.next.start.difference(now))}).'),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13.5, height: 1.5),
          ),
          if (status.available) ...[
            const SizedBox(height: 14),
            PillButton(label: 'Take it now', icon: Icons.arrow_forward_rounded, onPressed: onStart),
          ],
        ]),
      ]),
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({required this.profile, required this.onEdit});
  final Profile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final exam = examById(profile.targetExam);
    final date = profile.examDate;
    final days = date == null ? null : DateTime(date.year, date.month, date.day).difference(DateTime.now()).inDays + 1;
    return Panel(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.flag_outlined, color: GlobioColors.primary),
          SizedBox(width: 10),
          Text('My target exam', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        if (exam == null)
          Row(children: [
            const Expanded(
              child: Text('Set your target exam and date to see a countdown.',
                  style: TextStyle(fontSize: 13.5, color: GlobioColors.mutedForeground)),
            ),
            TextButton(onPressed: onEdit, child: const Text('Set it')),
          ])
        else ...[
          Text(exam.fullName, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            date == null
                ? 'No date set yet'
                : (days! > 0 ? '$days days to go · ${formatShortDate(date)} ${date.year}' : 'Exam date passed — report your real result in My results'),
            style: const TextStyle(fontSize: 13, color: GlobioColors.mutedForeground),
          ),
        ],
      ]),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.b, required this.onOpen});
  final MentorBooking b;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Panel(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          const Icon(Icons.support_agent_rounded, color: GlobioColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Mentor session requested', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
              Text(Ist.label(b.slot), style: const TextStyle(fontSize: 13, color: GlobioColors.mutedForeground)),
            ]),
          ),
          TextButton(onPressed: onOpen, child: const Text('View')),
        ]),
      );
}

class _RecentTile extends StatelessWidget {
  const _RecentTile({required this.r});
  final AttemptResult r;

  @override
  Widget build(BuildContext context) {
    final st = VerdictStyle.of(r.verdict);
    return InkWell(
      borderRadius: BorderRadius.circular(GlobioTheme.radius + 4),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => ResultScreen(exam: r.exam, attempt: r.attempt),
      )),
      child: Panel(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: st.soft, borderRadius: BorderRadius.circular(GlobioTheme.radius)),
            child: Text('${r.overallPct}%', style: TextStyle(fontWeight: FontWeight.w800, color: st.onSoft)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.exam.title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
              Text('${formatDateTime(r.attempt.submittedAt!)} · ${r.verdict.title}',
                  style: const TextStyle(fontSize: 12.5, color: GlobioColors.mutedForeground)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: GlobioColors.mutedForeground),
        ]),
      ),
    );
  }
}

class _CoinGuide extends StatelessWidget {
  const _CoinGuide();

  @override
  Widget build(BuildContext context) {
    final earn = [
      ('Welcome bonus', '+${Wallet.welcomeBonus}'),
      ('Mock score (full marks)', 'up to +${Wallet.mockPrice}'),
      ('Daily question · advanced', '+${Wallet.dailyAdvanced}'),
      ('Daily question · medium / easy', '+${Wallet.dailyMedium} / +${Wallet.dailyEasy}'),
      ('Daily question · wrong answer', '+${Wallet.dailyWrong}'),
    ];
    final spend = [
      ('Mock exam', '${Wallet.mockPrice}'),
      ('Mentor session', '${Wallet.mentorPrice}'),
      ('Free mock (every other Friday)', 'Free'),
    ];
    Widget table(String title, List<(String, String)> rows, Color accent) => Panel(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title.toUpperCase(),
                style: TextStyle(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700, color: accent)),
            const SizedBox(height: 10),
            for (final (k, v) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Expanded(child: Text(k, style: const TextStyle(fontSize: 13.5))),
                  Text(v, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                ]),
              ),
          ]),
        );
    return LayoutBuilder(builder: (context, c) {
      final a = table('Earn', earn, GlobioColors.success);
      final b = table('Spend', spend, GlobioColors.primary);
      if (c.maxWidth < 700) return Column(children: [a, const SizedBox(height: 16), b]);
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: a),
        const SizedBox(width: 16),
        Expanded(child: b),
      ]);
    });
  }
}
