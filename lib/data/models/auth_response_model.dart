import 'user_model.dart';

class LoginResponseModel {
  final String message;
  final String accessToken;
  final UserModel user;

  const LoginResponseModel({
    required this.message,
    required this.accessToken,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      message: json['message'] as String,
      accessToken: json['accessToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class RegisterResponseModel {
  final String message;
  final UserModel user;

  const RegisterResponseModel({
    required this.message,
    required this.user,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      message: json['message'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class VerifyOtpResponseModel {
  final String message;
  final String accessToken;
  final UserModel user;

  const VerifyOtpResponseModel({
    required this.message,
    required this.accessToken,
    required this.user,
  });

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseModel(
      message: json['message'] as String,
      accessToken: json['accessToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class MessageResponseModel {
  final String message;

  const MessageResponseModel({
    required this.message,
  });

  factory MessageResponseModel.fromJson(Map<String, dynamic> json) {
    return MessageResponseModel(
      message: json['message'] as String,
    );
  }
}
