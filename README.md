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
| Readiness check (10–15 questions: vocabulary, grammar, reading) | ⏳ Next |
| Result page with per-skill breakdown + 2–3 focus areas | ⏳ Next |

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
  main.dart                 App entry
  theme/app_theme.dart      Globio colours, gradients, theme
  services/auth_service.dart Local-only auth
  screens/splash_screen.dart
  screens/landing_screen.dart
  screens/auth_screen.dart
  widgets/brand_widgets.dart Logo, gold text, pill buttons, dot pattern
test/auth_service_test.dart Auth unit tests
research/                   Evidence sheet: why learners fail German exams
```
