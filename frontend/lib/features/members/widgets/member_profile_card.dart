import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/member.dart';

class MemberProfileCard extends StatelessWidget {
  const MemberProfileCard({super.key, required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(theme),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.memberCode,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(theme),
              ],
            ),

            const SizedBox(height: 24),

            const Divider(),

            const SizedBox(height: 20),

            _buildInfoGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    final initials = _getInitials();

    return CircleAvatar(
      radius: 30,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      child: Text(
        initials,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _statusColor(theme).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        member.statusLabel,
        style: TextStyle(
          color: _statusColor(theme),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _statusColor(ThemeData theme) {
    switch (member.status) {
      case MemberStatus.active:
        return Colors.green;

      case MemberStatus.inactive:
        return theme.colorScheme.onSurfaceVariant;

      case MemberStatus.suspended:
        return theme.colorScheme.error;
    }
  }

  Widget _buildInfoGrid(BuildContext context) {
    final items = <Widget>[
      _buildInfoItem(
        context,
        icon: Icons.person_outline,
        label: 'Nom complet',
        value: member.fullName,
      ),
      _buildInfoItem(
        context,
        icon: Icons.badge_outlined,
        label: 'ID membre',
        value: member.memberCode,
      ),
      _buildInfoItem(
        context,
        icon: Icons.phone_outlined,
        label: 'Téléphone',
        value: _displayValue(member.phone),
      ),
      _buildInfoItem(
        context,
        icon: Icons.location_on_outlined,
        label: 'Adresse',
        value: _displayValue(member.address),
      ),
      _buildInfoItem(
        context,
        icon: Icons.map_outlined,
        label: 'Champ',
        value: _displayValue(member.field),
      ),
      _buildInfoItem(
        context,
        icon: Icons.location_city_outlined,
        label: 'District',
        value: _displayValue(member.district),
      ),
      _buildInfoItem(
        context,
        icon: Icons.church_outlined,
        label: 'Église',
        value: _displayValue(member.church),
      ),
      _buildInfoItem(
        context,
        icon: Icons.calendar_today_outlined,
        label: 'Date d’adhésion',
        value: member.joinedAt == null
            ? 'Non renseignée'
            : DateFormat('dd/MM/yyyy').format(member.joinedAt!),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;

        return Wrap(
          spacing: 16,
          runSpacing: 20,
          children: items
              .map(
                (item) => SizedBox(
                  width: isWide
                      ? (constraints.maxWidth - 16) / 2
                      : constraints.maxWidth,
                  child: item,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Non renseigné';
    }

    return value;
  }

  String _getInitials() {
    final first = member.firstName.trim();
    final last = member.lastName.trim();

    if (first.isEmpty && last.isEmpty) {
      return '?';
    }

    final firstInitial = first.isNotEmpty ? first[0] : '';
    final lastInitial = last.isNotEmpty ? last[0] : '';

    return '$lastInitial$firstInitial'.toUpperCase();
  }
}
