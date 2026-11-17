# Am I exam-ready? — Globio

A Flutter web app that helps learners who have finished A1 German find out whether they are
ready to book their **Goethe-Zertifikat A1** or **ÖSD A1** exam.

Built for the Globio *Founder's Office – Product Manager Intern* assignment.

## Status

| Part | State |
|---|---|
| Splash screen with loading animation | ✅ Done |
| Landing page in Globio's brand (palette + Poppins, taken from globio.ai) | ✅ Done |
| Sign up / Log in (local only, no backend) | ✅ Done |
| Mock exams: Goethe A1, ÖSD A1, Goethe A2, Goethe B1 (16 questions each, incl. listening with audio) | ✅ Done |
| Analysis dashboard: readiness, per-skill breakdown, 2–3 focus areas, question review, tips | ✅ Done |
| Result confidence: close-call flag + confirmation over the last 2 mocks | ✅ Done |
| History of all past mocks with progress per exam | ✅ Done |
| Dashboard app shell: Home, Mock exams, My results, Mentor, Profile (sidebar / bottom nav) | ✅ Done |
| Personal student ID + editable profile | ✅ Done |
| Globio coins: earn by score & daily question, spend on mocks & mentor sessions | ✅ Done |
| Free biweekly mock (Fri 6 PM – Sat 6 PM IST) | ✅ Done |
| Mentor session request & booking | ✅ Done |
| Real exam result reporting, linked to the latest mock (predicted vs real) | ✅ Done |

## Coins

| Earn | Coins |
|---|---|
| Welcome bonus | +100 |
| Mock score | score % (full marks = +100, the price of the next mock) |
| Daily question — easy (A1) / medium (A2) / advanced (B1) | +5 / +10 / +20 (advanced = 1/5 of a mock) |
| Daily question — wrong answer | +1 |

| Spend | Coins |
|---|---|
| Mock exam | 100 |
| Mentor session (= two full-marks mocks) | 200 |
| Free mock, every other Friday 6 PM – Saturday 6 PM IST | free (one attempt per window) |

The balance is the sum of an append-only ledger with a unique id per entry, so a reward or
purchase can never be applied twice. The daily question is derived from (email, IST day), so a
refresh cannot re-roll it. Mentor sessions need 24 h notice and can be cancelled up to 24 h before
for a full refund.

**Why Friday 6 PM – Saturday 6 PM IST for the free mock:** working professionals are free after
office on Friday evening, college students on Saturday morning/afternoon, and it matches Globio's
own evening demo slots (4 PM / 8 PM IST) and weekend live classes.

**Real exam results** can't be pulled in automatically — Goethe/ÖSD exams are taken at a test
centre and results are published on the provider's portal with no public API. The learner enters
pass/fail (+ score); it is linked automatically to their latest mock for that exam before the exam
date, and the app shows whether the mock's prediction matched.

## The mock exams

| Exam | Bank | Per mock | Time | Pass mark used |
|---|---|---|---|---|
| Goethe-Zertifikat A1 (Start Deutsch 1) | 40 | 4 listening · 4 reading · 4 grammar · 4 vocabulary | 20 min | 60% |
| ÖSD Zertifikat A1 | 40 (Austrian settings) | 4 · 4 · 4 · 4 | 20 min | 50% |
| Goethe-Zertifikat A2 | 40 | 4 · 4 · 4 · 4 | 25 min | 60% |
| Goethe-Zertifikat B1 | 40 | 4 · 4 · 4 · 4 | 30 min | 60% |

**Why 16 questions and four skills:** the assignment allows 10–15 questions; we use 16, the
smallest number that gives every skill the same weight. In the real written exams listening
(Hören) and reading (Lesen) are separate parts with equal points (Goethe A1: 25 points each, 3 parts
each; ÖSD A1: 3 tasks each; A2/B1: 4–5 parts each), so the mock gives them the same number of
questions. Vocabulary and grammar are kept as separate skills because they are what a learner can
practise directly.

**Listening** (`lib/data/banks/listening.dart`, `lib/services/speech*.dart`): each item is a German
script read aloud by the browser's built-in speech engine (Web Speech API) — no audio files, no
third-party requests from the app. It mirrors the real exam parts: short dialogues (played twice),
announcements (played **once**), phone messages, and at B1 guided talks and opinions. The play count
is saved with the attempt, so a refresh cannot reset it. Dialogues use two voices (or two pitches).
Before a mock starts, the app checks the browser has a German voice and warns *before charging*
if it does not (Chrome, Edge and Safari include one). The transcript is shown only in the analysis.

Pass marks come from the Goethe-Institut India exam FAQ and the ÖSD Durchführungsbestimmungen ZA1
(written 38/75, oral 12/25).

**A different set for every student and every retake** (`lib/services/quiz_engine.dart`):
questions are drawn only from that exam's own bank, the learner's least-seen questions are
preferred (random tie-break), then the question order and the answer options are shuffled
(Richtig/Falsch keeps its natural order).

