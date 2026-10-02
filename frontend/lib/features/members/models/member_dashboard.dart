import 'member_contribution.dart';
import 'member_payment.dart';

class MemberDashboard {
  const MemberDashboard({
    required this.memberId,
    required this.totalContributed,
    required this.currentMonth,
    required this.currentMonthPaid,
    required this.totalAdvance,
    required this.aheadMonths,
    required this.contributions,
    required this.payments,
  });

  final String memberId;

  final double totalContributed;

  final MemberContribution currentMonth;

  final double currentMonthPaid;

  final double totalAdvance;

  final int aheadMonths;

  final List<MemberContribution> contributions;

  final List<MemberPayment> payments;

  bool get isCurrentMonthPaid =>
      currentMonthPaid >= currentMonth.expectedAmount;

  factory MemberDashboard.fromJson(Map<String, dynamic> json) {
    return MemberDashboard(
      memberId: json['memberId'] as String,
      totalContributed: _toDouble(json['totalContributed']),
      currentMonth: MemberContribution.fromJson(
        Map<String, dynamic>.from(json['currentMonth'] as Map),
      ),
      currentMonthPaid: _toDouble(json['currentMonthPaid']),
      totalAdvance: _toDouble(json['totalAdvance']),
      aheadMonths: _toInt(json['aheadMonths']),
      contributions:
          (json['contributions'] as List?)
              ?.whereType<Map>()
              .map(
                (item) => MemberContribution.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList() ??
          const [],
      payments:
          (json['payments'] as List?)
              ?.whereType<Map>()
              .map(
                (item) =>
                    MemberPayment.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList() ??
          const [],
    );
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
}
