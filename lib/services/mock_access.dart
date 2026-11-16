import '../models/attempt.dart';
import '../utils/ist.dart';
import 'local_store.dart';
import 'wallet_service.dart';

class FreeStatus {
  const FreeStatus({required this.open, required this.used, required this.next});

  /// The free window open right now, if any.
  final FreeWindow? open;

  /// Whether the learner already used the open window.
  final bool used;

  /// The next window after now.
  final FreeWindow next;

  bool get available => open != null && !used;
}

/// Decides how a mock is paid for: the free biweekly mock (one attempt per
/// window) or 100 coins.
class MockAccess {
  MockAccess._();

  static String _key(String email) => 'globio.free.v1|$email';

  static Future<Set<String>> _used(String email) async {
    final v = await LocalStore.read(_key(email));
    return v is List ? v.whereType<String>().toSet() : <String>{};
  }

  static Future<FreeStatus> freeStatus(String email, {DateTime? now}) async {
    final t = now ?? DateTime.now();
    final open = FreeMockSchedule.openAt(t);
    final used = open != null && (await _used(email)).contains(open.id);
    return FreeStatus(open: open, used: used, next: FreeMockSchedule.next(t));
  }

  /// Pays for [attempt] and records the payment on it.
  /// Returns null on success, otherwise a message.
  static Future<String?> pay(String email, Attempt attempt, {required bool useFree, DateTime? now}) async {
    final t = now ?? DateTime.now();
    if (useFree) {
      final status = await freeStatus(email, now: t);
      if (!status.available) return 'The free mock is not available right now.';
      final used = await _used(email);
      if (!await LocalStore.write(_key(email), [...used, status.open!.id])) {
        return 'Could not save — browser storage is blocked.';
      }
      attempt.payment = 'free:${status.open!.id}';
      AppEvents.instance.changed();
      return null;
    }
    final err = await Wallet.spend(email,
        id: 'buy:${attempt.id}', amount: Wallet.mockPrice, kind: 'spend_mock', note: 'Mock purchase');
    if (err != null) return err;
    attempt.payment = 'coins';
    return null;
  }

  /// Undo a payment if the attempt could not be started.
  static Future<void> refund(String email, Attempt attempt) async {
    final p = attempt.payment;
    if (p == null) return;
    if (p.startsWith('free:')) {
      final id = p.substring(5);
      final used = await _used(email)..remove(id);
      await LocalStore.write(_key(email), used.toList());
    } else if (p == 'coins') {
      await Wallet.add(email,
          CoinEntry(id: 'refund:${attempt.id}', amount: Wallet.mockPrice, kind: 'refund', note: 'Mock could not start — refund', at: DateTime.now()));
    }
    attempt.payment = null;
    AppEvents.instance.changed();
  }
}
