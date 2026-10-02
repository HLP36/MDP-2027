import 'package:flutter/material.dart';

import '../models/organization_overview.dart';

class OrganizationKpiRow extends StatelessWidget {
  const OrganizationKpiRow({super.key, required this.overview});

  final OrganizationOverview overview;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < 700) {
          return Column(
            children: [
              _KpiCard(
                title: 'Membres',
                value: overview.membersCount,
                icon: Icons.people_outline,
              ),
              const SizedBox(height: 12),
              _KpiCard(
                title: 'Unités',
                value: overview.unitsCount,
                icon: Icons.account_tree_outlined,
              ),
              const SizedBox(height: 12),
              _KpiCard(
                title: 'Responsables',
                value: overview.leadersCount,
                icon: Icons.manage_accounts_outlined,
              ),
              const SizedBox(height: 12),
              _KpiCard(
                title: 'Alertes',
                value: overview.alertsCount,
                icon: Icons.notifications_none_outlined,
                isAlert: true,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _KpiCard(
                title: 'Membres',
                value: overview.membersCount,
                icon: Icons.people_outline,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _KpiCard(
                title: 'Unités',
                value: overview.unitsCount,
                icon: Icons.account_tree_outlined,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _KpiCard(
                title: 'Responsables',
                value: overview.leadersCount,
                icon: Icons.manage_accounts_outlined,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _KpiCard(
                title: 'Alertes',
                value: overview.alertsCount,
                icon: Icons.notifications_none_outlined,
                isAlert: true,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    this.isAlert = false,
  });

  final String title;
  final int value;
  final IconData icon;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final accentColor = isAlert ? colorScheme.error : colorScheme.primary;

    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.12 : 0.035,
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatNumber(value),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int value) {
    if (value < 1000) {
      return value.toString();
    }

    final formatted = value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)} ',
    );

    return formatted;
  }
}
