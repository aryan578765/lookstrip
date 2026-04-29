# LooksTrip

AI-powered Flutter travel planner with phone auth, local-first trip storage,
Supabase sync, Mapbox maps, backend-proxied itinerary/chat generation, backend
proxy travel search, expenses, packing lists, and trip collaboration.

## Setup

1. Install Flutter for the SDK version in `pubspec.yaml`.
2. Run `flutter pub get`.
3. Copy `.env.example` to `.env` for local development, or provide the same
   keys with `--dart-define` / `--dart-define-from-file` in production.
4. Deploy `supabase/functions/travel-proxy` or another compatible backend proxy.
5. Configure backend secrets from `supabase/functions/travel-proxy/.env.example`.
6. Run `supabase_migration.sql` in the Supabase SQL editor.
7. Run `supabase_collaboration_patch.sql` after the base migration.
8. Start the app with `flutter run`.

## Environment

`BACKEND_PROXY_BASE_URL` points the app to the backend proxy used for AI and
live travel search. OpenRouter and SerpApi keys must stay on that backend, not
inside the mobile app.
`DEFAULT_DEPARTURE_AIRPORT` is the default IATA/city code for flight search.
`MAPBOX_ACCESS_TOKEN` enables destination maps.
`SUPABASE_URL` and `SUPABASE_ANON_KEY` enable auth, cloud sync, and sharing.

## Verification

Use these before shipping changes:

```sh
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
```

For Android release builds, add `android/key.properties` with `keyAlias`,
`keyPassword`, `storeFile`, and `storePassword`. Release builds no longer use
debug signing keys.
