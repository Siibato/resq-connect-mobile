class RegisterParams {
  final String fullName;
  final DateTime dateOfBirth;
  final String mobile;
  final String password;
  final String role;

  const RegisterParams({
    required this.fullName,
    required this.dateOfBirth,
    required this.mobile,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'mobile': mobile,
        'password': password,
        'role': role,
      };
}

class LoginParams {
  final String name;
  final String phone;
  final String password;

  const LoginParams({
    required this.name,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'password': password,
      };
}

class VerifyOtpParams {
  final String identifier; // Can be mobile or name
  final String otp;

  const VerifyOtpParams({
    required this.identifier,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'identifier': identifier,
        'otp': otp,
      };
}

class UpdateProfileParams {
  final String? fullName;
  final DateTime? dateOfBirth;
  final String? mobile;
  final String? address;
  final String? notificationPreference;

  const UpdateProfileParams({
    this.fullName,
    this.dateOfBirth,
    this.mobile,
    this.address,
    this.notificationPreference,
  });

  Map<String, dynamic> toJson() => {
        if (fullName != null) 'fullName': fullName,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
        if (mobile != null) 'mobile': mobile,
        if (address != null) 'address': address,
        if (notificationPreference != null)
          'notificationPreference': notificationPreference,
      };
}

class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      };
}
