import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../repositories/auth_repository.dart';

class LogoutUser {
  final AuthRepository _repository;

  LogoutUser(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.logout();
  }
}

final logoutUserProvider = Provider<LogoutUser>((ref) {
  return LogoutUser(ref.watch(authRepositoryProvider));
});