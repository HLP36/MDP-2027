import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/organization_provider.dart';
import '../widgets/organization_empty_state.dart';
import '../widgets/organization_header.dart';
import '../widgets/organization_kpi_row.dart';
import '../widgets/organization_tree.dart';

class OrganizationPage extends ConsumerWidget {
  const OrganizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizationAsync = ref.watch(organizationTreeProvider);

    final overviewAsync = ref.watch(organizationOverviewProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==================================================
              // HEADER
              // ==================================================
              OrganizationHeader(
                onRefresh: () {
                  ref.read(organizationTreeProvider.notifier).refresh();

                  ref.invalidate(organizationOverviewProvider);
                },
                onCreate: () {
                  _showCreateMessage(context);
                },
              ),

              const SizedBox(height: 24),

              // ==================================================
              // ORGANIZATION KPI
              // ==================================================
              overviewAsync.when(
                loading: () {
                  return const _OrganizationKpiLoading();
                },

                error: (error, stackTrace) {
                  return _OrganizationKpiError(
                    onRetry: () {
                      ref.invalidate(organizationOverviewProvider);
                    },
                  );
                },

                data: (overview) {
                  return OrganizationKpiRow(overview: overview);
                },
              ),

              const SizedBox(height: 24),

              // ==================================================
              // ORGANIZATION TREE
              // ==================================================
              Expanded(
                child: organizationAsync.when(
                  loading: () {
                    return const Center(child: CircularProgressIndicator());
                  },

                  error: (error, stackTrace) {
                    return _OrganizationErrorState(
                      error: error,
                      onRetry: () {
                        ref.read(organizationTreeProvider.notifier).refresh();

                        ref.invalidate(organizationOverviewProvider);
                      },
                    );
                  },

                  data: (units) {
                    if (units.isEmpty) {
                      return OrganizationEmptyState(
                        onCreate: () {
                          _showCreateMessage(context);
                        },
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await ref
                            .read(organizationTreeProvider.notifier)
                            .refresh();

                        ref.invalidate(organizationOverviewProvider);

                        // Make sure the latest KPI
                        // request has completed before
                        // ending pull-to-refresh.
                        await ref.read(organizationOverviewProvider.future);
                      },

                      child: OrganizationTree(units: units),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================
  // CREATE MESSAGE
  // ======================================================

  void _showCreateMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Le formulaire de création sera disponible prochainement.',
        ),
      ),
    );
  }
}

// ==========================================================
// KPI LOADING STATE
// ==========================================================

class _OrganizationKpiLoading extends StatelessWidget {
  const _OrganizationKpiLoading();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 108,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

// ==========================================================
// KPI ERROR STATE
// ==========================================================

class _OrganizationKpiError extends StatelessWidget {
  const _OrganizationKpiError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 20, color: colorScheme.error),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              'Impossible de charger les indicateurs organisationnels.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),

          const SizedBox(width: 12),

          IconButton(
            tooltip: 'Réessayer',
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// ORGANIZATION ERROR STATE
// ==========================================================

class _OrganizationErrorState extends StatelessWidget {
  const _OrganizationErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 32,
                  color: colorScheme.error,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Impossible de charger l’organisation',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                error.toString(),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 22),

              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
