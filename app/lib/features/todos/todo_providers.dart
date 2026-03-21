import 'package:app/data/services/fake_firebase_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'todo_providers.g.dart';

@riverpod
FakeFirebaseService firebaseService(Ref ref) {
  final service = FakeFirebaseService();
  ref.onDispose(service.dispose);
  return service;
}
