import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BreathHaloButton extends StatelessWidget {
  const BreathHaloButton({
    super.key,
    required this.isRecording,
    required this.isAnalyzing,
    required this.durationLabel,
    required this.onPressed,
  });

  final bool isRecording;
  final bool isAnalyzing;
  final String durationLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final Color accent = isRecording
        ? AppTheme.oxide
        : AppTheme.respiratoryTeal;
    final String label = isAnalyzing
        ? 'Analysis in progress'
        : isRecording
        ? 'Stop capture'
        : 'Begin live capture';
    final IconData icon = isAnalyzing
        ? Icons.hourglass_top_rounded
        : isRecording
        ? Icons.stop_rounded
        : Icons.mic_rounded;

    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: 260,
        height: 260,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            IgnorePointer(
              child: CustomPaint(
                size: const Size.square(260),
                painter: _HaloPainter(
                  accent: accent,
                  isRecording: isRecording,
                  isAnalyzing: isAnalyzing,
                ),
              ),
            ),
            Container(
              width: 188,
              height: 188,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    AppTheme.glass,
                    accent.withValues(alpha: 0.18),
                  ],
                ),
                border: Border.all(
                  color: accent.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: accent.withValues(alpha: 0.12),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(156, 156),
                maximumSize: const Size(156, 156),
                backgroundColor: isAnalyzing
                    ? AppTheme.frostDeep
                    : AppTheme.slate,
                foregroundColor: isAnalyzing
                    ? AppTheme.slateMuted
                    : AppTheme.glass,
                shape: const CircleBorder(),
              ),
              onPressed: isAnalyzing ? null : onPressed,
              icon: Icon(icon, size: 28),
              label: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isAnalyzing ? AppTheme.slateMuted : AppTheme.glass,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    durationLabel,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isAnalyzing ? AppTheme.slateMuted : AppTheme.glass,
                      fontFeatures: AppTheme.tabularFigures,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HaloPainter extends CustomPainter {
  const _HaloPainter({
    required this.accent,
    required this.isRecording,
    required this.isAnalyzing,
  });

  final Color accent;
  final bool isRecording;
  final bool isAnalyzing;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final Paint outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppTheme.glassBorder;

    for (int index = 0; index < 4; index++) {
      canvas.drawCircle(center, 104 + index * 12, outer);
    }

    final Paint accentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..color = accent.withValues(alpha: isAnalyzing ? 0.28 : 0.88);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 102),
      -math.pi * 0.8,
      isRecording ? math.pi * 1.4 : math.pi * 0.86,
      false,
      accentPaint,
    );

    final Paint dashed = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = accent.withValues(alpha: 0.35);

    for (int tick = 0; tick < 18; tick++) {
      final double angle = (math.pi * 2 / 18) * tick;
      final Offset p1 = center + Offset(math.cos(angle), math.sin(angle)) * 118;
      final Offset p2 = center + Offset(math.cos(angle), math.sin(angle)) * 126;
      canvas.drawLine(p1, p2, dashed);
    }
  }

  @override
  bool shouldRepaint(covariant _HaloPainter oldDelegate) {
    return oldDelegate.accent != accent ||
        oldDelegate.isRecording != isRecording ||
        oldDelegate.isAnalyzing != isAnalyzing;
  }
}
