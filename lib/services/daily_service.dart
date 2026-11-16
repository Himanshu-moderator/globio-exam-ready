import 'dart:math';

import '../data/exams.dart';
import '../models/quiz.dart';
import '../utils/ist.dart';
import 'local_store.dart';
import 'wallet_service.dart';

enum Difficulty { easy, medium, advanced }

extension DifficultyInfo on Difficulty {
  String get label => switch (this) {
        Difficulty.easy => 'Easy · A1',
        Difficulty.medium => 'Medium · A2',
        Difficulty.advanced => 'Advanced · B1',
      };

  int get reward => switch (this) {
        Difficulty.easy => Wallet.dailyEasy,
        Difficulty.medium => Wallet.dailyMedium,
        Difficulty.advanced => Wallet.dailyAdvanced,
      };

  /// Which banks each level draws from.
  List<String> get examIds => switch (this) {
        Difficulty.easy => const ['goethe-a1', 'osd-a1'],
        Difficulty.medium => const ['goethe-a2'],
        Difficulty.advanced => const ['goethe-b1'],
      };
}

class DailyQuestion {
  const DailyQuestion({
    required this.day,
    required this.difficulty,
    required this.question,
    required this.order,
    this.chosen,
    this.coins,
  });

  final String day;
  final Difficulty difficulty;
  final Question question;
  final List<int> order;

  /// Original option index picked, or null if not answered yet.
  final int? chosen;
  final int? coins;

  bool get answered => chosen != null;
  bool get correct => chosen == question.answer;
}

/// One random question per learner per IST day.
///
/// The question, its difficulty and option order are derived from a stable
/// hash of (email, day), so refreshing the page can never re-roll an easier
/// or more valuable question. It can be answered once.
class DailyService {
  DailyService._();

  static String _key(String email) => 'globio.daily.v1|$email';

  /// FNV-1a — stable across sessions and platforms (unlike String.hashCode).
  static int _hash(String s) {
    var h = 0x811c9dc5;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xffffffff;
    }
    return h;
  }

  static DailyQuestion pick(String email, String day) {
    final rnd = Random(_hash('$email|$day'));
    final difficulty = Difficulty.values[rnd.nextInt(Difficulty.values.length)];
    final pool = [
      for (final id in difficulty.examIds) ...examById(id)!.questions,
    ];
    final q = pool[rnd.nextInt(pool.length)];
    final order = List<int>.generate(q.options.length, (i) => i);
    if (q.shuffleOptions) order.shuffle(rnd);
    return DailyQuestion(day: day, difficulty: difficulty, question: q, order: order);
  }

  static Future<DailyQuestion> today(String email, {DateTime? now}) async {
    final day = Ist.dayKey(now ?? DateTime.now());
    final base = pick(email, day);
    final saved = (await LocalStore.readMap(_key(email)))[day];
    if (saved is Map && saved['q'] == base.question.id && saved['c'] is int) {
      final c = saved['c'] as int;
      if (c >= 0 && c < base.question.options.length) {
        return DailyQuestion(
          day: day,
          difficulty: base.difficulty,
          question: base.question,
          order: base.order,
          chosen: c,
          coins: saved['coins'] is int ? saved['coins'] as int : null,
        );
      }
    }
    return base;
  }

  /// Answers today's question once and pays the reward. Returns the updated state.
  static Future<DailyQuestion> answer(String email, int originalIndex, {DateTime? now}) async {
    final current = await today(email, now: now);
    if (current.answered) return current; // already answered: no second reward
    if (originalIndex < 0 || originalIndex >= current.question.options.length) return current;
    final correct = originalIndex == current.question.answer;
    final coins = correct ? current.difficulty.reward : Wallet.dailyWrong;
    final all = await LocalStore.readMap(_key(email));
    all[current.day] = {'q': current.question.id, 'c': originalIndex, 'coins': coins};
    await LocalStore.write(_key(email), all);
    await Wallet.add(
      email,
      CoinEntry(
        id: 'daily:${current.day}',
        amount: coins,
        kind: 'daily',
        note: correct ? 'Daily question (${current.difficulty.label})' : 'Daily question — thanks for trying',
        at: now ?? DateTime.now(),
      ),
    );
    return DailyQuestion(
      day: current.day,
      difficulty: current.difficulty,
      question: current.question,
      order: current.order,
      chosen: originalIndex,
      coins: coins,
    );
  }

  /// Consecutive IST days with an answered daily question, ending today
  /// (or yesterday, if today is still open).
  static Future<int> streak(String email, {DateTime? now}) async {
    final all = await LocalStore.readMap(_key(email));
    var t = now ?? DateTime.now();
    if (!all.containsKey(Ist.dayKey(t))) t = t.subtract(const Duration(days: 1));
    var n = 0;
    while (all.containsKey(Ist.dayKey(t)) && n < 3650) {
      n++;
      t = t.subtract(const Duration(days: 1));
    }
    return n;
  }
}
