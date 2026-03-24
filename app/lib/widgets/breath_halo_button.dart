import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'reactive_liquid_ripple.dart';

class BreathHaloButton extends StatelessWidget {
  const BreathHaloButton({
    super.key,
    required this.isRecording,
    required this.isAnalyzing,
    required this.durationLabel,
    required this.onPressed,
    this.amplitude = 1.0,
  });

  final bool isRecording;
  final bool isAnalyzing;
  final String durationLabel;
  final VoidCallback? onPressed;
  final double amplitude;

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
              child: ReactiveLiquidRipple(
                size: 260,
                color: accent,
                amplitude: isRecording ? amplitude : 0.2,
                isAnimating: isRecording || isAnalyzing,
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
