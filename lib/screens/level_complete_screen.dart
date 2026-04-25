import 'package:flutter/material.dart';

import '../ds/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../widgets/game_card.dart';
import '../widgets/gradient_background.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import 'gameplay_screen.dart';
import 'home_screen.dart';

const _kIconSize = 96.0;
const _kScoreSize = 56.0;
const _kTitleSize = 30.0;
const _kSpacing = 18.0;
const _kHorizontalPad = 28.0;

/// Modal-style screen shown when the player reaches the phase target.
class LevelCompleteScreen extends StatelessWidget {
  const LevelCompleteScreen({
    required this.score,
    required this.phase,
    super.key,
  });

  final int score;
  final int phase;

  int get _nextPhase => phase + 1;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _kHorizontalPad),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GameCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28.0,
                    vertical: 36.0,
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        size: _kIconSize,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(height: _kSpacing),
                      Text(
                        loc.youWin,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: _kTitleSize,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: _kSpacing),
                      Text(
                        score.toString(),
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: _kScoreSize,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        loc.score,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: _kSpacing),
                GamePrimaryButton(
                  label: loc.nextPhase,
                  icon: Icons.skip_next_rounded,
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => GameplayScreen(phase: _nextPhase),
                    ),
                  ),
                ),
                const SizedBox(height: _kSpacing),
                GameSecondaryButton(
                  icon: Icons.home_rounded,
                  label: loc.backHome,
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (_) => const HomeScreen(),
                    ),
                    (_) => false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
