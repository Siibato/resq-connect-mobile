import 'package:fpdart/fpdart.dart';

import '../../core/errors/failures.dart';
import '../entities/user.dart';
import '../params/auth_params.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> register(RegisterParams params);
  Future<Either<Failure, User>> login(LoginParams params);
  Future<Either<Failure, User>> verifyOtp(VerifyOtpParams params);
  Future<Either<Failure, void>> resendOtp(String identifier);
  Future<Either<Failure, User>> getProfile();
  Future<Either<Failure, User>> updateProfile(UpdateProfileParams params);
  Future<Either<Failure, void>> changePassword(ChangePasswordParams params);
  Future<Either<Failure, void>> logout();
  Future<bool> isLoggedIn();
  Future<User?> getCachedUser();
}