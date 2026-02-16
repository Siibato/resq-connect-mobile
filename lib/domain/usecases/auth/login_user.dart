import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../entities/user.dart';
import '../../params/auth_params.dart';
import '../../repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository _repository;

  LoginUser(this._repository);

  Future<Either<Failure, User>> call(LoginParams params) {
    return _repository.login(params);
  }
}

final loginUserProvider = Provider<LoginUser>((ref) {
  return LoginUser(ref.watch(authRepositoryProvider));
});