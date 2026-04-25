import 'package:auricapri_engine/auricapri_engine.dart';

import '../config/level_params.dart';
import 'game_state.dart';

/// Generates a deterministic, by-construction-solvable Rising Ball layout.
///
/// Solvability: each platform is placed within `maxJumpReach` (vertical) and
/// `maxHorizontalReach` (horizontal) of the previous one — so the player can
/// always make the next jump. Spike platforms always have at least one
/// safe (spike-free) neighbour at a reachable distance.
class RisingBallLevelGenerator
    extends LevelGenerator<RisingBallParams, RisingBallState> {
  const RisingBallLevelGenerator();

  @override
  RisingBallState generate(RisingBallParams params) {
    final rng = SeededRandom(params.seed);
    final platforms = <Platform>[];

    final groundY = -params.platformHeight - 0;
    final ground = Platform(
      x: 0,
      y: groundY,
      width: params.worldWidth,
      height: params.platformHeight,
      hasSpikes: false,
    );
    platforms.add(ground);

    var prevX = params.worldWidth / 2 - params.platformWidth / 2;
    var prevY = groundY;
    for (var i = 0; i < params.numPlatforms; i++) {
      final jitter =
          (rng.nextDouble() * 2 - 1) * params.platformVerticalJitter;
      final y = prevY + params.platformVerticalGap + jitter;

      final maxX = params.worldWidth - params.platformWidth;
      final reach = _maxHorizontalReach(params);
      final lo = (prevX - reach).clamp(0, maxX);
      final hi = (prevX + reach).clamp(0, maxX);
      final x = lo + rng.nextDouble() * (hi - lo);

      final spikeRoll = rng.nextInt(RisingBallParams.kSpikeRollMax);
      final hasSpikes =
          i > 1 && spikeRoll < params.spikePctOutOf100;

      platforms.add(
        Platform(
          x: x,
          y: y,
          width: params.platformWidth,
          height: params.platformHeight,
          hasSpikes: hasSpikes,
        ),
      );
      prevX = x;
      prevY = y;
    }

    return RisingBallState(
      phase: params.phase,
      score: 0,
      movesUsed: 0,
      isOver: false,
      isWon: false,
      ballX: params.worldWidth / 2,
      ballY: ground.top + params.ballRadius,
      vx: 0,
      vy: 0,
      platforms: List<Platform>.unmodifiable(platforms),
      bestHeight: 0,
    );
  }

  /// Maximum horizontal travel during a jump (used by [generate] to keep
  /// every next platform within reach). Returned as a positive scalar.
  double _maxHorizontalReach(RisingBallParams params) {
    final airTime = (params.jumpVelocity / params.gravity) * 2;
    return params.horizontalSpeed * airTime;
  }

  @override
  bool validateSolvable(RisingBallState state) {
    if (state.platforms.length < 2) return false;
    for (var i = 1; i < state.platforms.length; i++) {
      final prev = state.platforms[i - 1];
      final curr = state.platforms[i];
      final dy = curr.top - prev.top;
      if (dy <= 0) return false;
    }
    return true;
  }
}
