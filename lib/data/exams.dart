import '../models/quiz.dart';
import 'banks/goethe_a1.dart';
import 'banks/goethe_a2.dart';
import 'banks/goethe_b1.dart';
import 'banks/listening.dart';
import 'banks/osd_a1.dart';

/// The mock exams offered. Pass rules are taken from the official
/// Goethe-Institut India FAQ and the ÖSD Durchführungsbestimmungen ZA1.
const exams = <ExamInfo>[
  ExamInfo(
    id: 'goethe-a1',
    provider: 'Goethe-Institut',
    title: 'Goethe-Zertifikat A1',
    subtitle: 'Start Deutsch 1',
    level: 'A1',
    minutes: 20,
    perSkill: 4,
    passPct: 60,
    passRule: 'At least 60 of 100 points, and every part must be passed. '
        'A1 can only be retaken as a whole exam.',
    tips: [
      'The written part (listening, reading, writing) is 65 minutes with no break — practise a full timed paper at least once.',
      'Speaking is done in a small group with no preparation time: introduce yourself, ask and answer questions, make polite requests ("Können Sie bitte …?").',
      'In the writing task, answer every point the task asks for, even with one short sentence each.',
      'Because A1 is retaken as a whole, one weak skill can cost you the full fee again — fix weak areas before you book.',
    ],
    questions: [...goetheA1Questions, ...goetheA1Listening],
  ),
  ExamInfo(
    id: 'osd-a1',
    provider: 'ÖSD',
    title: 'ÖSD Zertifikat A1',
    subtitle: 'ZA1',
    level: 'A1',
    minutes: 20,
    perSkill: 4,
    passPct: 50,
    passRule: 'Two modules passed separately: written 38 of 75 points (plus a minimum in each part), '
        'oral 12 of 25. Each module can be retaken on its own.',
    tips: [
      'Texts come from Austria, Germany and Switzerland — expect Austrian words like Jänner (January), Semmel (bread roll) or Grüß Gott.',
      'Reading is 25 minutes for three tasks: matching situations to ads, Richtig/Falsch, and matching texts to pictures.',
      'Speaking is one-to-one after 10 minutes of preparation: a short introduction, a picture description and a role play.',
      'You must reach a minimum in reading, listening and writing, so don\'t skip any part.',
    ],
    questions: [...osdA1Questions, ...osdA1Listening],
  ),
  ExamInfo(
    id: 'goethe-a2',
    provider: 'Goethe-Institut',
    title: 'Goethe-Zertifikat A2',
    subtitle: 'A2',
    level: 'A2',
    minutes: 25,
    perSkill: 4,
    passPct: 60,
    passRule: 'At least 60 of 100 points in total, with at least 45 in the written exam and 15 in the oral exam.',
    tips: [
      'A2 texts are longer: read the question first, then look for the matching line in the text.',
      'Know the Perfekt well — haben or sein — it appears in reading, writing and speaking.',
      'In writing, use connectors like weil, dass and deshalb, and check the verb goes to the end after weil/dass.',
      'You need minimums in both written and oral parts, so practise speaking even if your reading is strong.',
    ],
    questions: [...goetheA2Questions, ...goetheA2Listening],
  ),
  ExamInfo(
    id: 'goethe-b1',
    provider: 'Goethe-Institut',
    title: 'Goethe-Zertifikat B1',
    subtitle: 'B1',
    level: 'B1',
    minutes: 30,
    perSkill: 4,
    passPct: 60,
    passRule: 'Modular exam: each module (reading, listening, writing, speaking) is passed with 60%. '
        'Modules can be taken and retaken separately.',
    tips: [
      'B1 answers are usually paraphrased — match meaning, not single words.',
      'Since each module needs 60%, plan extra time for your weakest module rather than equal time for all four.',
      'For writing and speaking, learn Redemittel: "Meiner Meinung nach …", "Einerseits … andererseits …", "Ich schlage vor, …".',
      'Practise full timed modules — timing is a separate skill from knowing German.',
    ],
    questions: [...goetheB1Questions, ...goetheB1Listening],
  ),
];

ExamInfo? examById(String id) {
  for (final e in exams) {
    if (e.id == id) return e;
  }
  return null;
}

Question? questionById(ExamInfo exam, String id) {
  for (final q in exam.questions) {
    if (q.id == id) return q;
  }
  return null;
}
