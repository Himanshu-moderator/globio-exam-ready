import '../../models/quiz.dart';

/// Goethe-Zertifikat A2 — question bank (30 items).
const goetheA2Questions = <Question>[
  // ── Vocabulary ──
  Question(
    id: 'ga2-v01', skill: Skill.vocabulary, topic: 'health',
    prompt: 'Ich habe mir den Arm gebrochen. Ich muss ins …',
    options: ['Krankenhaus', 'Rathaus', 'Kaufhaus', 'Reisebüro'], answer: 0,
    explanation: 'A broken arm is treated in hospital: das Krankenhaus.',
  ),
  Question(
    id: 'ga2-v02', skill: Skill.vocabulary, topic: 'work',
    prompt: 'Mein Chef ist sehr nett, und meine … im Büro sind auch freundlich.',
    options: ['Kollegen', 'Geschwister', 'Großeltern', 'Patienten'], answer: 0,
    explanation: 'The people you work with are your colleagues: die Kollegen.',
  ),
  Question(
    id: 'ga2-v03', skill: Skill.vocabulary, topic: 'housing',
    prompt: 'Wenn man eine Wohnung mietet, unterschreibt man einen …',
    options: ['Mietvertrag', 'Führerschein', 'Fahrplan', 'Reisepass'], answer: 0,
    explanation: 'Renting a flat means signing a lease: der Mietvertrag.',
  ),
  Question(
    id: 'ga2-v04', skill: Skill.vocabulary, topic: 'places',
    prompt: 'Ich möchte Bargeld von meinem Konto holen. Ich gehe zum …',
    options: ['Geldautomaten', 'Briefkasten', 'Kühlschrank', 'Spielplatz'], answer: 0,
    explanation: 'Cash comes from the cash machine: der Geldautomat.',
  ),
  Question(
    id: 'ga2-v05', skill: Skill.vocabulary, topic: 'adjectives',
    prompt: 'Das Gegenteil von „billig“ ist …',
    options: ['teuer', 'günstig', 'kurz', 'leer'], answer: 0,
    explanation: 'billig (cheap) vs. teuer (expensive). "günstig" means almost the same as billig.',
  ),
  Question(
    id: 'ga2-v06', skill: Skill.vocabulary, topic: 'travel',
    prompt: 'Für die Reise in manche Länder braucht man ein …',
    options: ['Visum', 'Rezept', 'Gehalt', 'Gewitter'], answer: 0,
    explanation: 'Some countries require a visa: das Visum.',
  ),
  Question(
    id: 'ga2-v07', skill: Skill.vocabulary, topic: 'adjectives',
    prompt: 'Es regnet und es ist windig. Das Wetter ist …',
    options: ['schlecht', 'sonnig', 'heiß', 'wolkenlos'], answer: 0,
    explanation: 'Rain and wind = bad weather: schlecht.',
  ),
  Question(
    id: 'ga2-v08', skill: Skill.vocabulary, topic: 'work',
    prompt: 'Ich suche eine neue Arbeit. Deshalb lese ich die …',
    options: ['Stellenanzeigen', 'Speisekarte', 'Wettervorhersage', 'Gebrauchsanweisung'], answer: 0,
    explanation: 'Job ads are "Stellenanzeigen".',
  ),
  Question(
    id: 'ga2-v09', skill: Skill.vocabulary, topic: 'food_shopping',
    prompt: 'Im Restaurant: „Die Rechnung, bitte. Ich möchte …“',
    options: ['bezahlen', 'bestellen', 'reservieren', 'kochen'], answer: 0,
    explanation: 'Asking for the bill (die Rechnung) means you want to pay: bezahlen.',
  ),
  Question(
    id: 'ga2-v10', skill: Skill.vocabulary, topic: 'health',
    prompt: 'Wenn man Fieber hat, misst man die Temperatur mit einem …',
    options: ['Thermometer', 'Kalender', 'Wecker', 'Lineal'], answer: 0,
    explanation: 'Temperature is measured with a thermometer: das Thermometer.',
  ),

  // ── Grammar ──
  Question(
    id: 'ga2-g01', skill: Skill.grammar, topic: 'perfekt',
    prompt: 'Gestern ___ ich ins Kino gegangen.',
    options: ['bin', 'habe', 'war', 'hat'], answer: 0,
    explanation: '"gehen" is movement, so the Perfekt uses "sein": ich bin gegangen.',
  ),
  Question(
    id: 'ga2-g02', skill: Skill.grammar, topic: 'perfekt',
    prompt: 'Ich ___ am Wochenende viel gearbeitet.',
    options: ['habe', 'bin', 'werde', 'wird'], answer: 0,
    explanation: '"arbeiten" is not movement, so the Perfekt uses "haben": ich habe gearbeitet.',
  ),
  Question(
    id: 'ga2-g03', skill: Skill.grammar, topic: 'dative',
    prompt: 'Ich helfe ___ Mann.',
    options: ['dem', 'den', 'der', 'das'], answer: 0,
    explanation: '"helfen" takes the dative. der Mann › dem Mann.',
  ),
  Question(
    id: 'ga2-g04', skill: Skill.grammar, topic: 'subordinate',
    prompt: 'Welcher Satz ist richtig?',
    options: [
      'Ich komme nicht, weil ich krank bin.',
      'Ich komme nicht, weil ich bin krank.',
      'Ich komme nicht, weil bin ich krank.',
      'Ich komme nicht, weil krank ich bin.',
    ], answer: 0,
    explanation: 'After "weil" the conjugated verb goes to the end: … weil ich krank bin.',
  ),
  Question(
    id: 'ga2-g05', skill: Skill.grammar, topic: 'comparison',
    prompt: 'Berlin ist ___ als München.',
    options: ['größer', 'groß', 'am größten', 'größte'], answer: 0,
    explanation: 'Comparative + als: groß › größer als.',
  ),
  Question(
    id: 'ga2-g06', skill: Skill.grammar, topic: 'praeteritum',
    prompt: 'Als Kind ___ ich nicht schwimmen.',
    options: ['konnte', 'kann', 'gekonnt', 'könnte'], answer: 0,
    explanation: 'Past of "können" (Präteritum): ich konnte. "könnte" is Konjunktiv II.',
  ),
  Question(
    id: 'ga2-g07', skill: Skill.grammar, topic: 'two_way_prep',
    prompt: 'Ich lege das Buch auf ___ Tisch.',
    options: ['den', 'dem', 'der', 'des'], answer: 0,
    explanation: '"legen" shows movement (Wohin?), so "auf" takes the accusative: auf den Tisch.',
  ),
  Question(
    id: 'ga2-g08', skill: Skill.grammar, topic: 'reflexive',
    prompt: 'Ich freue ___ auf den Urlaub.',
    options: ['mich', 'mir', 'sich', 'dich'], answer: 0,
    explanation: 'sich freuen auf: ich freue mich.',
  ),
  Question(
    id: 'ga2-g09', skill: Skill.grammar, topic: 'subordinate',
    prompt: 'Welcher Satz ist richtig?',
    options: [
      'Ich glaube, dass er morgen kommt.',
      'Ich glaube, dass er kommt morgen.',
      'Ich glaube, dass kommt er morgen.',
      'Ich glaube, dass morgen er kommt.',
    ], answer: 0,
    explanation: 'After "dass" the verb goes to the end: … dass er morgen kommt.',
  ),
  Question(
    id: 'ga2-g10', skill: Skill.grammar, topic: 'imperative',
    prompt: 'Du sprichst mit deinem Bruder: „___ bitte das Fenster zu!“',
    options: ['Mach', 'Machst', 'Machen', 'Gemacht'], answer: 0,
    explanation: 'du-imperative: du machst › Mach! (drop "du" and "-st").',
  ),

  // ── Reading ──
  Question(
    id: 'ga2-r01', skill: Skill.reading, topic: 'read_messages', passageLabel: 'E-Mail',
    passage: 'Liebe Sandra,\nvielen Dank für die Einladung zu deiner Hochzeit! Ich komme sehr gern, aber erst am Samstagabend, weil ich am Vormittag noch arbeiten muss. Soll ich etwas mitbringen?\nViele Grüße\nKatrin',
    prompt: 'Warum kommt Katrin erst am Abend?',
    options: ['Sie muss am Vormittag arbeiten.', 'Sie hat keine Einladung.', 'Sie möchte nicht zur Hochzeit.'], answer: 0,
    explanation: 'The reason follows "weil": she has to work in the morning.',
  ),
  Question.trueFalse(
    id: 'ga2-r02', topic: 'read_notices', passageLabel: 'Aushang',
    passage: 'Wegen Bauarbeiten fährt die Linie 5 vom 3. bis 10. Juni nicht zwischen Hauptbahnhof und Rathaus. Bitte benutzen Sie den Ersatzbus.',
    prompt: 'Zwischen Hauptbahnhof und Rathaus fährt im Juni eine Woche lang ein Bus statt der Linie 5.', isTrue: true,
    explanation: 'From 3 to 10 June a replacement bus (Ersatzbus) runs instead of line 5.',
  ),
  Question.trueFalse(
    id: 'ga2-r03', topic: 'read_ads', passageLabel: 'Stellenanzeige',
    passage: 'Wir suchen eine Aushilfe (m/w/d) für unser Café am Wochenende. Sie sind freundlich und sprechen gut Deutsch? Erfahrung ist nicht nötig. Bewerbung bitte per E-Mail.',
    prompt: 'Man braucht Erfahrung für die Stelle.', isTrue: false,
    explanation: '"Erfahrung ist nicht nötig" — experience is not needed.',
  ),
  Question(
    id: 'ga2-r04', skill: Skill.reading, topic: 'read_details', passageLabel: 'Text',
    passage: 'Herr Yilmaz arbeitet seit fünf Jahren als Koch. Früher hat er in einem Hotel gearbeitet, jetzt hat er ein eigenes Restaurant. Er arbeitet viel, aber montags ist das Restaurant geschlossen.',
    prompt: 'Wo arbeitet Herr Yilmaz jetzt?',
    options: ['In seinem eigenen Restaurant', 'In einem Hotel', 'In einer Kantine'], answer: 0,
    explanation: '"Früher" (before) he worked in a hotel; "jetzt" (now) he has his own restaurant.',
  ),
  Question.trueFalse(
    id: 'ga2-r05', topic: 'read_notices', passageLabel: 'Aushang im Haus',
    passage: 'Liebe Mieterinnen und Mieter, am Donnerstag gibt es zwischen 9 und 12 Uhr kein Wasser. Ein Techniker repariert die Leitungen. Ihre Hausverwaltung',
    prompt: 'Am Donnerstagnachmittag gibt es wieder Wasser.', isTrue: true,
    explanation: 'The water is off only between 9 and 12 Uhr, so it is back in the afternoon.',
  ),
  Question(
    id: 'ga2-r06', skill: Skill.reading, topic: 'read_messages', passageLabel: 'Nachricht',
    passage: 'Hallo Paul, ich habe zwei Karten für das Konzert am Freitag, aber Maria ist krank. Hast du Lust mitzukommen? Die Karte kostet dich nichts – ich lade dich ein! Ben',
    prompt: 'Was muss Paul für die Karte bezahlen?',
    options: ['Nichts', 'Den halben Preis', 'Den vollen Preis'], answer: 0,
    explanation: '"Die Karte kostet dich nichts – ich lade dich ein" — Ben pays.',
  ),
  Question.trueFalse(
    id: 'ga2-r07', topic: 'read_details', passageLabel: 'Kursprogramm',
    passage: 'Volkshochschule: Der Kochkurs „Indisch kochen“ findet jeden Dienstag statt. Bitte bringen Sie eine Schürze mit. Die Lebensmittel sind im Kurspreis enthalten.',
    prompt: 'Die Teilnehmer müssen die Lebensmittel selbst kaufen.', isTrue: false,
    explanation: 'The food is included in the course price ("im Kurspreis enthalten").',
  ),
  Question(
    id: 'ga2-r08', skill: Skill.reading, topic: 'read_messages', passageLabel: 'E-Mail',
    passage: 'Sehr geehrte Damen und Herren,\nich habe am 5. Mai bei Ihnen eine Jacke bestellt. Leider ist sie zu klein. Kann ich sie umtauschen?\nMit freundlichen Grüßen\nAnil Kumar',
    prompt: 'Was möchte Herr Kumar?',
    options: ['Die Jacke umtauschen', 'Eine zweite Jacke bestellen', 'Die Jacke schneller bekommen'], answer: 0,
    explanation: 'The jacket is too small and he asks "Kann ich sie umtauschen?" (exchange it).',
  ),
  Question.trueFalse(
    id: 'ga2-r09', topic: 'read_details', passageLabel: 'Wetterbericht',
    passage: 'Morgen wird es im Norden regnerisch und kühl. Im Süden bleibt es sonnig bei bis zu 25 Grad.',
    prompt: 'Im Süden regnet es morgen.', isTrue: false,
    explanation: 'Rain is in the north; the south stays sunny.',
  ),
  Question.trueFalse(
    id: 'ga2-r10', topic: 'read_ads', passageLabel: 'Kleinanzeige',
    passage: 'Möbel günstig abzugeben: Sofa, Schrank und Esstisch wegen Umzug. Nur Abholung, am besten am Wochenende. Preis VB.',
    prompt: 'Die Möbel werden nach Hause geliefert.', isTrue: false,
    explanation: '"Nur Abholung" — pick-up only, no delivery.',
  ),
];
