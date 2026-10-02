import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key, required this.onMenuPressed});

  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;

    final isMobile = width < 700;
    final isTablet = width >= 700 && width < 1000;

    return Container(
      height: isMobile ? 64 : 72,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.94)
            : AppColors.lightSurface.withValues(alpha: 0.94),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          if (!isTablet && isMobile)
            _MobileMenuButton(onPressed: onMenuPressed),

          if (isTablet) _MobileMenuButton(onPressed: onMenuPressed),

          _HeaderTitle(localization: localization, compact: isMobile),

          if (!isMobile) ...[
            const SizedBox(width: 24),
            const Expanded(child: _SearchField()),
          ] else
            const Spacer(),

          _HeaderActions(localization: localization, compact: isMobile),
        ],
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({required this.localization, required this.compact});

  final AppLocalizations localization;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.dashboard,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 16 : 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        if (!compact)
          Text(
            'MDP 2027',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.48),
            ),
          ),
      ],
    );
  }
}

class _MobileMenuButton extends StatelessWidget {
  const _MobileMenuButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: IconButton(
        tooltip: 'Menu',
        onPressed: onPressed,
        icon: const Icon(Icons.menu_rounded, size: 23),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 700) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: SizedBox(
          height: 42,
          child: TextField(
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Rechercher...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  widthFactor: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '⌘ K',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderActions extends ConsumerWidget {
  const _HeaderActions({required this.localization, required this.compact});

  final AppLocalizations localization;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact && width >= 700) ...[
          _LanguageButton(localization: localization),
          const SizedBox(width: 2),
          const _ThemeButton(),
          const SizedBox(width: 2),
        ],
        const _NotificationButton(),
        const SizedBox(width: 6),
        const _ProfileButton(),
      ],
    );
  }
}

class _LanguageButton extends ConsumerWidget {
  const _LanguageButton({required this.localization});

  final AppLocalizations localization;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFrench = ref.watch(localeProvider).languageCode == 'fr';

    return Tooltip(
      message: isFrench ? localization.english : localization.french,
      child: IconButton(
        onPressed: () {
          ref.read(localeProvider.notifier).toggle();
        },
        icon: Text(
          isFrench ? 'FR' : 'EN',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _ThemeButton extends ConsumerWidget {
  const _ThemeButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final brightness = Theme.of(context).brightness;

    final IconData icon;

    switch (themeMode) {
      case MdpThemeMode.system:
        icon = Icons.brightness_auto_outlined;
        break;

      case MdpThemeMode.light:
        icon = Icons.light_mode_outlined;
        break;

      case MdpThemeMode.dark:
        icon = Icons.dark_mode_outlined;
        break;
    }

    return Tooltip(
      message: 'Thème',
      child: IconButton(
        onPressed: () {
          ref.read(themeModeProvider.notifier).toggle(brightness);
        },
        icon: Icon(icon, size: 20),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded, size: 21),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Profil',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (_) {},
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 19),
              SizedBox(width: 10),
              Text('Mon profil'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, size: 19),
              SizedBox(width: 10),
              Text('Paramètres'),
            ],
          ),
        ),
      ],
      child: const CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.primary,
        child: Text(
          'A',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
