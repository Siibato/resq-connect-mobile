import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../repositories/auth_repository.dart';

class ResendOtp {
  final AuthRepository _repository;

  ResendOtp(this._repository);

  Future<Either<Failure, void>> call(String identifier) {
    return _repository.resendOtp(identifier);
  }
}

final resendOtpProvider = Provider<ResendOtp>((ref) {
  return ResendOtp(ref.watch(authRepositoryProvider));
});