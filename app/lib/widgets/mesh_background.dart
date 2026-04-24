import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // For potential future subtle animation additions

import '../theme/app_theme.dart';

class MeshBackground extends StatefulWidget {
  final Widget child;

  const MeshBackground({super.key, required this.child});

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
      duration: const Duration(seconds: 20), // Slower, more subtle animation
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine the base background color from the current theme
    final Color baseBackgroundColor = Theme.of(
      context,
    ).colorScheme.background; // Should be vaprupMint in Vaprup theme

    final Size size = MediaQuery.sizeOf(context); // Define size here

    return Stack(
      children: <Widget>[
        // Base background color
        Container(color: baseBackgroundColor),

        // Subtle Animated Gradient Blobs (mimicking gentle breath)
        AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            final double scale =
                1.0 + (_controller.value * 0.05); // Very subtle scale
            final double opacity1 = (0.2 + _controller.value * 0.1).clamp(
              0.2,
              0.3,
            ); // Gentle opacity pulse
            final double opacity2 = (0.1 + (1 - _controller.value) * 0.1).clamp(
              0.1,
              0.2,
            );

            return Stack(
              children: <Widget>[
                Positioned(
                  top: -size.height * 0.1,
                  left: -size.width * 0.15,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: size.width * 0.6,
                      height: size.width * 0.6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: <Color>[
                            AppTheme.vaprupTeal.withAlpha(
                              (opacity1 * 255).round(),
                            ),
                            baseBackgroundColor.withAlpha(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -size.height * 0.15,
                  right: -size.width * 0.2,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: size.width * 0.7,
                      height: size.width * 0.7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: <Color>[
                            AppTheme.vaprupBlue.withAlpha(
                              (opacity2 * 255).round(),
                            ),
                            baseBackgroundColor.withAlpha(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // Optional: Very subtle grid or pattern overlay (low opacity)
        // Opacity(
        //   opacity: 0.01, // Extremely low opacity for barely perceptible effect
        //   child: CustomPaint(
        //     painter: _GridPainter(color: Theme.of(context).colorScheme.onBackground),
        //     child: Container(),
        //   ),
        // ),

        // Child content over everything
        widget.child,
      ],
    );
  }
}

// Optional: If a grid painter is needed, simplify it or remove if not minimalist enough
// class _GridPainter extends CustomPainter {
//   final Color color;

//   _GridPainter({required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..color = color
//       ..strokeWidth = 0.5 // Thinner lines
//       ..style = PaintingStyle.stroke;

//     const double spacing = 60.0; // Larger spacing for subtlety

//     for (double i = 0; i < size.width; i += spacing) {
//       canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
//     }

//     for (double i = 0; i < size.height; i += spacing) {
//       canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
