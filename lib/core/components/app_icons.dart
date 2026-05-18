import 'package:flutter/material.dart';
import 'package:fundlink_app/core/constants/colors.dart';

class TransactionTypeIcon extends StatelessWidget {
  final bool isIncome;
  final double size;
  final Color? color;

  const TransactionTypeIcon({
    super.key,
    required this.isIncome,
    this.size = 22,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? (isIncome ? AppColors.primary : Colors.red);

    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _TransactionTypeIconPainter(
          color: iconColor,
          isIncome: isIncome,
        ),
      ),
    );
  }
}

class _TransactionTypeIconPainter extends CustomPainter {
  final Color color;
  final bool isIncome;

  const _TransactionTypeIconPainter({
    required this.color,
    required this.isIncome,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final axis = Path()
      ..moveTo(size.width * 0.2, size.height * 0.14)
      ..lineTo(size.width * 0.2, size.height * 0.78)
      ..lineTo(size.width * 0.82, size.height * 0.78);
    canvas.drawPath(axis, stroke);

    final line = Path();
    if (isIncome) {
      line
        ..moveTo(size.width * 0.32, size.height * 0.62)
        ..lineTo(size.width * 0.45, size.height * 0.5)
        ..lineTo(size.width * 0.58, size.height * 0.55)
        ..lineTo(size.width * 0.76, size.height * 0.34);
    } else {
      line
        ..moveTo(size.width * 0.32, size.height * 0.36)
        ..lineTo(size.width * 0.45, size.height * 0.5)
        ..lineTo(size.width * 0.58, size.height * 0.46)
        ..lineTo(size.width * 0.76, size.height * 0.66);
    }
    canvas.drawPath(line, stroke);
  }

  @override
  bool shouldRepaint(_TransactionTypeIconPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isIncome != isIncome;
  }
}
