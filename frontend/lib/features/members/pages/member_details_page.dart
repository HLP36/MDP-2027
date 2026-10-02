import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/member.dart';
import '../providers/member_dashboard_provider.dart';
import '../providers/member_details_provider.dart';
import '../widgets/contribution_journal.dart';
import '../widgets/contribution_summary.dart';
import '../widgets/member_assignment_card.dart';
import '../widgets/member_credentials_card.dart';
import '../widgets/member_profile_card.dart';

class MemberDetailsPage extends ConsumerWidget {
  const MemberDetailsPage({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(memberDetailsProvider(memberId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du membre'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: () {
              ref.invalidate(memberDetailsProvider(memberId));
              ref.invalidate(memberDashboardProvider(memberId));
            },
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: memberAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildMemberError(context, ref, error),
        data: (member) => _buildContent(context, ref, member),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Member member) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, member),

                const SizedBox(height: 24),

                MemberProfileCard(member: member),

                const SizedBox(height: 20),

                if (member.credentials != null) ...[
                  MemberCredentialsCard(
                    credentials: member.credentials!,
                    memberCode: member.memberCode,
                  ),
                  const SizedBox(height: 20),
                ],

                MemberAssignmentCard(
                  member: member,
                  onAssign: () {
                    _showPendingMessage(
                      context,
                      'Le formulaire d’affectation sera '
                      'connecté dans une prochaine étape.',
                    );
                  },
                ),

                const SizedBox(height: 32),

                _buildSectionHeader(
                  context,
                  title: 'Contributions',
                  subtitle: 'Résumé financier et journal mensuel.',
                  icon: Icons.account_balance_wallet_outlined,
                ),

                const SizedBox(height: 16),

                _buildFinancialSection(context, ref),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialSection(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(memberDashboardProvider(memberId));

    return dashboardAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) {
        final isNotConnected = error is UnimplementedError;

        return Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isNotConnected
                      ? Icons.construction_outlined
                      : Icons.error_outline,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(height: 12),

                Text(
                  isNotConnected
                      ? 'Module financier en préparation'
                      : 'Impossible de charger les contributions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  isNotConnected
                      ? 'Le résumé financier et le journal mensuel '
                            'seront disponibles après la connexion '
                            'de l’API des contributions.'
                      : 'Une erreur est survenue lors du '
                            'chargement des données financières.',
                ),

                if (!isNotConnected) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.invalidate(memberDashboardProvider(memberId));
                    },
                    icon: const Icon(Icons.refresh_outlined),
                    label: const Text('Réessayer'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      data: (dashboard) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContributionSummary(dashboard: dashboard),

          const SizedBox(height: 20),

          ContributionJournal(contributions: dashboard.contributions),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Member member) {
    final theme = Theme.of(context);

    return Row(
      children: [
        IconButton(
          tooltip: 'Retour',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_outlined),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.fullName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Fiche membre • ${member.memberCode}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        OutlinedButton.icon(
          onPressed: () {
            _showPendingMessage(
              context,
              'La modification du membre sera bientôt disponible.',
            );
          },
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Modifier'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberError(BuildContext context, WidgetRef ref, Object error) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),

            const SizedBox(height: 16),

            Text(
              'Impossible de charger le membre',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(error.toString(), textAlign: TextAlign.center),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: () {
                ref.invalidate(memberDetailsProvider(memberId));
              },
              icon: const Icon(Icons.refresh_outlined),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPendingMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
