import '../../models/quiz.dart';

/// Listening (Hören) items for every exam, 10 per exam.
///
/// Modelled on the parts of the real written exams:
/// • Goethe A1 — Teil 1 short dialogues (heard twice), Teil 2 announcements
///   (heard once, Richtig/Falsch), Teil 3 phone messages (heard twice).
/// • ÖSD A1 — global, detailed and selective listening; Austrian settings.
/// • Goethe A2 — radio / phone texts, conversations, interview (Richtig/Falsch).
/// • Goethe B1 — short messages, guided talks (heard once), conversations
///   and opinions in a discussion.
///
/// The script is read aloud by the browser's German voice. "A:" / "B:" / "C:"
/// mark speaker turns and are not spoken. Numbers that matter are written as
/// words so every voice reads them the same way.

// ─────────────────────────── Goethe A1 ───────────────────────────
const goetheA1Listening = <Question>[
  Question(
    id: 'ga1-l01', skill: Skill.listening, topic: 'listen_dialogues', passageLabel: 'Gespräch im Café',
    audio: 'A: Entschuldigung, wie viel kostet ein Kaffee?\n'
        'B: Ein Kaffee kostet zwei Euro achtzig.\n'
        'A: Und mit Milch?\n'
        'B: Mit Milch kostet er drei Euro.',
    prompt: 'Wie viel kostet der Kaffee mit Milch?',
    options: ['3,00 €', '2,80 €', '3,80 €'], answer: 0,
    explanation: 'Coffee is 2,80 €, but with milk ("mit Milch") it is drei Euro — 3,00 €.',
  ),
  Question(
    id: 'ga1-l02', skill: Skill.listening, topic: 'listen_dialogues', passageLabel: 'Gespräch in der Sprachschule',
    audio: 'A: Wann beginnt der Deutschkurs?\n'
        'B: Am Montag um neun Uhr.\n'
        'A: Um neun? Ich dachte, um zehn.\n'
        'B: Nein, um neun. Nur am Freitag beginnen wir um zehn.',
    prompt: 'Wann beginnt der Kurs am Montag?',
    options: ['Um 9 Uhr', 'Um 10 Uhr', 'Um 8 Uhr'], answer: 0,
    explanation: 'Monday starts at neun (9). Zehn (10) is only on Friday — a typical distractor.',
  ),
  Question(
    id: 'ga1-l03', skill: Skill.listening, topic: 'listen_dialogues', passageLabel: 'Gespräch unter Freunden',
    audio: 'A: Gehen wir heute Abend ins Kino?\n'
        'B: Nein, ich habe keine Lust. Gehen wir lieber ins Restaurant?\n'
        'A: Okay, gern. Um sieben?\n'
        'B: Ja, um sieben ist gut.',
    prompt: 'Was machen die beiden heute Abend?',
    options: ['Sie gehen ins Restaurant.', 'Sie gehen ins Kino.', 'Sie bleiben zu Hause.'], answer: 0,
    explanation: 'The cinema is suggested first, but they agree on the restaurant ("lieber ins Restaurant"). The last plan counts.',
  ),
  Question(
    id: 'ga1-l04', skill: Skill.listening, topic: 'listen_dialogues', passageLabel: 'Auf der Straße',
    audio: 'A: Entschuldigung, wo ist hier die Post?\n'
        'B: Gehen Sie geradeaus und dann die zweite Straße links. Die Post ist neben dem Supermarkt.\n'
        'A: Neben dem Supermarkt. Vielen Dank!',
    prompt: 'Wo ist die Post?',
    options: ['Neben dem Supermarkt', 'Neben dem Bahnhof', 'Gegenüber vom Supermarkt'], answer: 0,
    explanation: '"neben dem Supermarkt" = next to the supermarket. "gegenüber" would mean opposite.',
  ),
  Question.trueFalse(
    id: 'ga1-l05', topic: 'listen_announcements', passageLabel: 'Durchsage am Bahnhof', plays: 1,
    audio: 'Achtung an Gleis drei. Der Regionalexpress nach Köln, Abfahrt zehn Uhr fünfzehn, '
        'hat heute etwa zwanzig Minuten Verspätung.',
    prompt: 'Der Zug nach Köln kommt pünktlich.', isTrue: false,
    explanation: 'The train has about 20 minutes delay ("zwanzig Minuten Verspätung"), so it is not on time.',
  ),
  Question.trueFalse(
    id: 'ga1-l06', topic: 'listen_announcements', passageLabel: 'Durchsage im Supermarkt', plays: 1,
    audio: 'Liebe Kundinnen und Kunden, heute haben wir Äpfel im Angebot: '
        'ein Kilo kostet nur ein Euro neunundneunzig.',
    prompt: 'Heute sind Äpfel billiger.', isTrue: true,
    explanation: '"im Angebot" means on special offer — the apples are cheaper today.',
  ),
  Question.trueFalse(
    id: 'ga1-l07', topic: 'listen_announcements', passageLabel: 'Durchsage am Flughafen', plays: 1,
    audio: 'Liebe Fluggäste, der Flug nach München startet heute nicht von Gate A zwölf, '
        'sondern von Gate B sieben.',
    prompt: 'Der Flug nach München startet von Gate A12.', isTrue: false,
    explanation: '"nicht von Gate A12, sondern von Gate B7" — the gate has changed to B7.',
  ),
  Question(
    id: 'ga1-l08', skill: Skill.listening, topic: 'listen_messages', passageLabel: 'Nachricht auf dem Anrufbeantworter',
    audio: 'Hallo Frau Becker, hier ist die Praxis Doktor Lange. Ihr Termin am Dienstag um neun Uhr geht leider nicht. '
        'Können Sie am Mittwoch um elf Uhr kommen? Bitte rufen Sie uns zurück. Danke!',
    prompt: 'Wann soll Frau Becker kommen?',
    options: ['Am Mittwoch um 11 Uhr', 'Am Dienstag um 9 Uhr', 'Am Mittwoch um 9 Uhr'], answer: 0,
    explanation: 'Tuesday at 9 is cancelled ("geht leider nicht"). The new time is Wednesday at elf (11).',
  ),
  Question(
    id: 'ga1-l09', skill: Skill.listening, topic: 'listen_messages', passageLabel: 'Nachricht auf dem Handy',
    audio: 'Hi Paul, hier ist Anna. Ich bin morgen leider nicht in der Schule. '
        'Kannst du mir bitte die Hausaufgaben schicken? Danke und tschüss!',
    prompt: 'Was soll Paul machen?',
    options: ['Anna die Hausaufgaben schicken', 'Morgen nicht in die Schule gehen', 'Anna von der Schule abholen'], answer: 0,
    explanation: 'Anna asks: "Kannst du mir bitte die Hausaufgaben schicken?" — send her the homework.',
  ),
  Question(
    id: 'ga1-l10', skill: Skill.listening, topic: 'listen_numbers', passageLabel: 'Nachricht vom Hotel',
    audio: 'Guten Tag, hier ist das Hotel Sonne. Ihr Zimmer ist jetzt fertig. '
        'Sie haben Zimmer Nummer dreiundvierzig im vierten Stock.',
    prompt: 'Welche Zimmernummer hat der Gast?',
    options: ['43', '34', '4'], answer: 0,
    explanation: '"dreiundvierzig" = three-and-forty = 43. German says the ones first. 4 is the floor (Stock).',
  ),
];

