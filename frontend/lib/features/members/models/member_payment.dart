enum MemberPaymentMethod { cash, airtel, vodacom, orange }

enum MemberPaymentStatus { pending, verifying, validated, rejected }

class MemberPayment {
  const MemberPayment({
    required this.id,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
    this.destinationNetwork,
    this.reference,
    this.proofUrl,
    this.note,
    this.validatedAt,
  });

  final String id;
  final double amount;

  final MemberPaymentMethod method;
  final MemberPaymentStatus status;

  final DateTime createdAt;
  final DateTime? validatedAt;

  final String? destinationNetwork;
  final String? reference;
  final String? proofUrl;
  final String? note;

  bool get isCash => method == MemberPaymentMethod.cash;

  bool get isMobileMoney => method != MemberPaymentMethod.cash;

  String get methodLabel {
    switch (method) {
      case MemberPaymentMethod.cash:
        return 'Cash';
      case MemberPaymentMethod.airtel:
        return 'Airtel';
      case MemberPaymentMethod.vodacom:
        return 'Vodacom';
      case MemberPaymentMethod.orange:
        return 'Orange';
    }
  }

  String get statusLabel {
    switch (status) {
      case MemberPaymentStatus.pending:
        return 'En attente';
      case MemberPaymentStatus.verifying:
        return 'En vérification';
      case MemberPaymentStatus.validated:
        return 'Validé';
      case MemberPaymentStatus.rejected:
        return 'Rejeté';
    }
  }

  factory MemberPayment.fromJson(Map<String, dynamic> json) {
    return MemberPayment(
      id: json['id'] as String,
      amount: _toDouble(json['amount']),
      method: _parseMethod(json['method']),
      status: _parseStatus(json['status']),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      validatedAt: _parseDate(json['validatedAt']),
      destinationNetwork: json['destinationNetwork'] as String?,
      reference: json['reference'] as String?,
      proofUrl: json['proofUrl'] as String?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'method': method.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'validatedAt': validatedAt?.toIso8601String(),
      'destinationNetwork': destinationNetwork,
      'reference': reference,
      'proofUrl': proofUrl,
      'note': note,
    };
  }

  static MemberPaymentMethod _parseMethod(dynamic value) {
    switch (value?.toString()) {
      case 'airtel':
        return MemberPaymentMethod.airtel;
      case 'vodacom':
        return MemberPaymentMethod.vodacom;
      case 'orange':
        return MemberPaymentMethod.orange;
      case 'cash':
      default:
        return MemberPaymentMethod.cash;
    }
  }

  static MemberPaymentStatus _parseStatus(dynamic value) {
    switch (value?.toString()) {
      case 'verifying':
        return MemberPaymentStatus.verifying;
      case 'validated':
        return MemberPaymentStatus.validated;
      case 'rejected':
        return MemberPaymentStatus.rejected;
      case 'pending':
      default:
        return MemberPaymentStatus.pending;
    }
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
