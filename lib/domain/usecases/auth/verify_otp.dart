import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../entities/user.dart';
import '../../params/auth_params.dart';
import '../../repositories/auth_repository.dart';

class VerifyOtp {
  final AuthRepository _repository;

  VerifyOtp(this._repository);

  Future<Either<Failure, User>> call(VerifyOtpParams params) {
    return _repository.verifyOtp(params);
  }
}

final verifyOtpProvider = Provider<VerifyOtp>((ref) {
  return VerifyOtp(ref.watch(authRepositoryProvider));
});