/// Guidance for each topic a question can test. Used on the analysis page
/// to turn wrong answers into "what to practise" advice.
class TopicGuide {
  const TopicGuide({
    required this.title,
    required this.fix,
    required this.example,
    required this.practise,
  });

  final String title;

  /// One-line rule / quick fix.
  final String fix;

  /// A correct German example.
  final String example;

  /// How to practise it this week.
  final String practise;
}

const Map<String, TopicGuide> topicGuides = {
  // ── Vocabulary ──
  'family': TopicGuide(
    title: 'Family words',
    fix: 'Learn family words in pairs: Mutter/Vater, Großmutter/Großvater, Bruder/Schwester, Eltern/Großeltern.',
    example: 'Die Mutter von meiner Mutter ist meine Großmutter (Oma).',
    practise: 'Draw your family tree and label every person in German.',
  ),
  'numbers_time': TopicGuide(
    title: 'Numbers, prices & time',
    fix: 'German says the ones before the tens (47 = siebenundvierzig). "halb drei" means 2:30, not 3:30.',
    example: 'Es ist Viertel nach sieben. Das kostet drei Euro fünfzig.',
    practise: 'Say every price and clock time you see today out loud in German.',
  ),
  'dates': TopicGuide(
    title: 'Days, months & dates',
    fix: 'Learn the days in order (Montag › Sonntag) and use "am" with days: am Montag.',
    example: 'Der Kurs ist am Dienstag. In Österreich sagt man oft "Jänner" für Januar.',
    practise: 'Write your week plan in German, one line per day.',
  ),
  'food_shopping': TopicGuide(
    title: 'Food, drinks & shopping',
    fix: 'Group words by category (Obst, Getränke, Möbel) so odd-one-out questions become easy.',
    example: 'Apfel, Banane und Orange sind Obst. Ein Stuhl ist ein Möbelstück.',
    practise: 'Write your next shopping list in German.',
  ),
  'places': TopicGuide(
    title: 'Places in town',
    fix: 'Link each place to what you do there: Bäckerei › Brot, Apotheke › Medikamente, Haltestelle › Bus.',
    example: 'Ich kaufe Brot in der Bäckerei.',
    practise: 'Make flashcards: place on one side, activity on the other.',
  ),
  'home': TopicGuide(
    title: 'Home & rooms',
    fix: 'Learn rooms with their article and one activity: die Küche (kochen), das Bad (duschen).',
    example: 'Ich koche in der Küche.',
    practise: 'Walk through your home and name every room and object in German.',
  ),
  'phrases': TopicGuide(
    title: 'Greetings & everyday phrases',
    fix: 'Match the greeting to the time and situation: Guten Morgen / Guten Abend / Gute Nacht (going to bed).',
    example: 'Am Abend sagt man "Guten Abend". In Österreich hört man oft "Grüß Gott".',
    practise: 'Use one new phrase in each German conversation this week.',
  ),
  'everyday': TopicGuide(
    title: 'Everyday words',
    fix: 'Learn verbs together with typical nouns: Durst › trinken, Hunger › essen, müde › schlafen.',
    example: 'Ich habe Durst. Ich möchte etwas trinken.',
    practise: 'Describe your day in five simple German sentences every evening.',
  ),
  'work': TopicGuide(
    title: 'Work & jobs',
    fix: 'Know the job-search chain: Stellenanzeige › Bewerbung › Vorstellungsgespräch › Arbeitsvertrag.',
    example: 'Ich habe mich beworben und warte auf ein Vorstellungsgespräch.',
    practise: 'Read three German job ads and underline the key words.',
  ),
  'housing': TopicGuide(
    title: 'Housing & renting',
    fix: 'Kaltmiete = rent without heating/water; Warmmiete includes them; Kaution = deposit; Mietvertrag = lease.',
    example: 'Die Kaltmiete beträgt 500 €, die Warmmiete 650 €.',
    practise: 'Read flat ads online and explain each one in a German sentence.',
  ),
  'health': TopicGuide(
    title: 'Health & body',
    fix: 'Learn the key places and things: Arzt, Krankenhaus, Apotheke, Rezept, Fieber, Termin.',
    example: 'Ich habe Fieber. Ich gehe zum Arzt.',
    practise: 'Role-play booking a doctor\'s appointment in German.',
  ),
  'travel': TopicGuide(
    title: 'Travel & transport',
    fix: 'Learn travel documents and transport words together: Visum, Reisepass, Fahrkarte, Gleis, Haltestelle.',
    example: 'Für die Reise brauche ich ein Visum.',
    practise: 'Plan an imaginary trip in German: ticket, platform, times.',
  ),
  'adjectives': TopicGuide(
    title: 'Opposites & adjectives',
    fix: 'Learn adjectives as opposite pairs: billig/teuer, pünktlich/verspätet, warm/kalt.',
    example: 'Das Hotel ist teuer, aber das Hostel ist billig.',
    practise: 'Write ten opposite pairs from memory, then check them.',
  ),
  'formal': TopicGuide(
    title: 'Formal language & useful phrases',
    fix: 'Formal letters end with "Mit freundlichen Grüßen"; give opinions with "Meiner Meinung nach …".',
    example: 'Meiner Meinung nach ist Homeoffice praktisch.',
    practise: 'Write a short formal email (to a landlord or office) and check the opening and closing.',
  ),
  'society': TopicGuide(
    title: 'Society & official matters',
    fix: 'Know common "life in Germany" words: anmelden (Bürgeramt), Umwelt, Müll trennen, Behörde.',
    example: 'Nach dem Umzug muss ich mich beim Bürgeramt anmelden.',
    practise: 'Read one short German news article a day and note five new words.',
  ),

  // ── Grammar ──
  'verb_position': TopicGuide(
    title: 'Verb in second position',
    fix: 'In a statement the conjugated verb is always in position 2, even when the sentence starts with time or place.',
    example: 'Am Wochenende spiele ich Fußball.',
    practise: 'Take five sentences and rewrite each starting with a time word.',
  ),
  'conjugation': TopicGuide(
    title: 'Verb endings',
    fix: 'ich -e, du -st, er/sie/es -t, wir -en, ihr -t, sie/Sie -en. Learn "sein" and "haben" by heart.',
    example: 'Wir wohnen in Wien. Wie alt seid ihr?',
    practise: 'Conjugate three verbs a day out loud, all six persons.',
  ),
  'accusative': TopicGuide(
    title: 'Articles & accusative',
    fix: 'Only masculine changes in the accusative: der › den, ein › einen, kein › keinen.',
    example: 'Ich habe einen Bruder. Ich kaufe den Tisch.',
    practise: 'Write "Ich habe / Ich brauche …" with ten masculine nouns.',
  ),
  'dative': TopicGuide(
    title: 'Dative',
    fix: 'After helfen, danken, gefallen and after mit, bei, von, zu, nach, aus: dem (m/n), der (f), den + n (pl).',
    example: 'Ich helfe dem Mann. Ich fahre mit dem Bus.',
    practise: 'Make ten sentences with "mit" + a vehicle or a person.',
  ),
  'modal_verbs': TopicGuide(
    title: 'Modal verbs',
    fix: 'Modal verb in position 2, infinitive at the end. ich/er forms have no ending: ich kann, er kann.',
    example: 'Ich kann heute nicht kommen. Möchtest du Tee?',
    practise: 'Say what you can, must and want to do today with können, müssen, wollen.',
  ),
  'questions': TopicGuide(
    title: 'Question words',
    fix: 'Wo = where, Woher = where from, Wann = when, Wer = who, Was = what, Wie viel = how much.',
    example: 'Wo wohnst du? – In Hamburg.',
    practise: 'Interview yourself: write and answer one question with each W-word.',
  ),
  'separable': TopicGuide(
    title: 'Separable verbs',
    fix: 'The prefix goes to the end of the sentence: abfahren › Der Zug fährt um 8 Uhr ab.',
    example: 'Ich stehe um 7 Uhr auf.',
    practise: 'Describe your morning routine using aufstehen, anziehen, einkaufen.',
  ),
  'possessives': TopicGuide(
    title: 'Possessive words',
    fix: 'her = ihr, his = sein. The ending follows the noun: ihr Mann, ihre Tochter, mein Auto.',
    example: 'Das ist Anna. Ihr Mann heißt Peter.',
    practise: 'Describe a friend\'s family using sein/ihr.',
  ),
  'prepositions': TopicGuide(
    title: 'Prepositions of time & place',
    fix: 'am + day, um + clock time, im + month; aus + country (origin), nach + city/country (direction).',
    example: 'Ich komme aus Indien. Der Kurs beginnt am Montag um 9 Uhr.',
    practise: 'Write five sentences about your week with am, um, im.',
  ),
  'negation': TopicGuide(
    title: 'nicht or kein',
    fix: '"kein" negates nouns with ein/no article; "nicht" negates verbs, adjectives and the rest.',
    example: 'Ich habe keine Kinder. Ich komme heute nicht.',
    practise: 'Answer ten yes/no questions negatively, choosing nicht or kein.',
  ),
  'perfekt': TopicGuide(
    title: 'Perfekt: haben or sein',
    fix: 'Use "sein" with movement or change (gehen, fahren, kommen); most other verbs use "haben".',
    example: 'Gestern bin ich ins Kino gegangen. Ich habe viel gearbeitet.',
    practise: 'Tell what you did yesterday in five Perfekt sentences.',
  ),
  'praeteritum': TopicGuide(
    title: 'Präteritum of sein, haben & modals',
    fix: 'war, hatte, konnte, musste, wollte — these are used in Präteritum even in speech.',
    example: 'Als Kind konnte ich nicht schwimmen.',
    practise: 'Write about your childhood with war, hatte, konnte.',
  ),
  'subordinate': TopicGuide(
    title: 'Word order after weil / dass',
    fix: 'After weil, dass, wenn, ob the conjugated verb goes to the very end.',
    example: 'Ich komme nicht, weil ich krank bin.',
    practise: 'Answer "Warum …?" questions with full weil-sentences.',
  ),
  'comparison': TopicGuide(
    title: 'Comparisons',
    fix: 'Comparative = adjective + -er + als (often with umlaut): groß › größer als.',
    example: 'Berlin ist größer als München.',
    practise: 'Compare two cities you know in five sentences.',
  ),
  'two_way_prep': TopicGuide(
    title: 'Two-way prepositions',
    fix: 'Movement/direction (Wohin?) › accusative; position (Wo?) › dative: auf den Tisch / auf dem Tisch.',
    example: 'Ich lege das Buch auf den Tisch. Das Buch liegt auf dem Tisch.',
    practise: 'Describe where things are in your room, then where you put them.',
  ),
  'reflexive': TopicGuide(
    title: 'Reflexive verbs',
    fix: 'sich freuen, sich interessieren … : ich › mich, du › dich, er/sie › sich.',
    example: 'Ich freue mich auf den Urlaub.',
    practise: 'Learn five reflexive verbs with their preposition (freuen auf, interessieren für).',
  ),
  'imperative': TopicGuide(
    title: 'Imperative',
    fix: 'du-form: take the du-verb, drop -st and "du": du machst › Mach!',
    example: 'Mach bitte das Fenster zu!',
    practise: 'Give a friend five polite instructions in German.',
  ),
  'relative': TopicGuide(
    title: 'Relative clauses',
    fix: 'The relative pronoun takes gender from the noun and case from its own clause: helfen + dative › dem.',
    example: 'Das ist der Mann, dem ich geholfen habe.',
    practise: 'Join two short sentences into one with der/die/das ten times.',
  ),
  'konjunktiv2': TopicGuide(
    title: 'Konjunktiv II (wishes & conditions)',
    fix: 'Use hätte, wäre, könnte, or würde + infinitive for unreal situations.',
    example: 'Wenn ich mehr Zeit hätte, würde ich mehr reisen.',
    practise: 'Finish the sentence "Wenn ich in Deutschland wäre, …" five ways.',
  ),
  'passive': TopicGuide(
    title: 'Passive',
    fix: 'werden + Partizip II. Past: wurde + Partizip II.',
    example: 'Das Haus wurde 1950 gebaut.',
    practise: 'Describe how something is made (Tee, Brot) in the passive.',
  ),
  'connectors': TopicGuide(
    title: 'Connectors (obwohl, trotzdem, deshalb)',
    fix: '"obwohl" starts a clause with the verb at the end; "trotzdem/deshalb" sit in position 1 with the verb next.',
    example: 'Obwohl es regnet, gehen wir spazieren. Es regnet. Trotzdem gehen wir spazieren.',
    practise: 'Write the same idea twice: once with obwohl, once with trotzdem.',
  ),
  'genitive': TopicGuide(
    title: 'Genitive (wegen, trotz)',
    fix: 'After wegen/trotz use genitive: des (m/n) + noun-s, der (f/pl). Adjective ending: -en.',
    example: 'Wegen des schlechten Wetters fällt das Spiel aus.',
    practise: 'Explain five cancellations: "Wegen des/der … fällt … aus."',
  ),
  'infinitive_zu': TopicGuide(
    title: 'Infinitive with zu',
    fix: 'After Lust haben, versuchen, vergessen … : "zu" + infinitive at the end; separable verbs put zu inside (einzukaufen).',
    example: 'Ich habe keine Lust, heute einkaufen zu gehen.',
    practise: 'Make sentences with "Ich habe vergessen, … zu …".',
  ),
  'tenses': TopicGuide(
    title: 'Past perfect (Plusquamperfekt)',
    fix: 'hatte/war + Partizip II for what happened before another past action, often with "nachdem".',
    example: 'Nachdem er gegessen hatte, ging er schlafen.',
    practise: 'Tell a short story using nachdem + Plusquamperfekt.',
  ),
  'adjective_endings': TopicGuide(
    title: 'Adjective endings',
    fix: 'After ein (neuter, nom./acc.) the adjective shows the gender: ein neues Auto; after the: das neue Auto.',
    example: 'Ich wünsche mir ein neues Auto.',
    practise: 'Describe five things you own with an adjective + ein/eine.',
  ),
  'verb_prep': TopicGuide(
    title: 'Verbs with prepositions',
    fix: 'Learn verb + preposition as one unit: warten auf, sich freuen auf, denken an, sich interessieren für.',
    example: 'Ich warte auf den Bus.',
    practise: 'Make flashcards with the verb on one side, preposition + case on the other.',
  ),
  'indirect_questions': TopicGuide(
    title: 'Indirect questions',
    fix: 'Keep the question word (wann, wo, wie) or use "ob" for yes/no, and put the verb at the end.',
    example: 'Können Sie mir sagen, wann der Zug abfährt?',
    practise: 'Turn ten direct questions into polite "Können Sie mir sagen, …" questions.',
  ),

  // ── Reading ──
  'read_notices': TopicGuide(
    title: 'Signs & notices',
    fix: 'Scan for days, times and small words that change meaning: nur, nicht, geschlossen, außer Betrieb, frei.',
    example: '"Sa 8–12 Uhr" means the shop is open only until noon on Saturday.',
    practise: 'Photograph German signs online (or around you) and explain each in one sentence.',
  ),
  'read_messages': TopicGuide(
    title: 'Messages & emails',
    fix: 'First find who writes and why. The reason often follows "leider", "weil" or "da".',
    example: '"Ich bin leider krank und kann nicht kommen" › the person cancels.',
    practise: 'Read short German emails and write the purpose in five words.',
  ),
  'read_ads': TopicGuide(
    title: 'Adverts',
    fix: 'Look for price, time, conditions and limits: nur, ab, nicht nötig, VB (price negotiable).',
    example: '"Nur Abholung" = you must pick it up yourself; no delivery.',
    practise: 'Compare three ads for the same thing and pick the best one in German.',
  ),
  'read_details': TopicGuide(
    title: 'Finding details in info texts',
    fix: 'Read the question first, then find the exact line. Answers are often paraphrased, not copied.',
    example: '"Die Lebensmittel sind im Kurspreis enthalten" = you do not buy the food yourself.',
    practise: 'Do one timed reading task a day: question first, then text.',
  ),
  'read_gist': TopicGuide(
    title: 'Main idea & opinions (B1)',
    fix: 'Do not match single words. Match the meaning of the whole sentence — and watch for "jedoch", "aber", "andere".',
    example: '"Viele sparen Zeit … Andere vermissen den Kontakt" › there are pros and cons.',
    practise: 'After each article, write one sentence: "Der Text sagt, dass …".',
  ),
};
