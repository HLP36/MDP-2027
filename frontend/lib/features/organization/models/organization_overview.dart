class OrganizationOverview {
  const OrganizationOverview({
    required this.unitsCount,
    required this.membersCount,
    required this.leadersCount,
    required this.alertsCount,
  });

  final int unitsCount;
  final int membersCount;
  final int leadersCount;
  final int alertsCount;

  factory OrganizationOverview.fromJson(Map<String, dynamic> json) {
    return OrganizationOverview(
      unitsCount: _toInt(json['unitsCount']),
      membersCount: _toInt(json['membersCount']),
      leadersCount: _toInt(json['leadersCount']),
      alertsCount: _toInt(json['alertsCount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unitsCount': unitsCount,
      'membersCount': membersCount,
      'leadersCount': leadersCount,
      'alertsCount': alertsCount,
    };
  }

  static int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
