import 'package:flutter/material.dart';

import '../models/member_dashboard.dart';

class ContributionSummary extends StatelessWidget {
  const ContributionSummary({super.key, required this.dashboard});

  final MemberDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        final cards = [
          _SummaryItem(
            title: 'Total contribué',
            value: _formatAmount(dashboard.totalContributed),
            icon: Icons.account_balance_wallet_outlined,
          ),
          _SummaryItem(
            title: 'Mois actuel',
            value: dashboard.isCurrentMonthPaid ? 'Payé' : 'En attente',
            icon: dashboard.isCurrentMonthPaid
                ? Icons.check_circle_outline
                : Icons.pending_outlined,
          ),
          _SummaryItem(
            title: 'Avance',
            value: _formatAmount(dashboard.totalAdvance),
            icon: Icons.trending_up_outlined,
          ),
          _SummaryItem(
            title: 'Mois d’avance',
            value: '${dashboard.aheadMonths}',
            icon: Icons.calendar_month_outlined,
          ),
        ];

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards
              .map(
                (item) => SizedBox(
                  width: isWide
                      ? (constraints.maxWidth - 48) / 4
                      : constraints.maxWidth >= 600
                      ? (constraints.maxWidth - 16) / 2
                      : constraints.maxWidth,
                  child: _SummaryCard(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return '${amount.toInt()}\$';
    }

    return '${amount.toStringAsFixed(2)}\$';
  }
}

class _SummaryItem {
  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.item});

  final _SummaryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
