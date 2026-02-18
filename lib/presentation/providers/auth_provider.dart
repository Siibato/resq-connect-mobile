import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/params/auth_params.dart';
import '../../domain/usecases/auth/login_user.dart';
import '../../domain/usecases/auth/logout_user.dart';
import '../../domain/usecases/auth/register_user.dart';
import '../../domain/usecases/auth/resend_otp.dart';
import '../../domain/usecases/auth/verify_otp.dart';
import '../../domain/usecases/auth/check_auth_status.dart';
import '../../domain/usecases/auth/get_current_user.dart';
import 'auth_state.dart';

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState.initial();
  }

  LoginUser get _loginUser => ref.read(loginUserProvider);
  RegisterUser get _registerUser => ref.read(registerUserProvider);
  VerifyOtp get _verifyOtp => ref.read(verifyOtpProvider);
  ResendOtp get _resendOtp => ref.read(resendOtpProvider);
  LogoutUser get _logoutUser => ref.read(logoutUserProvider);
  CheckAuthStatus get _checkAuthStatus => ref.read(checkAuthStatusProvider);
  GetCurrentUser get _getCurrentUser => ref.read(getCurrentUserProvider);

  Future<void> register({
    required String fullName,
    required DateTime dateOfBirth,
    required String mobile,
    required String password,
    required String role,
  }) async {
    state = const AuthState.loading();

    final result = await _registerUser(RegisterParams(
      fullName: fullName,
      dateOfBirth: dateOfBirth,
      mobile: mobile,
      password: password,
      role: role,
    ));

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.registered(fullName),
    );
  }

  Future<void> login({
    required String name,
    required String phone,
    required String password,
  }) async {
    state = const AuthState.loading();

    final result = await _loginUser(LoginParams(
      name: name,
      phone: phone,
      password: password,
    ));

    result.fold(
      (failure) {
        if (failure.message == 'Please verify your account first') {
          state = AuthState.unverified(name);
        } else {
          state = AuthState.error(failure.message);
        }
      },
      (user) => state = AuthState.authenticated(user),
    );
  }

  Future<void> verifyOtp(String identifier, String otp) async {
    state = const AuthState.loading();

    final result = await _verifyOtp(VerifyOtpParams(
      identifier: identifier,
      otp: otp,
    ));

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }

  Future<void> resendOtp(String identifier) async {
    final result = await _resendOtp(identifier);
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (_) {},
    );
  }

  Future<void> logout() async {
    await _logoutUser();
    state = const AuthState.unauthenticated();
  }

  Future<void> updateProfile(UpdateProfileParams params) async {
    state = const AuthState.loading();
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.updateProfile(params);
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }

  Future<bool> changePassword(ChangePasswordParams params) async {
    final currentUser = state.maybeWhen(
      authenticated: (user) => user,
      orElse: () => null,
    );
    state = const AuthState.loading();
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.changePassword(params);
    return result.fold(
      (failure) {
        state = AuthState.error(failure.message);
        return false;
      },
      (_) {
        if (currentUser != null) state = AuthState.authenticated(currentUser);
        return true;
      },
    );
  }

  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _checkAuthStatus();
    if (isLoggedIn) {
      final userResult = await _getCurrentUser();
      userResult.fold(
        (_) => state = const AuthState.unauthenticated(),
        (user) => state = AuthState.authenticated(user),
      );
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  void clearError() {
    state.maybeWhen(
      error: (_) => state = const AuthState.unauthenticated(),
      unverified: (_) => state = const AuthState.unauthenticated(),
      orElse: () {},
    );
  }
}
