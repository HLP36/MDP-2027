import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DashboardChartCard extends StatelessWidget {
  const DashboardChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 330,
      padding: const EdgeInsets.all(20),
      decoration: _decoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ChartHeader(),
          const SizedBox(height: 22),
          Expanded(
            child: CustomPaint(
              painter: _ChartPainter(
                isDark: Theme.of(context).brightness == Brightness.dark,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _decoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
    );
  }
}

class _ChartHeader extends StatelessWidget {
  const _ChartHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activité mensuelle',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'Évolution des contributions',
                style: TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                size: 15,
                color: AppColors.primary,
              ),
              SizedBox(width: 5),
              Text(
                'Cette année',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = isDark ? AppColors.darkBorder : AppColors.lightBorder
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final points = <Offset>[
      Offset(0, size.height * .72),
      Offset(size.width * .10, size.height * .62),
      Offset(size.width * .20, size.height * .67),
      Offset(size.width * .30, size.height * .48),
      Offset(size.width * .40, size.height * .55),
      Offset(size.width * .50, size.height * .35),
      Offset(size.width * .60, size.height * .42),
      Offset(size.width * .70, size.height * .25),
      Offset(size.width * .80, size.height * .34),
      Offset(size.width * .90, size.height * .18),
      Offset(size.width, size.height * .24),
    ];

    for (var i = 0; i < 5; i++) {
      final y = size.height * i / 4;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];

      final controlPoint1 = Offset(
        previous.dx + (current.dx - previous.dx) / 2,
        previous.dy,
      );

      final controlPoint2 = Offset(
        previous.dx + (current.dx - previous.dx) / 2,
        current.dy,
      );

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        current.dx,
        current.dy,
      );
    }

    canvas.drawPath(path, linePaint);

    for (final point in points) {
      canvas.drawCircle(point, 3.5, Paint()..color = AppColors.primary);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
