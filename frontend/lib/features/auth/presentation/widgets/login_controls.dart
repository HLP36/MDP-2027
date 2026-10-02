import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';

class LoginControls extends ConsumerWidget {
  const LoginControls({
    super.key,
    required this.localization,
    required this.isDark,
  });

  final AppLocalizations localization;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ControlButton(
          icon: Icons.language_rounded,
          label: localization.isFrench ? 'FR' : 'EN',
          tooltip: localization.isFrench
              ? 'Changer la langue'
              : 'Change language',
          onPressed: () {
            ref.read(localeProvider.notifier).toggle();
          },
        ),
        const SizedBox(width: 8),
        _ControlButton(
          icon: _themeIcon(themeMode),
          label: _themeLabel(themeMode),
          tooltip: localization.isFrench ? 'Changer le thème' : 'Change theme',
          onPressed: () {
            ref
                .read(themeModeProvider.notifier)
                .toggle(isDark ? Brightness.dark : Brightness.light);
          },
        ),
      ],
    );
  }

  IconData _themeIcon(MdpThemeMode mode) {
    switch (mode) {
      case MdpThemeMode.system:
        return Icons.desktop_windows_outlined;
      case MdpThemeMode.light:
        return Icons.light_mode_outlined;
      case MdpThemeMode.dark:
        return Icons.dark_mode_outlined;
    }
  }

  String _themeLabel(MdpThemeMode mode) {
    switch (mode) {
      case MdpThemeMode.system:
        return 'Auto';
      case MdpThemeMode.light:
        return localization.isFrench ? 'Clair' : 'Light';
      case MdpThemeMode.dark:
        return localization.isFrench ? 'Sombre' : 'Dark';
    }
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.colorScheme.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
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
