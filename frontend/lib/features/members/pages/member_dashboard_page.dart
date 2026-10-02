import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/member.dart';
import '../models/member_dashboard.dart';
import '../providers/member_dashboard_provider.dart';
import '../providers/member_details_provider.dart';
import '../widgets/contribution_journal.dart';
import '../widgets/contribution_summary.dart';
import '../widgets/member_notifications.dart';
import '../widgets/member_payment_history.dart';
import '../widgets/member_profile_card.dart';
import '../widgets/member_team_card.dart';
import 'member_payment_page.dart';

class MemberDashboardPage extends ConsumerWidget {
  const MemberDashboardPage({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(memberDetailsProvider(memberId));

    final dashboardAsync = ref.watch(memberDashboardProvider(memberId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard membre'),
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
        error: (error, stackTrace) => _ErrorState(
          onRetry: () {
            ref.invalidate(memberDetailsProvider(memberId));
          },
        ),
        data: (member) {
          return dashboardAsync.when(
            loading: () => _DashboardLoading(memberName: member.fullName),
            error: (error, stackTrace) =>
                _DashboardContent(member: member, dashboard: null),
            data: (dashboard) =>
                _DashboardContent(member: member, dashboard: dashboard),
          );
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.member, required this.dashboard});

  final Member member;
  final MemberDashboard? dashboard;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 1200
            ? 32.0
            : constraints.maxWidth >= 700
            ? 24.0
            : 16.0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            40,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DashboardHeader(
                    memberName: member.fullName,
                    memberCode: member.memberCode,
                  ),
                  const SizedBox(height: 24),
                  MemberProfileCard(member: member),
                  const SizedBox(height: 20),
                  _MemberActions(
                    memberId: member.id,
                    memberName: member.fullName,
                  ),
                  const SizedBox(height: 20),
                  if (dashboard != null) ...[
                    ContributionSummary(dashboard: dashboard!),
                    const SizedBox(height: 20),
                    ContributionJournal(
                      contributions: dashboard!.contributions,
                    ),
                    const SizedBox(height: 20),
                    MemberPaymentHistory(payments: dashboard!.payments),
                  ] else
                    const _FinanceUnavailableCard(),
                  const SizedBox(height: 20),
                  MemberTeamCard(assignment: member.assignment),
                  const SizedBox(height: 20),
                  const MemberNotifications(notifications: []),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MemberActions extends StatelessWidget {
  const _MemberActions({required this.memberId, required this.memberName});

  final String memberId;
  final String memberName;

  void _openPaymentPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            MemberPaymentPage(memberId: memberId, memberName: memberName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 650;

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ActionHeader(theme: theme),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openPaymentPage(context),
                      icon: const Icon(Icons.add_card_outlined),
                      label: const Text('Payer une contribution'),
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: _ActionHeader(theme: theme)),
                const SizedBox(width: 20),
                FilledButton.icon(
                  onPressed: () => _openPaymentPage(context),
                  icon: const Icon(Icons.add_card_outlined),
                  label: const Text('Payer une contribution'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ActionHeader extends StatelessWidget {
  const _ActionHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.payments_outlined,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contribution',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Effectuez directement votre contribution MDP.',
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
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.memberName, required this.memberCode});

  final String memberName;
  final String memberCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour, $memberName',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Voici votre espace personnel MDP.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'ID membre : $memberCode',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading({required this.memberName});

  final String memberName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Chargement de l’espace de $memberName...',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FinanceUnavailableCard extends StatelessWidget {
  const _FinanceUnavailableCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations financières',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Le journal des contributions et l’historique '
                    'des paiements seront disponibles après la '
                    'connexion du module financier au backend.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'Impossible de charger le membre.',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_outlined),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
