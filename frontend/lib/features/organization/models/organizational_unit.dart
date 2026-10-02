class OrganizationalUnit {
  const OrganizationalUnit({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.parentId,
    this.leaderId,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.parent,
    this.leader,
    this.children = const [],
    this.childrenCount,
    this.usersCount,
  });

  final String id;
  final String name;
  final String type;
  final String? description;

  final String? parentId;
  final String? leaderId;

  final bool isActive;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final OrganizationalUnitSummary? parent;
  final OrganizationalUnitLeader? leader;

  final List<OrganizationalUnit> children;

  final int? childrenCount;
  final int? usersCount;

  factory OrganizationalUnit.fromJson(Map<String, dynamic> json) {
    final count = json['_count'];

    return OrganizationalUnit(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      parentId: json['parentId'] as String?,
      leaderId: json['leaderId'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      parent: json['parent'] is Map
          ? OrganizationalUnitSummary.fromJson(
              Map<String, dynamic>.from(json['parent'] as Map),
            )
          : null,
      leader: json['leader'] is Map
          ? OrganizationalUnitLeader.fromJson(
              Map<String, dynamic>.from(json['leader'] as Map),
            )
          : null,
      children: json['children'] is List
          ? (json['children'] as List)
                .whereType<Map>()
                .map(
                  (item) => OrganizationalUnit.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
      childrenCount: count is Map ? (count['children'] as num?)?.toInt() : null,
      usersCount: count is Map ? (count['users'] as num?)?.toInt() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'parentId': parentId,
      'leaderId': leaderId,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'parent': parent?.toJson(),
      'leader': leader?.toJson(),
      'children': children.map((item) => item.toJson()).toList(),
      '_count': {'children': childrenCount, 'users': usersCount},
    };
  }

  OrganizationalUnit copyWith({
    String? id,
    String? name,
    String? type,
    String? description,
    String? parentId,
    String? leaderId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    OrganizationalUnitSummary? parent,
    OrganizationalUnitLeader? leader,
    List<OrganizationalUnit>? children,
    int? childrenCount,
    int? usersCount,
  }) {
    return OrganizationalUnit(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      leaderId: leaderId ?? this.leaderId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parent: parent ?? this.parent,
      leader: leader ?? this.leader,
      children: children ?? this.children,
      childrenCount: childrenCount ?? this.childrenCount,
      usersCount: usersCount ?? this.usersCount,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}

class OrganizationalUnitSummary {
  const OrganizationalUnitSummary({
    required this.id,
    required this.name,
    required this.type,
  });

  final String id;
  final String name;
  final String type;

  factory OrganizationalUnitSummary.fromJson(Map<String, dynamic> json) {
    return OrganizationalUnitSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'type': type};
  }
}

class OrganizationalUnitLeader {
  const OrganizationalUnitLeader({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.status,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? status;

  String get fullName => '$firstName $lastName'.trim();

  factory OrganizationalUnitLeader.fromJson(Map<String, dynamic> json) {
    return OrganizationalUnitLeader(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'status': status,
    };
  }
}
