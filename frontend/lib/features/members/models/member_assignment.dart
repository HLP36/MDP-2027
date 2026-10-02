class MemberAssignment {
  const MemberAssignment({
    this.teamId,
    this.teamName,
    this.teamLeaderId,
    this.teamLeaderName,
    this.supervisorId,
    this.supervisorName,
    this.inspectorId,
    this.inspectorName,
  });

  final String? teamId;
  final String? teamName;

  final String? teamLeaderId;
  final String? teamLeaderName;

  final String? supervisorId;
  final String? supervisorName;

  final String? inspectorId;
  final String? inspectorName;

  factory MemberAssignment.fromJson(Map<String, dynamic> json) {
    return MemberAssignment(
      teamId: json['teamId'] as String?,
      teamName: json['teamName'] as String?,
      teamLeaderId: json['teamLeaderId'] as String?,
      teamLeaderName: json['teamLeaderName'] as String?,
      supervisorId: json['supervisorId'] as String?,
      supervisorName: json['supervisorName'] as String?,
      inspectorId: json['inspectorId'] as String?,
      inspectorName: json['inspectorName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'teamName': teamName,
      'teamLeaderId': teamLeaderId,
      'teamLeaderName': teamLeaderName,
      'supervisorId': supervisorId,
      'supervisorName': supervisorName,
      'inspectorId': inspectorId,
      'inspectorName': inspectorName,
    };
  }

  MemberAssignment copyWith({
    String? teamId,
    String? teamName,
    String? teamLeaderId,
    String? teamLeaderName,
    String? supervisorId,
    String? supervisorName,
    String? inspectorId,
    String? inspectorName,
  }) {
    return MemberAssignment(
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      teamLeaderId: teamLeaderId ?? this.teamLeaderId,
      teamLeaderName: teamLeaderName ?? this.teamLeaderName,
      supervisorId: supervisorId ?? this.supervisorId,
      supervisorName: supervisorName ?? this.supervisorName,
      inspectorId: inspectorId ?? this.inspectorId,
      inspectorName: inspectorName ?? this.inspectorName,
    );
  }
}
