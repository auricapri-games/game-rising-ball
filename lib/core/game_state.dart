import 'package:auricapri_engine/auricapri_engine.dart';
import 'package:meta/meta.dart';

/// World-space platform: horizontal segment the ball can land on top of.
@immutable
class Platform {
  const Platform({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.hasSpikes,
  });

  final double x;
  final double y;
  final double width;
  final double height;
  final bool hasSpikes;

  double get left => x;
  double get right => x + width;
  double get top => y;
  double get bottom => y + height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Platform &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height &&
          hasSpikes == other.hasSpikes;

  @override
  int get hashCode => Object.hash(x, y, width, height, hasSpikes);
}

/// Input emitted each frame: horizontal direction (-1 left, 0 idle, 1 right)
/// and the timestep (`dt`) in seconds.
@immutable
class RisingBallMove {
  const RisingBallMove({required this.horizontal, required this.dt});
  final int horizontal;
  final double dt;
}

/// Immutable snapshot of a Rising Ball game frame.
///
/// `ballY` uses world coordinates where positive Y points UP. Score is
/// derived from the ball's peak Y; phase clears when `bestHeight >= targetHeight`.
@immutable
class RisingBallState extends GameState {
  const RisingBallState({
    required super.phase,
    required super.score,
    required super.movesUsed,
    required super.isOver,
    required super.isWon,
    required this.ballX,
    required this.ballY,
    required this.vx,
    required this.vy,
    required this.platforms,
    required this.bestHeight,
  });

  final double ballX;
  final double ballY;
  final double vx;
  final double vy;
  final List<Platform> platforms;
  final double bestHeight;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RisingBallState &&
          phase == other.phase &&
          score == other.score &&
          movesUsed == other.movesUsed &&
          isOver == other.isOver &&
          isWon == other.isWon &&
          ballX == other.ballX &&
          ballY == other.ballY &&
          vx == other.vx &&
          vy == other.vy &&
          bestHeight == other.bestHeight;

  @override
  int get hashCode => Object.hash(
        phase,
        score,
        movesUsed,
        isOver,
        isWon,
        ballX,
        ballY,
        vx,
        vy,
        bestHeight,
      );

  RisingBallState copyWith({
    int? phase,
    int? score,
    int? movesUsed,
    bool? isOver,
    bool? isWon,
    double? ballX,
    double? ballY,
    double? vx,
    double? vy,
    List<Platform>? platforms,
    double? bestHeight,
  }) {
    return RisingBallState(
      phase: phase ?? this.phase,
      score: score ?? this.score,
      movesUsed: movesUsed ?? this.movesUsed,
      isOver: isOver ?? this.isOver,
      isWon: isWon ?? this.isWon,
      ballX: ballX ?? this.ballX,
      ballY: ballY ?? this.ballY,
      vx: vx ?? this.vx,
      vy: vy ?? this.vy,
      platforms: platforms ?? this.platforms,
      bestHeight: bestHeight ?? this.bestHeight,
    );
  }
}
