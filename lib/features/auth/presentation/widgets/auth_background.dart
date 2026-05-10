import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _AuthBackgroundPainter()),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class _AuthBackgroundPainter extends CustomPainter {
  const _AuthBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()
      ..color = AppColors.authGold
      ..style = PaintingStyle.fill;

    final blackPaint = Paint()
      ..color = AppColors.authBlack
      ..style = PaintingStyle.fill;

    final topPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.10,
        size.width * 0.62,
        size.height * 0.13,
        size.width * 0.38,
        size.height * 0.14,
      )
      ..cubicTo(
        size.width * 0.20,
        size.height * 0.15,
        size.width * 0.13,
        size.height * 0.20,
        0,
        size.height * 0.25,
      )
      ..close();

    canvas.drawPath(topPath, goldPaint);

    final bottomPath = Path()
      ..moveTo(size.width, size.height * 0.77)
      ..cubicTo(
        size.width * 0.80,
        size.height * 0.92,
        size.width * 0.62,
        size.height * 0.86,
        size.width * 0.40,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(bottomPath, blackPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
