import 'dart:math';
import 'package:flutter/material.dart';

/// A widget that displays a human body silhouette with water-filling animation
/// Water fills from bottom to top with a smooth sine wave effect
class WaterBodyTracker extends StatefulWidget {
  /// Water level from 0.0 (empty) to 1.0 (full)
  final double waterLevel;

  /// Width of the widget
  final double width;

  /// Height of the widget
  final double height;

  /// Color of the body silhouette
  final Color bodyColor;

  /// Primary water color (top of gradient)
  final Color waterColorStart;

  /// Secondary water color (bottom of gradient)
  final Color waterColorEnd;

  const WaterBodyTracker({
    super.key,
    required this.waterLevel,
    this.width = 200,
    this.height = 400,
    this.bodyColor = Colors.grey,
    this.waterColorStart = const Color(0xFF2196F3),
    this.waterColorEnd = const Color(0xFF64B5F6),
  });

  @override
  State<WaterBodyTracker> createState() => _WaterBodyTrackerState();
}

class _WaterBodyTrackerState extends State<WaterBodyTracker>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: RepaintBoundary(
        child: Stack(
          children: [
            // Water layer (behind the body)
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.width, widget.height),
                  painter: WaterWavePainter(
                    waterLevel: widget.waterLevel,
                    wavePhase: _waveController.value,
                    colorStart: widget.waterColorStart,
                    colorEnd: widget.waterColorEnd,
                  ),
                );
              },
            ),
            // Body silhouette layer (with transparency to see water)
            CustomPaint(
              size: Size(widget.width, widget.height),
              painter: BodySilhouettePainter(bodyColor: widget.bodyColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the human body silhouette
class BodySilhouettePainter extends CustomPainter {
  final Color bodyColor;

  BodySilhouettePainter({required this.bodyColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createBodyPath(size);

    // Shadow for 3D effect (claymorphism)
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);

    canvas.save();
    canvas.translate(2, 3);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Matte fill with soft color
    final fillPaint = Paint()
      ..color = bodyColor.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    // Subtle outline
    final outlinePaint = Paint()
      ..color = bodyColor.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw filled body silhouette
    canvas.drawPath(path, fillPaint);

    // Draw body outline
    canvas.drawPath(path, outlinePaint);

    // Add highlight for 3D depth
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.save();
    canvas.translate(-0.5, -0.5);
    canvas.drawPath(path, highlightPaint);
    canvas.restore();
  }

  Path _createBodyPath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Head - smooth circle
    final headRadius = w * 0.125;
    final headCenter = Offset(w / 2, h * 0.095);
    path.addOval(Rect.fromCircle(center: headCenter, radius: headRadius));

    // Body with rounded edges - claymorphism style
    final shoulderY = h * 0.19;
    final torsoWidth = w * 0.26;
    final torsoBottom = h * 0.54;
    final legWidth = w * 0.11;
    final legGap = w * 0.025;
    final cornerRadius = w * 0.06;

    // Torso with rounded corners
    final torsoRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        w / 2 - torsoWidth,
        shoulderY,
        torsoWidth * 2,
        torsoBottom - shoulderY,
      ),
      Radius.circular(cornerRadius),
    );
    path.addRRect(torsoRect);

    // Left leg with rounded corners
    final leftLegRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        w / 2 - legGap - legWidth,
        torsoBottom,
        legWidth,
        h * 0.96 - torsoBottom,
      ),
      Radius.circular(cornerRadius * 0.8),
    );
    path.addRRect(leftLegRect);

    // Right leg with rounded corners
    final rightLegRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        w / 2 + legGap,
        torsoBottom,
        legWidth,
        h * 0.96 - torsoBottom,
      ),
      Radius.circular(cornerRadius * 0.8),
    );
    path.addRRect(rightLegRect);

    // Left arm with hand - rounded
    final armWidth = w * 0.09;
    final armStartY = shoulderY + h * 0.03;
    final armEndY = h * 0.48;
    final handRadius = w * 0.055;

    final leftArmRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        w / 2 - torsoWidth - armWidth - w * 0.04,
        armStartY,
        armWidth,
        armEndY - armStartY,
      ),
      Radius.circular(cornerRadius * 0.9),
    );
    path.addRRect(leftArmRect);

    // Left hand - circle
    path.addOval(
      Rect.fromCircle(
        center: Offset(
          w / 2 - torsoWidth - armWidth / 2 - w * 0.04,
          armEndY + handRadius * 0.7,
        ),
        radius: handRadius,
      ),
    );

    // Right arm with hand - rounded
    final rightArmRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        w / 2 + torsoWidth + w * 0.04,
        armStartY,
        armWidth,
        armEndY - armStartY,
      ),
      Radius.circular(cornerRadius * 0.9),
    );
    path.addRRect(rightArmRect);

    // Right hand - circle
    path.addOval(
      Rect.fromCircle(
        center: Offset(
          w / 2 + torsoWidth + armWidth / 2 + w * 0.04,
          armEndY + handRadius * 0.7,
        ),
        radius: handRadius,
      ),
    );

    return path;
  }

  @override
  bool shouldRepaint(BodySilhouettePainter oldDelegate) {
    return oldDelegate.bodyColor != bodyColor;
  }
}