// ─────────────────────────── ÖSD A1 ───────────────────────────
const osdA1Listening = <Question>[
  Question(
    id: 'oa1-l01', skill: Skill.listening, topic: 'listen_dialogues', passageLabel: 'In der Bäckerei',
    audio: 'A: Grüß Gott! Ich hätte gern zwei Semmeln und ein Kipferl.\n'
        'B: Gerne. Sonst noch etwas?\n'
        'A: Nein, danke. Was macht das?\n'
        'B: Das macht zwei Euro zehn.',
    prompt: 'Was kauft die Kundin oder der Kunde?',
    options: ['Zwei Semmeln und ein Kipferl', 'Ein Brot und zwei Kipferl', 'Eine Semmel und zwei Kipferl'], answer: 0,
    explanation: '"zwei Semmeln und ein Kipferl" — Semmel is the Austrian word for a bread roll.',
  ),
  Question(
    id: 'oa1-l02', skill: Skill.listening, topic: 'listen_dialogues', passageLabel: 'Gespräch unter Freunden',
    audio: 'A: Fahren wir am Samstag mit dem Zug nach Salzburg?\n'
        'B: Am Samstag kann ich nicht, da arbeite ich. Aber am Sonntag habe ich Zeit.\n'
        'A: Gut, dann fahren wir am Sonntag.',
    prompt: 'Wann fahren die beiden nach Salzburg?',
    options: ['Am Sonntag', 'Am Samstag', 'Am Freitag'], answer: 0,
    explanation: 'Saturday does not work ("da arbeite ich"), so they go on Sunday.',
  ),
  Question.trueFalse(
    id: 'oa1-l03', topic: 'listen_announcements', passageLabel: 'Durchsage in der U-Bahn', plays: 1,
    audio: 'Liebe Fahrgäste, wegen Bauarbeiten fährt die Linie U vier heute zwischen Karlsplatz und Hütteldorf nicht. '
        'Bitte benützen Sie die Ersatzbusse.',
    prompt: 'Heute fährt die U4 nicht bis Hütteldorf.', isTrue: true,
    explanation: 'The U4 does not run between Karlsplatz and Hütteldorf today — you take replacement buses.',
  ),
  Question.trueFalse(
    id: 'oa1-l04', topic: 'listen_announcements', passageLabel: 'Wetter im Radio', plays: 1,
    audio: 'Und nun das Wetter für morgen: In Wien und Niederösterreich scheint die Sonne, bis zu fünfundzwanzig Grad. '
        'Im Westen, in Tirol und Vorarlberg, regnet es am Nachmittag.',
    prompt: 'Morgen regnet es in Wien.', isTrue: false,
    explanation: 'In Wien the sun shines. The rain is in the west (Tirol, Vorarlberg).',
  ),
  Question.trueFalse(
    id: 'oa1-l05', topic: 'listen_announcements', passageLabel: 'Durchsage im Geschäft', plays: 1,
    audio: 'Liebe Kundinnen und Kunden, unser Geschäft schließt in fünfzehn Minuten. Bitte kommen Sie zur Kassa.',
    prompt: 'Das Geschäft schließt in einer Viertelstunde.', isTrue: true,
    explanation: '15 Minuten = eine Viertelstunde. "Kassa" is Austrian for the checkout (Kasse).',
  ),
  Question(
    id: 'oa1-l06', skill: Skill.listening, topic: 'listen_messages', passageLabel: 'Nachricht auf dem Handy',
    audio: 'Servus Lisa, hier ist Markus. Unser Treffen im Kaffeehaus ist nicht um drei, sondern um halb fünf. Bis dann!',
    prompt: 'Wann ist das Treffen?',
    options: ['Um halb fünf', 'Um drei', 'Um halb drei'], answer: 0,
    explanation: '"nicht um drei, sondern um halb fünf" — the new time is 4:30.',
  ),
  Question(
    id: 'oa1-l07', skill: Skill.listening, topic: 'listen_messages', passageLabel: 'Nachricht von der Hausverwaltung',
    audio: 'Guten Tag, hier spricht Frau Huber von der Hausverwaltung. Am Donnerstag kommt ein Techniker und repariert die Heizung. '
        'Bitte seien Sie zwischen acht und zwölf Uhr zu Hause.',
    prompt: 'Warum ruft Frau Huber an?',
    options: ['Ein Techniker repariert die Heizung.', 'Die Miete wird teurer.', 'Die Wohnung ist frei.'], answer: 0,
    explanation: 'A technician is coming on Thursday to repair the heating (Heizung).',
  ),
  Question(
    id: 'oa1-l08', skill: Skill.listening, topic: 'listen_dialogues', passageLabel: 'Gespräch am Montag',
    audio: 'A: Was hast du am Wochenende gemacht?\n'
        'B: Ich war mit meiner Familie in den Bergen wandern.\n'
        'A: Schön! Und wie war das Wetter?\n'
        'B: Am Samstag schön, am Sonntag hat es geregnet.',
    prompt: 'Was hat die zweite Person am Wochenende gemacht?',
    options: ['Sie war wandern.', 'Sie war schwimmen.', 'Sie war zu Hause.'], answer: 0,
    explanation: '"Ich war … in den Bergen wandern" — hiking in the mountains.',
  ),
  Question(
    id: 'oa1-l09', skill: Skill.listening, topic: 'listen_numbers', passageLabel: 'Am Telefon',
    audio: 'A: Wie ist Ihre Telefonnummer, bitte?\n'
        'B: Null, sechs, sechs, vier. Zwei, eins. Neun, acht, sieben.\n'
        'A: Danke schön.',
    prompt: 'Welche Telefonnummer hören Sie?',
    options: ['0664 21 987', '0664 12 987', '0646 21 987'], answer: 0,
    explanation: 'Null-sechs-sechs-vier, zwei-eins, neun-acht-sieben = 0664 21 987.',
  ),
  Question(
    id: 'oa1-l10', skill: Skill.listening, topic: 'listen_numbers', passageLabel: 'Gespräch',
    audio: 'A: Wann hast du Geburtstag?\n'
        'B: Am zwölften Jänner.\n'
        'A: Im Jänner? Ich auch, am zwanzigsten!',
    prompt: 'Wann hat die zweite Person Geburtstag?',
    options: ['Am 12. Januar', 'Am 20. Januar', 'Am 12. Juni'], answer: 0,
    explanation: '"am zwölften Jänner" = 12 January. Jänner is Austrian for Januar. The 20th is the other person.',
  ),
];

