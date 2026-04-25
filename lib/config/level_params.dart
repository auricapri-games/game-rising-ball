import 'package:auricapri_engine/auricapri_engine.dart';
import 'package:meta/meta.dart';

/// Per-phase parameters for Rising Ball.
///
/// Holds layout + physics constants. Centralising here keeps lib/core/
/// free of magic numbers (game_params_in_config_only) and makes balancing
/// a single-file change.
@immutable
class RisingBallParams extends LevelParams {
  const RisingBallParams({
    required super.phase,
    required super.seed,
    required this.worldWidth,
    required this.worldHeight,
    required this.gravity,
    required this.jumpVelocity,
    required this.horizontalSpeed,
    required this.platformWidth,
    required this.platformHeight,
    required this.ballRadius,
    required this.platformVerticalGap,
    required this.platformVerticalJitter,
    required this.numPlatforms,
    required this.spikePctOutOf100,
    required this.targetHeight,
    required this.scorePerUnit,
  });

  /// Default tunables — single source of truth for physics + layout.
  static const double kBaseWorldWidth = 360;
  static const double kBaseWorldHeight = 640;
  static const double kBaseGravity = 1300;
  static const double kBaseJumpVelocity = 720;
  static const double kBaseHorizontalSpeed = 320;
  static const double kBasePlatformWidth = 88;
  static const double kBasePlatformHeight = 16;
  static const double kBaseBallRadius = 18;
  static const double kBasePlatformVerticalGap = 110;
  static const double kBasePlatformJitter = 22;
  static const int kBaseNumPlatforms = 18;
  static const int kBasePhaseTarget = 600;
  static const int kBaseScorePerUnit = 1;
  static const int kBaseSpikeChance = 8;
  static const int kSpikeRollMax = 100;
  static const int kSeedMultiplier = 31;
  static const int kSeedOffset = 7;
  static const int kSpikeStep = 2;
  static const int kSpikeCap = 38;
  static const int kPlatformShrinkPerPhase = 4;
  static const double kPlatformMinWidth = 56;
  static const int kNumPlatformsStep = 4;
  static const int kTargetHeightStep = 200;

  /// Per-phase tuning ramps — change difficulty by editing this factory.
  factory RisingBallParams.fromPhase(int phase) {
    final clamped = phase < 1 ? 1 : phase;
    final hardness = clamped - 1;
    final spike = kBaseSpikeChance + hardness * kSpikeStep;
    final clampedSpike = spike > kSpikeCap ? kSpikeCap : spike;
    final platformWidthShrink = hardness * kPlatformShrinkPerPhase;
    final shrunk = kBasePlatformWidth - platformWidthShrink;
    final pw = shrunk < kPlatformMinWidth ? kPlatformMinWidth : shrunk;
    return RisingBallParams(
      phase: clamped,
      seed: clamped * kSeedMultiplier + kSeedOffset,
      worldWidth: kBaseWorldWidth,
      worldHeight: kBaseWorldHeight,
      gravity: kBaseGravity,
      jumpVelocity: kBaseJumpVelocity,
      horizontalSpeed: kBaseHorizontalSpeed,
      platformWidth: pw,
      platformHeight: kBasePlatformHeight,
      ballRadius: kBaseBallRadius,
      platformVerticalGap: kBasePlatformVerticalGap,
      platformVerticalJitter: kBasePlatformJitter,
      numPlatforms: kBaseNumPlatforms + hardness * kNumPlatformsStep,
      spikePctOutOf100: clampedSpike,
      targetHeight: kBasePhaseTarget + hardness * kTargetHeightStep,
      scorePerUnit: kBaseScorePerUnit,
    );
  }

  final double worldWidth;
  final double worldHeight;
  final double gravity;
  final double jumpVelocity;
  final double horizontalSpeed;
  final double platformWidth;
  final double platformHeight;
  final double ballRadius;
  final double platformVerticalGap;
  final double platformVerticalJitter;
  final int numPlatforms;
  final int spikePctOutOf100;
  final int targetHeight;
  final int scorePerUnit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RisingBallParams &&
          phase == other.phase &&
          seed == other.seed &&
          numPlatforms == other.numPlatforms &&
          spikePctOutOf100 == other.spikePctOutOf100 &&
          targetHeight == other.targetHeight;

  @override
  int get hashCode => Object.hash(
        phase,
        seed,
        numPlatforms,
        spikePctOutOf100,
        targetHeight,
      );
}
