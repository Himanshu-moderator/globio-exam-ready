import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/exams.dart';
import '../../services/auth_service.dart';
import '../../services/local_store.dart';
import '../../services/profile_service.dart';
import '../../services/wallet_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_header.dart';
import '../../widgets/brand_widgets.dart';
import '../../widgets/coin_widgets.dart';
import '../app_shell.dart';
import '../landing_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _loading = true;
  Profile? _profile;
  int _balance = 0;
  List<CoinEntry> _ledger = [];

  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  String _goal = '';
  String _level = '';
  String _target = '';
  DateTime? _examDate;
  bool _saving = false;
  bool _dirty = false;

  String get _email => AuthService.instance.currentUser!.email;

  @override
  void initState() {
    super.initState();
    AppEvents.instance.addListener(_loadWallet);
    _load();
  }

  @override
  void dispose() {
    AppEvents.instance.removeListener(_loadWallet);
    _name.dispose();
    _phone.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final p = await ProfileService.ensure(_email);
    await _loadWallet();
    if (!mounted) return;
    setState(() {
      _profile = p;
      _name.text = AuthService.instance.currentUser!.name;
      _phone.text = p.phone;
      _city.text = p.city;
      _goal = p.goal;
      _level = p.level;
      _target = examById(p.targetExam) == null ? '' : p.targetExam;
      _examDate = p.examDate;
      _loading = false;
    });
  }

  Future<void> _loadWallet() async {
    final email = AuthService.instance.currentUser?.email;
    if (email == null) return;
    final ledger = await Wallet.ledger(email);
    if (!mounted) return;
    setState(() {
      _ledger = ledger;
      _balance = ledger.fold(0, (s, e) => s + e.amount);
    });
  }

  void _touch() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _examDate != null && _examDate!.isAfter(now) ? _examDate! : now.add(const Duration(days: 30)),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (d != null) {
      setState(() => _examDate = d);
      _touch();
    }
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    String? err;
    if (_name.text.trim() != AuthService.instance.currentUser!.name) {
      err = await AuthService.instance.updateName(_name.text);
    }
    if (err == null) {
      final ok = await ProfileService.save(
        _email,
        Profile(
          studentId: _profile!.studentId,
          createdAt: _profile!.createdAt,
          phone: _phone.text,
          city: _city.text,
          goal: _goal,
          level: _level,
          targetExam: _target,
          examDate: _examDate,
        ),
      );
      if (!ok) err = AuthService.storageUnavailable;
    }
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (err == null) _dirty = false;
    });
    messenger.showSnackBar(SnackBar(content: Text(err ?? 'Profile saved.')));
  }

  Future<void> _logout() async {
    await AuthService.instance.logOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LandingScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: GlobioColors.primary));
    final user = AuthService.instance.currentUser!;
    final p = _profile!;
    final w = MediaQuery.sizeOf(context).width;

    final idCard = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(gradient: GlobioColors.heroGradient, borderRadius: BorderRadius.circular(GlobioTheme.radius + 6)),
      child: Stack(children: [
        const Positioned.fill(child: DotPattern(opacity: 0.07)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            UserAvatar(name: user.name, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                Text(user.email, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
              ]),
            ),
          ]),
          const SizedBox(height: 18),
          Text('STUDENT ID',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(children: [
            Text(p.studentId,
                style: const TextStyle(color: GlobioColors.secondary, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Copy ID',
              icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: p.studentId));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student ID copied')));
              },
            ),
          ]),
          const SizedBox(height: 6),
          Text('Member since ${formatShortDate(p.createdAt)} ${p.createdAt.year}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12.5)),
        ]),
      ]),
    );

    final form = Panel(
      child: Form(
        key: _form,
        onChanged: _touch,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Personal details', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _name,
            maxLength: AuthLimits.nameMax,
            decoration: const InputDecoration(labelText: 'Full name', counterText: ''),
            validator: AuthLimits.validateName,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: user.email,
            enabled: false,
            decoration: const InputDecoration(labelText: 'Email (used to log in — cannot be changed)'),
          ),
          const SizedBox(height: 12),
          _TwoCol(
            a: TextFormField(
              controller: _phone,
              maxLength: ProfileService.phoneMax,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone (optional)', counterText: ''),
              validator: ProfileService.validatePhone,
            ),
            b: TextFormField(
              controller: _city,
              maxLength: ProfileService.cityMax,
              decoration: const InputDecoration(labelText: 'City', counterText: ''),
              validator: ProfileService.validateCity,
            ),
          ),
          const SizedBox(height: 20),
          const Text('My German goal', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _TwoCol(
            a: DropdownButtonFormField<String>(
              value: _goal.isEmpty ? null : _goal,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Why are you learning German?'),
              items: [for (final g in Profile.goals) DropdownMenuItem(value: g, child: Text(g))],
              onChanged: (v) => setState(() {
                _goal = v ?? '';
                _dirty = true;
              }),
            ),
            b: DropdownButtonFormField<String>(
              value: _level.isEmpty ? null : _level,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Current level'),
              items: [for (final l in Profile.levels) DropdownMenuItem(value: l, child: Text(l))],
              onChanged: (v) => setState(() {
                _level = v ?? '';
                _dirty = true;
              }),
            ),
          ),
          const SizedBox(height: 12),
          _TwoCol(
            a: DropdownButtonFormField<String>(
              value: _target.isEmpty ? null : _target,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Target exam'),
              items: [for (final e in exams) DropdownMenuItem(value: e.id, child: Text(e.fullName, overflow: TextOverflow.ellipsis))],
              onChanged: (v) => setState(() {
                _target = v ?? '';
                _dirty = true;
              }),
            ),
            b: InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(GlobioTheme.radius - 4),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Planned exam date', suffixIcon: Icon(Icons.calendar_today_outlined, size: 18)),
                child: Text(_examDate == null ? 'Not set' : '${formatShortDate(_examDate!)} ${_examDate!.year}'),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: PillButton(
              label: _saving ? 'Saving…' : 'Save changes',
              variant: PillVariant.primary,
              onPressed: _saving || !_dirty ? null : _save,
            ),
          ),
        ]),
      ),
    );

    final wallet = Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const CoinIcon(size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$_balance coins', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const Text('Coin history', style: TextStyle(fontSize: 12.5, color: GlobioColors.mutedForeground)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        if (_ledger.isEmpty)
          const Text('No coin activity yet.', style: TextStyle(color: GlobioColors.mutedForeground))
        else
          for (final e in _ledger.take(30))
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: GlobioColors.border))),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.note, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
                    Text(formatDateTime(e.at), style: const TextStyle(fontSize: 11.5, color: GlobioColors.mutedForeground)),
                  ]),
                ),
                Text(e.amount > 0 ? '+${e.amount}' : '${e.amount}',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: e.amount > 0 ? GlobioColors.success : GlobioColors.destructive)),
              ]),
            ),
      ]),
    );

    return SingleChildScrollView(
      child: PageBody(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Profile', style: TextStyle(fontSize: w < 600 ? 24 : 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, c) {
            final side = Column(children: [
              idCard,
              const SizedBox(height: 16),
              wallet,
            ]);
            if (c.maxWidth < 900) return Column(children: [side, const SizedBox(height: 16), form]);
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 2, child: side),
              const SizedBox(width: 20),
              Expanded(flex: 3, child: form),
            ]);
          }),
          const SizedBox(height: 24),
          Panel(
            child: Row(children: [
              const Icon(Icons.shield_outlined, color: GlobioColors.primary),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Your account, results and coins are stored only in this browser.',
                    style: TextStyle(fontSize: 13.5, color: GlobioColors.mutedForeground)),
              ),
              const SizedBox(width: 12),
              PillButton(label: 'Log out', variant: PillVariant.outlineDark, onPressed: _logout),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _TwoCol extends StatelessWidget {
  const _TwoCol({required this.a, required this.b});
  final Widget a;
  final Widget b;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        if (c.maxWidth < 520) return Column(children: [a, const SizedBox(height: 12), b]);
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: a),
          const SizedBox(width: 12),
          Expanded(child: b),
        ]);
      });
}
