import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:globio_exam_ready/data/exams.dart';
import 'package:globio_exam_ready/services/attempt_store.dart';
import 'package:globio_exam_ready/services/daily_service.dart';
import 'package:globio_exam_ready/services/mentor_service.dart';
import 'package:globio_exam_ready/services/mock_access.dart';
import 'package:globio_exam_ready/services/profile_service.dart';
import 'package:globio_exam_ready/services/quiz_engine.dart';
import 'package:globio_exam_ready/services/real_result_service.dart';
import 'package:globio_exam_ready/services/wallet_service.dart';
import 'package:globio_exam_ready/utils/ist.dart';
import 'package:shared_preferences/shared_preferences.dart';

const email = 'asha@example.com';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Coins', () {
    test('score → coins: full marks pays exactly one mock', () {
      expect(Wallet.coinsForScore(15, 15), Wallet.mockPrice);
      expect(Wallet.coinsForScore(0, 15), 0);
      expect(Wallet.coinsForScore(9, 15), 60);
      expect(Wallet.coinsForScore(1, 15), 7);
    });

    test('welcome bonus is paid once', () async {
      await Wallet.ensureWelcome(email);
      await Wallet.ensureWelcome(email);
      expect(await Wallet.balance(email), Wallet.welcomeBonus);
    });

    test('cannot spend more than the balance; same purchase id never charged twice', () async {
      await Wallet.ensureWelcome(email);
      expect(await Wallet.spend(email, id: 'x', amount: 300, kind: 'k', note: 'n'), isNotNull);
      expect(await Wallet.spend(email, id: 'buy:1', amount: 100, kind: 'k', note: 'n'), isNull);
      expect(await Wallet.spend(email, id: 'buy:1', amount: 100, kind: 'k', note: 'n'), isNull);
      expect(await Wallet.balance(email), 0);
    });

    test('a finished mock pays its coins exactly once', () async {
      final exam = examById('goethe-a1')!;
      final a = QuizEngine.create(exam, random: Random(1));
      for (final item in a.items) {
        item.chosen = questionById(exam, item.questionId)!.answer; // all correct
      }
      final store = AttemptStore.instance;
      await store.saveActive(email, a);
      await store.submit(email, a);
      await store.awardCoins(email, a); // a second award attempt
      expect(await Wallet.balance(email), Wallet.mockPrice);
    });
  });

  group('Free biweekly mock', () {
    final fri = Ist.instant(2026, 11, 20, 18, 0);

    test('opens every other Friday 18:00 IST for exactly 24 hours', () {
      expect(FreeMockSchedule.openAt(fri.subtract(const Duration(minutes: 1))), isNull);
      expect(FreeMockSchedule.openAt(fri), isNotNull);
      expect(FreeMockSchedule.openAt(fri.add(const Duration(hours: 23, minutes: 59))), isNotNull);
      expect(FreeMockSchedule.openAt(fri.add(const Duration(hours: 24))), isNull);
      expect(FreeMockSchedule.openAt(fri.add(const Duration(days: 7))), isNull, reason: 'not weekly');
      expect(FreeMockSchedule.openAt(fri.add(const Duration(days: 14, hours: 2))), isNotNull);
    });

    test('the window is Friday 6 PM to Saturday 6 PM in IST', () {
      final w = FreeMockSchedule.openAt(fri.add(const Duration(hours: 1)))!;
      expect(Ist.wall(w.start).weekday, DateTime.friday);
      expect(Ist.wall(w.start).hour, 18);
      expect(Ist.wall(w.end).weekday, DateTime.saturday);
      expect(Ist.wall(w.end).hour, 18);
    });

    test('next window is announced correctly', () {
      final before = DateTime.utc(2026, 11, 16, 6);
      expect(FreeMockSchedule.next(before).start, fri);
      expect(FreeMockSchedule.next(fri.add(const Duration(hours: 30))).start, fri.add(const Duration(days: 14)));
    });

    test('only one free attempt per window', () async {
      final exam = examById('osd-a1')!;
      final now = fri.add(const Duration(hours: 2));
      final a = QuizEngine.create(exam, random: Random(2), now: now);
      expect(await MockAccess.pay(email, a, useFree: true, now: now), isNull);
      expect(a.wasFree, isTrue);
      final b = QuizEngine.create(exam, random: Random(3), now: now);
      expect(await MockAccess.pay(email, b, useFree: true, now: now), isNotNull);
      final later = fri.add(const Duration(days: 14, hours: 1));
      final c = QuizEngine.create(exam, random: Random(4), now: later);
      expect(await MockAccess.pay(email, c, useFree: true, now: later), isNull, reason: 'next window is free again');
    });

    test('paid mocks cost 100 coins and are refunded if the mock cannot start', () async {
      await Wallet.ensureWelcome(email);
      final a = QuizEngine.create(examById('goethe-a2')!, random: Random(5));
      expect(await MockAccess.pay(email, a, useFree: false), isNull);
      expect(await Wallet.balance(email), 0);
      await MockAccess.refund(email, a);
      expect(await Wallet.balance(email), Wallet.mockPrice);
    });
  });

  group('Daily question', () {
    final day = DateTime.utc(2026, 11, 16, 6); // 11:30 IST

    test('same question all day for the same learner (no re-rolling by refresh)', () async {
      final a = await DailyService.today(email, now: day);
      final b = await DailyService.today(email, now: day.add(const Duration(hours: 8)));
      expect(a.question.id, b.question.id);
      expect(a.order, b.order);
    });

    test('pays by difficulty when correct, 1 when wrong, and only once per day', () async {
      final q = await DailyService.today(email, now: day);
      final res = await DailyService.answer(email, q.question.answer, now: day);
      expect(res.coins, q.difficulty.reward);
      final again = await DailyService.answer(email, q.question.answer, now: day);
      expect(again.coins, q.difficulty.reward);
      expect(await Wallet.balance(email), q.difficulty.reward, reason: 'no double reward');

      final tomorrow = day.add(const Duration(days: 1));
      final t = await DailyService.today(email, now: tomorrow);
      final wrong = (t.question.answer + 1) % t.question.options.length;
      final r2 = await DailyService.answer(email, wrong, now: tomorrow);
      expect(r2.coins, Wallet.dailyWrong);
    });

    test('advanced pays 1/5 of a mock', () {
      expect(Difficulty.advanced.reward * 5, Wallet.mockPrice);
    });

    test('streak counts consecutive IST days', () async {
      for (var i = 0; i < 3; i++) {
        final d = day.subtract(Duration(days: i));
        final q = await DailyService.today(email, now: d);
        await DailyService.answer(email, q.question.answer, now: d);
      }
      expect(await DailyService.streak(email, now: day), 3);
      expect(await DailyService.streak(email, now: day.add(const Duration(days: 2))), 0);
    });
  });

  group('Mentor sessions', () {
    final now = DateTime.utc(2026, 11, 16, 6);

    test('slots are at least 24 h ahead and at the agreed IST times', () {
      final s = MentorService.slots(now: now);
      expect(s, isNotEmpty);
      for (final slot in s) {
        expect(slot.difference(now) >= const Duration(hours: 24), isTrue);
        final w = Ist.wall(slot);
        final weekend = w.weekday >= DateTime.saturday;
        expect(weekend ? [10, 11, 16, 17] : [19, 20, 21], contains(w.hour));
      }
    });

    test('needs 200 coins; booking spends them; cancelling refunds', () async {
      final slot = MentorService.slots(now: now).first;
      await Wallet.ensureWelcome(email); // 100
      expect(await MentorService.book(email, topic: MentorService.topics.first, slot: slot, now: now), isNotNull);
      await Wallet.add(email, CoinEntry(id: 'test', amount: 100, kind: 'daily', note: 't', at: now));
      expect(await MentorService.book(email, topic: MentorService.topics.first, slot: slot, now: now), isNull);
      expect(await Wallet.balance(email), 0);
      expect(await MentorService.book(email, topic: MentorService.topics.first, slot: slot, now: now), isNotNull,
          reason: 'no coins left / slot already booked');
      final b = (await MentorService.bookings(email)).single;
      expect(await MentorService.cancel(email, b.id, now: now), isNull);
      expect(await Wallet.balance(email), Wallet.mentorPrice);
      expect(await MentorService.cancel(email, b.id, now: now), isNotNull, reason: 'cannot refund twice');
    });
  });

  group('Profile', () {
    test('student ID is created once, has the right format and survives edits', () async {
      final p = await ProfileService.ensure(email);
      expect(ProfileService.idPattern.hasMatch(p.studentId), isTrue);
      p.city = 'Pune';
      p.goal = 'Ausbildung';
      await ProfileService.save(email, p);
      final again = await ProfileService.ensure(email);
      expect(again.studentId, p.studentId);
      expect(again.city, 'Pune');
      expect(again.goal, 'Ausbildung');
    });

    test('different learners get different IDs', () async {
      final a = await ProfileService.ensure('a@x.com');
      final b = await ProfileService.ensure('b@x.com');
      expect(a.studentId, isNot(b.studentId));
    });

    test('invalid values are rejected', () async {
      expect(ProfileService.validatePhone('abc'), isNotNull);
      expect(ProfileService.validatePhone('+91 98765 43210'), isNull);
      final p = await ProfileService.ensure(email);
      p.goal = 'Hacker';
      await ProfileService.save(email, p);
      expect((await ProfileService.ensure(email)).goal, '');
    });
  });

  group('Real exam results', () {
    test('auto-links to the latest mock of that exam before the exam date', () {
      final exam = examById('goethe-a1')!;
      final d = DateTime(2026, 12, 10);
      final old = QuizEngine.create(exam, random: Random(1))..submittedAt = DateTime(2026, 12, 1);
      final recent = QuizEngine.create(exam, random: Random(2))..submittedAt = DateTime(2026, 12, 8);
      final after = QuizEngine.create(exam, random: Random(3))..submittedAt = DateTime(2026, 12, 12);
      final other = QuizEngine.create(examById('goethe-b1')!, random: Random(4))..submittedAt = DateTime(2026, 12, 9);
      expect(RealResultService.autoLink([old, recent, after, other], exam.id, d)?.id, recent.id);
    });

    test('future dates and bad scores are rejected', () async {
      final now = DateTime(2026, 11, 16);
      expect(await RealResultService.add(email, examId: 'goethe-a1', date: now.add(const Duration(days: 2)), passed: true, now: now),
          isNotNull);
      expect(await RealResultService.add(email, examId: 'goethe-a1', date: now, passed: true, score: 120, now: now), isNotNull);
      expect(await RealResultService.add(email, examId: 'goethe-a1', date: now, passed: true, score: 72, now: now), isNull);
      expect((await RealResultService.all(email)).single.score, 72);
    });
  });
}
