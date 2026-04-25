import 'package:auricapri_engine/auricapri_engine.dart';

import '../config/level_params.dart';
import 'game_state.dart';

/// Pure-function rules for Rising Ball physics.
///
/// `applyMove` advances the simulation by `move.dt` seconds, applies the
/// player's horizontal input, resolves collisions with platforms and the
/// world bounds, and returns a fresh state. NEVER mutates the input.
class RisingBallRules
    extends GameRules<RisingBallParams, RisingBallState, RisingBallMove> {
  const RisingBallRules(this.params);

  final RisingBallParams params;

  @override
  bool isLegal(RisingBallState state, RisingBallMove move) =>
      !state.isOver && move.dt >= 0;

  @override
  RisingBallState applyMove(RisingBallState state, RisingBallMove move) {
    if (!isLegal(state, move)) return state;

    var ballX = state.ballX;
    var ballY = state.ballY;
    var vx = state.horizontalSpeedFor(move.horizontal, params);
    var vy = state.vy;

    final dt = move.dt;
    vy = vy - params.gravity * dt;
    ballX = ballX + vx * dt;
    ballY = ballY + vy * dt;

    final minX = params.ballRadius;
    final maxX = params.worldWidth - params.ballRadius;
    if (ballX < minX) {
      ballX = minX;
    }
    if (ballX > maxX) {
      ballX = maxX;
    }

    var newPlatforms = state.platforms;
    var isOver = state.isOver;
    var isWon = state.isWon;
    var score = state.score;
    final movesUsed = state.movesUsed + 1;

    if (vy <= 0) {
      final landed = _landingPlatform(
        ballX: ballX,
        prevY: state.ballY,
        nextY: ballY,
        radius: params.ballRadius,
        platforms: state.platforms,
      );
      if (landed != null) {
        if (landed.hasSpikes) {
          isOver = true;
          isWon = false;
        } else {
          ballY = landed.top + params.ballRadius;
          vy = params.jumpVelocity;
        }
      }
    }

    var bestHeight = state.bestHeight;
    if (ballY > bestHeight) {
      bestHeight = ballY;
      score = (bestHeight * params.scorePerUnit).round();
    }

    if (bestHeight >= params.targetHeight && !isOver) {
      isOver = true;
      isWon = true;
    }

    final firstPlatformTop = state.platforms.first.top;
    final fallLimit = firstPlatformTop - params.worldHeight;
    if (ballY < fallLimit && !isOver) {
      isOver = true;
      isWon = false;
    }

    return state.copyWith(
      ballX: ballX,
      ballY: ballY,
      vx: vx,
      vy: vy,
      platforms: newPlatforms,
      score: score,
      bestHeight: bestHeight,
      isOver: isOver,
      isWon: isWon,
      movesUsed: movesUsed,
    );
  }

  Platform? _landingPlatform({
    required double ballX,
    required double prevY,
    required double nextY,
    required double radius,
    required List<Platform> platforms,
  }) {
    Platform? best;
    for (final p in platforms) {
      final ballHorizOnTop = ballX + radius >= p.left && ballX - radius <= p.right;
      if (!ballHorizOnTop) continue;
      final wasAbove = prevY - radius >= p.top;
      final nowOnOrBelow = nextY - radius <= p.top;
      if (wasAbove && nowOnOrBelow) {
        if (best == null || p.top > best.top) {
          best = p;
        }
      }
    }
    return best;
  }
}

/// Helper extension keeping the per-frame velocity logic out of [applyMove].
extension on RisingBallState {
  double horizontalSpeedFor(int input, RisingBallParams params) {
    if (input == 0) return 0;
    return params.horizontalSpeed * input;
  }
}
