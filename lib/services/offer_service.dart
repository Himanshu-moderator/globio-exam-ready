import '../utils/ist.dart';
import 'local_store.dart';
import 'wallet_service.dart';

/// Limited launch offer: 3 mocks for 100 coins.
///
/// • Can be bought from 17 Nov 2026, 00:00 IST until the end of
///   25 Nov 2026 (IST), once per account.
/// • The 3 mocks never expire once bought (like other purchased mocks).
/// • Paid through the coin ledger (id [ledgerId]), so it can only be
///   charged once; the mocks used are stored as attempt ids, so a refund
///   (mock could not start) returns the mock.
class LaunchOffer {
  LaunchOffer._();

  static const mocks = 3;
  static const price = 100;
  static const ledgerId = 'offer:launch3';

  static final start = Ist.instant(2026, 11, 17, 0, 0);

  /// Exclusive: the offer runs through 25 Nov (IST).
  static final end = Ist.instant(2026, 11, 26, 0, 0);

  static bool isOpen([DateTime? now]) {
    final t = now ?? DateTime.now();
    return !t.isBefore(start) && t.isBefore(end);
  }

  static String _key(String email) => 'globio.offer.v1|$email';

  static Future<bool> bought(String email) => Wallet.has(email, ledgerId);

  static Future<List<String>> _used(String email) async {
    final v = await LocalStore.read(_key(email));
    return v is List ? v.whereType<String>().toSet().toList() : <String>[];
  }

  /// Offer mocks the learner can still use.
  static Future<int> left(String email) async {
    if (!await bought(email)) return 0;
    return (mocks - (await _used(email)).length).clamp(0, mocks);
  }

  /// Whether the offer should be shown to this learner now.
  static Future<bool> canBuy(String email, {DateTime? now}) async => isOpen(now) && !await bought(email);

  /// Buys the offer. Returns null on success, otherwise a message.
  static Future<String?> buy(String email, {DateTime? now}) async {
    if (!isOpen(now)) return 'This offer ended on 25 Nov.';
    if (await bought(email)) return 'You already have this offer.';
    final err = await Wallet.spend(email, id: ledgerId, amount: price, kind: 'spend_offer', note: 'Launch offer · $mocks mocks');
    if (err != null) return err;
    AppEvents.instance.changed();
    return null;
  }

  /// Uses one offer mock for [attemptId]. Returns false if none is left.
  static Future<bool> use(String email, String attemptId) async {
    if (await left(email) <= 0) return false;
    final used = await _used(email);
    if (used.contains(attemptId)) return true;
    final ok = await LocalStore.write(_key(email), [...used, attemptId]);
    if (ok) AppEvents.instance.changed();
    return ok;
  }

  /// Gives the mock back if the attempt could not start.
  static Future<void> giveBack(String email, String attemptId) async {
    final used = await _used(email)..remove(attemptId);
    await LocalStore.write(_key(email), used);
    AppEvents.instance.changed();
  }
}
