import '../../domain/entities/user.dart';

sealed class AuthState {
  const AuthState();

  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.loading() = AuthStateLoading;
  const factory AuthState.authenticated(User user) = AuthStateAuthenticated;
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;
  const factory AuthState.registered(String identifier) = AuthStateRegistered;
  const factory AuthState.otpVerified() = AuthStateOtpVerified;
  const factory AuthState.unverified(String identifier) = AuthStateUnverified;
  const factory AuthState.error(String message) = AuthStateError;

  bool get isLoading => this is AuthStateLoading;
  bool get isAuthenticated => this is AuthStateAuthenticated;
  bool get isUnauthenticated => this is AuthStateUnauthenticated;
  bool get isRegistered => this is AuthStateRegistered;
  bool get isOtpVerified => this is AuthStateOtpVerified;
  bool get isUnverified => this is AuthStateUnverified;
  bool get isError => this is AuthStateError;

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(User user) authenticated,
    required T Function() unauthenticated,
    required T Function(String identifier) registered,
    required T Function() otpVerified,
    required T Function(String identifier) unverified,
    required T Function(String message) error,
  }) {
    return switch (this) {
      AuthStateInitial() => initial(),
      AuthStateLoading() => loading(),
      AuthStateAuthenticated(user: final user) => authenticated(user),
      AuthStateUnauthenticated() => unauthenticated(),
      AuthStateRegistered(identifier: final identifier) => registered(identifier),
      AuthStateOtpVerified() => otpVerified(),
      AuthStateUnverified(identifier: final identifier) => unverified(identifier),
      AuthStateError(message: final message) => error(message),
    };
  }

  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(User user)? authenticated,
    T Function()? unauthenticated,
    T Function(String identifier)? registered,
    T Function()? otpVerified,
    T Function(String identifier)? unverified,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    return switch (this) {
      AuthStateInitial() => initial != null ? initial() : orElse(),
      AuthStateLoading() => loading != null ? loading() : orElse(),
      AuthStateAuthenticated(user: final user) =>
        authenticated != null ? authenticated(user) : orElse(),
      AuthStateUnauthenticated() =>
        unauthenticated != null ? unauthenticated() : orElse(),
      AuthStateRegistered(identifier: final identifier) =>
        registered != null ? registered(identifier) : orElse(),
      AuthStateOtpVerified() =>
        otpVerified != null ? otpVerified() : orElse(),
      AuthStateUnverified(identifier: final identifier) =>
        unverified != null ? unverified(identifier) : orElse(),
      AuthStateError(message: final message) =>
        error != null ? error(message) : orElse(),
    };
  }
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateAuthenticated extends AuthState {
  final User user;
  const AuthStateAuthenticated(this.user);
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

class AuthStateRegistered extends AuthState {
  final String identifier;
  const AuthStateRegistered(this.identifier);
}

class AuthStateOtpVerified extends AuthState {
  const AuthStateOtpVerified();
}

class AuthStateUnverified extends AuthState {
  final String identifier;
  const AuthStateUnverified(this.identifier);
}

class AuthStateError extends AuthState {
  final String message;
  const AuthStateError(this.message);
}