**Final results** (`lib/services/attempt_store.dart`): a submitted mock is append-only — no edit,
no delete. The running mock is saved after every answer, so a refresh resumes the same questions
and timer; when time runs out it is submitted automatically. Leaving the exam submits it. While
a mock is running, no other mock can be started.

## How "ready" is calculated

`lib/services/readiness.dart`:

1. Each skill gets a percentage.
2. **Readiness score = 60% × overall + 40% × weakest skill** — the weakest skill weighs heavily
   because real exams fail you on one weak part (Goethe A1: every part; B1: every module; ÖSD:
   minimum per part).
3. Verdict against the real exam's pass mark *P*:
   - **Ready to book** — overall ≥ P + 15 and every skill ≥ P
   - **Almost ready** — overall ≥ P and every skill ≥ P − 20
   - **Not ready yet** — below that
4. Focus areas: topics where points were lost — one per weak skill first (weakest skill first),
   then by number of mistakes; max 3. Each comes with a quick fix, an example and how to practise.
5. **How sure is this result?** With 4 questions per skill one answer moves a skill by 25 points,
   so the analysis also shows:
   - **Close call** — getting a single question right/wrong would change the verdict.
   - **Confirmed** — the last two mocks of the same exam, pooled (32 questions, 8 per skill), give
     the same verdict. If they disagree, the app says the level is still moving.

## Brand tokens (from globio.ai CSS)

| Token | Hex |
|---|---|
| brand (navbar) | `#181C7B` |
| primary | `#2328BE` |
| hero gradient end | `#1217A5` |
| accent | `#585FE4` |
| secondary / gold | `#FFC233` → `#FFD980` |
| foreground | `#071B36` |
| muted foreground | `#667B99` |
| muted | `#F1F3F8` |
| border | `#E0E4EB` |

Font: **Poppins** 300–800, bundled in `assets/fonts` (SIL Open Font License, see `assets/fonts/OFL.txt`).

## How sign-in works (and its limits)

There is deliberately **no backend**. Accounts are stored in the browser's local storage on the
learner's own device:

- No email confirmation, no Google sign-in, nothing sent to any server.
- Passwords are never stored in plain text: PBKDF2-HMAC-SHA256 (20,000 iterations) with a random
  per-user salt, compared in constant time.
- 5 wrong passwords → 30-second cooldown. Wrong email and wrong password show the same message.
- Input limits are enforced in the service, not just the form (name ≤ 60, email ≤ 254,
  password 8–128 with a letter and a number).
- If the browser blocks storage (some private modes), the app still loads and shows a clear message.

Because it all runs in the browser, this protects the password itself but is **not** a replacement
for server-side authentication — anyone with access to the same browser profile can clear or edit
local storage. That trade-off is intended for this no-backend prototype.

## Web hardening

- Built with `--no-web-resources-cdn`: the Flutter engine (CanvasKit) and all fonts are served from
  this site, so no third-party requests are made.
- Strict Content-Security-Policy in `web/index.html` (`default-src 'self'`, no inline scripts,
  `object-src 'none'`, `form-action 'none'`), and `referrer: no-referrer`.

## Run locally

```bash
flutter pub get
flutter test
flutter run -d chrome
```

Release build:

```bash
flutter build web --release --no-web-resources-cdn
```

## Project structure

```
lib/
  main.dart                      App entry
  theme/app_theme.dart           Globio colours, gradients, theme
  data/exams.dart                Exam definitions + pass marks
  data/banks/                    160 questions (40 per exam, 10 per skill)
  data/topics.dart               Fix / example / practice tip per topic
  models/                        Question, exam and attempt models
  services/readiness.dart        Scoring + readiness formula  ← the core
  services/quiz_engine.dart      Builds a different set per learner
  services/speech.dart           Browser text-to-speech for listening (web + test stub)
  services/attempt_store.dart    Final, append-only results
  services/auth_service.dart     Local-only auth
  services/wallet_service.dart   Coins ledger and prices
  services/daily_service.dart    Daily question
  services/mentor_service.dart   Mentor slots and bookings
  services/mock_access.dart      Free biweekly mock / paid access
  services/profile_service.dart  Student ID and profile
  services/real_result_service.dart  Real exam result vs. prediction
  screens/                       Splash, landing, auth, exam, result
  screens/app_shell.dart         Dashboard shell (sidebar / bottom nav)
  screens/tabs/                  Home, Mock exams, My results, Mentor, Profile
  widgets/                       Brand, header, coin and launcher widgets
  utils/                         Date formatting, IST time helpers
test/                            Auth, question-bank, engine, readiness, coins, schedule tests
research/                        Evidence sheet: why learners fail German exams
```

**Live app:** https://himanshu-moderator.github.io/globio-exam-ready/
