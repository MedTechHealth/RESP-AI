import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final LinearGradient? gradient;
  final Color? borderColor;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.spaceMd),
    this.borderRadius = 24.0,
    this.gradient,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine background color
    Color containerColor;
    if (gradient == null) {
      containerColor = isDark
          ? AppTheme.surfaceDark.withAlpha((0.4 * 255).round())
          : AppTheme.surfaceLight.withAlpha((0.7 * 255).round());
    } else {
      // If gradient is provided, the color property of BoxDecoration should not be set
      // as it will be overridden by the gradient. This is handled by not setting
      // containerColor if gradient is present.
      containerColor = Colors.transparent; // Transparent if gradient is used
    }

    // Determine border color
    Color finalBorderColor =
        borderColor ??
        (isDark
            ? Colors.white.withAlpha((0.08 * 255).round())
            : AppTheme.lungBlue.withAlpha((0.05 * 255).round()));

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: gradient == null
                ? containerColor
                : null, // Set color only if no gradient
            gradient: gradient, // Apply gradient if provided
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: finalBorderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 24,
                spreadRadius: -8,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
