import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_theme.dart';
import 'reactive_liquid_ripple.dart';
import 'holographic_lung.dart';

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
    final Color accent = isRecording ? AppTheme.oxide : AppTheme.mentholCyan;
    final String label = isAnalyzing
        ? 'ANALYZING'
        : isRecording
        ? 'STOP CAPTURE'
        : 'START CAPTURE';
    final IconData icon = isAnalyzing
        ? LucideIcons.loader2
        : isRecording
        ? LucideIcons.square
        : LucideIcons.mic;

    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            IgnorePointer(
              child: RepaintBoundary(
                child: ReactiveLiquidRipple(
                  size: 300,
                  color: accent,
                  amplitude: isRecording ? amplitude : 0.15,
                  isAnimating: isRecording || isAnalyzing,
                ),
              ),
            ),
            // Holographic Lung Viz
            IgnorePointer(
              child: HolographicLung(
                isRecording: isRecording,
                size: 240,
                confidence: 1.0, // Default for home screen
              ),
            ),
            // Morphing Background
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutQuart,
              width: isRecording ? 200 : 180,
              height: isRecording ? 200 : 180,
              decoration: BoxDecoration(
                color: AppTheme.glass.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(isRecording ? 48 : 100),
                border: Border.all(
                  color: accent.withValues(alpha: 0.25),
                  width: 1,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: accent.withValues(alpha: 0.12),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
            ),
            // Morphing Primary Button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isAnalyzing ? null : onPressed,
                borderRadius: BorderRadius.circular(isRecording ? 48 : 100),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutQuart,
                  width: isRecording ? 160 : 160,
                  height: isRecording ? 160 : 160,
                  decoration: BoxDecoration(
                    color: isAnalyzing
                        ? AppTheme.frostDeep.withValues(alpha: 0.8)
                        : AppTheme.vicksBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(isRecording ? 40 : 80),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                            icon,
                            size: 32,
                            color: isAnalyzing
                                ? AppTheme.vicksBlue.withValues(alpha: 0.5)
                                : AppTheme.vicksBlue,
                          )
                          .animate(
                            onPlay: (controller) {
                              if (isAnalyzing) {
                                controller.repeat();
                              }
                            },
                          )
                          .rotate(duration: 1.seconds),
                      const SizedBox(height: 12),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isAnalyzing
                              ? AppTheme.vicksBlue.withValues(alpha: 0.5)
                              : AppTheme.vicksBlue,
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        durationLabel,
                        style: GoogleFonts.dmSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: isAnalyzing
                              ? AppTheme.vicksBlue.withValues(alpha: 0.5)
                              : AppTheme.vicksBlue,
                          fontFeatures: AppTheme.tabularFigures,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
