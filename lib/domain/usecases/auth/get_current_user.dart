import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository _repository;

  GetCurrentUser(this._repository);

  Future<Either<Failure, User>> call() {
    return _repository.getProfile();
  }

  Future<User?> getCached() {
    return _repository.getCachedUser();
  }
}

final getCurrentUserProvider = Provider<GetCurrentUser>((ref) {
  return GetCurrentUser(ref.watch(authRepositoryProvider));
});