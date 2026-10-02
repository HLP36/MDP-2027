class City {
  const City({
    required this.id,
    required this.name,
    required this.code,
    this.country,
    this.isActive = true,
    this.memberCount = 0,
  });

  final String id;
  final String name;
  final String code;
  final String? country;
  final bool isActive;
  final int memberCount;

  factory City.fromJson(Map<String, dynamic> json) {
    final count = json['_count'];

    return City(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      country: json['country'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      memberCount: count is Map
          ? (count['members'] as int? ?? 0)
          : (json['memberCount'] as int? ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'country': country,
      'isActive': isActive,
      'memberCount': memberCount,
    };
  }
}