// ─────────────────────────── Goethe A2 ───────────────────────────
const goetheA2Listening = <Question>[
  Question(
    id: 'ga2-l01', skill: Skill.listening, topic: 'listen_announcements', passageLabel: 'Verkehrsmeldung im Radio',
    audio: 'Und jetzt der Verkehr: Auf der Autobahn zwischen Frankfurt und Würzburg gibt es nach einem Unfall zehn Kilometer Stau. '
        'Wer in Richtung Würzburg fährt, sollte ab Frankfurt eine andere Strecke nehmen.',
    prompt: 'Was sollen die Autofahrer tun?',
    options: ['Eine andere Strecke fahren', 'Langsamer fahren', 'In Frankfurt warten'], answer: 0,
    explanation: '"eine andere Strecke nehmen" = take another route because of the 10 km jam.',
  ),
  Question(
    id: 'ga2-l02', skill: Skill.listening, topic: 'listen_messages', passageLabel: 'Nachricht von der Werkstatt',
    audio: 'Hallo Herr Krüger, hier ist die Autowerkstatt Schmidt. Ihr Auto ist leider noch nicht fertig, wir brauchen noch ein Ersatzteil. '
        'Sie können es am Donnerstag ab vierzehn Uhr abholen.',
    prompt: 'Wann kann Herr Krüger das Auto abholen?',
    options: ['Am Donnerstag ab 14 Uhr', 'Heute ab 14 Uhr', 'Am Donnerstag vor 14 Uhr'], answer: 0,
    explanation: 'The car is not ready today; pick-up is Thursday from ("ab") 14 Uhr.',
  ),
  Question(
    id: 'ga2-l03', skill: Skill.listening, topic: 'listen_dialogues', passageLabel: 'Gespräch',
    audio: 'A: Hast du schon ein Geschenk für Tante Inge?\n'
        'B: Ich wollte ihr ein Buch kaufen, aber sie liest nicht so gern. Jetzt kaufe ich ihr lieber Blumen.\n'
        'A: Gute Idee, sie hat doch einen Garten.',
    prompt: 'Was kauft die zweite Person für Tante Inge?',
    options: ['Blumen', 'Ein Buch', 'Etwas für den Garten'], answer: 0,
    explanation: 'The book was the first idea ("wollte"), but she now buys flowers ("lieber Blumen").',
  ),
  Question(
    id: 'ga2-l04', skill: Skill.listening, topic: 'listen_dialogues', passageLabel: 'Gespräch bei der Arbeit',
    audio: 'A: Wie bist du heute zur Arbeit gekommen? Dein Auto ist doch kaputt.\n'
        'B: Ja. Ich wollte den Bus nehmen, aber der war total voll. Dann bin ich mit dem Fahrrad gefahren.',
    prompt: 'Wie ist die zweite Person zur Arbeit gekommen?',
    options: ['Mit dem Fahrrad', 'Mit dem Bus', 'Mit dem Auto'], answer: 0,
    explanation: 'The car is broken and the bus was full, so: "mit dem Fahrrad gefahren".',
  ),
  Question.trueFalse(
    id: 'ga2-l05', topic: 'listen_announcements', passageLabel: 'Durchsage im Museum', plays: 1,
    audio: 'Sehr geehrte Besucherinnen und Besucher, das Museum schließt heute wegen einer Veranstaltung schon um sechzehn Uhr. '
        'Die Cafeteria im Erdgeschoss bleibt bis achtzehn Uhr geöffnet.',
    prompt: 'Man kann heute um 17 Uhr noch in die Cafeteria gehen.', isTrue: true,
    explanation: 'The museum closes at 16 Uhr, but the cafeteria stays open until 18 Uhr.',
  ),
  Question.trueFalse(
    id: 'ga2-l06', topic: 'listen_announcements', passageLabel: 'Durchsage am Bahnhof', plays: 1,
    audio: 'Liebe Fahrgäste, wegen einer Signalstörung fällt die S-Bahn zum Flughafen heute aus. '
        'Bitte nehmen Sie den Bus Nummer hundert vor dem Bahnhof.',
    prompt: 'Die S-Bahn zum Flughafen fährt heute mit Verspätung.', isTrue: false,
    explanation: '"fällt aus" means it is cancelled, not late. Passengers take bus 100.',
  ),
  Question.trueFalse(
    id: 'ga2-l07', topic: 'listen_detail', passageLabel: 'Interview im Radio',
    audio: 'A: Frau Yilmaz, Sie sind vor drei Jahren nach Deutschland gekommen. Wie haben Sie Deutsch gelernt?\n'
        'B: Zuerst in einem Kurs an der Volkshochschule. Aber am meisten habe ich bei der Arbeit gelernt, im Gespräch mit den Kollegen.',
    prompt: 'Frau Yilmaz hat am meisten im Deutschkurs gelernt.', isTrue: false,
    explanation: 'She started with a course, but learned most at work ("am meisten … bei der Arbeit").',
  ),
  Question.trueFalse(
    id: 'ga2-l08', topic: 'listen_detail', passageLabel: 'Interview im Radio',
    audio: 'A: Und was machen Sie in Ihrer Freizeit?\n'
        'B: Ich spiele seit einem Jahr in einem Volleyballverein. Dort habe ich viele Freunde gefunden.',
    prompt: 'Frau Yilmaz hat im Sportverein Freunde gefunden.', isTrue: true,
    explanation: 'In her volleyball club ("Volleyballverein") she found many friends.',
  ),
  Question(
    id: 'ga2-l09', skill: Skill.listening, topic: 'listen_numbers', passageLabel: 'Nachricht von der Bibliothek',
    audio: 'Guten Tag, hier ist die Stadtbibliothek. Das Buch, das Sie bestellt haben, ist jetzt da. '
        'Sie können es bis zum achtzehnten März abholen. Wir haben Montag bis Freitag von zehn bis neunzehn Uhr geöffnet.',
    prompt: 'Bis wann muss man das Buch abholen?',
    options: ['Bis zum 18. März', 'Bis zum 8. März', 'Bis zum 19. März'], answer: 0,
    explanation: '"bis zum achtzehnten März" = by 18 March. 19 is the closing hour, not the date.',
  ),
  Question(
    id: 'ga2-l10', skill: Skill.listening, topic: 'listen_dialogues', passageLabel: 'Gespräch',
    audio: 'A: Wollen wir am Wochenende ins Schwimmbad gehen?\n'
        'B: Am Samstag muss ich meiner Schwester beim Umzug helfen. Am Sonntag gern, aber erst nachmittags.\n'
        'A: Okay, dann Sonntag um drei.',
    prompt: 'Was macht die zweite Person am Samstag?',
    options: ['Sie hilft ihrer Schwester beim Umzug.', 'Sie geht ins Schwimmbad.', 'Sie arbeitet am Nachmittag.'], answer: 0,
    explanation: '"Am Samstag muss ich meiner Schwester beim Umzug helfen" — helping her sister move.',
  ),
];

