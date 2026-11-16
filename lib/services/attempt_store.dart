import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/exams.dart';
import '../models/attempt.dart';
import 'local_store.dart';
import 'readiness.dart';
import 'wallet_service.dart';

/// Saves attempts per learner in the browser (no backend).
///
/// • Finished attempts are append-only: there is no edit or delete, so a
///   submitted result is final.
/// • The in-progress attempt is saved after every answer, so a refresh or a
///   closed tab resumes the same exam (same questions, same timer) instead of
///   giving a fresh set. If the time ran out meanwhile, it is submitted.
class AttemptStore {
  AttemptStore._();
  static final AttemptStore instance = AttemptStore._();

  static const maxHistory = 100;

  String _historyKey(String email) => 'globio.attempts.v1|$email';
  String _activeKey(String email) => 'globio.active.v1|$email';

  Future<SharedPreferences?> _prefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  /// Finished attempts, newest first.
  Future<List<Attempt>> history(String email) async {
    final p = await _prefs();
    final raw = p?.getString(_historyKey(email));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw);
      if (list is! List) return [];
      final out = list.map(Attempt.fromJson).whereType<Attempt>().where((a) => a.isFinished).toList()
        ..sort((a, b) => b.submittedAt!.compareTo(a.submittedAt!));
      return out;
    } catch (_) {
      return [];
    }
  }

  /// Returns false if storage is unavailable.
  Future<bool> saveFinished(String email, Attempt attempt) async {
    if (!attempt.isFinished) return false;
    final p = await _prefs();
    if (p == null) return false;
    final all = await history(email);
    if (all.any((a) => a.id == attempt.id)) return true; // already final, never overwrite
    final updated = [attempt, ...all].take(maxHistory).map((a) => a.toJson()).toList();
    try {
      return await p.setString(_historyKey(email), jsonEncode(updated));
    } catch (_) {
      return false;
    }
  }

  Future<Attempt?> active(String email) async {
    final p = await _prefs();
    final raw = p?.getString(_activeKey(email));
    if (raw == null) return null;
    try {
      final a = Attempt.fromJson(jsonDecode(raw));
      return (a == null || a.isFinished) ? null : a;
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveActive(String email, Attempt attempt) async {
    final p = await _prefs();
    if (p == null) return false;
    try {
      return await p.setString(_activeKey(email), jsonEncode(attempt.toJson()));
    } catch (_) {
      return false;
    }
  }

  Future<void> clearActive(String email) async {
    final p = await _prefs();
    try {
      await p?.remove(_activeKey(email));
    } catch (_) {}
  }

  /// Submits an attempt: marks it final, stores it in history, clears it as active.
  Future<bool> submit(String email, Attempt attempt, {bool auto = false, DateTime? at}) async {
    if (!attempt.isFinished) {
      final now = at ?? DateTime.now();
      attempt.submittedAt = now.isAfter(attempt.deadline) ? attempt.deadline : now;
      attempt.autoSubmitted = auto;
    }
    final ok = await saveFinished(email, attempt);
    if (ok) {
      await clearActive(email);
      await awardCoins(email, attempt);
      AppEvents.instance.changed();
    }
    return ok;
  }

  /// Coins earned for a finished mock (score % of the mock price). Paid once
  /// per attempt — the ledger id `mock:<attempt id>` makes it idempotent.
  static int coinsFor(Attempt attempt) {
    final exam = examById(attempt.examId);
    if (exam == null || !attempt.isFinished) return 0;
    final r = Readiness.evaluate(exam, attempt);
    return Wallet.coinsForScore(r.correct, r.total);
  }

  Future<void> awardCoins(String email, Attempt attempt) async {
    final coins = coinsFor(attempt);
    if (coins <= 0) return;
    final exam = examById(attempt.examId);
    await Wallet.add(
      email,
      CoinEntry(
        id: 'mock:${attempt.id}',
        amount: coins,
        kind: 'mock',
        note: 'Mock score · ${exam?.title ?? attempt.examId}',
        at: attempt.submittedAt ?? DateTime.now(),
      ),
    );
  }

  /// If the in-progress attempt's time is over, submit it and return it.
  Future<Attempt?> finalizeIfExpired(String email, {DateTime? now}) async {
    final a = await active(email);
    if (a == null) return null;
    if ((now ?? DateTime.now()).isBefore(a.deadline)) return null;
    await submit(email, a, auto: true, at: a.deadline);
    return a;
  }
}
