import 'package:flutter/material.dart';

import '../models/organizational_unit.dart';

class OrganizationUnitDetails extends StatelessWidget {
  const OrganizationUnitDetails({super.key, required this.unit, this.onEdit});

  final OrganizationalUnit unit;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  unit.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onEdit != null)
                IconButton(
                  tooltip: 'Modifier',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(label: 'Type', value: unit.type),
          _InfoRow(
            label: 'Statut',
            value: unit.isActive ? 'Active' : 'Inactive',
          ),
          if (unit.description != null && unit.description!.isNotEmpty)
            _InfoRow(label: 'Description', value: unit.description!),
          if (unit.leader != null)
            _InfoRow(label: 'Responsable', value: unit.leader!.fullName),
          _InfoRow(label: 'Sous-unités', value: '${unit.childrenCount ?? 0}'),
          _InfoRow(label: 'Utilisateurs', value: '${unit.usersCount ?? 0}'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
