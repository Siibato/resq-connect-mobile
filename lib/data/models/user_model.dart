import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final String fullName;
  final DateTime dateOfBirth;
  final String? mobile;
  final String role;
  final String? status;
  final String? lguId;
  final String? profilePicture;
  final String? address;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.dateOfBirth,
    this.mobile,
    required this.role,
    this.status,
    this.lguId,
    this.profilePicture,
    this.address,
    required this.isVerified,
    this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse date of birth with fallback
    DateTime parsedDob;
    try {
      parsedDob = DateTime.parse(json['dateOfBirth']?.toString() ?? json['date_of_birth']?.toString() ?? '');
    } catch (e) {
      parsedDob = DateTime.now().subtract(const Duration(days: 365 * 18)); // Default to 18 years ago
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['full_name']?.toString() ?? '',
      dateOfBirth: parsedDob,
      mobile: json['mobile']?.toString(),
      role: json['role']?.toString() ?? 'USER',
      status: json['status']?.toString(),
      lguId: json['lguId']?.toString() ?? json['lgu_id']?.toString(),
      profilePicture: json['profilePicture']?.toString() ?? json['profile_picture']?.toString(),
      address: json['address']?.toString(),
      isVerified: (json['isVerified'] as bool?) ?? (json['is_verified'] as bool?) ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
      lastLogin: json['lastLogin'] != null
          ? DateTime.tryParse(json['lastLogin'].toString())
          : json['last_login'] != null
              ? DateTime.tryParse(json['last_login'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'mobile': mobile,
      'role': role,
      'status': status,
      'lguId': lguId,
      'profilePicture': profilePicture,
      'address': address,
      'isVerified': isVerified,
      'createdAt': createdAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  User toEntity() {
    return User(
      id: id,
      fullName: fullName,
      dateOfBirth: dateOfBirth,
      mobile: mobile,
      role: role,
      status: status,
      lguId: lguId,
      profilePicture: profilePicture,
      address: address,
      isVerified: isVerified,
      createdAt: createdAt,
      lastLogin: lastLogin,
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      fullName: user.fullName,
      dateOfBirth: user.dateOfBirth,
      mobile: user.mobile,
      role: user.role,
      status: user.status,
      lguId: user.lguId,
      profilePicture: user.profilePicture,
      address: user.address,
      isVerified: user.isVerified,
      createdAt: user.createdAt,
      lastLogin: user.lastLogin,
    );
  }
}