/// Custom painter for the water wave animation
class WaterWavePainter extends CustomPainter {
  final double waterLevel; // 0.0 to 1.0
  final double wavePhase; // Animation phase 0.0 to 1.0
  final Color colorStart;
  final Color colorEnd;

  WaterWavePainter({
    required this.waterLevel,
    required this.wavePhase,
    required this.colorStart,
    required this.colorEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waterLevel <= 0) return;

    final w = size.width;
    final h = size.height;

    // Water level position (inverted because y increases downward)
    final waterY = h * (1 - waterLevel);

    // Create gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [colorStart, colorEnd],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, waterY, w, h - waterY))
      ..style = PaintingStyle.fill;

    final path = Path();

    // Wave parameters
    final waveAmplitude = w * 0.03; // Height of the wave
    final waveFrequency = 2.0; // Number of waves across width
    final phaseShift = wavePhase * 2 * pi; // Animate the wave

    // Start from bottom left
    path.moveTo(0, h);
    path.lineTo(0, waterY);

    // Draw sine wave at water surface
    for (double x = 0; x <= w; x += 1) {
      final normalizedX = x / w;
      final y =
          waterY +
          waveAmplitude *
              sin(2 * pi * waveFrequency * normalizedX + phaseShift);

      if (x == 0) {
        path.lineTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Complete the path
    path.lineTo(w, h);
    path.close();

    // Clip to body shape for more realistic effect
    canvas.save();
    canvas.clipPath(_createBodyClipPath(size));
    canvas.drawPath(path, paint);
    canvas.restore();

    // Add shine effect
    _drawShineEffect(canvas, size, waterY);
  }

  void _drawShineEffect(Canvas canvas, Size size, double waterY) {
    if (waterLevel <= 0) return;

    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final shinePath = Path();
    final w = size.width;
    final shineAmplitude = w * 0.02;
    final phaseShift = wavePhase * 2 * pi;

    // Draw a subtle shine wave slightly above the main wave
    shinePath.moveTo(0, waterY - 3);
    for (double x = 0; x <= w; x += 2) {
      final normalizedX = x / w;
      final y =
          waterY -
          3 +
          shineAmplitude * sin(2 * pi * 2.5 * normalizedX + phaseShift);
      shinePath.lineTo(x, y);
    }
    shinePath.lineTo(w, waterY + 5);
    shinePath.lineTo(0, waterY + 5);
    shinePath.close();

    canvas.save();
    canvas.clipPath(_createBodyClipPath(size));
    canvas.drawPath(shinePath, shinePaint);
    canvas.restore();
  }

  Path _createBodyClipPath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Rounded body clip path - claymorphism style (torso and legs only)
    final shoulderY = h * 0.19;
    final torsoWidth = w * 0.26;
    final torsoBottom = h * 0.54;
    final legWidth = w * 0.11;
    final legGap = w * 0.025;
    final cornerRadius = w * 0.06;

    // Torso with rounded corners
    final torsoRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        w / 2 - torsoWidth,
        shoulderY,
        torsoWidth * 2,
        torsoBottom - shoulderY,
      ),
      Radius.circular(cornerRadius),
    );
    path.addRRect(torsoRect);

    // Left leg with rounded corners
    final leftLegRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        w / 2 - legGap - legWidth,
        torsoBottom,
        legWidth,
        h * 0.96 - torsoBottom,
      ),
      Radius.circular(cornerRadius * 0.8),
    );
    path.addRRect(leftLegRect);

    // Right leg with rounded corners
    final rightLegRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        w / 2 + legGap,
        torsoBottom,
        legWidth,
        h * 0.96 - torsoBottom,
      ),
      Radius.circular(cornerRadius * 0.8),
    );
    path.addRRect(rightLegRect);

    return path;
  }

  @override
  bool shouldRepaint(WaterWavePainter oldDelegate) {
    return oldDelegate.waterLevel != waterLevel ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.colorStart != colorStart ||
        oldDelegate.colorEnd != colorEnd;
  }
}
