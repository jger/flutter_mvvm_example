## Flutter MVVM Example (Fake Firebase BaaS)

This example shows a minimal MVVM-style Flutter app using `flutter_riverpod` and a fake Firebase-like backend service.

- **Architecture**: MVVM with small layers (`core` fake backend, `features` with `model`, `view_model`, `view`).
- **Backend**: `FakeFirebaseService` simulates auth + todos as if backed by Firebase.
- **UI/Web**: Material 3, responsive layout, centered constrained content for good web ergonomics.

Run in web:

```bash
cd app
flutter run -d chrome
```

