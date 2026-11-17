import '../data/exams.dart';
import '../data/topics.dart';
import '../models/attempt.dart';
import '../models/quiz.dart';

/// How "ready" is decided.
///
/// 1. Each skill (listening, reading, grammar, vocabulary) gets a percentage.
/// 2. Readiness score = 60% × overall score + 40% × weakest skill.
///    The weakest skill weighs heavily because real exams fail you on a
///    weak part even when the total looks fine (Goethe A1: every part must
///    be passed; B1: every module needs 60%; ÖSD: minimums per part).
/// 3. Verdict, judged against the real exam's pass mark (P):
///    • Ready to book   — overall ≥ P + 15 and every skill ≥ P
///    • Almost ready    — overall ≥ P and every skill ≥ P − 20
///    • Not ready yet   — anything below that
///    The +15 safety margin exists because a 16-question check is shorter
///    and calmer than the real exam (nerves, timing, writing, speaking).
/// 4. Precision: with 4 questions per skill one answer moves a skill by 25
///    points, so the result also says
///    • whether it is a close call (one answer would change the verdict), and
///    • what the last two mocks of the same exam say together (32 questions),
///      which is what "confirmed" means.
class Readiness {
  Readiness._();

  static const readyMargin = 15;
  static const almostBand = 20;
  static const overallWeight = 0.6;
  static const weakestWeight = 0.4;
  static const maxFocusAreas = 3;

  static AttemptResult evaluate(ExamInfo exam, Attempt attempt) {
    final reviews = <QuestionReview>[];
    for (final item in attempt.items) {
      final q = questionById(exam, item.questionId);
      if (q == null) continue; // unknown id (old or tampered data): skip safely
      final validOrder = item.order.length == q.options.length &&
          item.order.toSet().length == q.options.length &&
          item.order.every((i) => i >= 0 && i < q.options.length);
      final order = validOrder ? item.order : List<int>.generate(q.options.length, (i) => i);
      final chosen = (item.chosen != null && item.chosen! >= 0 && item.chosen! < q.options.length)
          ? item.chosen
          : null;
      reviews.add(QuestionReview(
        question: q,
        order: order,
        chosen: chosen,
        isCorrect: chosen == q.answer,
      ));
    }

    final skills = <Skill, SkillScore>{
      for (final s in Skill.values)
        s: SkillScore(
          skill: s,
          correct: reviews.where((r) => r.question.skill == s && r.isCorrect).length,
          total: reviews.where((r) => r.question.skill == s).length,
        ),
    };
    final scored = skills.values.where((s) => s.total > 0).toList();
    final correct = reviews.where((r) => r.isCorrect).length;
    final total = reviews.length;
    final overall = total == 0 ? 0 : (correct * 100 / total).round();
    final weakest = scored.isEmpty ? 0 : scored.map((s) => s.pct).reduce((a, b) => a < b ? a : b);
    final readinessScore = (overallWeight * overall + weakestWeight * weakest).round();

    final p = exam.passPct;
    final verdict = verdictFor(overall, weakest, p);
    final borderline = _isCloseCall(skills, verdict, p);

    // Focus areas: topics with the most mistakes, weakest skill first on ties.
    final misses = <String, int>{};
    final topicSkill = <String, Skill>{};
    for (final r in reviews.where((r) => !r.isCorrect)) {
      misses[r.question.topic] = (misses[r.question.topic] ?? 0) + 1;
      topicSkill[r.question.topic] = r.question.skill;
    }
    final topics = misses.keys.where(topicGuides.containsKey).toList()
      ..sort((a, b) {
        final byMisses = misses[b]!.compareTo(misses[a]!);
        if (byMisses != 0) return byMisses;
        return skills[topicSkill[a]]!.pct.compareTo(skills[topicSkill[b]]!.pct);
      });
    // Cover every skill that is below "strong" first (one topic each, weakest
    // skill first), then fill the remaining slots by number of mistakes.
    final picked = <String>[];
    final weakSkills = skills.values
        .where((s) => s.total > 0 && s.pct < p + readyMargin)
        .toList()
      ..sort((a, b) => a.pct.compareTo(b.pct));
    for (final s in weakSkills) {
      final t = topics.where((t) => topicSkill[t] == s.skill && !picked.contains(t));
      if (t.isNotEmpty && picked.length < maxFocusAreas) picked.add(t.first);
    }
    for (final t in topics) {
      if (picked.length >= maxFocusAreas) break;
      if (!picked.contains(t)) picked.add(t);
    }
    final focus = picked
        .map((t) => FocusArea(
              topicId: t,
              guide: topicGuides[t]!,
              misses: misses[t]!,
              skill: topicSkill[t]!,
            ))
        .toList();

    return AttemptResult(
      exam: exam,
      attempt: attempt,
      correct: correct,
      total: total,
      overallPct: overall,
      weakestPct: weakest,
      readinessScore: readinessScore,
      verdict: verdict,
      skills: skills,
      focusAreas: focus,
      reviews: reviews,
      isCloseCall: borderline,
    );
  }

