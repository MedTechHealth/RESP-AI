import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HolographicLung extends StatefulWidget {
  const HolographicLung({
    super.key,
    this.isRecording = false,
    this.confidence = 1.0,
    this.disease,
    this.size = 200,
  });

  final bool isRecording;
  final double confidence;
  final String? disease;
  final double size;

  @override
  State<HolographicLung> createState() => _HolographicLungState();
}

class _HolographicLungState extends State<HolographicLung>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: LungPainter(
          animationValue: _controller.value,
          isRecording: widget.isRecording,
          confidence: widget.confidence,
          disease: widget.disease,
        ),
      ),
    );
  }
}

class LungPainter extends CustomPainter {
  LungPainter({
    required this.animationValue,
    required this.isRecording,
    required this.confidence,
    this.disease,
  });

  final double animationValue;
  final bool isRecording;
  final double confidence;
  final String? disease;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.45);
    final scale = math.min(size.width, size.height) * 0.45;

    _drawLobes(canvas, center, scale);
    _drawBronchialTree(canvas, center, scale);
    if (isRecording) {
      _drawParticles(canvas, center, scale);
    }
    if (disease != null) {
      _drawDiseaseOverlay(canvas, center, scale);
    }
  }

  void _drawLobes(Canvas canvas, Offset center, double scale) {
    final baseColor = AppTheme.mentholCyan;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = baseColor.withValues(alpha: 0.4);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.radial(center, scale * 1.5, [
        baseColor.withValues(alpha: 0.1),
        baseColor.withValues(alpha: 0.0),
      ]);

    if (confidence < 0.8) {
      final blur = (1.0 - confidence) * 8.0;
      strokePaint.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    }

    // Right Lung (3 lobes: Superior, Middle, Inferior)
    final rightLungPath = Path()
      ..moveTo(center.dx + scale * 0.1, center.dy - scale * 0.8)
      ..quadraticBezierTo(
        center.dx + scale * 0.7,
        center.dy - scale * 0.9,
        center.dx + scale * 0.85,
        center.dy - scale * 0.2,
      )
      ..quadraticBezierTo(
        center.dx + scale * 1.0,
        center.dy + scale * 0.5,
        center.dx + scale * 0.8,
        center.dy + scale * 0.9,
      )
      ..quadraticBezierTo(
        center.dx + scale * 0.4,
        center.dy + scale * 1.0,
        center.dx + scale * 0.1,
        center.dy + scale * 0.7,
      )
      ..lineTo(center.dx + scale * 0.1, center.dy - scale * 0.8)
      ..close();

    // Left Lung (2 lobes: Superior, Inferior - with cardiac notch)
    final leftLungPath = Path()
      ..moveTo(center.dx - scale * 0.1, center.dy - scale * 0.8)
      ..quadraticBezierTo(
        center.dx - scale * 0.7,
        center.dy - scale * 0.9,
        center.dx - scale * 0.85,
        center.dy - scale * 0.2,
      )
      ..quadraticBezierTo(
        center.dx - scale * 0.9,
        center.dy + scale * 0.1,
        center.dx - scale * 0.7,
        center.dy + scale * 0.3,
      ) // Cardiac Notch
      ..quadraticBezierTo(
        center.dx - scale * 1.0,
        center.dy + scale * 0.6,
        center.dx - scale * 0.8,
        center.dy + scale * 0.9,
      )
      ..quadraticBezierTo(
        center.dx - scale * 0.4,
        center.dy + scale * 1.0,
        center.dx - scale * 0.1,
        center.dy + scale * 0.7,
      )
      ..lineTo(center.dx - scale * 0.1, center.dy - scale * 0.8)
      ..close();

    canvas.drawPath(rightLungPath, fillPaint);
    canvas.drawPath(leftLungPath, fillPaint);
    canvas.drawPath(rightLungPath, strokePaint);
    canvas.drawPath(leftLungPath, strokePaint);

    // Subtle internal structure lines
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = baseColor.withValues(alpha: 0.15);

    // Horizontal fissures
    canvas.drawLine(
      Offset(center.dx + scale * 0.2, center.dy - scale * 0.2),
      Offset(center.dx + scale * 0.8, center.dy - scale * 0.3),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx + scale * 0.15, center.dy + scale * 0.3),
      Offset(center.dx + scale * 0.9, center.dy + scale * 0.2),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx - scale * 0.2, center.dy),
      Offset(center.dx - scale * 0.8, center.dy + scale * 0.1),
      linePaint,
    );
  }

  void _drawBronchialTree(Canvas canvas, Offset center, double scale) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = AppTheme.mentholCyan.withValues(alpha: 0.7);

    if (confidence < 0.9) {
      final blur = (1.0 - confidence) * 4.0;
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    }

    final tree = Path();

    // Trachea
    tree.moveTo(center.dx, center.dy - scale * 1.1);
    tree.lineTo(center.dx, center.dy - scale * 0.4);

    // Primary Bronchi
    // Left
    tree.moveTo(center.dx, center.dy - scale * 0.4);
    tree.quadraticBezierTo(
      center.dx - scale * 0.1,
      center.dy - scale * 0.35,
      center.dx - scale * 0.4,
      center.dy,
    );
    // Right
    tree.moveTo(center.dx, center.dy - scale * 0.4);
    tree.quadraticBezierTo(
      center.dx + scale * 0.1,
      center.dy - scale * 0.35,
      center.dx + scale * 0.4,
      center.dy,
    );

    // Secondary/Tertiary (Stylized)
    _addBronchiBranch(tree, center, scale, -0.4, 0.0, -0.6, 0.3);
    _addBronchiBranch(tree, center, scale, -0.4, 0.0, -0.3, 0.5);
    _addBronchiBranch(tree, center, scale, 0.4, 0.0, 0.6, 0.3);
    _addBronchiBranch(tree, center, scale, 0.4, 0.0, 0.3, 0.5);
    _addBronchiBranch(tree, center, scale, 0.4, 0.0, 0.7, -0.3);
    _addBronchiBranch(tree, center, scale, -0.4, 0.0, -0.7, -0.3);

    canvas.drawPath(tree, paint);
  }

  void _addBronchiBranch(
    Path path,
    Offset center,
    double scale,
    double startX,
    double startY,
    double endX,
    double endY,
  ) {
    path.moveTo(center.dx + scale * startX, center.dy + scale * startY);
    path.quadraticBezierTo(
      center.dx + scale * (startX + endX) / 2,
      center.dy + scale * (startY + endY) / 2 - scale * 0.1,
      center.dx + scale * endX,
      center.dy + scale * endY,
    );
  }

  void _drawParticles(Canvas canvas, Offset center, double scale) {
    final particlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppTheme.mentholCyan;

    final random = math.Random(1234);
    for (int i = 0; i < 30; i++) {
      final delay = random.nextDouble();
      final t = (animationValue + delay) % 1.0;

      // Determine which branch this particle is on
      final branchId = i % 6;
      Offset pos;

      // Starting point: Trachea top
      Offset start = Offset(center.dx, center.dy - scale * 1.1);
      // Intermediate: Bifurcation
      Offset bifur = Offset(center.dx, center.dy - scale * 0.4);

      if (t < 0.3) {
        // In Trachea
        double subT = t / 0.3;
        pos = Offset.lerp(start, bifur, subT)!;
      } else {
        // In branches
        double subT = (t - 0.3) / 0.7;
        Offset end;
        switch (branchId) {
          case 0:
            end = Offset(center.dx - scale * 0.6, center.dy + scale * 0.3);
            break;
          case 1:
            end = Offset(center.dx - scale * 0.3, center.dy + scale * 0.5);
            break;
          case 2:
            end = Offset(center.dx + scale * 0.6, center.dy + scale * 0.3);
            break;
          case 3:
            end = Offset(center.dx + scale * 0.3, center.dy + scale * 0.5);
            break;
          case 4:
            end = Offset(center.dx + scale * 0.7, center.dy - scale * 0.3);
            break;
          default:
            end = Offset(center.dx - scale * 0.7, center.dy - scale * 0.3);
            break;
        }
        // Quadratic bezier approximation
        Offset cp = Offset(
          (bifur.dx + end.dx) / 2,
          (bifur.dy + end.dy) / 2 - scale * 0.1,
        );
        pos = _getBezierPoint(bifur, cp, end, subT);
      }

      final double opacity = math.sin(t * math.pi);
      particlePaint.color = AppTheme.mentholCyan.withValues(
        alpha: opacity * 0.8,
      );
      canvas.drawCircle(pos, 1.5 + random.nextDouble() * 1.5, particlePaint);
    }
  }

  Offset _getBezierPoint(Offset p0, Offset p1, Offset p2, double t) {
    double x =
        (1 - t) * (1 - t) * p0.dx + 2 * (1 - t) * t * p1.dx + t * t * p2.dx;
    double y =
        (1 - t) * (1 - t) * p0.dy + 2 * (1 - t) * t * p1.dy + t * t * p2.dy;
    return Offset(x, y);
  }

  void _drawDiseaseOverlay(Canvas canvas, Offset center, double scale) {
    if (disease == 'Pneumonia') {
      // Glowing fog in lower lobes
      final paint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(center.dx + scale * 0.4, center.dy + scale * 0.6),
          scale * 0.6,
          [
            AppTheme.clinicalAmber.withValues(
              alpha: 0.4 + 0.1 * math.sin(animationValue * 2 * math.pi),
            ),
            AppTheme.clinicalAmber.withValues(alpha: 0.0),
          ],
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawCircle(
        Offset(center.dx + scale * 0.4, center.dy + scale * 0.6),
        scale * 0.5,
        paint,
      );
      canvas.drawCircle(
        Offset(center.dx - scale * 0.4, center.dy + scale * 0.6),
        scale * 0.5,
        paint,
      );
    } else if (disease == 'Asthma') {
      // Constricting bronchial lines with intensity pulse
      final pulse = 0.5 + 0.5 * math.sin(animationValue * 4 * math.pi);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = AppTheme.clinicalAmber.withValues(alpha: 0.3 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      final asthmaTree = Path();
      asthmaTree.moveTo(center.dx - scale * 0.5, center.dy);
      asthmaTree.lineTo(center.dx + scale * 0.5, center.dy);

      // Draw some constricting rings
      for (int i = 0; i < 5; i++) {
        canvas.drawCircle(
          Offset(center.dx, center.dy - scale * 0.4 + i * scale * 0.2),
          scale * 0.1 * (1.0 + 0.2 * pulse),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant LungPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isRecording != isRecording ||
        oldDelegate.confidence != confidence ||
        oldDelegate.disease != disease;
  }
}
