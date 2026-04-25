import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_rising_ball/ds/app_theme.dart';
import 'package:game_rising_ball/l10n/app_localizations.dart';
import 'package:game_rising_ball/screens/gameplay_screen.dart';
import 'package:game_rising_ball/screens/home_screen.dart';
import 'package:game_rising_ball/widgets/score_chip.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _testApp() => MaterialApp(
      title: 'Rising Ball',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: const HomeScreen(),
    );

/// Pumps repeatedly until [predicate] is true or the budget is exhausted.
/// Used in place of `pumpAndSettle` on screens with continuous Tickers.
Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() predicate, {
  int maxFrames = 60,
}) async {
  for (var i = 0; i < maxFrames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
    if (predicate()) return;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('home renders the JOGAR CTA', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('JOGAR'), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('tap JOGAR enters gameplay and the ticker advances frames',
      (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('JOGAR'));
    // Cannot pumpAndSettle: the gameplay Ticker schedules new frames forever.
    await _pumpUntil(tester, () => find.byType(GameplayScreen).evaluate().isNotEmpty);

    expect(find.byType(GameplayScreen), findsOneWidget);
    expect(find.byType(ScoreChip), findsWidgets);

    // Drive the simulation forward by pumping frames manually.
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    final state =
        tester.state<State<GameplayScreen>>(find.byType(GameplayScreen));
    expect(state.mounted, isTrue);
  });

  testWidgets('pressing the left zone routes pointer events without crashing',
      (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('JOGAR'));
    await _pumpUntil(tester, () => find.byType(GameplayScreen).evaluate().isNotEmpty);

    final leftZone = find.byKey(const Key('game-left-zone'));
    expect(leftZone, findsOneWidget);

    final gesture = await tester.startGesture(tester.getCenter(leftZone));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(GameplayScreen), findsOneWidget);
  });
}
