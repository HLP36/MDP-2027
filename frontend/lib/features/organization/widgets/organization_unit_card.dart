import 'package:flutter/material.dart';

import '../models/organizational_unit.dart';

class OrganizationUnitCard extends StatefulWidget {
  const OrganizationUnitCard({super.key, required this.unit, this.level = 0});

  final OrganizationalUnit unit;
  final int level;

  @override
  State<OrganizationUnitCard> createState() => _OrganizationUnitCardState();
}

class _OrganizationUnitCardState extends State<OrganizationUnitCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final unit = widget.unit;
    final hasChildren = unit.children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCard(context, theme, colorScheme, unit, hasChildren),
        if (hasChildren && _expanded)
          Padding(
            padding: const EdgeInsets.only(left: 28, top: 10),
            child: Column(
              children: [
                for (final child in unit.children)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OrganizationUnitCard(
                      unit: child,
                      level: widget.level + 1,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    OrganizationalUnit unit,
    bool hasChildren,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: hasChildren
            ? () {
                setState(() {
                  _expanded = !_expanded;
                });
              }
            : null,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.12 : 0.04,
                ),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildLeading(context, colorScheme, unit),
              const SizedBox(width: 14),
              Expanded(child: _buildContent(context, unit)),
              const SizedBox(width: 12),
              _buildTrailing(context, colorScheme, unit, hasChildren),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(
    BuildContext context,
    ColorScheme colorScheme,
    OrganizationalUnit unit,
  ) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(_unitIcon(unit.type), color: colorScheme.primary, size: 23),
    );
  }

  Widget _buildContent(BuildContext context, OrganizationalUnit unit) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          unit.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            _TypeBadge(type: unit.type),
            const SizedBox(width: 8),
            if (unit.leader != null)
              Flexible(
                child: Text(
                  unit.leader!.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrailing(
    BuildContext context,
    ColorScheme colorScheme,
    OrganizationalUnit unit,
    bool hasChildren,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (unit.childrenCount != null)
          _CountBadge(
            icon: Icons.account_tree_outlined,
            value: unit.childrenCount!,
          ),
        if (unit.usersCount != null) ...[
          const SizedBox(width: 8),
          _CountBadge(icon: Icons.people_outline, value: unit.usersCount!),
        ],
        if (hasChildren) ...[
          const SizedBox(width: 8),
          Icon(
            _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ],
    );
  }

  IconData _unitIcon(String type) {
    switch (type.toUpperCase()) {
      case 'GLOBAL':
        return Icons.public;
      case 'COMMITTEE':
        return Icons.account_balance_outlined;
      case 'INSPECTOR':
        return Icons.manage_accounts_outlined;
      case 'SUPERVISOR':
        return Icons.supervisor_account_outlined;
      case 'TEAM':
        return Icons.groups_outlined;
      case 'CHURCH':
        return Icons.church_outlined;
      case 'CITY':
        return Icons.location_city_outlined;
      case 'COUNTRY':
        return Icons.flag_outlined;
      default:
        return Icons.account_tree_outlined;
    }
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.icon, required this.value});

  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
