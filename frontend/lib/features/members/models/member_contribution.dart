enum MemberContributionStatus { pending, partiallyPaid, paid, ahead }

class MemberContribution {
  const MemberContribution({
    required this.id,
    required this.year,
    required this.month,
    required this.expectedAmount,
    required this.paidAmount,
    required this.balance,
    required this.advanceAmount,
    required this.status,
    this.paidAt,
  });

  final String id;
  final int year;
  final int month;

  final double expectedAmount;
  final double paidAmount;
  final double balance;
  final double advanceAmount;

  final MemberContributionStatus status;
  final DateTime? paidAt;

  factory MemberContribution.fromJson(Map<String, dynamic> json) {
    return MemberContribution(
      id: json['id'] as String,
      year: _toInt(json['year']),
      month: _toInt(json['month']),
      expectedAmount: _toDouble(json['expectedAmount']),
      paidAmount: _toDouble(json['paidAmount']),
      balance: _toDouble(json['balance']),
      advanceAmount: _toDouble(json['advanceAmount']),
      status: _parseStatus(json['status']),
      paidAt: _parseDate(json['paidAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'month': month,
      'expectedAmount': expectedAmount,
      'paidAmount': paidAmount,
      'balance': balance,
      'advanceAmount': advanceAmount,
      'status': status.name,
      'paidAt': paidAt?.toIso8601String(),
    };
  }

  bool get isPaid => status == MemberContributionStatus.paid;

  bool get isAhead => status == MemberContributionStatus.ahead;

  bool get isPending => status == MemberContributionStatus.pending;

  bool get isPartiallyPaid => status == MemberContributionStatus.partiallyPaid;

  String get statusLabel {
    switch (status) {
      case MemberContributionStatus.pending:
        return 'À payer';

      case MemberContributionStatus.partiallyPaid:
        return 'Partiellement payé';

      case MemberContributionStatus.paid:
        return 'Payé';

      case MemberContributionStatus.ahead:
        return 'En avance';
    }
  }

  MemberContribution copyWith({
    String? id,
    int? year,
    int? month,
    double? expectedAmount,
    double? paidAmount,
    double? balance,
    double? advanceAmount,
    MemberContributionStatus? status,
    DateTime? paidAt,
  }) {
    return MemberContribution(
      id: id ?? this.id,
      year: year ?? this.year,
      month: month ?? this.month,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      balance: balance ?? this.balance,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  static MemberContributionStatus _parseStatus(dynamic value) {
    switch (value?.toString()) {
      case 'partiallyPaid':
        return MemberContributionStatus.partiallyPaid;

      case 'paid':
        return MemberContributionStatus.paid;

      case 'ahead':
        return MemberContributionStatus.ahead;

      case 'pending':
      default:
        return MemberContributionStatus.pending;
    }
  }

  static int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}
