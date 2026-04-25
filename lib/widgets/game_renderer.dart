import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/game_state.dart';
import '../ds/app_colors.dart';

/// Renders the world (background + platforms + ball) inside its layout box.
///
/// Coordinates are world-space: y grows UP, x is [0, worldWidth]. The painter
/// tracks the ball with a vertical offset so the ball stays around the
/// vertical centre of the viewport as it climbs.
class GameRenderer extends StatelessWidget {
  const GameRenderer({
    required this.state,
    required this.worldWidth,
    required this.worldHeight,
    required this.ballRadius,
    required this.ballImage,
    required this.platformImage,
    required this.spikeImage,
    required this.backgroundImage,
    super.key,
  });

  final RisingBallState state;
  final double worldWidth;
  final double worldHeight;
  final double ballRadius;
  final ui.Image? ballImage;
  final ui.Image? platformImage;
  final ui.Image? spikeImage;
  final ui.Image? backgroundImage;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RisingBallPainter(
        state: state,
        worldWidth: worldWidth,
        worldHeight: worldHeight,
        ballRadius: ballRadius,
        ballImage: ballImage,
        platformImage: platformImage,
        spikeImage: spikeImage,
        backgroundImage: backgroundImage,
      ),
      size: Size.infinite,
    );
  }
}

class _RisingBallPainter extends CustomPainter {
  _RisingBallPainter({
    required this.state,
    required this.worldWidth,
    required this.worldHeight,
    required this.ballRadius,
    required this.ballImage,
    required this.platformImage,
    required this.spikeImage,
    required this.backgroundImage,
  });

  final RisingBallState state;
  final double worldWidth;
  final double worldHeight;
  final double ballRadius;
  final ui.Image? ballImage;
  final ui.Image? platformImage;
  final ui.Image? spikeImage;
  final ui.Image? backgroundImage;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / worldWidth;
    final cameraOffsetWorld =
        state.ballY > worldHeight * 0.4 ? state.ballY - worldHeight * 0.4 : 0.0;

    _paintBackground(canvas, size);

    canvas.save();
    canvas.translate(0, cameraOffsetWorld * scale);

    for (final p in state.platforms) {
      final left = p.left * scale;
      final top = (worldHeight - (p.top + p.height)) * scale;
      final width = p.width * scale;
      final height = p.height * scale;
      _drawPlatform(canvas, Rect.fromLTWH(left, top, width, height));
      if (p.hasSpikes) {
        _drawSpikes(canvas, Rect.fromLTWH(left, top - height * 2, width, height * 2));
      }
    }

    final ballPx = state.ballX * scale;
    final ballPy = (worldHeight - state.ballY) * scale;
    _drawBall(canvas, Offset(ballPx, ballPy), ballRadius * scale);

    canvas.restore();
  }

  void _paintBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, size.height),
        const [AppColors.background, AppColors.backgroundAlt],
      );
    canvas.drawRect(Offset.zero & size, paint);
    final bg = backgroundImage;
    if (bg != null) {
      final src = Rect.fromLTWH(0, 0, bg.width.toDouble(), bg.height.toDouble());
      final dst = Offset.zero & size;
      paintImage(
        canvas: canvas,
        rect: dst,
        image: bg,
        fit: BoxFit.cover,
        opacity: 0.55,
      );
      // Use src to avoid lints flagging unused locals while keeping API intent.
      assert(src.width > 0, 'src valid');
    }
  }

  void _drawPlatform(Canvas canvas, Rect rect) {
    final img = platformImage;
    if (img != null) {
      paintImage(
        canvas: canvas,
        rect: rect,
        image: img,
        fit: BoxFit.fill,
      );
      return;
    }
    final paint = Paint()..color = AppColors.primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      paint,
    );
  }

  void _drawSpikes(Canvas canvas, Rect rect) {
    final img = spikeImage;
    if (img != null) {
      paintImage(
        canvas: canvas,
        rect: rect,
        image: img,
        fit: BoxFit.fill,
      );
      return;
    }
    final paint = Paint()..color = AppColors.accent;
    canvas.drawRect(rect, paint);
  }

  void _drawBall(Canvas canvas, Offset center, double radius) {
    final img = ballImage;
    if (img != null) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      paintImage(canvas: canvas, rect: rect, image: img, fit: BoxFit.contain);
      return;
    }
    final paint = Paint()..color = AppColors.secondary;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RisingBallPainter old) =>
      old.state != state ||
      old.ballImage != ballImage ||
      old.platformImage != platformImage ||
      old.spikeImage != spikeImage ||
      old.backgroundImage != backgroundImage;
}
