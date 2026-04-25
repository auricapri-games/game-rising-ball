import 'package:flutter/material.dart';

import 'ds/app_colors.dart';

void main() {
  runApp(const GameRisingBallApp());
}

class GameRisingBallApp extends StatelessWidget {
  const GameRisingBallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rising Ball',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Rising Ball — building...',
            style: TextStyle(color: AppColors.text, fontSize: 22),
          ),
        ),
      ),
    );
  }
}
