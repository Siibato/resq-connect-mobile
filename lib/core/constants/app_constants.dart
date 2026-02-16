class AppConstants {
  AppConstants._();

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int otpLength = 6;

  // OTP
  static const int otpExpiryMinutes = 10;
  static const int otpResendCooldownSeconds = 60;

  // Regex patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^(\+639|09)\d{9}$';
  static const String passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[\d\W]).{8,32}$';
}