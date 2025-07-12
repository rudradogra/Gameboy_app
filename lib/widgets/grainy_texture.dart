import 'package:flutter/material.dart';
import 'dart:math' as math;

class GrainyTexturePainter extends CustomPainter {
  final Color baseColor;
  final double intensity;
  final int seed;

  GrainyTexturePainter({
    required this.baseColor,
    this.intensity = 0.5,
    this.seed = 42,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final paint = Paint();

    // Draw base color
    paint.color = baseColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Add grainy texture
    final grainSize = 3.0;
    for (double x = 0; x < size.width; x += grainSize) {
      for (double y = 0; y < size.height; y += grainSize) {
        final noise = (random.nextDouble() - 0.5) * 2 * intensity;
        final grainColor = Color.fromRGBO(
          (baseColor.red + (noise * 255)).clamp(0, 255).round(),
          (baseColor.green + (noise * 255)).clamp(0, 255).round(),
          (baseColor.blue + (noise * 255)).clamp(0, 255).round(),
          baseColor.opacity,
        );

        paint.color = grainColor;
        canvas.drawRect(Rect.fromLTWH(x, y, grainSize, grainSize), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GrainyContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final BorderRadius? borderRadius;
  final double intensity;
  final int seed;
  final List<BoxShadow>? boxShadow;

  const GrainyContainer({
    Key? key,
    required this.child,
    required this.color,
    this.borderRadius,
    this.intensity = 0.15,
    this.seed = 42,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Stack(
          children: [
            // Base color layer
            Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: borderRadius,
              ),
              child: child,
            ),
            // Grainy texture overlay
            Positioned.fill(
              child: CustomPaint(
                painter: GrainyTexturePainter(
                  baseColor: Colors.transparent,
                  intensity: intensity,
                  seed: seed,
                ),
                child: Container(),
              ),
            ),
            // Child content on top
            child,
          ],
        ),
      ),
    );
  }
}

class GrainyButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color color;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final double intensity;
  final int seed;

  const GrainyButton({
    Key? key,
    required this.child,
    this.onPressed,
    required this.color,
    this.borderRadius,
    this.padding,
    this.intensity = 0.2,
    this.seed = 42,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: GrainyContainer(
        color: color,
        borderRadius: borderRadius,
        intensity: intensity,
        seed: seed,
        boxShadow: [
          BoxShadow(color: Colors.black45, blurRadius: 3, offset: Offset(1, 1)),
          BoxShadow(
            color: Colors.white24,
            blurRadius: 1,
            offset: Offset(-0.5, -0.5),
          ),
        ],
        child: Container(padding: padding, child: child),
      ),
    );
  }
}