// ─────────────────────────── Goethe B1 ───────────────────────────
const goetheB1Listening = <Question>[
  Question.trueFalse(
    id: 'gb1-l01', topic: 'listen_messages', passageLabel: 'Nachricht auf der Mailbox',
    audio: 'Hallo Jana, hier ist Ben. Du, wegen Samstag: Der Ausflug an den See findet leider nicht statt, weil fast alle abgesagt haben. '
        'Stattdessen treffen wir uns um acht bei mir zum Grillen auf dem Balkon. Bring doch bitte einen Salat mit, Getränke habe ich genug.',
    prompt: 'Der Ausflug zum See findet wie geplant statt.', isTrue: false,
    explanation: 'The trip "findet leider nicht statt" because almost everyone cancelled — they grill at Ben\'s instead.',
  ),
  Question(
    id: 'gb1-l02', skill: Skill.listening, topic: 'listen_messages', passageLabel: 'Nachricht vom Kundenservice',
    audio: 'Guten Tag, Frau Petersen, hier spricht Herr Schulz vom Kundenservice der Stadtwerke. Sie hatten wegen Ihrer Stromrechnung angerufen. '
        'Wir haben das geprüft: Sie haben tatsächlich zu viel bezahlt. Den Betrag überweisen wir Ihnen in den nächsten zwei Wochen zurück. '
        'Sie müssen nichts weiter tun.',
    prompt: 'Was muss Frau Petersen jetzt tun?',
    options: ['Nichts, das Geld wird zurücküberwiesen.', 'Die Stadtwerke zurückrufen.', 'Die Rechnung noch einmal bezahlen.'], answer: 0,
    explanation: '"Sie müssen nichts weiter tun" — the overpaid amount is transferred back automatically.',
  ),
  Question(
    id: 'gb1-l03', skill: Skill.listening, topic: 'listen_detail', passageLabel: 'Führung im Rathaus', plays: 1,
    audio: 'Herzlich willkommen im Rathaus! Bevor wir mit der Führung beginnen, noch ein paar Hinweise. '
        'Fotografieren ist im ganzen Gebäude erlaubt, nur im Ratssaal leider nicht, weil dort heute eine Sitzung stattfindet. '
        'Die Führung dauert etwa eine Stunde.',
    prompt: 'Wo darf man heute nicht fotografieren?',
    options: ['Im Ratssaal', 'Im ganzen Rathaus', 'Nirgends, Fotos sind überall erlaubt'], answer: 0,
    explanation: 'Photos are allowed everywhere "nur im Ratssaal leider nicht" — not in the council chamber.',
  ),
  Question(
    id: 'gb1-l04', skill: Skill.listening, topic: 'listen_detail', passageLabel: 'Stadtrundfahrt', plays: 1,
    audio: 'Liebe Gäste, willkommen zu unserer Stadtrundfahrt. Wir fahren zuerst zum Hafen, dort machen wir zwanzig Minuten Pause. '
        'Bitte seien Sie pünktlich wieder am Bus, denn um zwölf Uhr haben wir die Führung im Dom. '
        'Das Mittagessen ist nicht im Preis enthalten, ich empfehle Ihnen aber gern ein paar Restaurants in der Altstadt.',
    prompt: 'Was ist nicht im Preis enthalten?',
    options: ['Das Mittagessen', 'Die Führung im Dom', 'Die Fahrt zum Hafen'], answer: 0,
    explanation: '"Das Mittagessen ist nicht im Preis enthalten" — lunch is extra.',
  ),
  Question.trueFalse(
    id: 'gb1-l05', topic: 'listen_detail', passageLabel: 'Gespräch unter Kollegen', plays: 1,
    audio: 'A: Und, wie gefällt dir die neue Wohnung?\n'
        'B: Eigentlich gut. Sie ist größer als die alte und viel heller. Nur der Weg zur Arbeit ist jetzt länger, ich brauche fast eine Stunde mit der Bahn.\n'
        'A: Und die Nachbarn?\n'
        'B: Sehr nett. Die Familie unter mir hat mich sogar zum Essen eingeladen.',
    prompt: 'Der Weg zur Arbeit ist jetzt kürzer als früher.', isTrue: false,
    explanation: '"Nur der Weg zur Arbeit ist jetzt länger" — the commute is longer, almost an hour.',
  ),
  Question.trueFalse(
    id: 'gb1-l06', topic: 'listen_detail', passageLabel: 'Gespräch unter Freunden', plays: 1,
    audio: 'A: Hast du dich jetzt für den Job in Hamburg entschieden?\n'
        'B: Ja, ich habe gestern zugesagt. Das Gehalt ist zwar nicht höher als jetzt, aber die Arbeit ist interessanter, '
        'und ich kann zwei Tage pro Woche von zu Hause arbeiten.',
    prompt: 'In Hamburg kann die Person zum Teil von zu Hause arbeiten.', isTrue: true,
    explanation: '"zwei Tage pro Woche von zu Hause arbeiten" — partly home office. The salary is not higher.',
  ),
  Question(
    id: 'gb1-l07', skill: Skill.listening, topic: 'listen_detail', passageLabel: 'Diskussion im Radio',
    audio: 'A: Sollten Kinder schon in der Grundschule ein Smartphone haben?\n'
        'B: Ich finde, nein. Kinder sollen draußen spielen und Freunde treffen, nicht stundenlang auf einen Bildschirm schauen.\n'
        'C: Da bin ich anderer Meinung. Mit einem Handy können Eltern ihre Kinder jederzeit erreichen, das gibt Sicherheit.',
    prompt: 'Welches Argument FÜR ein Smartphone hören Sie?',
    options: ['Eltern können ihre Kinder immer erreichen.', 'Kinder lernen damit besser.', 'Kinder spielen dann mehr draußen.'], answer: 0,
    explanation: 'The third speaker argues for it: parents can reach their children at any time ("jederzeit erreichen").',
  ),
  Question(
    id: 'gb1-l08', skill: Skill.listening, topic: 'listen_detail', passageLabel: 'Diskussion im Radio',
    audio: 'A: Viele Städte wollen weniger Autos in der Innenstadt. Was meinen Sie?\n'
        'B: Grundsätzlich finde ich das richtig, die Luft wäre besser. Aber dann müssen Busse und Bahnen billiger werden und öfter fahren, '
        'sonst funktioniert das nicht.',
    prompt: 'Was ist die Meinung der zweiten Person?',
    options: ['Sie ist dafür, aber nur mit besserem Nahverkehr.', 'Sie ist ganz dagegen.', 'Sie findet, Busse sind schon billig genug.'], answer: 0,
    explanation: '"Grundsätzlich richtig … aber dann müssen Busse und Bahnen billiger werden" — yes, with conditions.',
  ),
  Question.trueFalse(
    id: 'gb1-l09', topic: 'listen_numbers', passageLabel: 'Ansage der Arztpraxis',
    audio: 'Hier ist die Ansage der Arztpraxis Doktor Nowak. Unsere Praxis ist vom dreiundzwanzigsten Dezember bis zum dritten Januar geschlossen. '
        'In dringenden Fällen rufen Sie bitte den ärztlichen Bereitschaftsdienst an.',
    prompt: 'Die Praxis ist über Weihnachten geschlossen.', isTrue: true,
    explanation: 'Closed from 23 December to 3 January — that includes Christmas.',
  ),
  Question(
    id: 'gb1-l10', skill: Skill.listening, topic: 'listen_announcements', passageLabel: 'Wetterbericht im Radio',
    audio: 'Und nun zum Wetter: Nach einem sonnigen Vormittag ziehen am Nachmittag von Westen Wolken auf. '
        'Ab dem Abend muss man im ganzen Land mit kräftigem Regen rechnen, in den Bergen kann es sogar schneien. '
        'Morgen wird es dann wieder freundlicher, allerdings deutlich kühler.',
    prompt: 'Wie wird das Wetter morgen?',
    options: ['Freundlich, aber kühler', 'Regnerisch und kühl', 'Sonnig und wärmer'], answer: 0,
    explanation: '"Morgen wird es wieder freundlicher, allerdings deutlich kühler" — nicer but colder. The rain is tonight.',
  ),
];
