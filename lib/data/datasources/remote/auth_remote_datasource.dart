import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../models/auth_response_model.dart';
import '../../models/user_model.dart';
import '../../../domain/params/auth_params.dart';

abstract class AuthRemoteDataSource {
  Future<RegisterResponseModel> register(RegisterParams params);
  Future<LoginResponseModel> login(LoginParams params);
  Future<VerifyOtpResponseModel> verifyOtp(VerifyOtpParams params);
  Future<MessageResponseModel> resendOtp(String identifier);
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(UpdateProfileParams params);
  Future<void> changePassword(ChangePasswordParams params);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<RegisterResponseModel> register(RegisterParams params) async {
    final response = await _dioClient.post(
      ApiConstants.register,
      data: params.toJson(),
    );
    return RegisterResponseModel.fromJson(response.data);
  }

  @override
  Future<LoginResponseModel> login(LoginParams params) async {
    final response = await _dioClient.post(
      ApiConstants.login,
      data: params.toJson(),
    );
    return LoginResponseModel.fromJson(response.data);
  }

  @override
  Future<VerifyOtpResponseModel> verifyOtp(VerifyOtpParams params) async {
    final response = await _dioClient.post(
      ApiConstants.verifyOtp,
      data: params.toJson(),
    );
    return VerifyOtpResponseModel.fromJson(response.data);
  }

  @override
  Future<MessageResponseModel> resendOtp(String identifier) async {
    final response = await _dioClient.post(
      ApiConstants.resendOtp,
      data: {'identifier': identifier},
    );
    return MessageResponseModel.fromJson(response.data);
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await _dioClient.get(ApiConstants.profile);
    // Handle both direct user object and wrapped response
    final data = response.data as Map<String, dynamic>;
    final userData = data['user'] ?? data;
    return UserModel.fromJson(userData as Map<String, dynamic>);
  }

  @override
  Future<UserModel> updateProfile(UpdateProfileParams params) async {
    final response = await _dioClient.patch(
      ApiConstants.profile,
      data: params.toJson(),
    );
    // The response contains {message: ..., user: {...}}
    // We need to extract the user object
    final data = response.data as Map<String, dynamic>;
    final userData = data['user'] ?? data;
    return UserModel.fromJson(userData as Map<String, dynamic>);
  }

  @override
  Future<void> changePassword(ChangePasswordParams params) async {
    await _dioClient.post(
      ApiConstants.changePassword,
      data: params.toJson(),
    );
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioClientProvider));
});