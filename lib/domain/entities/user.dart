class User {
  final String id;
  final String fullName;
  final DateTime dateOfBirth;
  final String? mobile;
  final String role;
  final String? status;
  final String? lguId;
  final String? profilePicture;
  final String? address;
  final String? department;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  const User({
    required this.id,
    required this.fullName,
    required this.dateOfBirth,
    this.mobile,
    required this.role,
    this.status,
    this.lguId,
    this.profilePicture,
    this.address,
    this.department,
    required this.isVerified,
    this.createdAt,
    this.lastLogin,
  });

  bool get isActive => status == 'ACTIVE';
  bool get isCitizen => role == 'CITIZEN';
  bool get isResponder => role == 'RESPONDER';
  bool get isLguAdmin => role == 'LGU_ADMIN';
  bool get isSuperAdmin => role == 'SUPER_ADMIN';
}
