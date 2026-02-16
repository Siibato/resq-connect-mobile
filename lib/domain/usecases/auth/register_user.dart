import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../entities/user.dart';
import '../../params/auth_params.dart';
import '../../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository _repository;

  RegisterUser(this._repository);

  Future<Either<Failure, User>> call(RegisterParams params) {
    return _repository.register(params);
  }
}

final registerUserProvider = Provider<RegisterUser>((ref) {
  return RegisterUser(ref.watch(authRepositoryProvider));
});