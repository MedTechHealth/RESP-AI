import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MeshBackground extends StatefulWidget {
  const MeshBackground({super.key, required this.child});

  final Widget child;

  @override
  State<MeshBackground> createState() => _MeshBackgroundState();
}

class _MeshBackgroundState extends State<MeshBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
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
      children: <Widget>[
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              return CustomPaint(
                painter: _EditorialBackgroundPainter(
                  progress: _controller.value,
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppTheme.frost.withValues(alpha: 0.88),
                  AppTheme.frost.withValues(alpha: 0.92),
                ],
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _EditorialBackgroundPainter extends CustomPainter {
  const _EditorialBackgroundPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint fill = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.55, -0.65),
        radius: 1.15,
        colors: <Color>[
          AppTheme.goldSoft.withValues(alpha: 0.65),
          AppTheme.frost.withValues(alpha: 0.1),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, fill);

    final Paint secondary = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          0.75,
          -0.25 + math.sin(progress * math.pi * 2) * 0.06,
        ),
        radius: 0.95,
        colors: <Color>[
          AppTheme.respiratoryTealSoft.withValues(alpha: 0.55),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, secondary);

    final Paint contourPaint = Paint()
      ..color = AppTheme.glassBorder.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final Offset center = Offset(size.width * 0.78, size.height * 0.22);
    for (int index = 0; index < 7; index++) {
      final double radius = size.shortestSide * (0.24 + index * 0.085);
      canvas.drawOval(
        Rect.fromCenter(center: center, width: radius * 1.8, height: radius),
        contourPaint,
      );
    }

    final Paint wavePaint = Paint()
      ..color = AppTheme.slate.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (int line = 0; line < 4; line++) {
      final Path path = Path();
      final double startY = size.height * (0.66 + line * 0.05);
      path.moveTo(-40, startY);
      for (double x = -40; x <= size.width + 40; x += 8) {
        final double y =
            startY +
            math.sin(
                  (x / size.width) * math.pi * 3 +
                      progress * math.pi * 2 +
                      line,
                ) *
                (8 + line * 2);
        path.lineTo(x, y);
      }
      canvas.drawPath(path, wavePaint);
    }

    final Paint markerPaint = Paint()
      ..color = AppTheme.slate.withValues(alpha: 0.09);
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.17),
      72,
      markerPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.18),
      58,
      Paint()..color = AppTheme.frost.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _EditorialBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
