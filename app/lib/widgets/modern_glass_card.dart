import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ModernGlassCard extends StatelessWidget {
  const ModernGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(28),
    this.borderRadius = 24,
    this.tint,
    this.borderColor,
    this.blur = 30.0,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? tint;
  final Color? borderColor;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: (tint ?? Theme.of(context).colorScheme.surface).withAlpha(
              (0.3 * 255).round(),
            ), // Use Theme surface color
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color:
                  borderColor ??
                  Theme.of(context).colorScheme.outline.withAlpha(
                    (0.5 * 255).round(),
                  ), // Use Theme outline color
              width: 0.5,
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
