class MemberCredentials {
  const MemberCredentials({
    required this.loginId,
    this.temporaryPassword,
    this.isPasswordChanged = false,
  });

  final String loginId;
  final String? temporaryPassword;
  final bool isPasswordChanged;

  factory MemberCredentials.fromJson(Map<String, dynamic> json) {
    return MemberCredentials(
      loginId: json['loginId'] as String,
      temporaryPassword: json['temporaryPassword'] as String?,
      isPasswordChanged: json['isPasswordChanged'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loginId': loginId,
      'temporaryPassword': temporaryPassword,
      'isPasswordChanged': isPasswordChanged,
    };
  }
}
