import 'package:flutter_test/flutter_test.dart';
import 'package:game_rising_ball/config/level_params.dart';

void main() {
  group('RisingBallParams.fromPhase', () {
    test('phase < 1 is clamped to phase 1', () {
      final a = RisingBallParams.fromPhase(0);
      final b = RisingBallParams.fromPhase(1);
      expect(a.phase, b.phase);
      expect(a.numPlatforms, b.numPlatforms);
      expect(a.targetHeight, b.targetHeight);
    });

    test('difficulty grows with phase', () {
      final p1 = RisingBallParams.fromPhase(1);
      final p5 = RisingBallParams.fromPhase(5);
      expect(p5.spikePctOutOf100, greaterThan(p1.spikePctOutOf100));
      expect(p5.numPlatforms, greaterThan(p1.numPlatforms));
      expect(p5.targetHeight, greaterThan(p1.targetHeight));
      expect(p5.platformWidth, lessThanOrEqualTo(p1.platformWidth));
    });

    test('platform width never drops below the safe minimum', () {
      final extreme = RisingBallParams.fromPhase(50);
      expect(
        extreme.platformWidth,
        greaterThanOrEqualTo(RisingBallParams.kPlatformMinWidth),
      );
    });

    test('spike chance is capped to keep levels playable', () {
      final extreme = RisingBallParams.fromPhase(100);
      expect(
        extreme.spikePctOutOf100,
        lessThanOrEqualTo(RisingBallParams.kSpikeCap),
      );
    });

    test('seed is deterministic per phase', () {
      final a = RisingBallParams.fromPhase(7);
      final b = RisingBallParams.fromPhase(7);
      expect(a.seed, b.seed);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('different phases produce different seeds', () {
      final a = RisingBallParams.fromPhase(3);
      final b = RisingBallParams.fromPhase(4);
      expect(a.seed, isNot(b.seed));
      expect(a, isNot(b));
    });
  });
}
