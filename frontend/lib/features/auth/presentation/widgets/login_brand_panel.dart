import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mdp_logo.dart';

class LoginBrandPanel extends StatelessWidget {
  const LoginBrandPanel({super.key, required this.localization});

  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MdpLogo(size: 88, showName: true, center: false),
        const SizedBox(height: 36),
        Text(
          localization.isFrench
              ? 'Bâtir sur la Terre\npour la gloire du Ciel.'
              : 'Build on Earth\nfor the glory of Heaven.',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.05,
            letterSpacing: -1.8,
          ),
        ),
        const SizedBox(height: 22),
        Container(
          width: 54,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          localization.isFrench
              ? 'Plateforme administrative de la Maison du Père.'
              : 'Administrative platform of the House of the Father.',
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.65,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
          ),
        ),
      ],
    );
  }
}
