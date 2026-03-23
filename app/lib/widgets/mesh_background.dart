import 'dart:math' as math;
import 'package:flutter/material.dart';

class MeshBackground extends StatefulWidget {
  final Widget child;
  const MeshBackground({super.key, required this.child});

  @override
  State<MeshBackground> createState() => _MeshBackgroundState();
}

class _MeshBackgroundState extends State<MeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(painter: MeshPainter(_controller.value));
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class MeshPainter extends CustomPainter {
  final double animationValue;
  MeshPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    // Color 1: Indigo
    _drawBlob(
      canvas,
      size,
      paint..color = const Color(0xFF4F46E5).withOpacity(0.08),
      offset: Offset(
        size.width * 0.2 + math.sin(animationValue * math.pi * 2) * 50,
        size.height * 0.2 + math.cos(animationValue * math.pi * 2) * 50,
      ),
      radius: size.width * 0.6,
    );

    // Color 2: Cyan
    _drawBlob(
      canvas,
      size,
      paint..color = const Color(0xFF06B6D4).withOpacity(0.08),
      offset: Offset(
        size.width * 0.8 + math.cos(animationValue * math.pi * 2) * 80,
        size.height * 0.1 + math.sin(animationValue * math.pi * 2) * 80,
      ),
      radius: size.width * 0.5,
    );

    // Color 3: Rose/Pink
    _drawBlob(
      canvas,
      size,
      paint..color = const Color(0xFFE11D48).withOpacity(0.05),
      offset: Offset(
        size.width * 0.5 + math.sin(animationValue * math.pi * 2 + 1) * 100,
        size.height * 0.8 + math.cos(animationValue * math.pi * 2 + 1) * 100,
      ),
      radius: size.width * 0.7,
    );
  }

  void _drawBlob(
    Canvas canvas,
    Size size,
    Paint paint, {
    required Offset offset,
    required double radius,
  }) {
    canvas.drawCircle(offset, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
