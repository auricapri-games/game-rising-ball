import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_rising_ball/main.dart';

void main() {
  testWidgets('app boots without crashing', (tester) async {
    await tester.pumpWidget(const GameRisingBallApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
