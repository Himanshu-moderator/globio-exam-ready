import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:globio_exam_ready/data/exams.dart';
import 'package:globio_exam_ready/data/topics.dart';
import 'package:globio_exam_ready/models/attempt.dart';
import 'package:globio_exam_ready/models/quiz.dart';
import 'package:globio_exam_ready/services/attempt_store.dart';
import 'package:globio_exam_ready/services/quiz_engine.dart';
import 'package:globio_exam_ready/services/readiness.dart';
import 'package:globio_exam_ready/services/speech.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Answers an attempt so that exactly [correctPerSkill] questions per skill are right.
void answer(ExamInfo exam, Attempt a, Map<Skill, int> correctPerSkill) {
  final left = Map.of(correctPerSkill);
  for (final item in a.items) {
    final q = questionById(exam, item.questionId)!;
    if ((left[q.skill] ?? 0) > 0) {
      item.chosen = q.answer;
      left[q.skill] = left[q.skill]! - 1;
    } else {
      item.chosen = (q.answer + 1) % q.options.length;
    }
  }
}

void main() {
  group('Question banks', () {
    test('every exam has its own bank with enough questions per skill', () {
      final allIds = <String>{};
      for (final e in exams) {
        for (final s in Skill.values) {
          final n = e.questions.where((q) => q.skill == s).length;
          expect(n, greaterThanOrEqualTo(e.perSkill * 2),
              reason: '${e.id} needs at least 2× perSkill ${s.name} questions for variety');
        }
        for (final q in e.questions) {
          expect(allIds.add(q.id), isTrue, reason: 'duplicate id ${q.id} (exams must not share questions)');
        }
      }
    });

    test('every question is well-formed', () {
      for (final e in exams) {
        for (final q in e.questions) {
          final where = '${e.id}/${q.id}';
          expect(q.options.length, inInclusiveRange(2, 4), reason: where);
          expect(q.options.toSet().length, q.options.length, reason: '$where has duplicate options');
          expect(q.answer, inInclusiveRange(0, q.options.length - 1), reason: where);
          expect(q.prompt.trim(), isNotEmpty, reason: where);
          expect(q.explanation.trim(), isNotEmpty, reason: where);
          expect(topicGuides.containsKey(q.topic), isTrue, reason: '$where has unknown topic ${q.topic}');
          if (q.skill == Skill.reading) {
            expect(q.passage?.trim(), isNotEmpty, reason: '$where: reading needs a text');
          }
          if (q.skill == Skill.listening) {
            expect(q.audio?.trim(), isNotEmpty, reason: '$where: listening needs a script');
            expect(q.passage, isNull, reason: '$where: listening text must not be shown');
            expect(q.plays, inInclusiveRange(1, 2), reason: where);
            expect(speechTurns(q.audio!), isNotEmpty, reason: where);
          } else {
            expect(q.audio, isNull, reason: where);
          }
        }
      }
    });

    test('no characters the Poppins font cannot draw (arrows etc.)', () {
      final banned = RegExp('[←-⇿⁠￼]');
      final texts = <String>[
        for (final e in exams) ...[
          e.passRule,
          ...e.tips,
          for (final q in e.questions) ...[q.prompt, q.explanation, ...q.options, q.passage ?? '', q.audio ?? ''],
        ],
        for (final g in topicGuides.values) ...[g.title, g.fix, g.example, g.practise],
      ];
      for (final t in texts) {
        expect(banned.hasMatch(t), isFalse, reason: 'unsupported glyph in: $t');
      }
    });

    test('the mock mirrors the real exam: 4 skills, listening = reading, max 16 questions', () {
      for (final e in exams) {
        expect(e.totalQuestions, lessThanOrEqualTo(16), reason: e.id);
        expect(e.totalQuestions, 16, reason: e.id);
        final listen = e.questions.where((q) => q.isListening).toList();
        expect(listen.length, e.questions.where((q) => q.skill == Skill.reading).length,
            reason: '${e.id}: listening and reading weigh the same, as in the real exam');
        expect(listen.where((q) => q.plays == 1), isNotEmpty,
            reason: '${e.id}: some recordings are heard only once, as in the real exam');
      }
    });

    test('speech script: speaker marks are not spoken, long lines split at sentences', () {
      final t = speechTurns('A: Hallo! Wie geht es dir?\nB: Gut, danke.\nAchtung: Gleis drei.');
      expect(t.map((x) => x.text), ['Hallo!', 'Wie geht es dir?', 'Gut, danke.', 'Achtung: Gleis drei.']);
      expect(t.map((x) => x.speaker), [0, 0, 1, 0]);
    });

    test('Richtig/Falsch items are not all the same answer', () {
      for (final e in exams) {
        final tf = e.questions.where((q) => !q.shuffleOptions).toList();
        expect(tf.where((q) => q.answer == 0), isNotEmpty, reason: e.id);
        expect(tf.where((q) => q.answer == 1), isNotEmpty, reason: e.id);
      }
    });
  });

  group('Quiz engine', () {
    final exam = examById('goethe-a1')!;

    test('draws perSkill questions per skill, no duplicates, only from that exam', () {
      final a = QuizEngine.create(exam, random: Random(1));
      expect(a.items.length, exam.totalQuestions);
      expect(a.items.map((i) => i.questionId).toSet().length, a.items.length);
      for (final s in Skill.values) {
        expect(a.items.where((i) => questionById(exam, i.questionId)!.skill == s).length, exam.perSkill);
      }
      expect(a.deadline.difference(a.startedAt), Duration(minutes: exam.minutes));
    });

    test('different learners get different sets and orders', () {
      final sets = <String>{};
      final orders = <String>{};
      for (var seed = 0; seed < 20; seed++) {
        final a = QuizEngine.create(exam, random: Random(seed));
        sets.add((a.items.map((i) => i.questionId).toList()..sort()).join(','));
        orders.add(a.items.map((i) => i.questionId).join(','));
      }
      expect(sets.length, greaterThan(15));
      expect(orders.length, 20);
    });

    test('options are shuffled (except Richtig/Falsch) and stay a valid permutation', () {
      var moved = 0;
      for (var seed = 0; seed < 10; seed++) {
        final a = QuizEngine.create(exam, random: Random(seed));
        for (final item in a.items) {
          final q = questionById(exam, item.questionId)!;
          expect(item.order.toSet(), Set<int>.from(List.generate(q.options.length, (i) => i)));
          if (!q.shuffleOptions) expect(item.order, [0, 1]);
          if (q.shuffleOptions && item.order.first != 0) moved++;
        }
      }
      expect(moved, greaterThan(0), reason: 'correct answer must not always be shown first');
    });

    test('a retake prefers questions the learner has not seen yet', () {
      final first = QuizEngine.create(exam, random: Random(7));
      first.submittedAt = DateTime.now();
      final second = QuizEngine.create(exam, history: [first], random: Random(8));
      final overlap = first.items.map((i) => i.questionId).toSet()
        ..retainAll(second.items.map((i) => i.questionId));
      expect(overlap, isEmpty, reason: 'bank has 10 per skill, so 4 fresh ones are available');
    });
  });

  group('Readiness', () {
    final goethe = examById('goethe-a1')!; // pass 60
    final osd = examById('osd-a1')!; // pass 50

    /// Correct answers per skill: listening, reading, grammar, vocabulary (4 each).
    AttemptResult run(ExamInfo e, int l, int r, int g, int v, {int seed = 3, DateTime? at}) {
      final a = QuizEngine.create(e, random: Random(seed));
      answer(e, a, {Skill.listening: l, Skill.reading: r, Skill.grammar: g, Skill.vocabulary: v});
      a.submittedAt = at ?? DateTime.now();
      return Readiness.evaluate(e, a);
    }

    test('all correct → ready, no focus areas', () {
      final res = run(goethe, 4, 4, 4, 4);
      expect(res.overallPct, 100);
      expect(res.verdict, Verdict.ready);
      expect(res.focusAreas, isEmpty);
    });

    test('high total but one weak skill is NOT ready (one weak part fails the exam)', () {
      final res = run(goethe, 4, 4, 4, 1); // 81% overall, vocabulary 25%
      expect(res.overallPct, 81);
      expect(res.verdict, isNot(Verdict.ready));
    });

    test('weak listening blocks "ready" just like any other skill', () {
      final res = run(goethe, 1, 4, 4, 4); // 81% overall, listening 25%
      expect(res.verdict, isNot(Verdict.ready));
      expect(res.focusAreas.first.skill, Skill.listening);
    });

    test('around the pass mark → almost ready', () {
      final res = run(goethe, 3, 3, 3, 2); // 69%, weakest 50
      expect(res.verdict, Verdict.almost);
    });

    test('below the pass mark → not ready', () {
      final res = run(goethe, 2, 2, 2, 2); // 50%
      expect(res.verdict, Verdict.notYet);
    });

    test('pass mark is exam-specific: same score can mean different verdicts', () {
      expect(run(goethe, 3, 2, 2, 2).verdict, Verdict.notYet); // 56% < 60
      expect(run(osd, 3, 2, 2, 2).verdict, Verdict.almost); // 56% ≥ 50
    });

    test('readiness score = 60% overall + 40% weakest skill', () {
      final res = run(goethe, 4, 4, 3, 1); // overall 75, weakest 25
      expect(res.readinessScore, (0.6 * 75 + 0.4 * 25).round());
    });

    test('close call: flagged when one answer would change the verdict', () {
      expect(run(goethe, 4, 4, 3, 3).isCloseCall, isTrue, reason: 'one more grammar mistake › almost');
      expect(run(goethe, 4, 4, 4, 4).isCloseCall, isFalse, reason: 'one mistake still leaves it ready');
      expect(run(goethe, 0, 0, 0, 0).isCloseCall, isFalse);
    });

    test('confidence: one mock asks for a second; two agreeing mocks confirm', () {
      final t0 = DateTime(2026, 11, 10);
      final first = run(goethe, 4, 4, 4, 4, seed: 1, at: t0);
      expect(Readiness.confidence(first, [first.attempt]).level, ConfidenceLevel.singleMock);

      final second = run(goethe, 4, 4, 4, 4, seed: 2, at: t0.add(const Duration(days: 1)));
      final c = Readiness.confidence(second, [second.attempt, first.attempt]);
      expect(c.level, ConfidenceLevel.confirmed);
      expect(c.mocks, 2);
      expect(c.questions, 32);
    });

    test('confidence: a lucky mock after a weak one is not confirmed', () {
      final t0 = DateTime(2026, 11, 10);
      final weak = run(goethe, 1, 1, 1, 1, seed: 1, at: t0);
      final lucky = run(goethe, 4, 4, 4, 4, seed: 2, at: t0.add(const Duration(days: 1)));
      final c = Readiness.confidence(lucky, [lucky.attempt, weak.attempt]);
      expect(c.level, ConfidenceLevel.mixed);
      expect(c.verdict, isNot(Verdict.ready));
    });

    test('confidence ignores other exams and later mocks', () {
      final t0 = DateTime(2026, 11, 10);
      final cur = run(goethe, 4, 4, 4, 4, seed: 1, at: t0);
      final otherExam = run(osd, 0, 0, 0, 0, seed: 2, at: t0.subtract(const Duration(days: 1)));
      final later = run(goethe, 0, 0, 0, 0, seed: 3, at: t0.add(const Duration(days: 1)));
      expect(Readiness.confidence(cur, [cur.attempt, otherExam.attempt, later.attempt]).level,
          ConfidenceLevel.singleMock);
    });

    test('focus areas come only from wrong answers, max 3', () {
      final res = run(goethe, 1, 1, 1, 1);
      expect(res.focusAreas.length, lessThanOrEqualTo(3));
      final wrongTopics = res.reviews.where((r) => !r.isCorrect).map((r) => r.question.topic).toSet();
      for (final f in res.focusAreas) {
        expect(wrongTopics, contains(f.topicId));
      }
    });

    test('focus areas cover every weak skill before repeating one', () {
      final res = run(goethe, 4, 4, 1, 0); // vocab 0%, grammar 25% (both weak), others 100%
      final skills = res.focusAreas.map((f) => f.skill).toSet();
      expect(skills, containsAll([Skill.vocabulary, Skill.grammar]));
      expect(res.focusAreas.first.skill, Skill.vocabulary, reason: 'weakest skill first');
    });

    test('unanswered questions count as wrong', () {
      final a = QuizEngine.create(goethe, random: Random(5));
      a.submittedAt = DateTime.now();
      final res = Readiness.evaluate(goethe, a);
      expect(res.correct, 0);
      expect(res.reviews.every((r) => r.unanswered), isTrue);
    });

    test('tampered answers (out of range / unknown ids) never crash', () {
      final a = QuizEngine.create(goethe, random: Random(5));
      a.items[0].chosen = 99;
      a.items.add(AttemptItem(questionId: 'does-not-exist', order: [0, 1]));
      a.items[1] = AttemptItem(questionId: a.items[1].questionId, order: [5, 5, 5], chosen: 0);
      final res = Readiness.evaluate(goethe, a);
      expect(res.total, goethe.totalQuestions);
      expect(res.reviews[0].unanswered, isTrue);
    });
  });

  group('Attempt storage', () {
    const email = 'asha@example.com';
    final exam = examById('goethe-a2')!;

    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('JSON round trip keeps everything', () {
      final a = QuizEngine.create(exam, random: Random(2));
      a.items[0].chosen = 2;
      a.items[1].heard = 1;
      final b = Attempt.fromJson(jsonDecode(jsonEncode(a.toJson())))!;
      expect(b.items[1].heard, 1, reason: 'listening play count survives a refresh');
      expect(b.id, a.id);
      expect(b.items.map((i) => i.questionId), a.items.map((i) => i.questionId));
      expect(b.items[0].chosen, 2);
      expect(b.items[0].order, a.items[0].order);
    });

    test('malformed JSON returns null instead of crashing', () {
      expect(Attempt.fromJson(null), isNull);
      expect(Attempt.fromJson({'id': 1}), isNull);
      expect(Attempt.fromJson({'id': 'x', 'exam': 'e', 'start': 'bad', 'deadline': 'bad', 'items': []}), isNull);
    });

    test('submitted results are final: saved once, never overwritten', () async {
      final store = AttemptStore.instance;
      final a = QuizEngine.create(exam, random: Random(2));
      await store.saveActive(email, a);
      a.items[0].chosen = 0;
      expect(await store.submit(email, a), isTrue);
      expect(await store.active(email), isNull);

      final changed = Attempt.fromJson(a.toJson())!..items[0].chosen = 1;
      await store.saveFinished(email, changed);
      final hist = await store.history(email);
      expect(hist.length, 1);
      expect(hist.first.items[0].chosen, 0, reason: 'a submitted attempt must not be changed');
    });

    test('an expired running exam is auto-submitted at its deadline', () async {
      final store = AttemptStore.instance;
      final start = DateTime.now().subtract(const Duration(hours: 1));
      final a = QuizEngine.create(exam, random: Random(4), now: start);
      await store.saveActive(email, a);
      final done = await store.finalizeIfExpired(email);
      expect(done, isNotNull);
      final hist = await store.history(email);
      expect(hist.single.autoSubmitted, isTrue);
      expect(hist.single.submittedAt, a.deadline);
      expect(await store.active(email), isNull);
    });

    test('history is per learner', () async {
      final store = AttemptStore.instance;
      final a = QuizEngine.create(exam, random: Random(9))..submittedAt = DateTime.now();
      await store.saveFinished(email, a);
      expect(await store.history('someone.else@example.com'), isEmpty);
    });
  });
}
