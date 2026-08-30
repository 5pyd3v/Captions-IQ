# Caption IQ


## How it works

1. **Add screenshots** — pick as many images as you like from your gallery.
2. **On-device OCR** — each image is run through Google ML Kit's text
   recognizer *on the device*. Images are never uploaded anywhere.
3. **Summarize** — the combined extracted text is sent to the Gemini API
   (using your own API key) with a prompt tuned to produce a natural,
   speakable summary in English and in Roman Urdu (Urdu written in the
   Latin alphabet, not Arabic script).
4. **Share & save** — the summary is saved to your history and one tap opens
   WhatsApp with it ready to send.

## One-time setup

### 1. Create a Supabase project

Go to [supabase.com](https://supabase.com), create a free project, then open
**SQL Editor** and run [`supabase/schema.sql`](supabase/schema.sql). This
creates the `scan_sessions` table with Row Level Security so every device
can only ever read/write its own history.

Then go to **Authentication → Providers → Anonymous** and enable it — the
app signs each device in anonymously (no login screen, no password) so
history stays private per-install without any signup friction.

### 2. Connect the app to Supabase

Open [`lib/core/config/supabase_config.dart`](lib/core/config/supabase_config.dart)
and replace the placeholders with your project's URL and anon/publishable
key (**Project Settings → API**):

```dart
static const String url = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://xxxxxxxx.supabase.co', // <- your project URL
);

static const String anonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'ey...', // <- your anon/publishable key
);
```

Or, without editing the file, pass them at build/run time:

```bash
flutter run --dart-define=SUPABASE_URL=https://xxxxxxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=ey...
```

If these are left as placeholders the app shows a friendly "setup needed"
screen instead of crashing.

### 3. Get a Gemini API key

Get a free key at [aistudio.google.com/apikey](https://aistudio.google.com/apikey).
You don't need to put it in code — open the app, go to **Settings**, and
paste it in. It's encrypted and stored only on that device (Android
Keystore / iOS Keychain), and can be changed or removed at any time from
the same screen.

### 4. Run it

```bash
flutter pub get
flutter run
```

## Architecture

```
lib/
  core/
    config/     Supabase config, Gemini config, go_router setup
    theme/      Design tokens: colors, spacing, typography, ThemeData
  models/       HistoryItem
  services/     OcrService (ML Kit), GeminiService (REST), SupabaseService,
                SecureKeyStore (encrypted API key storage)
  state/        Riverpod controllers: scan pipeline, history, settings
  screens/      Home (upload), Processing, Result, History (+ detail),
                Settings, root bottom-nav shell
  widgets/      Reusable UI: buttons, summary cards, image grid, empty
                states, WhatsApp share button
supabase/
  schema.sql    Table + RLS policies to run in the Supabase SQL editor
```

State management is [Riverpod](https://riverpod.dev). Navigation is
[go_router](https://pub.dev/packages/go_router). The scan pipeline
(`ScanController` in `lib/state/scan_controller.dart`) drives OCR → Gemini →
Supabase save, reporting progress the whole way so the Processing screen can
show live status for batches of 100+ screenshots without blocking the UI.

## Privacy notes

- Screenshots themselves never leave the device — only the OCR'd **text**
  is sent to Gemini, and only that text plus the resulting summaries are
  saved to Supabase.
- The Gemini API key never touches Supabase or any server of ours; it's
  read from encrypted local storage and used only to call Google's Gemini
  endpoint directly from the device.
