import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/services/fake_firebase_service.dart';

part 'todo_providers.g.dart';

@riverpod
FakeFirebaseService firebaseService(Ref ref) {
  final service = FakeFirebaseService();
  ref.onDispose(() => service.dispose());
  return service;
}
