import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mdp_logo.dart';

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.collapsed = false,
    this.onCollapseToggle,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool collapsed;
  final VoidCallback? onCollapseToggle;

  static const double expandedWidth = 270;
  static const double collapsedWidth = 76;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      width: collapsed ? collapsedWidth : expandedWidth,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        border: Border(
          right: BorderSide(
            color: theme.brightness == Brightness.dark
                ? AppColors.darkBorder
                : AppColors.lightBorder,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 180;

          return SafeArea(
            child: Column(
              children: [
                // ==================================================
                // HEADER
                // ==================================================
                _SidebarHeader(
                  compact: compact,
                  onCollapseToggle: onCollapseToggle,
                ),

                SizedBox(height: compact ? 8 : 12),

                // ==================================================
                // NAVIGATION
                // ==================================================
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 12),
                    child: Column(
                      children: [
                        // ==================================================
                        // DASHBOARD
                        // ==================================================
                        _section(
                          context,
                          compact: compact,
                          title: _translate(
                            AppLocalizations.of(context),
                            'TABLEAU DE BORD',
                            'DASHBOARD',
                          ),
                          children: [
                            _item(
                              context,
                              compact: compact,
                              icon: Icons.dashboard_rounded,
                              label: AppLocalizations.of(context).dashboard,
                              index: 0,
                            ),
                          ],
                        ),

                        // ==================================================
                        // ORGANISATION
                        // ==================================================
                        _section(
                          context,
                          compact: compact,
                          title: _translate(
                            AppLocalizations.of(context),
                            'ORGANISATION',
                            'ORGANIZATION',
                          ),
                          children: [
                            _item(
                              context,
                              compact: compact,
                              icon: Icons.account_tree_outlined,
                              label: _translate(
                                AppLocalizations.of(context),
                                'Organisation',
                                'Organization',
                              ),
                              index: 1,
                            ),
                            _item(
                              context,
                              compact: compact,
                              icon: Icons.people_alt_outlined,
                              label: _translate(
                                AppLocalizations.of(context),
                                'Membres',
                                'Members',
                              ),
                              index: 2,
                            ),
                            _item(
                              context,
                              compact: compact,
                              icon: Icons.groups_outlined,
                              label: _translate(
                                AppLocalizations.of(context),
                                'Équipe',
                                'Team',
                              ),
                              index: 3,
                            ),
                            _item(
                              context,
                              compact: compact,
                              icon: Icons.supervisor_account_outlined,
                              label: _translate(
                                AppLocalizations.of(context),
                                'Superviseurs',
                                'Supervisors',
                              ),
                              index: 4,
                            ),
                            _item(
                              context,
                              compact: compact,
                              icon: Icons.manage_accounts_outlined,
                              label: _translate(
                                AppLocalizations.of(context),
                                'Inspecteurs',
                                'Inspectors',
                              ),
                              index: 5,
                            ),
                          ],
                        ),

                        // ==================================================
                        // ACTIVITÉS
                        // ==================================================
                        _section(
                          context,
                          compact: compact,
                          title: _translate(
                            AppLocalizations.of(context),
                            'ACTIVITÉS',
                            'ACTIVITIES',
                          ),
                          children: [
                            _item(
                              context,
                              compact: compact,
                              icon: Icons.event_note_outlined,
                              label: _translate(
                                AppLocalizations.of(context),
                                'Activités',
                                'Activities',
                              ),
                              index: 6,
                            ),
                            _item(
                              context,
                              compact: compact,
                              icon: Icons.assignment_outlined,
                              label: _translate(
                                AppLocalizations.of(context),
                                'Rapports',
                                'Reports',
                              ),
                              index: 7,
                            ),
                          ],
                        ),

                        // ==================================================
                        // FINANCES
                        // ==================================================
                        _section(
                          context,
                          compact: compact,
                          title: _translate(
                            AppLocalizations.of(context),
                            'FINANCES',
                            'FINANCE',
                          ),
                          children: [
                            _item(
                              context,
                              compact: compact,
                              icon: Icons.payments_outlined,
                              label: _translate(
                                AppLocalizations.of(context),
                                'Contributions',
                                'Contributions',
                              ),
                              index: 8,
                            ),
                          ],
                        ),

                        // ==================================================
                        // MISSION
                        // ==================================================
                        _section(
                          context,
                          compact: compact,
                          title: _translate(
                            AppLocalizations.of(context),
                            'MISSION',
                            'MISSION',
                          ),
                          children: [
                            _item(
                              context,
                              compact: compact,
                              icon: Icons.account_balance_outlined,
                              label: _translate(
                                AppLocalizations.of(context),
                                'Projets',
                                'Projects',
                              ),
                              index: 9,
                            ),
                            _item(
                              context,
                              compact: compact,
                              icon: Icons.handshake_outlined,
                              label: _translate(
                                AppLocalizations.of(context),
                                'Sponsors',
                                'Sponsors',
                              ),
                              index: 10,
                            ),
                          ],
                        ),

                        // ==================================================
                        // ADMINISTRATION
                        // ==================================================
                        _section(
                          context,
                          compact: compact,
                          title: _translate(
                            AppLocalizations.of(context),
                            'ADMINISTRATION',
                            'ADMINISTRATION',
                          ),
                          children: [
                            _item(
                              context,
                              compact: compact,
                              icon: Icons.person_outline_rounded,
                              label: _translate(
                                AppLocalizations.of(context),
                                'Utilisateurs',
                                'Users',
                              ),
                              index: 11,
                            ),
                            _item(
                              context,
                              compact: compact,
                              icon: Icons.admin_panel_settings_outlined,
                              label: _translate(
                                AppLocalizations.of(context),
                                'Rôles',
                                'Roles',
                              ),
                              index: 12,
                            ),
                            _item(
                              context,
                              compact: compact,
                              icon: Icons.lock_outline_rounded,
                              label: _translate(
                                AppLocalizations.of(context),
                                'Permissions',
                                'Permissions',
                              ),
                              index: 13,
                            ),
                          ],
                        ),

                        // ==================================================
                        // SYSTÈME
                        // ==================================================
                        _section(
                          context,
                          compact: compact,
                          title: _translate(
                            AppLocalizations.of(context),
                            'SYSTÈME',
                            'SYSTEM',
                          ),
                          children: [
                            _item(
                              context,
                              compact: compact,
                              icon: Icons.notifications_none_rounded,
                              label: _translate(
                                AppLocalizations.of(context),
                                'Notifications',
                                'Notifications',
                              ),
                              index: 14,
                            ),
                            _item(
                              context,
                              compact: compact,
                              icon: Icons.history_rounded,
                              label: _translate(
                                AppLocalizations.of(context),
                                'Audit',
                                'Audit',
                              ),
                              index: 15,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // FOOTER
                // ==================================================
                _SidebarFooter(
                  compact: compact,
                  onSettings: () => onItemSelected(16),
                  onLogout: () => onItemSelected(17),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ======================================================
  // TRANSLATION
  // ======================================================

  String _translate(
    AppLocalizations localization,
    String french,
    String english,
  ) {
    return localization.isFrench ? french : english;
  }

  // ======================================================
  // SECTION
  // ======================================================

  Widget _section(
    BuildContext context, {
    required bool compact,
    required String title,
    required List<Widget> children,
  }) {
    if (compact) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(children: children),
      );
    }

    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 7),
            child: Text(
              title.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: colors.onSurface.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.68
                      : 0.55,
                ),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  // ======================================================
  // NAVIGATION ITEM
  // ======================================================

  Widget _item(
    BuildContext context, {
    required bool compact,
    required IconData icon,
    required String label,
    required int index,
  }) {
    final theme = Theme.of(context);

    final colors = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    final selected = selectedIndex == index;

    final iconColor = selected
        ? AppColors.primary
        : colors.onSurface.withValues(alpha: isDark ? 0.82 : 0.68);

    final textColor = selected
        ? AppColors.primary
        : colors.onSurface.withValues(alpha: isDark ? 0.92 : 0.78);

    final selectedBackground = AppColors.primary.withValues(
      alpha: isDark ? 0.16 : 0.09,
    );

    final selectedBorder = AppColors.primary.withValues(
      alpha: isDark ? 0.26 : 0.14,
    );

    if (compact) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Tooltip(
          message: label,
          waitDuration: const Duration(milliseconds: 300),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              hoverColor: colors.onSurface.withValues(
                alpha: isDark ? 0.06 : 0.035,
              ),
              splashColor: AppColors.primary.withValues(alpha: 0.10),
              onTap: () => onItemSelected(index),
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: Center(
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: selected ? selectedBackground : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? selectedBorder : Colors.transparent,
                      ),
                    ),
                    child: Icon(icon, size: 19, color: iconColor),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: colors.onSurface.withValues(
            alpha: isDark ? 0.055 : 0.035,
          ),
          splashColor: AppColors.primary.withValues(alpha: 0.10),
          onTap: () => onItemSelected(index),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? selectedBackground : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? selectedBorder : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 19, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// SIDEBAR HEADER
// ==========================================================

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({required this.compact, required this.onCollapseToggle});

  final bool compact;
  final VoidCallback? onCollapseToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.fromLTRB(compact ? 8 : 14, 16, compact ? 8 : 14, 0),
      child: Column(
        children: [
          if (compact)
            _CollapsedHeader(onCollapseToggle: onCollapseToggle)
          else
            _ExpandedHeader(onCollapseToggle: onCollapseToggle),
          Divider(
            height: compact ? 18 : 24,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// EXPANDED HEADER
// ==========================================================

class _ExpandedHeader extends StatelessWidget {
  const _ExpandedHeader({required this.onCollapseToggle});

  final VoidCallback? onCollapseToggle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        const SizedBox(
          width: 42,
          height: 42,
          child: MdpLogo(size: 42, showName: false, center: true),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppConstants.appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                AppConstants.organizationName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurface.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.70
                        : 0.62,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (onCollapseToggle != null) ...[
          const SizedBox(width: 6),
          _CollapseButton(collapsed: false, onPressed: onCollapseToggle!),
        ],
      ],
    );
  }
}

// ==========================================================
// COLLAPSED HEADER
// ==========================================================

class _CollapsedHeader extends StatelessWidget {
  const _CollapsedHeader({required this.onCollapseToggle});

  final VoidCallback? onCollapseToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 40,
          height: 40,
          child: MdpLogo(size: 40, showName: false, center: true),
        ),

        if (onCollapseToggle != null) ...[
          const SizedBox(height: 10),
          _CollapseButton(collapsed: true, onPressed: onCollapseToggle!),
        ],
      ],
    );
  }
}

// ==========================================================
// COLLAPSE BUTTON
// ==========================================================

class _CollapseButton extends StatelessWidget {
  const _CollapseButton({required this.collapsed, required this.onPressed});

  final bool collapsed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: collapsed ? 'Développer le menu' : 'Réduire le menu',
      waitDuration: const Duration(milliseconds: 300),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(9),
          hoverColor: colors.onSurface.withValues(alpha: isDark ? 0.07 : 0.04),
          splashColor: AppColors.primary.withValues(alpha: 0.10),
          child: SizedBox(
            width: 30,
            height: 30,
            child: Container(
              decoration: BoxDecoration(
                color: colors.onSurface.withValues(alpha: isDark ? 0.08 : 0.05),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: colors.outline.withValues(alpha: isDark ? 0.55 : 0.70),
                ),
              ),
              child: Icon(
                collapsed
                    ? Icons.keyboard_double_arrow_right_rounded
                    : Icons.keyboard_double_arrow_left_rounded,
                size: 17,
                color: colors.onSurface.withValues(alpha: isDark ? 0.88 : 0.68),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// SIDEBAR FOOTER
// ==========================================================

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter({
    required this.compact,
    required this.onSettings,
    required this.onLogout,
  });

  final bool compact;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(compact ? 6 : 12, 10, compact ? 6 : 12, 14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Column(
        children: [
          _footerItem(
            context,
            compact: compact,
            icon: Icons.settings_outlined,
            label: _translate(context, 'Paramètres', 'Settings'),
            onTap: onSettings,
          ),

          _footerItem(
            context,
            compact: compact,
            icon: Icons.logout_rounded,
            label: _translate(context, 'Déconnexion', 'Logout'),
            onTap: onLogout,
            danger: true,
          ),
        ],
      ),
    );
  }

  Widget _footerItem(
    BuildContext context, {
    required bool compact,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final theme = Theme.of(context);

    final colors = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    final color = danger
        ? AppColors.error
        : colors.onSurface.withValues(alpha: isDark ? 0.82 : 0.68);

    if (compact) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Tooltip(
          message: label,
          waitDuration: const Duration(milliseconds: 300),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              hoverColor: danger
                  ? AppColors.error.withValues(alpha: isDark ? 0.10 : 0.06)
                  : colors.onSurface.withValues(alpha: isDark ? 0.06 : 0.035),
              splashColor: danger
                  ? AppColors.error.withValues(alpha: 0.10)
                  : AppColors.primary.withValues(alpha: 0.10),
              onTap: onTap,
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: Center(child: Icon(icon, size: 19, color: color)),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: danger
              ? AppColors.error.withValues(alpha: isDark ? 0.10 : 0.06)
              : colors.onSurface.withValues(alpha: isDark ? 0.055 : 0.035),
          splashColor: danger
              ? AppColors.error.withValues(alpha: 0.10)
              : AppColors.primary.withValues(alpha: 0.10),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 19, color: color),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _translate(BuildContext context, String french, String english) {
    return AppLocalizations.of(context).isFrench ? french : english;
  }
}