  /// The verdict rule on its own (P = the real exam's pass mark).
  static Verdict verdictFor(int overallPct, int weakestPct, int p) {
    if (overallPct >= p + readyMargin && weakestPct >= p) return Verdict.ready;
    if (overallPct >= p && weakestPct >= p - almostBand) return Verdict.almost;
    return Verdict.notYet;
  }

  static Verdict _verdictOf(Map<Skill, SkillScore> skills, int p) {
    final scored = skills.values.where((s) => s.total > 0).toList();
    final total = scored.fold<int>(0, (n, s) => n + s.total);
    final correct = scored.fold<int>(0, (n, s) => n + s.correct);
    if (total == 0) return Verdict.notYet;
    final overall = (correct * 100 / total).round();
    final weakest = scored.map((s) => s.pct).reduce((a, b) => a < b ? a : b);
    return verdictFor(overall, weakest, p);
  }

  /// True if getting any single question right instead of wrong (or wrong
  /// instead of right) would change the verdict.
  static bool _isCloseCall(Map<Skill, SkillScore> skills, Verdict verdict, int p) {
    for (final s in skills.values.where((s) => s.total > 0)) {
      for (final delta in const [1, -1]) {
        final c = s.correct + delta;
        if (c < 0 || c > s.total) continue;
        final changed = {...skills, s.skill: SkillScore(skill: s.skill, correct: c, total: s.total)};
        if (_verdictOf(changed, p) != verdict) return true;
      }
    }
    return false;
  }

  /// How much to trust a result: pools [current] with the learner's
  /// previous finished mock of the same exam (if any) and compares.
  static Confidence confidence(AttemptResult current, List<Attempt> history) {
    final exam = current.exam;
    final at = current.attempt.submittedAt;
    final previous = history
        .where((a) =>
            a.examId == exam.id &&
            a.id != current.attempt.id &&
            a.isFinished &&
            (at == null || !a.submittedAt!.isAfter(at)))
        .toList()
      ..sort((a, b) => b.submittedAt!.compareTo(a.submittedAt!));
    if (previous.isEmpty) {
      return Confidence(
        level: current.isCloseCall ? ConfidenceLevel.closeCall : ConfidenceLevel.singleMock,
        mocks: 1,
        questions: current.total,
        verdict: current.verdict,
      );
    }
    final prev = evaluate(exam, previous.first);
    final pooled = <Skill, SkillScore>{
      for (final s in Skill.values)
        s: SkillScore(
          skill: s,
          correct: current.skills[s]!.correct + prev.skills[s]!.correct,
          total: current.skills[s]!.total + prev.skills[s]!.total,
        ),
    };
    final v = _verdictOf(pooled, exam.passPct);
    return Confidence(
      level: v == current.verdict ? ConfidenceLevel.confirmed : ConfidenceLevel.mixed,
      mocks: 2,
      questions: current.total + prev.total,
      verdict: v,
      pooledSkills: pooled,
    );
  }

  static SkillStatus skillStatus(int pct, int passPct) {
    if (pct >= passPct + readyMargin) return SkillStatus.strong;
    if (pct >= passPct) return SkillStatus.borderline;
    return SkillStatus.weak;
  }
}

enum Verdict { ready, almost, notYet }

enum ConfidenceLevel {
  /// The last two mocks together give the same verdict.
  confirmed,

