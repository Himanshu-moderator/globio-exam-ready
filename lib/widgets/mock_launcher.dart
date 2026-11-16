import 'package:flutter/material.dart';

import '../data/exams.dart';
import '../models/quiz.dart';
import '../screens/exam_screen.dart';
import '../services/attempt_store.dart';
import '../services/auth_service.dart';
import '../services/local_store.dart';
import '../services/mock_access.dart';
import '../services/quiz_engine.dart';
import '../services/wallet_service.dart';
import '../theme/app_theme.dart';
import '../utils/ist.dart';
import 'brand_widgets.dart';
import 'coin_widgets.dart';

/// Starts (or resumes) a mock: checks for a running mock, decides payment
/// (free biweekly mock or 100 coins), shows the rules, charges, opens the exam.
class MockLauncher {
  MockLauncher._();

  static Future<void> resumeActive(BuildContext context) async {
    final email = AuthService.instance.currentUser?.email;
    if (email == null) return;
    final store = AttemptStore.instance;
    await store.finalizeIfExpired(email);
    final active = await store.active(email);
    final exam = active == null ? null : examById(active.examId);
    if (active == null || exam == null || !context.mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ExamScreen(exam: exam, attempt: active, email: email),
    ));
    AppEvents.instance.changed();
  }

  static Future<void> start(BuildContext context, ExamInfo exam, {bool preferFree = true}) async {
    final email = AuthService.instance.currentUser?.email;
    if (email == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final store = AttemptStore.instance;

    await store.finalizeIfExpired(email);
    if (await store.active(email) != null) {
      if (!context.mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Finish your running mock first — opening it now.')));
      return resumeActive(context);
    }

    final free = await MockAccess.freeStatus(email);
    final balance = await Wallet.balance(email);
    final useFree = preferFree && free.available;
    if (!context.mounted) return;

    final go = await showDialog<bool>(
      context: context,
      builder: (_) => _StartDialog(exam: exam, useFree: useFree, balance: balance, free: free),
    );
    if (go != true || !context.mounted) return;

    final history = await store.history(email);
    final attempt = QuizEngine.create(exam, history: history);
    final payErr = await MockAccess.pay(email, attempt, useFree: useFree);
    if (payErr != null) {
      messenger.showSnackBar(SnackBar(content: Text(payErr)));
      return;
    }
    if (!await store.saveActive(email, attempt)) {
      await MockAccess.refund(email, attempt);
      messenger.showSnackBar(const SnackBar(content: Text(AuthService.storageUnavailable)));
      return;
    }
    AppEvents.instance.changed();
    if (!context.mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ExamScreen(exam: exam, attempt: attempt, email: email),
    ));
    AppEvents.instance.changed();
  }
}

class _StartDialog extends StatelessWidget {
  const _StartDialog({required this.exam, required this.useFree, required this.balance, required this.free});
  final ExamInfo exam;
  final bool useFree;
  final int balance;
  final FreeStatus free;

  @override
  Widget build(BuildContext context) {
    final canPay = useFree || balance >= Wallet.mockPrice;
    final rules = [
      (Icons.quiz_outlined, '${exam.totalQuestions} questions: ${exam.perSkill} vocabulary, ${exam.perSkill} grammar, ${exam.perSkill} reading — mixed order.'),
      (Icons.timer_outlined, '${exam.minutes} minutes. When time is up, your answers are submitted automatically.'),
      (Icons.lock_outline_rounded, 'Once submitted, the result is final. Leaving the exam also submits it.'),
      (Icons.toll_outlined, 'You earn coins for your score — full marks pays for your next mock (${Wallet.mockPrice} coins).'),
    ];
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Eyebrow('Before you start'),
            const SizedBox(height: 8),
            Text(exam.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            for (final (icon, text) in rules)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(icon, size: 20, color: GlobioColors.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text(text, style: const TextStyle(fontSize: 14, height: 1.5))),
                ]),
              ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: useFree
                    ? GlobioColors.successSoft
                    : (canPay ? GlobioColors.muted : GlobioColors.destructiveSoft),
                borderRadius: BorderRadius.circular(GlobioTheme.radius),
              ),
              child: useFree
                  ? Text('Free biweekly mock — no coins needed. Open until ${Ist.label(free.open!.end)}.',
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: GlobioColors.success))
                  : Row(children: [
                      const CoinIcon(size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          canPay
                              ? 'Costs ${Wallet.mockPrice} coins · balance $balance › ${balance - Wallet.mockPrice}'
                              : 'You need ${Wallet.mockPrice} coins and have $balance. Answer the daily question or wait for the free mock (${Ist.dateLabel(free.next.start)}).',
                          style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: canPay ? GlobioColors.foreground : GlobioColors.destructive),
                        ),
                      ),
                    ]),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: Wrap(alignment: WrapAlignment.end, spacing: 10, runSpacing: 10, children: [
                PillButton(label: 'Not now', variant: PillVariant.outlineDark, onPressed: () => Navigator.of(context).pop(false)),
                PillButton(
                  label: useFree ? 'Start free mock' : 'Pay & start',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: canPay ? () => Navigator.of(context).pop(true) : null,
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
