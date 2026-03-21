## Flutter MVVM Example (Fake Firebase BaaS)

MVVM-Beispiel mit `flutter_riverpod`, Fake-Backend und Schichten `data` / `domain` / `features`.

- **Architektur**: MVVM; `data` (Service + Repository), `domain` (Models), `features` (State, ViewModel, View, Provider).
- **Backend**: `FakeFirebaseService` simuliert ein Firebase-ähnliches Todo-API (keine echte Auth im Code; nur Platzhalter in Doku möglich).
- **UI**: Material 3, Hell/Dunkel (System), **easy_localization** mit **EN / DE / EL** (`assets/translations/`), Sprachmenü in der AppBar, Semantics, Web-Layout mit max. Breite.

```bash
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome
```

Tests & Analyse:

```bash
flutter test
flutter analyze
```
