import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import 'dashboard_activity_card.dart';
import 'dashboard_chart_card.dart';
import 'dashboard_quick_actions.dart';
import 'dashboard_stat_card.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeSection(localization: localization),
          const SizedBox(height: 26),
          const _StatsSection(),
          const SizedBox(height: 24),
          const _AnalyticsSection(),
          const SizedBox(height: 24),
          const _BottomSection(),
        ],
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection({required this.localization});

  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${localization.welcome}, Admin 👋',
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Voici un aperçu des activités de Maison du Père.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.58),
                ),
              ),
            ],
          ),
        ),
        if (MediaQuery.sizeOf(context).width >= 700) const _DateBadge(),
      ],
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            _formattedDate(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();

    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];

    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1200
            ? 4
            : constraints.maxWidth >= 700
            ? 2
            : 1;

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: constraints.maxWidth >= 700 ? 2.1 : 2.7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            DashboardStatCard(
              title: 'Membres',
              value: '—',
              subtitle: 'Membres enregistrés',
              icon: Icons.people_alt_outlined,
            ),
            DashboardStatCard(
              title: 'Contributions',
              value: '—',
              subtitle: 'Contributions du mois',
              icon: Icons.payments_outlined,
            ),
            DashboardStatCard(
              title: 'Projets',
              value: '—',
              subtitle: 'Projets actifs',
              icon: Icons.account_balance_outlined,
            ),
            DashboardStatCard(
              title: 'Rapports',
              value: '—',
              subtitle: 'Rapports à traiter',
              icon: Icons.assignment_outlined,
            ),
          ],
        );
      },
    );
  }
}

class _AnalyticsSection extends StatelessWidget {
  const _AnalyticsSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return const Column(
            children: [
              DashboardChartCard(),
              SizedBox(height: 16),
              DashboardQuickActions(),
            ],
          );
        }

        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: DashboardChartCard()),
            SizedBox(width: 16),
            Expanded(child: DashboardQuickActions()),
          ],
        );
      },
    );
  }
}

class _BottomSection extends StatelessWidget {
  const _BottomSection();

  @override
  Widget build(BuildContext context) {
    return const DashboardActivityCard();
  }
}
