import '../constants/app_constants.dart';

class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final regex = RegExp(AppConstants.emailPattern);
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password must not exceed ${AppConstants.maxPasswordLength} characters';
    }

    final regex = RegExp(AppConstants.passwordPattern);
    if (!regex.hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number/special character';
    }

    return null;
  }

  static String? name(String? value, {required String fieldName}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < AppConstants.minNameLength) {
      return '$fieldName must be at least ${AppConstants.minNameLength} characters';
    }

    if (value.length > AppConstants.maxNameLength) {
      return '$fieldName must not exceed ${AppConstants.maxNameLength} characters';
    }

    return null;
  }

  static String? mobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }

    final regex = RegExp(AppConstants.phonePattern);
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid Philippine mobile number';
    }

    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }

    if (value.length != AppConstants.otpLength) {
      return 'OTP must be exactly ${AppConstants.otpLength} digits';
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }

    return null;
  }

  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }
}