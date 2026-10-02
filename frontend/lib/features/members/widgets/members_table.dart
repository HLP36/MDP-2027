import 'package:flutter/material.dart';

import '../models/member.dart';

class MembersTable extends StatelessWidget {
  const MembersTable({
    super.key,
    required this.members,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Member> members;
  final ValueChanged<String> onView;
  final ValueChanged<String> onEdit;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (members.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text('Aucun membre trouvé.', style: theme.textTheme.titleMedium),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              columnSpacing: 28,
              headingRowHeight: 52,
              dataRowMinHeight: 64,
              dataRowMaxHeight: 72,
              columns: const [
                DataColumn(label: Text('Membre')),
                DataColumn(label: Text('ID membre')),
                DataColumn(label: Text('Téléphone')),
                DataColumn(label: Text('Église')),
                DataColumn(label: Text('Team')),
                DataColumn(label: Text('Statut')),
                DataColumn(label: Text('Actions')),
              ],
              rows: members.map((member) {
                return DataRow(
                  cells: [
                    DataCell(_MemberNameCell(member: member)),
                    DataCell(Text(member.memberCode)),
                    DataCell(Text(member.phone ?? '—')),
                    DataCell(Text(member.church ?? '—')),
                    DataCell(
                      Text(member.assignment?.teamName ?? 'Non affecté'),
                    ),
                    DataCell(_StatusBadge(status: member.status)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Voir',
                            onPressed: () {
                              onView(member.id);
                            },
                            icon: const Icon(Icons.visibility_outlined),
                          ),
                          IconButton(
                            tooltip: 'Modifier',
                            onPressed: () {
                              onEdit(member.id);
                            },
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Supprimer',
                            onPressed: () {
                              onDelete(member.id);
                            },
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberNameCell extends StatelessWidget {
  const _MemberNameCell({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 19, child: Text(_initials(member))),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member.fullName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (member.firstName.isNotEmpty)
              Text(member.firstName, style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  String _initials(Member member) {
    final first = member.lastName.isNotEmpty ? member.lastName[0] : '';

    final second = member.firstName.isNotEmpty ? member.firstName[0] : '';

    return '$first$second'.toUpperCase();
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final MemberStatus status;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;

    switch (status) {
      case MemberStatus.active:
        background = Colors.green.withValues(alpha: 0.10);
        foreground = Colors.green.shade700;
        break;

      case MemberStatus.inactive:
        background = Colors.grey.withValues(alpha: 0.12);
        foreground = Colors.grey.shade700;
        break;

      case MemberStatus.suspended:
        background = Colors.red.withValues(alpha: 0.10);
        foreground = Colors.red.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusLabel,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String get statusLabel {
    switch (status) {
      case MemberStatus.active:
        return 'Actif';
      case MemberStatus.inactive:
        return 'Inactif';
      case MemberStatus.suspended:
        return 'Suspendu';
    }
  }
}
