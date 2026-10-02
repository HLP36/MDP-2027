import 'package:flutter/material.dart';

import '../models/member_payment.dart';

class MemberPaymentHistory extends StatelessWidget {
  const MemberPaymentHistory({super.key, required this.payments});

  final List<MemberPayment> payments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (payments.isEmpty) {
      return _EmptyPaymentHistory(color: theme.colorScheme.onSurfaceVariant);
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HistoryHeader(paymentCount: payments.length),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 760) {
                  return _MobilePaymentList(payments: payments);
                }

                return _DesktopPaymentTable(payments: payments);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.paymentCount});

  final int paymentCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.history_outlined, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Historique des paiements',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$paymentCount paiement${paymentCount > 1 ? 's' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DesktopPaymentTable extends StatelessWidget {
  const _DesktopPaymentTable({required this.payments});

  final List<MemberPayment> payments;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 28,
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Montant')),
          DataColumn(label: Text('Mode')),
          DataColumn(label: Text('Réseau')),
          DataColumn(label: Text('Référence')),
          DataColumn(label: Text('Statut')),
        ],
        rows: payments
            .map(
              (payment) => DataRow(
                cells: [
                  DataCell(Text(_formatDate(payment.createdAt))),
                  DataCell(
                    Text(
                      _formatAmount(payment.amount),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  DataCell(Text(payment.methodLabel)),
                  DataCell(Text(payment.destinationNetwork ?? '—')),
                  DataCell(Text(payment.reference ?? '—')),
                  DataCell(_PaymentStatusBadge(status: payment.status)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MobilePaymentList extends StatelessWidget {
  const _MobilePaymentList({required this.payments});

  final List<MemberPayment> payments;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: payments
          .map(
            (payment) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MobilePaymentCard(payment: payment),
            ),
          )
          .toList(),
    );
  }
}

class _MobilePaymentCard extends StatelessWidget {
  const _MobilePaymentCard({required this.payment});

  final MemberPayment payment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatAmount(payment.amount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _PaymentStatusBadge(status: payment.status),
            ],
          ),
          const SizedBox(height: 14),
          _PaymentInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: _formatDate(payment.createdAt),
          ),
          const SizedBox(height: 8),
          _PaymentInfoRow(
            icon: Icons.payments_outlined,
            label: 'Mode',
            value: payment.methodLabel,
          ),
          if (payment.destinationNetwork != null) ...[
            const SizedBox(height: 8),
            _PaymentInfoRow(
              icon: Icons.network_cell_outlined,
              label: 'Réseau',
              value: payment.destinationNetwork!,
            ),
          ],
          if (payment.reference != null) ...[
            const SizedBox(height: 8),
            _PaymentInfoRow(
              icon: Icons.tag_outlined,
              label: 'Référence',
              value: payment.reference!,
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentInfoRow extends StatelessWidget {
  const _PaymentInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 9),
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  const _PaymentStatusBadge({required this.status});

  final MemberPaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (backgroundColor, foregroundColor, icon, label) = switch (status) {
      MemberPaymentStatus.pending => (
        theme.colorScheme.surfaceContainerHighest,
        theme.colorScheme.onSurfaceVariant,
        Icons.schedule_outlined,
        'En attente',
      ),
      MemberPaymentStatus.verifying => (
        theme.colorScheme.primary.withValues(alpha: 0.10),
        theme.colorScheme.primary,
        Icons.sync_outlined,
        'En vérification',
      ),
      MemberPaymentStatus.validated => (
        Colors.green.withValues(alpha: 0.10),
        Colors.green.shade700,
        Icons.check_circle_outline,
        'Validé',
      ),
      MemberPaymentStatus.rejected => (
        theme.colorScheme.error.withValues(alpha: 0.10),
        theme.colorScheme.error,
        Icons.cancel_outlined,
        'Rejeté',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foregroundColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPaymentHistory extends StatelessWidget {
  const _EmptyPaymentHistory({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 42, color: color),
            const SizedBox(height: 12),
            Text(
              'Aucun paiement enregistré',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Les paiements du membre apparaîtront ici.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatAmount(double amount) {
  if (amount == amount.roundToDouble()) {
    return '${amount.toInt()}\$';
  }

  return '${amount.toStringAsFixed(2)}\$';
}

String _formatDate(DateTime date) {
  final localDate = date.toLocal();

  final day = localDate.day.toString().padLeft(2, '0');
  final month = localDate.month.toString().padLeft(2, '0');
  final year = localDate.year.toString();

  return '$day/$month/$year';
}
