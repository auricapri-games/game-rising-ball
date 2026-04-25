import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'ds/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const GameRisingBallApp());
}

/// Root MaterialApp — wires theme, localizations and the splash entry point.
class GameRisingBallApp extends StatelessWidget {
  const GameRisingBallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const SplashScreen(),
    );
  }
}
