import 'package:flutter_test/flutter_test.dart';
import 'package:game_rising_ball/config/level_params.dart';
import 'package:game_rising_ball/core/game_rules.dart';
import 'package:game_rising_ball/core/game_state.dart';
import 'package:game_rising_ball/core/level_generator.dart';

void main() {
  group('RisingBallRules.applyMove', () {
    final params = RisingBallParams.fromPhase(1);
    const generator = RisingBallLevelGenerator();
    final rules = RisingBallRules(params);

    test('illegal move returns same state', () {
      final start = generator.generate(params);
      final ended = start.copyWith(isOver: true, isWon: false);
      final after =
          rules.applyMove(ended, const RisingBallMove(horizontal: 1, dt: 0.016));
      expect(after, ended);
    });

    test('move advances physics each tick', () {
      final start = generator.generate(params);
      final after = rules.applyMove(
        start,
        const RisingBallMove(horizontal: 1, dt: 0.016),
      );
      expect(after.movesUsed, start.movesUsed + 1);
      expect(after.ballX, greaterThan(start.ballX));
    });

    test('ball cannot exit horizontal world bounds', () {
      final start = generator.generate(params);
      var s = start.copyWith(ballX: params.worldWidth + 999);
      s = rules.applyMove(
        s,
        const RisingBallMove(horizontal: 1, dt: 0.016),
      );
      expect(s.ballX, lessThanOrEqualTo(params.worldWidth));
    });

    test('falling onto safe platform applies jump velocity', () {
      final start = generator.generate(params);
      final ground = start.platforms.first;
      final aboveGround = start.copyWith(
        ballY: ground.top + params.ballRadius + 4.0,
        vy: -50.0,
      );
      final after = rules.applyMove(
        aboveGround,
        const RisingBallMove(horizontal: 0, dt: 0.05),
      );
      expect(after.vy, greaterThan(0));
    });

    test('hitting a spike platform ends the run with isWon=false', () {
      final start = generator.generate(params);
      final spike = Platform(
        x: 0,
        y: start.ballY,
        width: params.worldWidth,
        height: params.platformHeight,
        hasSpikes: true,
      );
      final modified = start.copyWith(
        platforms: [spike],
        ballY: spike.top + params.ballRadius + 2.0,
        vy: -200.0,
      );
      final after = rules.applyMove(
        modified,
        const RisingBallMove(horizontal: 0, dt: 0.05),
      );
      expect(after.isOver, isTrue);
      expect(after.isWon, isFalse);
    });

    test('falling well below the world ends the run', () {
      final start = generator.generate(params);
      final fallen = start.copyWith(
        ballY: start.platforms.first.top - params.worldHeight * 2,
        vy: -100.0,
      );
      final after = rules.applyMove(
        fallen,
        const RisingBallMove(horizontal: 0, dt: 0.016),
      );
      expect(after.isOver, isTrue);
      expect(after.isWon, isFalse);
    });

    test('isLegal rejects negative dt', () {
      final start = generator.generate(params);
      expect(
        rules.isLegal(start, const RisingBallMove(horizontal: 0, dt: -1)),
        isFalse,
      );
    });

    test('reaching target height marks the level as won', () {
      final start = generator.generate(params);
      final near = start.copyWith(
        ballY: params.targetHeight + 10.0,
        bestHeight: params.targetHeight - 1.0,
        vy: 50.0,
      );
      final after = rules.applyMove(
        near,
        const RisingBallMove(horizontal: 0, dt: 0.016),
      );
      expect(after.isOver, isTrue);
      expect(after.isWon, isTrue);
    });
  });

  group('RisingBallLevelGenerator', () {
    test('produces deterministic output for the same seed', () {
      const generator = RisingBallLevelGenerator();
      final p = RisingBallParams.fromPhase(3);
      final a = generator.generate(p);
      final b = generator.generate(p);
      expect(a.platforms.length, b.platforms.length);
      for (var i = 0; i < a.platforms.length; i++) {
        expect(a.platforms[i].x, b.platforms[i].x);
        expect(a.platforms[i].y, b.platforms[i].y);
        expect(a.platforms[i].hasSpikes, b.platforms[i].hasSpikes);
      }
    });

    test('every generated phase passes validateSolvable', () {
      const generator = RisingBallLevelGenerator();
      for (var phase = 1; phase <= 10; phase++) {
        final state = generator.generate(RisingBallParams.fromPhase(phase));
        expect(generator.validateSolvable(state), isTrue,
            reason: 'phase $phase should be solvable');
      }
    });

    test('first platform is the wide ground floor', () {
      const generator = RisingBallLevelGenerator();
      final state =
          generator.generate(RisingBallParams.fromPhase(1));
      expect(state.platforms.first.width,
          RisingBallParams.fromPhase(1).worldWidth);
      expect(state.platforms.first.hasSpikes, isFalse);
    });
  });
}
