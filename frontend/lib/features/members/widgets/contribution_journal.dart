import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/member_contribution.dart';

class ContributionJournal extends StatelessWidget {
  const ContributionJournal({super.key, required this.contributions});

  final List<MemberContribution> contributions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (contributions.isEmpty) {
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 42,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'Aucune contribution enregistrée',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Le journal des contributions apparaîtra ici.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),

            const SizedBox(height: 20),

            const Divider(),

            const SizedBox(height: 8),

            _buildTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(Icons.calendar_month_outlined, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Journal des contributions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Suivi mensuel des contributions du membre.',
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

  Widget _buildTable(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: 28,
              horizontalMargin: 0,
              columns: const [
                DataColumn(label: Text('Mois')),
                DataColumn(label: Text('Attendu')),
                DataColumn(label: Text('Payé')),
                DataColumn(label: Text('Solde')),
                DataColumn(label: Text('Avance')),
                DataColumn(label: Text('Statut')),
                DataColumn(label: Text('Date')),
              ],
              rows: contributions
                  .map((contribution) => _buildRow(context, contribution))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildRow(BuildContext context, MemberContribution contribution) {
    return DataRow(
      cells: [
        DataCell(Text(_formatMonth(contribution.year, contribution.month))),

        DataCell(Text(_formatAmount(contribution.expectedAmount))),

        DataCell(Text(_formatAmount(contribution.paidAmount))),

        DataCell(Text(_formatAmount(contribution.balance))),

        DataCell(Text(_formatAmount(contribution.advanceAmount))),

        DataCell(_buildStatusBadge(context, contribution)),

        DataCell(
          Text(
            contribution.paidAt == null
                ? '—'
                : DateFormat('dd/MM/yyyy').format(contribution.paidAt!),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    MemberContribution contribution,
  ) {
    final theme = Theme.of(context);

    final color = _statusColor(theme, contribution.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        contribution.statusLabel,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _statusColor(ThemeData theme, MemberContributionStatus status) {
    switch (status) {
      case MemberContributionStatus.pending:
        return theme.colorScheme.onSurfaceVariant;

      case MemberContributionStatus.partiallyPaid:
        return Colors.orange;

      case MemberContributionStatus.paid:
        return Colors.green;

      case MemberContributionStatus.ahead:
        return theme.colorScheme.primary;
    }
  }

  String _formatMonth(int year, int month) {
    final date = DateTime(year, month);

    final formatted = DateFormat('MMMM yyyy', 'fr_FR').format(date);

    if (formatted.isEmpty) {
      return '$month/$year';
    }

    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  String _formatAmount(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}
