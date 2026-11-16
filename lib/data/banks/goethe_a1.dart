import '../../models/quiz.dart';

/// Goethe-Zertifikat A1: Start Deutsch 1 — question bank (30 items).
const goetheA1Questions = <Question>[
  // ── Vocabulary ──
  Question(
    id: 'ga1-v01', skill: Skill.vocabulary, topic: 'family',
    prompt: 'Die Mutter von meiner Mutter ist meine …',
    options: ['Großmutter', 'Tante', 'Schwester', 'Tochter'], answer: 0,
    explanation: 'Your mother\'s mother is your grandmother: die Großmutter (Oma).',
  ),
  Question(
    id: 'ga1-v02', skill: Skill.vocabulary, topic: 'numbers_time',
    prompt: 'Das kostet 3,50 €. Wie sagt man das?',
    options: ['drei Euro fünfzig', 'dreißig Euro fünf', 'drei Euro fünfzehn', 'dreizehn Euro fünfzig'], answer: 0,
    explanation: '3,50 € is "drei Euro fünfzig" — euros first, then the cents.',
  ),
  Question(
    id: 'ga1-v03', skill: Skill.vocabulary, topic: 'numbers_time',
    prompt: 'Es ist 14:30 Uhr. Man sagt auch: Es ist halb …',
    options: ['drei', 'zwei', 'vierzehn', 'vier'], answer: 0,
    explanation: '"halb drei" means half an hour before three, so 2:30 / 14:30.',
  ),
  Question(
    id: 'ga1-v04', skill: Skill.vocabulary, topic: 'food_shopping',
    prompt: 'Welches Wort passt nicht in die Gruppe?',
    options: ['Stuhl', 'Apfel', 'Banane', 'Orange'], answer: 0,
    explanation: 'Apfel, Banane and Orange are fruit (Obst). A Stuhl (chair) is furniture.',
  ),
  Question(
    id: 'ga1-v05', skill: Skill.vocabulary, topic: 'everyday',
    prompt: 'Ich habe Durst. Ich möchte etwas …',
    options: ['trinken', 'essen', 'schlafen', 'lesen'], answer: 0,
    explanation: 'Durst = thirst, so you want to drink: trinken.',
  ),
  Question(
    id: 'ga1-v06', skill: Skill.vocabulary, topic: 'dates',
    prompt: 'Der Tag nach Montag ist …',
    options: ['Dienstag', 'Mittwoch', 'Sonntag', 'Donnerstag'], answer: 0,
    explanation: 'Montag › Dienstag › Mittwoch › Donnerstag › Freitag › Samstag › Sonntag.',
  ),
  Question(
    id: 'ga1-v07', skill: Skill.vocabulary, topic: 'places',
    prompt: 'Wo kauft man Brot?',
    options: ['In der Bäckerei', 'In der Apotheke', 'Im Kino', 'Auf der Post'], answer: 0,
    explanation: 'Bread is sold at the bakery: die Bäckerei. Medicine is at the Apotheke.',
  ),
  Question(
    id: 'ga1-v08', skill: Skill.vocabulary, topic: 'phrases',
    prompt: 'Sie treffen um 19 Uhr eine Freundin. Was sagen Sie?',
    options: ['Guten Abend!', 'Guten Morgen!', 'Gute Nacht!', 'Auf Wiedersehen!'], answer: 0,
    explanation: 'In the evening you greet with "Guten Abend". "Gute Nacht" is said when going to bed.',
  ),
  Question(
    id: 'ga1-v09', skill: Skill.vocabulary, topic: 'home',
    prompt: 'In welchem Raum kocht man?',
    options: ['In der Küche', 'Im Bad', 'Im Schlafzimmer', 'Im Flur'], answer: 0,
    explanation: 'You cook in the kitchen: die Küche.',
  ),
  Question(
    id: 'ga1-v10', skill: Skill.vocabulary, topic: 'health',
    prompt: 'Ich bin krank. Ich gehe zum …',
    options: ['Arzt', 'Bäcker', 'Friseur', 'Kellner'], answer: 0,
    explanation: 'When you are ill you go to the doctor: zum Arzt.',
  ),

  // ── Grammar ──
  Question(
    id: 'ga1-g01', skill: Skill.grammar, topic: 'conjugation',
    prompt: 'Morgen ___ ich nach Berlin.',
    options: ['fahre', 'fährst', 'fahren', 'fährt'], answer: 0,
    explanation: 'ich › -e: ich fahre. (du fährst, er fährt, wir fahren)',
  ),
  Question(
    id: 'ga1-g02', skill: Skill.grammar, topic: 'verb_position',
    prompt: 'Welcher Satz ist richtig?',
    options: [
      'Am Wochenende spiele ich Fußball.',
      'Am Wochenende ich spiele Fußball.',
      'Am Wochenende spiele Fußball ich.',
      'Spiele am Wochenende ich Fußball.',
    ], answer: 0,
    explanation: 'The verb must be in position 2. If the sentence starts with "Am Wochenende", the subject comes after the verb.',
  ),
  Question(
    id: 'ga1-g03', skill: Skill.grammar, topic: 'accusative',
    prompt: 'Ich habe ___ Bruder und zwei Schwestern.',
    options: ['einen', 'ein', 'eine', 'einem'], answer: 0,
    explanation: '"haben" takes the accusative. Bruder is masculine: ein › einen.',
  ),
  Question(
    id: 'ga1-g04', skill: Skill.grammar, topic: 'questions',
    prompt: '___ wohnst du? – In Hamburg.',
    options: ['Wo', 'Wer', 'Wann', 'Was'], answer: 0,
    explanation: 'The answer is a place, so the question word is "Wo" (where).',
  ),
  Question(
    id: 'ga1-g05', skill: Skill.grammar, topic: 'modal_verbs',
    prompt: 'Ich ___ heute nicht kommen. Ich bin krank.',
    options: ['kann', 'kannst', 'können', 'könnt'], answer: 0,
    explanation: 'Modal verbs have no ending with ich: ich kann. The infinitive (kommen) goes to the end.',
  ),
  Question(
    id: 'ga1-g06', skill: Skill.grammar, topic: 'separable',
    prompt: 'Welcher Satz ist richtig?',
    options: [
      'Der Zug fährt um 8 Uhr ab.',
      'Der Zug abfährt um 8 Uhr.',
      'Der Zug fährt ab um 8 Uhr.',
      'Der Zug um 8 Uhr abfährt.',
    ], answer: 0,
    explanation: '"abfahren" is separable: the verb is in position 2 and "ab" goes to the end.',
  ),
  Question(
    id: 'ga1-g07', skill: Skill.grammar, topic: 'possessives',
    prompt: 'Das ist Anna. ___ Mann heißt Peter.',
    options: ['Ihr', 'Sein', 'Ihre', 'Seine'], answer: 0,
    explanation: 'Anna\'s = her = ihr. "Mann" is masculine (nominative), so no ending: ihr Mann.',
  ),
  Question(
    id: 'ga1-g08', skill: Skill.grammar, topic: 'prepositions',
    prompt: 'Ich komme ___ Indien.',
    options: ['aus', 'von', 'in', 'nach'], answer: 0,
    explanation: 'Origin of a country: "aus". (Direction would be "nach".)',
  ),
  Question(
    id: 'ga1-g09', skill: Skill.grammar, topic: 'prepositions',
    prompt: 'Der Kurs beginnt ___ Montag.',
    options: ['am', 'im', 'um', 'in'], answer: 0,
    explanation: 'Days take "am": am Montag. Clock times take "um", months take "im".',
  ),
  Question(
    id: 'ga1-g10', skill: Skill.grammar, topic: 'conjugation',
    prompt: 'Wie alt ___ ihr?',
    options: ['seid', 'sind', 'bist', 'ist'], answer: 0,
    explanation: '"sein" with ihr is "seid": ihr seid. (wir/sie sind, du bist, er ist)',
  ),

  // ── Reading ──
  Question.trueFalse(
    id: 'ga1-r01', topic: 'read_notices', passageLabel: 'Schild an der Tür',
    passage: 'Praxis Dr. Weber\nSprechzeiten: Mo–Fr 8–12 Uhr\nMittwoch auch 15–18 Uhr\nSamstag geschlossen',
    prompt: 'Sie können am Mittwochnachmittag zum Arzt gehen.', isTrue: true,
    explanation: 'On Wednesday the practice is also open 15–18 Uhr, which is the afternoon.',
  ),
  Question(
    id: 'ga1-r02', skill: Skill.reading, topic: 'read_messages', passageLabel: 'SMS',
    passage: 'Hallo Jonas, ich bin heute leider krank und kann nicht ins Kino kommen. Gehen wir am Freitag? Liebe Grüße, Mia',
    prompt: 'Warum schreibt Mia?',
    options: ['Sie kann heute nicht ins Kino.', 'Sie möchte heute ins Kino gehen.', 'Sie hat am Freitag keine Zeit.'], answer: 0,
    explanation: 'Mia is ill ("leider krank") and cancels today. She suggests Friday instead.',
  ),
  Question(
    id: 'ga1-r03', skill: Skill.reading, topic: 'read_ads', passageLabel: 'Anzeige',
    passage: 'Fahrrad zu verkaufen! 2 Jahre alt, sehr guter Zustand, nur 120 €.\nTel. 0171 2345678 (ab 18 Uhr)',
    prompt: 'Wann kann man anrufen?',
    options: ['Am Abend ab 18 Uhr', 'Nur am Vormittag', 'Den ganzen Tag'], answer: 0,
    explanation: '"ab 18 Uhr" means from 6 pm onwards.',
  ),
  Question.trueFalse(
    id: 'ga1-r04', topic: 'read_notices', passageLabel: 'Aushang im Supermarkt',
    passage: 'Liebe Kunden, am 24. Dezember ist unser Markt nur bis 14 Uhr geöffnet.',
    prompt: 'Am 24. Dezember kann man am Abend im Markt einkaufen.', isTrue: false,
    explanation: 'The shop is open "nur bis 14 Uhr" — only until 2 pm, so not in the evening.',
  ),
  Question(
    id: 'ga1-r05', skill: Skill.reading, topic: 'read_messages', passageLabel: 'E-Mail',
    passage: 'Liebe Frau Schmidt,\nder Deutschkurs am Dienstag fällt leider aus. Wir machen am Donnerstag um 18 Uhr weiter.\nViele Grüße\nThomas Berg, Sprachschule',
    prompt: 'Wann ist der nächste Kurs?',
    options: ['Am Donnerstag um 18 Uhr', 'Am Dienstag um 18 Uhr', 'Am Donnerstag um 8 Uhr'], answer: 0,
    explanation: 'Tuesday is cancelled ("fällt aus"); the course continues on Thursday at 18 Uhr.',
  ),
  Question.trueFalse(
    id: 'ga1-r06', topic: 'read_notices', passageLabel: 'Schild im Bahnhof',
    passage: 'Zu den Gleisen 1–5 bitte die Treppe benutzen. Aufzug außer Betrieb.',
    prompt: 'Sie können den Aufzug benutzen.', isTrue: false,
    explanation: '"außer Betrieb" means out of order, so you cannot use the lift.',
  ),
  Question(
    id: 'ga1-r07', skill: Skill.reading, topic: 'read_details', passageLabel: 'Information',
    passage: 'Stadtbibliothek: Bücher kann man drei Wochen ausleihen. Die Ausleihe ist kostenlos. Für DVDs bezahlen Sie 1 € pro Woche.',
    prompt: 'Was kostet Geld?',
    options: ['DVDs ausleihen', 'Bücher ausleihen', 'In der Bibliothek lesen'], answer: 0,
    explanation: 'Books are free ("kostenlos"); DVDs cost 1 € per week.',
  ),
  Question(
    id: 'ga1-r08', skill: Skill.reading, topic: 'read_messages', passageLabel: 'Nachricht',
    passage: 'Hi Lena! Die Party ist am Samstag bei mir, nicht bei Tom. Kannst du einen Salat mitbringen? Bis dann, Sara',
    prompt: 'Wo ist die Party?',
    options: ['Bei Sara', 'Bei Tom', 'Bei Lena'], answer: 0,
    explanation: 'Sara writes "bei mir, nicht bei Tom" — the party is at Sara\'s place.',
  ),
  Question.trueFalse(
    id: 'ga1-r09', topic: 'read_ads', passageLabel: 'Wohnungsanzeige',
    passage: 'Wohnung in Köln: 2 Zimmer, Küche, Bad, Balkon. 650 € warm. Ab 1. März frei.',
    prompt: 'Die Wohnung hat einen Balkon.', isTrue: true,
    explanation: 'The ad lists "Balkon".',
  ),
  Question.trueFalse(
    id: 'ga1-r10', topic: 'read_notices', passageLabel: 'Schild am Museum',
    passage: 'Montags geschlossen. Dienstag bis Sonntag 10–18 Uhr.\nKinder unter 6 Jahren: Eintritt frei.',
    prompt: 'Ein Kind mit 4 Jahren muss nichts bezahlen.', isTrue: true,
    explanation: 'Children under 6 enter free ("Eintritt frei"), so a 4-year-old pays nothing.',
  ),
];
