import 'dart:async';

import 'package:flutter/material.dart';

import '../ds/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../widgets/gradient_background.dart';
import 'home_screen.dart';

const _kSplashDelay = Duration(milliseconds: 1500);
const _kMascotSize = 180.0;
const _kTitleSize = 38.0;
const _kTaglineSize = 14.0;
const _kSpacingLg = 24.0;
const _kSpacingSm = 8.0;
const _kBounceMs = Duration(milliseconds: 600);
const _kFadeMs = Duration(milliseconds: 700);
const _kFadeSlowMs = Duration(milliseconds: 1100);

/// Auto-navigates to the Home screen after a short branded splash.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_kSplashDelay, _goHome);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1.0),
                duration: _kBounceMs,
                curve: Curves.elasticOut,
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Image.asset(
                  'assets/sprites/mascot.png',
                  width: _kMascotSize,
                  height: _kMascotSize,
                ),
              ),
              const SizedBox(height: _kSpacingLg),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: _kFadeMs,
                builder: (context, value, child) =>
                    Opacity(opacity: value, child: child),
                child: Text(
                  loc.appTitle,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: _kTitleSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: _kSpacingSm),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: _kFadeSlowMs,
                builder: (context, value, child) =>
                    Opacity(opacity: value, child: child),
                child: Text(
                  loc.appTagline,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: _kTaglineSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
