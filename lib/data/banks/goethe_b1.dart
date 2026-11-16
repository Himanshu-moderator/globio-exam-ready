import '../../models/quiz.dart';

/// Goethe-Zertifikat B1 — question bank (30 items).
const goetheB1Questions = <Question>[
  // ── Vocabulary ──
  Question(
    id: 'gb1-v01', skill: Skill.vocabulary, topic: 'work',
    prompt: 'Ich habe mich um die Stelle beworben. Jetzt warte ich auf eine Einladung zum …',
    options: ['Vorstellungsgespräch', 'Elternabend', 'Ausflug', 'Feierabend'], answer: 0,
    explanation: 'After applying (sich bewerben) you are invited to a job interview: das Vorstellungsgespräch.',
  ),
  Question(
    id: 'gb1-v02', skill: Skill.vocabulary, topic: 'work',
    prompt: 'Die Firma hat Probleme. Mein Arbeitgeber hat mir leider …',
    options: ['gekündigt', 'bestellt', 'verschrieben', 'erzählt'], answer: 0,
    explanation: '"jemandem kündigen" = to dismiss someone / end their contract.',
  ),
  Question(
    id: 'gb1-v03', skill: Skill.vocabulary, topic: 'formal',
    prompt: 'Welcher Ausdruck bedeutet ungefähr „sich entscheiden“?',
    options: ['einen Entschluss fassen', 'eine Ausrede finden', 'einen Termin verschieben', 'eine Meinung teilen'], answer: 0,
    explanation: '"einen Entschluss fassen" = to make a decision.',
  ),
  Question(
    id: 'gb1-v04', skill: Skill.vocabulary, topic: 'society',
    prompt: 'Viele Menschen trennen ihren Müll, weil sie die … schützen wollen.',
    options: ['Umwelt', 'Unterkunft', 'Umleitung', 'Unterschrift'], answer: 0,
    explanation: 'Separating rubbish protects the environment: die Umwelt.',
  ),
  Question(
    id: 'gb1-v05', skill: Skill.vocabulary, topic: 'housing',
    prompt: 'Die Miete ohne Heizung und Nebenkosten nennt man …',
    options: ['Kaltmiete', 'Warmmiete', 'Kaution', 'Rundfunkbeitrag'], answer: 0,
    explanation: 'Kaltmiete = rent without heating and extra costs. Warmmiete includes them.',
  ),
  Question(
    id: 'gb1-v06', skill: Skill.vocabulary, topic: 'formal',
    prompt: 'Er hat die Prüfung bestanden. Das bedeutet: Er hat sie …',
    options: ['geschafft', 'verschoben', 'abgesagt', 'wiederholt'], answer: 0,
    explanation: '"bestehen" (a test) = to pass it = "schaffen".',
  ),
  Question(
    id: 'gb1-v07', skill: Skill.vocabulary, topic: 'formal',
    prompt: 'Wie beendet man einen formellen Brief an eine Behörde?',
    options: ['Mit freundlichen Grüßen', 'Liebe Grüße und Küsse', 'Bis bald, dein …', 'Tschüss!'], answer: 0,
    explanation: 'Formal letters end with "Mit freundlichen Grüßen".',
  ),
  Question(
    id: 'gb1-v08', skill: Skill.vocabulary, topic: 'adjectives',
    prompt: 'Der Zug kommt nicht pünktlich, er ist …',
    options: ['verspätet', 'zuverlässig', 'geduldig', 'sofort'], answer: 0,
    explanation: 'Not on time = late: verspätet (or: Der Zug hat Verspätung).',
  ),
  Question(
    id: 'gb1-v09', skill: Skill.vocabulary, topic: 'formal',
    prompt: 'Sie möchten in der mündlichen Prüfung Ihre Meinung sagen. Was ist richtig?',
    options: ['Meiner Meinung nach …', 'Nach meiner Meinung nach …', 'Mit meiner Meinung …', 'Meine Meinung ist nach …'], answer: 0,
    explanation: 'The fixed phrase is "Meiner Meinung nach …" (or "Nach meiner Meinung …", but never "nach" twice).',
  ),
  Question(
    id: 'gb1-v10', skill: Skill.vocabulary, topic: 'society',
    prompt: 'Nach einem Umzug muss man sich in Deutschland beim Bürgeramt …',
    options: ['anmelden', 'bewerben', 'beschweren', 'entschuldigen'], answer: 0,
    explanation: 'You must register your new address: sich anmelden.',
  ),

  // ── Grammar ──
  Question(
    id: 'gb1-g01', skill: Skill.grammar, topic: 'relative',
    prompt: 'Das ist der Mann, ___ ich gestern geholfen habe.',
    options: ['dem', 'den', 'der', 'dessen'], answer: 0,
    explanation: '"helfen" takes the dative; der Mann (masculine) › relative pronoun "dem".',
  ),
  Question(
    id: 'gb1-g02', skill: Skill.grammar, topic: 'konjunktiv2',
    prompt: 'Wenn ich mehr Zeit ___, würde ich mehr reisen.',
    options: ['hätte', 'habe', 'hatte', 'würde'], answer: 0,
    explanation: 'Unreal condition › Konjunktiv II: hätte.',
  ),
  Question(
    id: 'gb1-g03', skill: Skill.grammar, topic: 'passive',
    prompt: 'Das Haus ___ im Jahr 1950 gebaut.',
    options: ['wurde', 'hat', 'würde', 'habe'], answer: 0,
    explanation: 'Passive in the past: wurde + Partizip II (gebaut).',
  ),
  Question(
    id: 'gb1-g04', skill: Skill.grammar, topic: 'connectors',
    prompt: '___ es regnet, gehen wir spazieren.',
    options: ['Obwohl', 'Trotzdem', 'Deshalb', 'Weil'], answer: 0,
    explanation: '"Obwohl" (although) starts a clause with the verb at the end. "Trotzdem" cannot start a clause like this.',
  ),
  Question(
    id: 'gb1-g05', skill: Skill.grammar, topic: 'genitive',
    prompt: 'Wegen ___ Wetters fällt das Spiel aus.',
    options: ['des schlechten', 'dem schlechten', 'das schlechte', 'der schlechten'], answer: 0,
    explanation: '"wegen" takes the genitive: das Wetter › des schlechten Wetters.',
  ),
  Question(
    id: 'gb1-g06', skill: Skill.grammar, topic: 'infinitive_zu',
    prompt: 'Ich habe keine Lust, heute …',
    options: ['einkaufen zu gehen.', 'zu einkaufen gehen.', 'einkaufen gehen zu.', 'zu gehen einkaufen.'], answer: 0,
    explanation: '"zu" comes right before the last infinitive: einkaufen zu gehen.',
  ),
  Question(
    id: 'gb1-g07', skill: Skill.grammar, topic: 'tenses',
    prompt: 'Nachdem er gegessen ___, ging er schlafen.',
    options: ['hatte', 'hat', 'war', 'ist'], answer: 0,
    explanation: '"nachdem" + Plusquamperfekt. "essen" uses haben › er hatte gegessen.',
  ),
  Question(
    id: 'gb1-g08', skill: Skill.grammar, topic: 'adjective_endings',
    prompt: 'Ich wünsche mir ein ___ Auto.',
    options: ['neues', 'neue', 'neuen', 'neuer'], answer: 0,
    explanation: 'das Auto (neuter), accusative after "ein": ein neues Auto.',
  ),
  Question(
    id: 'gb1-g09', skill: Skill.grammar, topic: 'verb_prep',
    prompt: 'Ich warte schon seit zehn Minuten ___ den Bus.',
    options: ['auf', 'für', 'an', 'nach'], answer: 0,
    explanation: 'The fixed combination is "warten auf" + accusative.',
  ),
  Question(
    id: 'gb1-g10', skill: Skill.grammar, topic: 'indirect_questions',
    prompt: 'Können Sie mir sagen, ___ der Zug nach Köln abfährt?',
    options: ['wann', 'dass', 'wenn', 'als'], answer: 0,
    explanation: 'An indirect question keeps the question word: … wann der Zug abfährt.',
  ),

  // ── Reading ──
  Question(
    id: 'gb1-r01', skill: Skill.reading, topic: 'read_gist', passageLabel: 'Forumsbeitrag',
    passage: 'Ich wohne seit einem Jahr in München und arbeite als Pflegekraft. Am Anfang war es schwer, weil die Kollegen sehr schnell gesprochen haben. Inzwischen verstehe ich fast alles. Was mir immer noch fehlt, sind Freunde außerhalb der Arbeit. – Priya',
    prompt: 'Was ist für Priya noch ein Problem?',
    options: ['Sie hat wenige Freunde außerhalb der Arbeit.', 'Sie versteht ihre Kollegen nicht.', 'Sie findet keine Arbeit.'], answer: 0,
    explanation: '"Inzwischen verstehe ich fast alles" — understanding is fine now. What is still missing: friends outside work.',
  ),
  Question.trueFalse(
    id: 'gb1-r02', topic: 'read_notices', passageLabel: 'Mitteilung',
    passage: 'Ab dem 1. Oktober gelten neue Regeln im Bürgeramt: Termine nur noch nach Online-Reservierung. Spontane Besuche sind leider nicht mehr möglich.',
    prompt: 'Ab Oktober kann man ohne Termin zum Bürgeramt gehen.', isTrue: false,
    explanation: 'Spontaneous visits are no longer possible — you need an online appointment.',
  ),
  Question(
    id: 'gb1-r03', skill: Skill.reading, topic: 'read_gist', passageLabel: 'Zeitungsartikel',
    passage: 'Immer mehr Menschen arbeiten im Homeoffice. Viele sparen dadurch Zeit, weil der Weg zur Arbeit wegfällt. Andere vermissen jedoch den Kontakt zu ihren Kollegen und fühlen sich manchmal einsam.',
    prompt: 'Welche Aussage passt zum Text?',
    options: ['Homeoffice hat Vorteile und Nachteile.', 'Alle Menschen arbeiten gern zu Hause.', 'Im Homeoffice braucht man mehr Zeit für den Arbeitsweg.'], answer: 0,
    explanation: 'Some save time (advantage), others feel lonely (disadvantage) — "jedoch" signals the contrast.',
  ),
  Question(
    id: 'gb1-r04', skill: Skill.reading, topic: 'read_messages', passageLabel: 'E-Mail',
    passage: 'Sehr geehrter Herr Fischer,\nleider muss ich unseren Termin am Mittwoch absagen, da ich kurzfristig eine Dienstreise nach Hamburg antreten muss. Wäre Ihnen der kommende Montag recht?\nMit freundlichen Grüßen\nLaura Becker',
    prompt: 'Warum sagt Frau Becker den Termin ab?',
    options: ['Sie muss beruflich verreisen.', 'Sie ist krank.', 'Sie hat den Termin vergessen.'], answer: 0,
    explanation: '"Dienstreise" = business trip. The reason comes after "da".',
  ),
  Question.trueFalse(
    id: 'gb1-r05', topic: 'read_ads', passageLabel: 'Aushang',
    passage: 'Sprachcafé jeden Donnerstag ab 19 Uhr in der Stadtbücherei: Hier treffen sich Muttersprachler und Deutschlernende zum Gespräch. Die Teilnahme ist kostenlos, eine Anmeldung ist nicht nötig.',
    prompt: 'Man kann ohne Anmeldung und kostenlos am Sprachcafé teilnehmen.', isTrue: true,
    explanation: '"Die Teilnahme ist kostenlos, eine Anmeldung ist nicht nötig" — free, and no registration needed.',
  ),
  Question(
    id: 'gb1-r06', skill: Skill.reading, topic: 'read_gist', passageLabel: 'Text',
    passage: 'Herr Müller hat sich ein E-Bike gekauft. Seitdem fährt er jeden Tag mit dem Rad zur Arbeit, statt mit dem Auto im Stau zu stehen. Er sagt, er fühle sich fitter und komme entspannter im Büro an.',
    prompt: 'Warum ist Herr Müller zufrieden?',
    options: ['Er ist fitter und weniger gestresst.', 'Er arbeitet jetzt von zu Hause.', 'Er fährt jetzt mit dem Auto ins Büro.'], answer: 0,
    explanation: '"fitter" and "entspannter" (more relaxed) — he is fitter and less stressed.',
  ),
  Question.trueFalse(
    id: 'gb1-r07', topic: 'read_details', passageLabel: 'Hausordnung',
    passage: 'Die Ruhezeiten sind von 22 bis 6 Uhr sowie sonntags ganztägig. Fahrräder dürfen nicht im Treppenhaus abgestellt werden.',
    prompt: 'Am Sonntagnachmittag darf man laut Musik hören.', isTrue: false,
    explanation: 'Quiet time applies "sonntags ganztägig" — all day on Sundays.',
  ),
  Question(
    id: 'gb1-r08', skill: Skill.reading, topic: 'read_details', passageLabel: 'Zeitungsmeldung',
    passage: 'Eine Studie zeigt: Wer regelmäßig liest, schläft besser. Besonders gedruckte Bücher helfen vor dem Einschlafen, weil man dabei nicht auf einen hellen Bildschirm schaut.',
    prompt: 'Warum hilft ein gedrucktes Buch beim Einschlafen?',
    options: ['Man schaut nicht auf einen hellen Bildschirm.', 'Gedruckte Bücher sind kürzer.', 'Man liest schneller.'], answer: 0,
    explanation: 'The reason follows "weil": you are not looking at a bright screen.',
  ),
  Question.trueFalse(
    id: 'gb1-r09', topic: 'read_messages', passageLabel: 'Rundmail',
    passage: 'Liebe Kolleginnen und Kollegen, unsere Weihnachtsfeier findet dieses Jahr nicht im Restaurant, sondern bei uns im Büro statt. Für Essen und Getränke ist gesorgt. Wer möchte, kann gern einen Nachtisch mitbringen.',
    prompt: 'Die Feier findet dieses Jahr im Büro statt, und das Essen wird organisiert.', isTrue: true,
    explanation: '"nicht im Restaurant, sondern bei uns im Büro" and "Für Essen und Getränke ist gesorgt" — food and drinks are provided.',
  ),
  Question.trueFalse(
    id: 'gb1-r10', topic: 'read_details', passageLabel: 'Information',
    passage: 'Wer in Deutschland wohnt und einen Führerschein aus einem Nicht-EU-Land hat, darf damit in der Regel sechs Monate lang fahren. Danach muss der Führerschein umgeschrieben werden.',
    prompt: 'Mit einem indischen Führerschein darf man in Deutschland unbegrenzt fahren.', isTrue: false,
    explanation: 'A non-EU licence is usually valid for six months only; after that it must be converted.',
  ),
];
