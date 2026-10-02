import 'package:flutter/material.dart';

import '../models/member.dart';

class MembersKpiRow extends StatelessWidget {
  const MembersKpiRow({super.key, required this.members});

  final List<Member> members;

  @override
  Widget build(BuildContext context) {
    final active = members
        .where((member) => member.status == MemberStatus.active)
        .length;

    final inactive = members
        .where((member) => member.status == MemberStatus.inactive)
        .length;

    final suspended = members
        .where((member) => member.status == MemberStatus.suspended)
        .length;

    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            title: 'Total membres',
            value: members.length.toString(),
            icon: Icons.groups_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KpiCard(
            title: 'Membres actifs',
            value: active.toString(),
            icon: Icons.verified_user_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KpiCard(
            title: 'Inactifs',
            value: inactive.toString(),
            icon: Icons.person_off_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KpiCard(
            title: 'Suspendus',
            value: suspended.toString(),
            icon: Icons.block_rounded,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
