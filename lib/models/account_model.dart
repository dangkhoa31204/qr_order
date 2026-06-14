// Model đồng bộ với bảng [Accounts] trong QROrderingDB
// Role: 1 = Admin, 2 = Staff

enum AccountRole {
  admin(1, 'Admin'),
  staff(2, 'Staff');

  final int value;
  final String label;
  const AccountRole(this.value, this.label);

  static AccountRole fromInt(int v) {
    switch (v) {
      case 1:
        return AccountRole.admin;
      case 2:
      default:
        return AccountRole.staff;
    }
  }
}

class AccountModel {
  final int accountId;
  final String username;
  final String email;
  final String passwordHash;
  final String fullName;
  final String? phoneNumber;
  final AccountRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  AccountModel({
    required this.accountId,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.fullName,
    this.phoneNumber,
    required this.role,
    this.isActive = true,
    DateTime? createdAt,
    this.lastLoginAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      accountId: json['accountId'] as int? ?? 0,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      passwordHash: json['passwordHash']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString(),
      role: AccountRole.fromInt(json['role'] as int? ?? 2),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role.value,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  AccountModel copyWith({
    int? accountId,
    String? username,
    String? email,
    String? passwordHash,
    String? fullName,
    String? phoneNumber,
    AccountRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return AccountModel(
      accountId: accountId ?? this.accountId,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

/// Model phản hồi từ API /api/Auth/login
/// Khớp với LoginResponse schema từ Swagger
class LoginResponse {
  final String accessToken;
  final DateTime expiresAt;
  final String username;
  final int role;

  LoginResponse({
    required this.accessToken,
    required this.expiresAt,
    required this.username,
    required this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken']?.toString() ?? '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      username: json['username']?.toString() ?? '',
      role: json['role'] != null 
          ? (int.tryParse(json['role'].toString()) ?? 2)
          : 2,
    );
  }

  /// Chuyển LoginResponse thành AccountModel để sử dụng trong app
  AccountModel toAccountModel() {
    return AccountModel(
      accountId: 0,
      username: username,
      email: '',
      passwordHash: '',
      fullName: username,
      role: AccountRole.fromInt(role),
      lastLoginAt: DateTime.now(),
    );
  }
}

/// Seed admin account khớp DB
final AccountModel seedAdmin = AccountModel(
  accountId: 1,
  username: 'admin',
  email: 'admin@qrorder.com',
  passwordHash: '\$2a\$11\$ReplaceWithBCryptHash',
  fullName: 'System Administrator',
  role: AccountRole.admin,
);

/// Mock staff account để test
final AccountModel seedStaff = AccountModel(
  accountId: 2,
  username: 'staff',
  email: 'staff@qrorder.com',
  passwordHash: '12345',
  fullName: 'Nhân viên QR Order',
  role: AccountRole.staff,
);
