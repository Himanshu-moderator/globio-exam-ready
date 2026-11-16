import '../../models/quiz.dart';

/// ÖSD Zertifikat A1 — question bank (30 items, Austrian settings).
const osdA1Questions = <Question>[
  // ── Vocabulary ──
  Question(
    id: 'oa1-v01', skill: Skill.vocabulary, topic: 'everyday',
    prompt: 'Ich bin müde. Ich gehe ins …',
    options: ['Bett', 'Kino', 'Büro', 'Restaurant'], answer: 0,
    explanation: 'müde = tired, so you go to bed: ins Bett.',
  ),
  Question(
    id: 'oa1-v02', skill: Skill.vocabulary, topic: 'dates',
    prompt: 'In Österreich sagt man oft „Jänner“. In Deutschland sagt man …',
    options: ['Januar', 'Juni', 'Juli', 'Februar'], answer: 0,
    explanation: '"Jänner" is the Austrian word for January (Januar). It can appear in ÖSD texts.',
  ),
  Question(
    id: 'oa1-v03', skill: Skill.vocabulary, topic: 'food_shopping',
    prompt: 'Was ist kein Getränk?',
    options: ['Brot', 'Tee', 'Saft', 'Milch'], answer: 0,
    explanation: 'Tee, Saft and Milch are drinks (Getränke). Brot (bread) is food.',
  ),
  Question(
    id: 'oa1-v04', skill: Skill.vocabulary, topic: 'family',
    prompt: 'Die Eltern von meinem Vater sind meine …',
    options: ['Großeltern', 'Geschwister', 'Kinder', 'Enkel'], answer: 0,
    explanation: 'Your father\'s parents are your grandparents: die Großeltern.',
  ),
  Question(
    id: 'oa1-v05', skill: Skill.vocabulary, topic: 'places',
    prompt: 'Ich brauche Medikamente. Ich gehe in die …',
    options: ['Apotheke', 'Bäckerei', 'Bank', 'Schule'], answer: 0,
    explanation: 'Medicine is sold at the pharmacy: die Apotheke.',
  ),
  Question(
    id: 'oa1-v06', skill: Skill.vocabulary, topic: 'phrases',
    prompt: 'Was sagt man in Österreich oft zur Begrüßung?',
    options: ['Grüß Gott!', 'Gute Nacht!', 'Tschüss!', 'Auf Wiederhören!'], answer: 0,
    explanation: '"Grüß Gott" is a common greeting in Austria. "Tschüss" and "Auf Wiederhören" are goodbyes.',
  ),
  Question(
    id: 'oa1-v07', skill: Skill.vocabulary, topic: 'numbers_time',
    prompt: 'Es ist 7:15 Uhr. Man sagt: Es ist Viertel nach …',
    options: ['sieben', 'acht', 'sechs', 'fünfzehn'], answer: 0,
    explanation: '7:15 = a quarter past seven: Viertel nach sieben.',
  ),
  Question(
    id: 'oa1-v08', skill: Skill.vocabulary, topic: 'adjectives',
    prompt: 'Im Winter ist es kalt. Im Sommer ist es …',
    options: ['warm', 'kalt', 'nass', 'dunkel'], answer: 0,
    explanation: 'The opposite of kalt (cold) is warm.',
  ),
  Question(
    id: 'oa1-v09', skill: Skill.vocabulary, topic: 'travel',
    prompt: 'Wo wartet man auf den Bus?',
    options: ['An der Haltestelle', 'Im Krankenhaus', 'An der Kasse', 'Im Hotel'], answer: 0,
    explanation: 'You wait for the bus at the stop: die Haltestelle.',
  ),
  Question(
    id: 'oa1-v10', skill: Skill.vocabulary, topic: 'numbers_time',
    prompt: 'Welche Zahl ist „siebenundvierzig“?',
    options: ['47', '74', '407', '17'], answer: 0,
    explanation: 'German says the ones first: sieben-und-vierzig = 7 + 40 = 47.',
  ),

  // ── Grammar ──
  Question(
    id: 'oa1-g01', skill: Skill.grammar, topic: 'conjugation',
    prompt: 'Wir ___ in Wien.',
    options: ['wohnen', 'wohnt', 'wohnst', 'wohne'], answer: 0,
    explanation: 'wir › -en: wir wohnen.',
  ),
  Question(
    id: 'oa1-g02', skill: Skill.grammar, topic: 'modal_verbs',
    prompt: '___ du Kaffee oder Tee?',
    options: ['Möchtest', 'Möchte', 'Möchten', 'Möchtet'], answer: 0,
    explanation: 'du › -st: du möchtest.',
  ),
  Question(
    id: 'oa1-g03', skill: Skill.grammar, topic: 'separable',
    prompt: 'Welcher Satz ist richtig?',
    options: [
      'Um 7 Uhr stehe ich auf.',
      'Um 7 Uhr ich stehe auf.',
      'Um 7 Uhr stehe auf ich.',
      'Um 7 Uhr ich aufstehe.',
    ], answer: 0,
    explanation: 'Verb in position 2, subject after it, and the prefix "auf" at the end.',
  ),
  Question(
    id: 'oa1-g04', skill: Skill.grammar, topic: 'accusative',
    prompt: 'Ich kaufe ___ Tisch.',
    options: ['einen', 'ein', 'eine', 'einer'], answer: 0,
    explanation: '"kaufen" takes the accusative; der Tisch is masculine › einen Tisch.',
  ),
  Question(
    id: 'oa1-g05', skill: Skill.grammar, topic: 'possessives',
    prompt: 'Das ist ___ Auto.',
    options: ['mein', 'meine', 'meinen', 'meiner'], answer: 0,
    explanation: 'das Auto is neuter, nominative: mein Auto (no ending).',
  ),
  Question(
    id: 'oa1-g06', skill: Skill.grammar, topic: 'questions',
    prompt: '___ kostet die Semmel? – 60 Cent.',
    options: ['Wie viel', 'Wie viele', 'Wann', 'Wo'], answer: 0,
    explanation: 'For a price you ask "Wie viel kostet …?". (Semmel = Austrian bread roll.)',
  ),
  Question(
    id: 'oa1-g07', skill: Skill.grammar, topic: 'prepositions',
    prompt: 'Ich fahre morgen ___ Salzburg.',
    options: ['nach', 'in', 'zu', 'aus'], answer: 0,
    explanation: 'Direction to a city or country: nach Salzburg.',
  ),
  Question(
    id: 'oa1-g08', skill: Skill.grammar, topic: 'prepositions',
    prompt: 'Der Film beginnt ___ 20 Uhr.',
    options: ['um', 'am', 'im', 'an'], answer: 0,
    explanation: 'Clock times take "um": um 20 Uhr.',
  ),
  Question(
    id: 'oa1-g09', skill: Skill.grammar, topic: 'negation',
    prompt: 'Hast du Kinder? – Nein, ich habe ___ Kinder.',
    options: ['keine', 'nicht', 'kein', 'nein'], answer: 0,
    explanation: 'Nouns are negated with "kein". Plural accusative: keine Kinder.',
  ),
  Question(
    id: 'oa1-g10', skill: Skill.grammar, topic: 'conjugation',
    prompt: 'Er ___ gern Fußball.',
    options: ['spielt', 'spielen', 'spielst', 'spiele'], answer: 0,
    explanation: 'er/sie/es › -t: er spielt.',
  ),

  // ── Reading ──
  Question.trueFalse(
    id: 'oa1-r01', topic: 'read_notices', passageLabel: 'Schild',
    passage: 'Apotheke am Ring\nÖffnungszeiten: Mo–Fr 8–18 Uhr, Sa 8–12 Uhr',
    prompt: 'Die Apotheke ist am Samstag den ganzen Tag offen.', isTrue: false,
    explanation: 'On Saturday it is open only 8–12 Uhr, not the whole day.',
  ),
  Question(
    id: 'oa1-r02', skill: Skill.reading, topic: 'read_messages', passageLabel: 'Nachricht',
    passage: 'Liebe Eva, ich komme heute später nach Hause, so um 21 Uhr. Das Essen ist im Kühlschrank. Bussi, Mama',
    prompt: 'Wann kommt die Mutter nach Hause?',
    options: ['Um 21 Uhr', 'Um 12 Uhr', 'Sie kommt heute nicht.'], answer: 0,
    explanation: '"so um 21 Uhr" — at about 9 pm. ("Bussi" is Austrian for a kiss.)',
  ),
  Question.trueFalse(
    id: 'oa1-r03', topic: 'read_ads', passageLabel: 'Anzeige',
    passage: 'Deutschkurs A1 in Graz – Montag und Mittwoch, 18–20 Uhr. 8 Wochen, 240 €. Anmeldung online.',
    prompt: 'Der Kurs ist zweimal pro Woche.', isTrue: true,
    explanation: 'Monday and Wednesday = twice a week.',
  ),
  Question.trueFalse(
    id: 'oa1-r04', topic: 'read_notices', passageLabel: 'Information im Hotel',
    passage: 'Frühstück gibt es von 7 bis 10 Uhr im Erdgeschoss. Am Sonntag bis 11 Uhr.',
    prompt: 'Am Sonntag kann man um 10:30 Uhr frühstücken.', isTrue: true,
    explanation: 'On Sunday breakfast is served until 11 Uhr, so 10:30 is fine.',
  ),
  Question(
    id: 'oa1-r05', skill: Skill.reading, topic: 'read_messages', passageLabel: 'E-Mail',
    passage: 'Sehr geehrter Herr Huber,\nIhr Termin beim Zahnarzt ist am Dienstag, 12. März, um 9:30 Uhr. Bitte bringen Sie Ihre e-card mit.',
    prompt: 'Was soll Herr Huber mitbringen?',
    options: ['Seine e-card', 'Geld', 'Ein Foto'], answer: 0,
    explanation: '"Bitte bringen Sie Ihre e-card mit." (The e-card is the Austrian health insurance card.)',
  ),
  Question.trueFalse(
    id: 'oa1-r06', topic: 'read_notices', passageLabel: 'Schild im Park',
    passage: 'Hunde bitte an die Leine! Radfahren verboten.',
    prompt: 'Man darf im Park Rad fahren.', isTrue: false,
    explanation: '"Radfahren verboten" — cycling is not allowed.',
  ),
  Question(
    id: 'oa1-r07', skill: Skill.reading, topic: 'read_messages', passageLabel: 'SMS',
    passage: 'Hi Max, das Fußballtraining ist heute nicht um 17 Uhr, sondern um 18 Uhr. Bring bitte Wasser mit! Jakob',
    prompt: 'Wann beginnt das Training heute?',
    options: ['Um 18 Uhr', 'Um 17 Uhr', 'Morgen'], answer: 0,
    explanation: '"nicht um 17 Uhr, sondern um 18 Uhr" — the new time is 18 Uhr.',
  ),
  Question.trueFalse(
    id: 'oa1-r08', topic: 'read_ads', passageLabel: 'Zimmeranzeige',
    passage: 'Zimmer frei in Wohngemeinschaft, Wien 7. Bezirk. 15 m², 420 € pro Monat. Nur für Nichtraucher.',
    prompt: 'Raucher können das Zimmer mieten.', isTrue: false,
    explanation: '"Nur für Nichtraucher" — only for non-smokers.',
  ),
  Question(
    id: 'oa1-r09', skill: Skill.reading, topic: 'read_notices', passageLabel: 'Durchsage im Bahnhof',
    passage: 'Achtung: Der Zug nach Linz fährt heute von Gleis 4, nicht von Gleis 2.',
    prompt: 'Von welchem Gleis fährt der Zug nach Linz?',
    options: ['Gleis 4', 'Gleis 2', 'Gleis 24'], answer: 0,
    explanation: 'Today the train leaves from platform 4, "nicht von Gleis 2".',
  ),
  Question.trueFalse(
    id: 'oa1-r10', topic: 'read_details', passageLabel: 'Preise im Schwimmbad',
    passage: 'Erwachsene 6 €, Kinder bis 14 Jahre 3 €.\nFamilienkarte (2 Erwachsene + Kinder): 14 €',
    prompt: 'Zwei Erwachsene und zwei Kinder bezahlen mit der Familienkarte 14 €.', isTrue: true,
    explanation: 'The family ticket covers 2 adults plus children for 14 €.',
  ),
];
