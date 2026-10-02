import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/members/pages/members_page.dart';
import '../../../features/organization/pages/organization_page.dart';
import '../widgets/dashboard_content.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_sidebar.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  static const double desktopBreakpoint = 1000;

  int _selectedIndex = 0;

  bool _sidebarOpen = false;
  bool _sidebarCollapsed = false;
  bool _isLoggingOut = false;

  bool _isDesktop(double width) {
    return width >= desktopBreakpoint;
  }

  // ===========================================================================
  // NAVIGATION
  // ===========================================================================

  void _selectMenu(int index) {
    // 17 = Déconnexion
    if (index == 17) {
      _logout();
      return;
    }

    setState(() {
      _selectedIndex = index;
      _sidebarOpen = false;
    });
  }

  // ===========================================================================
  // CONTENT
  // ===========================================================================

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardContent();

      case 1:
        return const OrganizationPage();

      case 2:
        return const MembersPage();

      case 3:
        return const _ModulePlaceholder(
          title: 'Équipe',
          subtitle: 'Gestion des équipes MDP.',
          icon: Icons.groups_outlined,
        );

      case 4:
        return const _ModulePlaceholder(
          title: 'Superviseurs',
          subtitle: 'Gestion des superviseurs MDP.',
          icon: Icons.supervisor_account_outlined,
        );

      case 5:
        return const _ModulePlaceholder(
          title: 'Inspecteurs',
          subtitle: 'Gestion des inspecteurs MDP.',
          icon: Icons.fact_check_outlined,
        );

      case 6:
        return const _ModulePlaceholder(
          title: 'Activités',
          subtitle: 'Gestion des activités MDP.',
          icon: Icons.event_note_outlined,
        );

      case 7:
        return const _ModulePlaceholder(
          title: 'Rapports',
          subtitle: 'Gestion et consultation des rapports.',
          icon: Icons.assessment_outlined,
        );

      case 8:
        return const _ModulePlaceholder(
          title: 'Contributions',
          subtitle: 'Gestion des contributions et paiements.',
          icon: Icons.account_balance_wallet_outlined,
        );

      case 9:
        return const _ModulePlaceholder(
          title: 'Projets',
          subtitle: 'Gestion des projets MDP.',
          icon: Icons.business_center_outlined,
        );

      case 10:
        return const _ModulePlaceholder(
          title: 'Sponsors',
          subtitle: 'Gestion des sponsors et partenaires.',
          icon: Icons.handshake_outlined,
        );

      case 11:
        return const _ModulePlaceholder(
          title: 'Utilisateurs',
          subtitle: 'Gestion des comptes utilisateurs.',
          icon: Icons.people_alt_outlined,
        );

      case 12:
        return const _ModulePlaceholder(
          title: 'Rôles',
          subtitle: 'Gestion des rôles du système.',
          icon: Icons.admin_panel_settings_outlined,
        );

      case 13:
        return const _ModulePlaceholder(
          title: 'Permissions',
          subtitle: 'Gestion des permissions du système.',
          icon: Icons.security_outlined,
        );

      case 14:
        return const _ModulePlaceholder(
          title: 'Notifications',
          subtitle: 'Gestion des notifications.',
          icon: Icons.notifications_none_outlined,
        );

      case 15:
        return const _ModulePlaceholder(
          title: 'Audit',
          subtitle: 'Journal des actions et de sécurité.',
          icon: Icons.history_outlined,
        );

      case 16:
        return const _ModulePlaceholder(
          title: 'Paramètres',
          subtitle: 'Configuration générale de MDP 2027.',
          icon: Icons.settings_outlined,
        );

      default:
        return const DashboardContent();
    }
  }

  // ===========================================================================
  // LOGOUT
  // ===========================================================================

  Future<void> _logout() async {
    if (_isLoggingOut) {
      return;
    }

    setState(() {
      _isLoggingOut = true;
      _sidebarOpen = false;
    });

    try {
      await ref.read(authProvider.notifier).logout();

      if (!mounted) {
        return;
      }

      context.go('/login');
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  // ===========================================================================
  // SIDEBAR
  // ===========================================================================

  void _toggleMobileSidebar() {
    setState(() {
      _sidebarOpen = !_sidebarOpen;
    });
  }

  void _toggleDesktopSidebar() {
    setState(() {
      _sidebarCollapsed = !_sidebarCollapsed;
    });
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = _isDesktop(width);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Row(
            children: [
              // -----------------------------------------------------------------
              // DESKTOP SIDEBAR
              // -----------------------------------------------------------------
              if (isDesktop)
                DashboardSidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: _selectMenu,
                  collapsed: _sidebarCollapsed,
                  onCollapseToggle: _toggleDesktopSidebar,
                ),

              // -----------------------------------------------------------------
              // MAIN CONTENT
              // -----------------------------------------------------------------
              Expanded(
                child: Column(
                  children: [
                    DashboardHeader(onMenuPressed: _toggleMobileSidebar),

                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: KeyedSubtree(
                          key: ValueKey(_selectedIndex),
                          child: _buildContent(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // -------------------------------------------------------------------
          // MOBILE / TABLET SIDEBAR
          // -------------------------------------------------------------------
          if (!isDesktop && _sidebarOpen)
            _MobileSidebarOverlay(
              onClose: _toggleMobileSidebar,
              selectedIndex: _selectedIndex,
              onItemSelected: _selectMenu,
            ),

          // -------------------------------------------------------------------
          // LOGOUT OVERLAY
          // -------------------------------------------------------------------
          if (_isLoggingOut) const _LogoutOverlay(),
        ],
      ),
    );
  }
}

// =============================================================================
// MODULE PLACEHOLDER
// =============================================================================

class _ModulePlaceholder extends StatelessWidget {
  const _ModulePlaceholder({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 24,
                    spreadRadius: 0,
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(icon, size: 34, color: colorScheme.primary),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Module en préparation',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MOBILE SIDEBAR OVERLAY
// =============================================================================

class _MobileSidebarOverlay extends StatelessWidget {
  const _MobileSidebarOverlay({
    required this.onClose,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final VoidCallback onClose;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ---------------------------------------------------------------------
        // BACKDROP
        // ---------------------------------------------------------------------
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),
        ),

        // ---------------------------------------------------------------------
        // SIDEBAR
        // ---------------------------------------------------------------------
        Align(
          alignment: Alignment.centerLeft,
          child: SafeArea(
            right: false,
            child: SizedBox(
              width: _sidebarWidth(context),
              child: Material(
                elevation: 24,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: DashboardSidebar(
                  selectedIndex: selectedIndex,
                  onItemSelected: onItemSelected,
                  collapsed: false,
                  onCollapseToggle: null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _sidebarWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 500) {
      return width * 0.86;
    }

    return 360;
  }
}

// =============================================================================
// LOGOUT OVERLAY
// =============================================================================

class _LogoutOverlay extends StatelessWidget {
  const _LogoutOverlay();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.18),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 30,
                  spreadRadius: 2,
                  color: Colors.black.withValues(alpha: 0.12),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
                SizedBox(width: 16),
                Text(
                  'Déconnexion...',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
