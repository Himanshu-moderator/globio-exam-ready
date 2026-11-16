/// Core quiz data types.
library;

enum Skill { vocabulary, grammar, reading }

extension SkillLabels on Skill {
  String get label => switch (this) {
        Skill.vocabulary => 'Vocabulary',
        Skill.grammar => 'Grammar',
        Skill.reading => 'Reading',
      };

  String get german => switch (this) {
        Skill.vocabulary => 'Wortschatz',
        Skill.grammar => 'Grammatik',
        Skill.reading => 'Lesen',
      };
}

/// One question in a bank. [answer] is the index of the correct option
/// in [options] as written (before any shuffling).
class Question {
  const Question({
    required this.id,
    required this.skill,
    required this.topic,
    required this.prompt,
    required this.options,
    required this.answer,
    required this.explanation,
    this.passage,
    this.passageLabel,
    this.shuffleOptions = true,
  });

  /// Richtig/Falsch item. Options stay in the order "Richtig, Falsch".
  const Question.trueFalse({
    required this.id,
    required this.topic,
    required this.prompt,
    required bool isTrue,
    required this.explanation,
    required String this.passage,
    required String this.passageLabel,
  })  : skill = Skill.reading,
        options = const ['Richtig', 'Falsch'],
        answer = isTrue ? 0 : 1,
        shuffleOptions = false;

  final String id;
  final Skill skill;

  /// Key into the topic guide (see `topics.dart`).
  final String topic;
  final String prompt;
  final List<String> options;
  final int answer;

  /// Short English explanation shown in the analysis.
  final String explanation;

  /// Reading text shown above the question (reading items only).
  final String? passage;

  /// What kind of text the passage is, e.g. "Notice", "Text message".
  final String? passageLabel;

  /// False for Richtig/Falsch, where a fixed order is clearer.
  final bool shuffleOptions;
}

/// A mock exam the learner can take.
class ExamInfo {
  const ExamInfo({
    required this.id,
    required this.provider,
    required this.title,
    required this.subtitle,
    required this.level,
    required this.minutes,
    required this.perSkill,
    required this.passPct,
    required this.passRule,
    required this.tips,
    required this.questions,
  });

  final String id;
  final String provider;
  final String title;
  final String subtitle;
  final String level;

  /// Time limit for this mock.
  final int minutes;

  /// Questions drawn per skill (3 skills › total = perSkill * 3).
  final int perSkill;

  /// Pass mark of the real exam in percent (Goethe 60, ÖSD A1 ≈ 50).
  /// Readiness is judged against this.
  final int passPct;

  /// How the real exam is passed (shown to the learner).
  final String passRule;

  /// Exam-specific tips for the analysis page.
  final List<String> tips;
  final List<Question> questions;

  int get totalQuestions => perSkill * Skill.values.length;
  String get fullName => '$title · $subtitle';
}
