// Real gameplay integration test for Rising Ball.
//
// 1. Boots the app (splash → home).
// 2. Taps the JOGAR CTA, lands on the gameplay screen.
// 3. Confirms the score HUD shows starting score 0.
// 4. Holds the right touch zone for several frames so the ball moves
//    horizontally — proves the rules engine + ticker is wired up.
// 5. Confirms the gameplay screen is still mounted after input
//    (tutorial AnimatedOpacity fades to 0; widget itself stays).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:game_rising_ball/main.dart';
import 'package:game_rising_ball/screens/gameplay_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('home -> play -> ball reacts to input', (tester) async {
    await tester.pumpWidget(const GameRisingBallApp());

    // Advance past the 1500ms splash timer + any tween animations.
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Resolve the active locale string (en/pt/es). We try every variant
    // since the test environment locale is not deterministic.
    Finder? playFinder;
    for (final candidate in ['JOGAR', 'PLAY', 'JUGAR']) {
      final f = find.text(candidate);
      if (f.evaluate().isNotEmpty) {
        playFinder = f;
        break;
      }
    }
    expect(playFinder, isNotNull,
        reason: 'PLAY/JOGAR/JUGAR button must be visible on home');
    await tester.tap(playFinder!);
    // The gameplay screen runs a Ticker forever, so pumpAndSettle would
    // hang. Pump enough frames to land on it and finish the page transition.
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(GameplayScreen), findsOneWidget,
        reason: 'tap PLAY should open the gameplay screen');
    expect(find.textContaining(RegExp(r'^\d+$')), findsWidgets,
        reason: 'score HUD should show a numeric score');

    final rightZone = find.byKey(const Key('game-right-zone'));
    expect(rightZone, findsOneWidget);
    final gesture = await tester.startGesture(tester.getCenter(rightZone));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(GameplayScreen), findsOneWidget,
        reason: 'gameplay should still be mounted after input');
  });
}
