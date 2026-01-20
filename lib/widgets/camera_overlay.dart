import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CameraOverlay extends StatelessWidget {
  final Size screenSize;
  final List<Offset>? detectedCorners;

  const CameraOverlay({
    super.key,
    required this.screenSize,
    this.detectedCorners,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: screenSize,
      painter: CameraOverlayPainter(detectedCorners: detectedCorners),
    );
  }
}

class CameraOverlayPainter extends CustomPainter {
  final List<Offset>? detectedCorners;

  CameraOverlayPainter({this.detectedCorners});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.scanOverlay
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.scanBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw semi-transparent overlay
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Calculate scan area
    final scanRect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.2,
      size.width * 0.8,
      size.height * 0.6,
    );

    // Clear scan area
    canvas.drawRect(
      scanRect,
      Paint()..blendMode = BlendMode.clear,
    );

    // Draw border or detected corners
    if (detectedCorners != null && detectedCorners!.length == 4) {
      final path = Path();
      path.moveTo(detectedCorners![0].dx, detectedCorners![0].dy);
      for (int i = 1; i < detectedCorners!.length; i++) {
        path.lineTo(detectedCorners![i].dx, detectedCorners![i].dy);
      }
      path.close();
      canvas.drawPath(path, borderPaint);

      // Draw corner handles
      final handlePaint = Paint()
        ..color = AppColors.cropHandle
        ..style = PaintingStyle.fill;

      for (final corner in detectedCorners!) {
        canvas.drawCircle(corner, 8, handlePaint);
      }
    } else {
      // Draw default scan rectangle
      canvas.drawRect(scanRect, borderPaint);
    }

    // Draw corner guides
    _drawCornerGuides(canvas, scanRect, borderPaint);
  }

  void _drawCornerGuides(Canvas canvas, Rect rect, Paint paint) {
    const guideLength = 30.0;
    
    // Top-left
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + guideLength, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.top + guideLength),
      paint,
    );

    // Top-right
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right - guideLength, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + guideLength),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + guideLength, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left, rect.bottom - guideLength),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right - guideLength, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - guideLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
