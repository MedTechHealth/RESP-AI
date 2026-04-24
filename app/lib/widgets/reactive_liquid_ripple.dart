import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A reactive liquid ripple visualization that responds to amplitude.
/// Uses a layered sine-wave algorithm for an organic feel.
class ReactiveLiquidRipple extends StatefulWidget {
  const ReactiveLiquidRipple({
    super.key,
    required this.size,
    required this.color,
    this.amplitude = 1.0,
    this.isAnimating = true,
  });

  final double size;
  final Color color;
  final double amplitude;
  final bool isAnimating;

  @override
  State<ReactiveLiquidRipple> createState() => _ReactiveLiquidRippleState();
}

class _ReactiveLiquidRippleState extends State<ReactiveLiquidRipple>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ReactiveLiquidRipple oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Step 3: Wrap the painter in RepaintBoundary for high performance.
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size.square(widget.size),
            painter: _RipplePainter(
              phase: _controller.value,
              amplitude: widget.amplitude,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  const _RipplePainter({
    required this.phase,
    required this.amplitude,
    required this.color,
  });

  final double phase;
  final double amplitude;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final baseRadius = size.width / 2.2;

    // Layer 1: Deep Slow Wave
    _drawLiquidLayer(
      canvas,
      center,
      baseRadius * 0.95,
      phase,
      amplitude,
      color.withValues(alpha: 0.15),
      3,
      1.2,
    );

    // Layer 2: Medium Fluid Wave
    _drawLiquidLayer(
      canvas,
      center,
      baseRadius * 1.0,
      phase * 1.5,
      amplitude * 0.8,
      color.withValues(alpha: 0.25),
      5,
      1.8,
    );

    // Layer 3: High Frequency Surface Wave
    _drawLiquidLayer(
      canvas,
      center,
      baseRadius * 1.05,
      phase * 2.2,
      amplitude * 0.5,
      color.withValues(alpha: 0.4),
      8,
      2.5,
    );
  }

  void _drawLiquidLayer(
    Canvas canvas,
    Offset center,
    double radius,
    double currentPhase,
    double currentAmplitude,
    Color layerColor,
    int waveCount,
    double speed,
  ) {
    final paint = Paint()
      ..color = layerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    const segments = 120; // High resolution for smooth curves

    for (int i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * math.pi;

      // Multi-layered sine wave distortion for "liquid" feel
      // Incorporates amplitude into the distortion depth
      final distortion =
          math.sin(angle * waveCount + currentPhase * 2 * math.pi) *
          10.0 *
          currentAmplitude;

      final secondaryDistortion =
          math.cos(angle * (waveCount / 2) - currentPhase * 3 * math.pi) *
          5.0 *
          currentAmplitude;

      final totalRadius = radius + distortion + secondaryDistortion;

      final x = center.dx + math.cos(angle) * totalRadius;
      final y = center.dy + math.sin(angle) * totalRadius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.color != color;
  }
}