  /// The last two mocks together give a different verdict — still moving.
  mixed,

  /// Only one mock so far, and the verdict is not a close call.
  singleMock,

  /// Only one mock, and a single answer would change the verdict.
  closeCall,
}

class Confidence {
  const Confidence({
    required this.level,
    required this.mocks,
    required this.questions,
    required this.verdict,
    this.pooledSkills,
  });
  final ConfidenceLevel level;

  /// How many mocks the statement is based on (1 or 2).
  final int mocks;
  final int questions;

  /// Verdict over all [mocks] together.
  final Verdict verdict;
  final Map<Skill, SkillScore>? pooledSkills;

  String get title => switch (level) {
        ConfidenceLevel.confirmed => 'Confirmed by your last 2 mocks',
        ConfidenceLevel.mixed => 'Your last 2 mocks disagree',
        ConfidenceLevel.singleMock => 'Based on 1 mock',
        ConfidenceLevel.closeCall => 'Close call',
      };

  String get message => switch (level) {
        ConfidenceLevel.confirmed =>
          'Together, your last 2 mocks ($questions questions) say the same: ${verdict.title.toLowerCase()}. This is a reliable result.',
        ConfidenceLevel.mixed =>
          'Together, your last 2 mocks ($questions questions) say: ${verdict.title.toLowerCase()}. Your level is still moving — take one more mock before you decide.',
        ConfidenceLevel.singleMock =>
          'This verdict comes from $questions questions. Take one more mock of this exam to confirm it — two mocks together are far more reliable than one.',
        ConfidenceLevel.closeCall =>
          'One answer more or less would change this verdict. Treat it as a close call and confirm it with another mock before you book.',
      };
}

extension VerdictText on Verdict {
  String get title => switch (this) {
        Verdict.ready => 'Ready to book',
        Verdict.almost => 'Almost ready',
        Verdict.notYet => 'Not ready yet',
      };

  String get message => switch (this) {
        Verdict.ready => 'You are comfortably above the pass mark in every skill. Book your exam and keep practising writing and speaking — this mock does not test them.',
        Verdict.almost => 'You are around the pass mark. Fix the focus areas below and take another mock before you book.',
        Verdict.notYet => 'Booking now risks losing your exam fee. Work on the focus areas below first, then take another mock.',
      };
}

enum SkillStatus { strong, borderline, weak }

extension SkillStatusText on SkillStatus {
  String get label => switch (this) {
        SkillStatus.strong => 'Strong',
        SkillStatus.borderline => 'Borderline',
        SkillStatus.weak => 'Needs work',
      };
}

class SkillScore {
  const SkillScore({required this.skill, required this.correct, required this.total});
  final Skill skill;
  final int correct;
  final int total;
  int get pct => total == 0 ? 0 : (correct * 100 / total).round();
}

class QuestionReview {
  const QuestionReview({
    required this.question,
    required this.order,
    required this.chosen,
    required this.isCorrect,
  });
  final Question question;
  final List<int> order;

  /// Original option index picked, or null if unanswered.
  final int? chosen;
  final bool isCorrect;

  bool get unanswered => chosen == null;
}

class FocusArea {
  const FocusArea({
    required this.topicId,
    required this.guide,
    required this.misses,
    required this.skill,
  });
  final String topicId;
  final TopicGuide guide;
  final int misses;
  final Skill skill;
}

class AttemptResult {
  const AttemptResult({
    required this.exam,
    required this.attempt,
    required this.correct,
    required this.total,
    required this.overallPct,
    required this.weakestPct,
    required this.readinessScore,
    required this.verdict,
    required this.skills,
    required this.focusAreas,
    required this.reviews,
    this.isCloseCall = false,
  });

  final ExamInfo exam;
  final Attempt attempt;
  final int correct;
  final int total;
  final int overallPct;
  final int weakestPct;
  final int readinessScore;
  final Verdict verdict;
  final Map<Skill, SkillScore> skills;
  final List<FocusArea> focusAreas;
  final List<QuestionReview> reviews;

  /// True if a single answer would change [verdict].
  final bool isCloseCall;

  bool get passedMock => overallPct >= exam.passPct;
}
