class AuthResponseModel {
  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AuthUserModel user;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      user: AuthUserModel.fromJson(
        Map<String, dynamic>.from(json['user'] as Map? ?? const {}),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }
}

class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.email,
    required this.loginId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.status,
    required this.accountType,
    required this.memberId,
    required this.roles,
    required this.permissions,
  });

  final String id;
  final String? email;
  final String? loginId;
  final String firstName;
  final String lastName;
  final String? phone;
  final String status;
  final String accountType;
  final String? memberId;
  final List<String> roles;
  final List<String> permissions;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String?,
      loginId: json['loginId'] as String?,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phone: json['phone'] as String?,
      status: json['status'] as String? ?? '',
      accountType: json['accountType'] as String? ?? '',
      memberId: json['memberId'] as String?,
      roles: _stringList(json['roles']),
      permissions: _stringList(json['permissions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'loginId': loginId,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'status': status,
      'accountType': accountType,
      'memberId': memberId,
      'roles': roles,
      'permissions': permissions,
    };
  }

  String get fullName => '$firstName $lastName'.trim();

  bool get isActive => status == 'ACTIVE';

  bool get isSystemAccount => accountType == 'SYSTEM';

  bool get isMemberAccount => accountType == 'MEMBER';

  bool get isResponsibilityAccount => accountType == 'RESPONSIBILITY';

  bool hasRole(String role) {
    return roles.contains(role);
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value.whereType<String>().toList(growable: false);
  }
}
