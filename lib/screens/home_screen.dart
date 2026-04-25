import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ds/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../widgets/gradient_background.dart';
import '../widgets/primary_button.dart';
import '../widgets/score_chip.dart';
import '../widgets/secondary_button.dart';
import 'gameplay_screen.dart';
import 'legal_screen.dart';
import 'level_select_screen.dart';
import 'remove_ads_screen.dart';
import 'settings_screen.dart';

const _kHeroSize = 200.0;
const _kTitleSize = 44.0;
const _kTaglineSize = 14.0;
const _kSpacing = 14.0;
const _kSpacingHalf = 7.0;
const _kBigSpacing = 26.0;
const _kHorizontalPad = 28.0;
const String _kBestKey = 'rising_ball_best_score';

/// Home screen — mascot + CTA + secondary actions.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<int> _bestScore = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _loadBest();
  }

  Future<void> _loadBest() async {
    final prefs = await SharedPreferences.getInstance();
    _bestScore.value = prefs.getInt(_kBestKey) ?? 0;
  }

  @override
  void dispose() {
    _bestScore.dispose();
    super.dispose();
  }

  void _onPlay() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const GameplayScreen(phase: 1)),
    ).then((_) => _loadBest());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _kHorizontalPad),
            child: Column(
              children: [
                const SizedBox(height: _kBigSpacing),
                ValueListenableBuilder<int>(
                  valueListenable: _bestScore,
                  builder: (context, value, _) => ScoreChip(
                    label: loc.bestScore,
                    value: value.toString(),
                    icon: Icons.emoji_events,
                  ),
                ),
                const Spacer(),
                Image.asset(
                  'assets/sprites/mascot.png',
                  width: _kHeroSize,
                  height: _kHeroSize,
                ),
                const SizedBox(height: _kSpacing),
                Text(
                  loc.appTitle,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: _kTitleSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: _kSpacingHalf),
                Text(
                  loc.appTagline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: _kTaglineSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                GamePrimaryButton(
                  label: loc.play,
                  icon: Icons.play_arrow_rounded,
                  onPressed: _onPlay,
                ),
                const SizedBox(height: _kSpacing),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: _kSpacingHalf,
                  runSpacing: _kSpacingHalf,
                  children: [
                    GameSecondaryButton(
                      icon: Icons.layers_rounded,
                      label: loc.levelSelect,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LevelSelectScreen(),
                        ),
                      ),
                    ),
                    GameSecondaryButton(
                      icon: Icons.settings_rounded,
                      label: loc.settings,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                    GameSecondaryButton(
                      icon: Icons.block_rounded,
                      label: loc.removeAds,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const RemoveAdsScreen(),
                        ),
                      ),
                    ),
                    GameSecondaryButton(
                      icon: Icons.gavel_rounded,
                      label: loc.legal,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const GameLegalScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: _kBigSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
