sealed class Failure {
  final String message;

  const Failure(this.message);

  String get displayMessage => message;

  factory Failure.server({required String message, int? statusCode}) =
      ServerFailure;
  factory Failure.network({required String message}) = NetworkFailure;
  factory Failure.cache({required String message}) = CacheFailure;
  factory Failure.validation(
      {required String message, Map<String, String>? errors}) = ValidationFailure;
  factory Failure.authentication({required String message}) =
      AuthenticationFailure;
  factory Failure.unauthorized({required String message}) = UnauthorizedFailure;
  factory Failure.unexpected({required String message}) = UnexpectedFailure;
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({required String message, this.statusCode})
      : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message);
}

class ValidationFailure extends Failure {
  final Map<String, String>? errors;

  const ValidationFailure({required String message, this.errors})
      : super(message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required String message}) : super(message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required String message}) : super(message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required String message}) : super(message);
}