import 'member_assignment.dart';
import 'member_credentials.dart';

enum MemberStatus { active, inactive, suspended }

class Member {
  const Member({
    required this.id,
    required this.memberCode,
    required this.firstName,
    required this.lastName,
    this.postName,
    this.phone,
    this.address,
    this.field,
    this.district,
    this.church,
    this.joinedAt,
    this.status = MemberStatus.active,
    this.assignment,
    this.credentials,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String memberCode;

  final String firstName;
  final String lastName;
  final String? postName;

  final String? phone;
  final String? address;

  final String? field;
  final String? district;
  final String? church;

  final DateTime? joinedAt;

  final MemberStatus status;

  final MemberAssignment? assignment;
  final MemberCredentials? credentials;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ---------------------------------------------------------------------------
  // DISPLAY
  // ---------------------------------------------------------------------------

  String get fullName {
    return [
      lastName,
      postName,
      firstName,
    ].whereType<String>().where((e) => e.trim().isNotEmpty).join(' ');
  }

  String get statusLabel {
    switch (status) {
      case MemberStatus.active:
        return 'Actif';

      case MemberStatus.inactive:
        return 'Inactif';

      case MemberStatus.suspended:
        return 'Suspendu';
    }
  }

  bool get isActive {
    return status == MemberStatus.active;
  }

  bool get isInactive {
    return status == MemberStatus.inactive;
  }

  bool get isSuspended {
    return status == MemberStatus.suspended;
  }

  // ---------------------------------------------------------------------------
  // JSON
  // ---------------------------------------------------------------------------

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      memberCode: json['memberCode'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      postName: json['postName'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      field: json['field'] as String?,
      district: json['district'] as String?,
      church: json['church'] as String?,
      joinedAt: _parseDate(json['joinedAt']),
      status: _parseStatus(json['status']),
      assignment: _parseAssignment(json['assignment']),
      credentials: _parseCredentials(json['credentials']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberCode': memberCode,
      'firstName': firstName,
      'lastName': lastName,
      'postName': postName,
      'phone': phone,
      'address': address,
      'field': field,
      'district': district,
      'church': church,
      'joinedAt': joinedAt?.toIso8601String(),
      'status': status.name,
      'assignment': assignment?.toJson(),
      'credentials': credentials?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // COPY
  // ---------------------------------------------------------------------------

  Member copyWith({
    String? id,
    String? memberCode,
    String? firstName,
    String? lastName,
    String? postName,
    String? phone,
    String? address,
    String? field,
    String? district,
    String? church,
    DateTime? joinedAt,
    MemberStatus? status,
    MemberAssignment? assignment,
    MemberCredentials? credentials,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Member(
      id: id ?? this.id,
      memberCode: memberCode ?? this.memberCode,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      postName: postName ?? this.postName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      field: field ?? this.field,
      district: district ?? this.district,
      church: church ?? this.church,
      joinedAt: joinedAt ?? this.joinedAt,
      status: status ?? this.status,
      assignment: assignment ?? this.assignment,
      credentials: credentials ?? this.credentials,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ---------------------------------------------------------------------------
  // PARSERS
  // ---------------------------------------------------------------------------

  static MemberStatus _parseStatus(dynamic value) {
    switch (value?.toString().toLowerCase()) {
      case 'inactive':
        return MemberStatus.inactive;

      case 'suspended':
        return MemberStatus.suspended;

      case 'active':
      default:
        return MemberStatus.active;
    }
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  static MemberAssignment? _parseAssignment(dynamic value) {
    if (value is! Map) {
      return null;
    }

    return MemberAssignment.fromJson(Map<String, dynamic>.from(value));
  }

  static MemberCredentials? _parseCredentials(dynamic value) {
    if (value is! Map) {
      return null;
    }

    return MemberCredentials.fromJson(Map<String, dynamic>.from(value));
  }
}
