import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key, required this.isDark, required this.child});

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF07111F), Color(0xFF0B0F14), Color(0xFF10151C)]
              : const [Color(0xFFF7F9FC), Color(0xFFFFFFFF), Color(0xFFF2F5F9)],
        ),
      ),
      child: Stack(
        children: [
          const _BackgroundGlow(alignment: Alignment.topLeft, size: 430),
          const _BackgroundGlow(alignment: Alignment.bottomRight, size: 500),
          child,
        ],
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow({required this.alignment, required this.size});

  final Alignment alignment;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Transform.translate(
          offset: Offset(
            alignment.x < 0 ? -180 : 170,
            alignment.y < 0 ? -180 : 230,
          ),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.055),
            ),
          ),
        ),
      ),
    );
  }
}
