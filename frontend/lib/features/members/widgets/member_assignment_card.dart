import 'package:flutter/material.dart';

import '../models/member.dart';
import '../models/member_assignment.dart';

class MemberAssignmentCard extends StatelessWidget {
  const MemberAssignmentCard({super.key, required this.member, this.onAssign});

  final Member member;
  final VoidCallback? onAssign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assignment = member.assignment;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_tree_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Affectation MDP',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Responsabilités et rattachement du membre.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onAssign != null)
                  OutlinedButton.icon(
                    onPressed: onAssign,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(assignment == null ? 'Affecter' : 'Modifier'),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            const Divider(),

            const SizedBox(height: 20),

            if (assignment == null)
              _buildEmptyState(context)
            else
              _buildAssignment(context, assignment),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_ind_outlined,
            size: 36,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            'Aucune affectation',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Ce membre n’est pas encore affecté à une équipe '
            'ou à une responsabilité.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignment(BuildContext context, MemberAssignment assignment) {
    return Column(
      children: [
        _buildAssignmentRow(
          context,
          icon: Icons.groups_outlined,
          label: 'Équipe',
          value: assignment.teamName,
        ),
        _buildAssignmentRow(
          context,
          icon: Icons.person_outline,
          label: 'Team Leader',
          value: assignment.teamLeaderName,
        ),
        _buildAssignmentRow(
          context,
          icon: Icons.supervisor_account_outlined,
          label: 'Superviseur',
          value: assignment.supervisorName,
        ),
        _buildAssignmentRow(
          context,
          icon: Icons.visibility_outlined,
          label: 'Inspecteur',
          value: assignment.inspectorName,
        ),
      ],
    );
  }

  Widget _buildAssignmentRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String? value,
  }) {
    final theme = Theme.of(context);

    final displayValue = value == null || value.trim().isEmpty
        ? 'Non affecté'
        : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayValue,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
