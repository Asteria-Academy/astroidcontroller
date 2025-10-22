import 'dart:math';
import 'package:flutter/material.dart';

class DonutLedPicker extends StatelessWidget {
  const DonutLedPicker({
    super.key,
    required this.ledColors,
    required this.onSegmentTapped,
    this.strokeWidth = 40.0,
  });

  final List<Color> ledColors;
  final ValueChanged<int> onSegmentTapped;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        _handleTap(localPosition, box.size);
      },
      child: CustomPaint(
        painter: _DonutLedPainter(
          ledColors: ledColors,
          strokeWidth: strokeWidth,
        ),
        size: const Size.square(180),
      ),
    );
  }

  void _handleTap(Offset tapPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final translatedPoint = tapPosition - center;
    final distance = translatedPoint.distance;

    if (distance > radius || distance < radius - strokeWidth) {
      return;
    }

    var angle = atan2(translatedPoint.dy, translatedPoint.dx) + (pi / 2);

    if (angle < 0) {
      angle += 2 * pi;
    }

    final segmentAngle = (2 * pi) / 12;
    final index = (angle / segmentAngle).floor() % 12;
    
    onSegmentTapped(index);
  }
}

class _DonutLedPainter extends CustomPainter {
  _DonutLedPainter({ required this.ledColors, required this.strokeWidth });
  final List<Color> ledColors;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    const totalAngle = 2 * pi;
    const segmentCount = 12;
    const gapAngle = totalAngle / 72;
    final sweepAngle = (totalAngle / segmentCount) - gapAngle;

    for (int i = 0; i < segmentCount; i++) {
      final startAngle = (i * (sweepAngle + gapAngle)) - (pi / 2) - (gapAngle / 2);
      
      final paint = Paint()
        ..color = ledColors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}