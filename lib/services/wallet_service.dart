import 'local_store.dart';

/// Globio coins.
///
/// Rules (agreed with the product owner):
/// • New account: 100 welcome coins (= one mock).
/// • A mock costs 100 coins (except the free biweekly mock).
/// • A mock earns coins = score % → full marks earns exactly 100, the price
///   of the next mock.
/// • A mentor session costs 200 coins (= two full-marks mocks).
/// • Daily question: easy 5, medium 10, advanced 20 (= 1/5 of a mock);
///   a wrong answer still earns 1.
///
/// The balance is always the sum of an append-only ledger. Every entry has a
/// unique id, so the same reward can never be paid twice (e.g. `mock:<id>`).
class Wallet {
  Wallet._();

  static const welcomeBonus = 100;
  static const mockPrice = 100;
  static const mentorPrice = 200;
  static const dailyEasy = 5;
  static const dailyMedium = 10;
  static const dailyAdvanced = 20;
  static const dailyWrong = 1;

  /// Coins for a mock score: full marks = [mockPrice].
  static int coinsForScore(int correct, int total) =>
      total <= 0 ? 0 : (correct * mockPrice / total).round().clamp(0, mockPrice);

  static String _key(String email) => 'globio.wallet.v1|$email';

  static Future<List<CoinEntry>> ledger(String email) async {
    final raw = await LocalStore.readList(_key(email));
    return raw.map(CoinEntry.fromJson).whereType<CoinEntry>().toList()
      ..sort((a, b) => b.at.compareTo(a.at));
  }

  static Future<int> balance(String email) async =>
      (await ledger(email)).fold<int>(0, (s, e) => s + e.amount);

  /// Adds an entry unless one with the same id exists. Returns true if the
  /// entry is now in the ledger (newly added or already there).
  static Future<bool> add(String email, CoinEntry entry) async {
    final all = await ledger(email);
    if (all.any((e) => e.id == entry.id)) return true;
    final ok = await LocalStore.write(_key(email), [entry, ...all].map((e) => e.toJson()).toList());
    if (ok) AppEvents.instance.changed();
    return ok;
  }

  static Future<bool> has(String email, String id) async => (await ledger(email)).any((e) => e.id == id);

  /// Gives the welcome bonus once per account.
  static Future<void> ensureWelcome(String email) => add(
        email,
        CoinEntry(id: 'welcome', amount: welcomeBonus, kind: 'welcome', note: 'Welcome bonus', at: DateTime.now()),
      );

  /// Spends coins if the balance allows. [id] must be unique for the purchase.
  /// Returns null on success, otherwise a message.
  static Future<String?> spend(String email, {required String id, required int amount, required String kind, required String note}) async {
    if (amount <= 0) return 'Invalid amount.';
    if (await has(email, id)) return null; // already paid for this exact purchase
    final bal = await balance(email);
    if (bal < amount) return 'You need $amount coins but have $bal.';
    final ok = await add(email, CoinEntry(id: id, amount: -amount, kind: kind, note: note, at: DateTime.now()));
    return ok ? null : 'Could not save — browser storage is blocked.';
  }
}

class CoinEntry {
  const CoinEntry({required this.id, required this.amount, required this.kind, required this.note, required this.at});

  final String id;

  /// Positive = earned, negative = spent.
  final int amount;

  /// welcome | mock | daily | spend_mock | spend_mentor | refund
  final String kind;
  final String note;
  final DateTime at;

  Map<String, dynamic> toJson() =>
      {'id': id, 'amt': amount, 'kind': kind, 'note': note, 'at': at.toUtc().toIso8601String()};

  static CoinEntry? fromJson(Map<String, dynamic> j) {
    final id = j['id'], amt = j['amt'], kind = j['kind'], note = j['note'];
    final at = DateTime.tryParse('${j['at']}');
    if (id is! String || amt is! int || kind is! String || note is! String || at == null) return null;
    if (amt.abs() > 1000) return null; // no single entry is ever this large
    return CoinEntry(id: id, amount: amt, kind: kind, note: note, at: at.toLocal());
  }
}
