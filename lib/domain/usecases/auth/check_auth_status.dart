import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/auth_repository_impl.dart';
import '../../repositories/auth_repository.dart';

class CheckAuthStatus {
  final AuthRepository _repository;

  CheckAuthStatus(this._repository);

  Future<bool> call() {
    return _repository.isLoggedIn();
  }
}

final checkAuthStatusProvider = Provider<CheckAuthStatus>((ref) {
  return CheckAuthStatus(ref.watch(authRepositoryProvider));
});