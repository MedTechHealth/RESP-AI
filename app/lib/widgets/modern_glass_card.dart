import 'dart:ui';
import 'package:flutter/material.dart';

class ModernGlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsets padding;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final Color? color;

  const ModernGlassCard({
    super.key,
    required this.child,
    this.blur = 30,
    this.opacity = 0.6,
    this.borderRadius = 32,
    this.padding = const EdgeInsets.all(32),
    this.border,
    this.boxShadow,
    this.gradient,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 40,
                offset: const Offset(0, 10),
                spreadRadius: -5,
              ),
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFF4F46E5))
                    .withOpacity(isDark ? 0.3 : 0.02),
                blurRadius: 20,
                offset: const Offset(0, 20),
                spreadRadius: -10,
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color:
                  color ??
                  (isDark ? Colors.black : Colors.white).withOpacity(opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border:
                  border ??
                  Border.all(
                    color: (isDark ? Colors.white : const Color(0xFF4F46E5))
                        .withOpacity(isDark ? 0.1 : 0.05),
                    width: 1.5,
                  ),
              gradient:
                  gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (isDark ? Colors.white : Colors.white).withOpacity(0.1),
                      (isDark ? Colors.white : Colors.white).withOpacity(0.02),
                    ],
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
