import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MdpLogo extends StatelessWidget {
  const MdpLogo({
    super.key,
    this.size = 72,
    this.showName = true,
    this.center = true,
  });

  final double size;
  final bool showName;
  final bool center;

  bool get _canShowName => showName && size >= 56;

  @override
  Widget build(BuildContext context) {
    final logo = _LogoMark(size: size);

    if (!_canShowName) {
      return center ? Center(child: logo) : logo;
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        const SizedBox(height: 14),
        Text(
          'MAISON DU PÈRE',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 2.2,
            color: AppColors.primary,
          ),
        ),
      ],
    );

    return center ? Center(child: content) : content;
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF123E76)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: size * 0.35,
            offset: Offset(0, size * 0.14),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.home_work_rounded,
            color: AppColors.gold,
            size: size * 0.50,
          ),
          Positioned(
            top: size * 0.16,
            child: Icon(Icons.add, color: Colors.white, size: size * 0.22),
          ),
        ],
      ),
    );
  }
}
