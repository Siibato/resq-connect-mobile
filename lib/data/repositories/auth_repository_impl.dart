import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/params/auth_params.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/secure_storage.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorage secureStorage,
  })  : _remoteDataSource = remoteDataSource,
        _secureStorage = secureStorage;

  @override
  Future<Either<Failure, User>> register(RegisterParams params) async {
    try {
      final response = await _remoteDataSource.register(params);
      return Right(response.user.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } on ValidationException catch (e) {
      return Left(Failure.validation(message: e.message, errors: e.errors));
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> login(LoginParams params) async {
    try {
      final response = await _remoteDataSource.login(params);
      
      // Save token and user to secure storage
      await _secureStorage.saveAccessToken(response.accessToken);
      await _secureStorage.saveUser(response.user);
      
      return Right(response.user.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(Failure.authentication(message: e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } on CacheException catch (e) {
      return Left(Failure.cache(message: e.message));
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> verifyOtp(VerifyOtpParams params) async {
    try {
      final response = await _remoteDataSource.verifyOtp(params);
      await _secureStorage.saveAccessToken(response.accessToken);
      await _secureStorage.saveUser(response.user);
      return Right(response.user.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } on ValidationException catch (e) {
      return Left(Failure.validation(message: e.message, errors: e.errors));
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendOtp(String identifier) async {
    try {
      await _remoteDataSource.resendOtp(identifier);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(UpdateProfileParams params) async {
    try {
      final userModel = await _remoteDataSource.updateProfile(params);
      await _secureStorage.saveUser(userModel);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } on ValidationException catch (e) {
      return Left(Failure.validation(message: e.message));
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
    ChangePasswordParams params,
  ) async {
    try {
      await _remoteDataSource.changePassword(params);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on UnauthorizedException catch (e) {
      return Left(Failure.authentication(message: e.message));
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final userModel = await _remoteDataSource.getProfile();
      
      // Update cached user
      await _secureStorage.saveUser(userModel);
      
      return Right(userModel.toEntity());
    } on UnauthorizedException catch (e) {
      await logout(); // Clear auth state on 401
      return Left(Failure.unauthorized(message: e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _secureStorage.clearAll();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(Failure.cache(message: e.message));
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await _secureStorage.getAccessToken();
      return token != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<User?> getCachedUser() async {
    try {
      final userModel = await _secureStorage.getUser();
      return userModel?.toEntity();
    } catch (e) {
      return null;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    secureStorage: ref.watch(secureStorageProvider),);
});