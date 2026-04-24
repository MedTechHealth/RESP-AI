import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_theme.dart';
// Removed ReactiveLiquidRipple and HolographicLung imports as per plan

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
        ? AppTheme.alertCoral
        : AppTheme.vaprupTeal;
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
            // Removed ReactiveLiquidRipple usage as per plan
            // Removed HolographicLung usage as per plan

            // Morphing Background
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutQuart,
              width: isRecording ? 200 : 180,
              height: isRecording ? 200 : 180,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withAlpha(
                  (0.1 * 255).round(),
                ), // AppTheme.glass
                borderRadius: BorderRadius.circular(isRecording ? 48 : 100),
                border: Border.all(
                  color: accent.withAlpha((0.25 * 255).round()),
                  width: 1,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: accent.withAlpha((0.12 * 255).round()),
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
                        ? AppTheme.vaprupMint.withAlpha(
                            (0.8 * 255).round(),
                          ) // AppTheme.frostDeep
                        : AppTheme.vaprupBlue.withAlpha(
                            (0.1 * 255).round(),
                          ), // AppTheme.vicksBlue
                    borderRadius: BorderRadius.circular(isRecording ? 40 : 80),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                            icon,
                            size: 32,
                            color: isAnalyzing
                                ? AppTheme.vaprupBlue.withAlpha(
                                    (0.5 * 255).round(),
                                  ) // AppTheme.vicksBlue
                                : AppTheme.vaprupBlue, // AppTheme.vicksBlue
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
                              ? AppTheme.vaprupBlue.withAlpha(
                                  (0.5 * 255).round(),
                                ) // AppTheme.vicksBlue
                              : AppTheme.vaprupBlue, // AppTheme.vicksBlue
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
                              ? AppTheme.vaprupBlue.withAlpha(
                                  (0.5 * 255).round(),
                                ) // AppTheme.vicksBlue
                              : AppTheme.vaprupBlue, // AppTheme.vicksBlue
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
