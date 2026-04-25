import 'package:flutter/material.dart';

import '../ds/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../widgets/game_card.dart';
import '../widgets/gradient_background.dart';
import 'gameplay_screen.dart';

const _kPad = 24.0;
const _kGridSpacing = 12.0;
const _kCellPadding = 12.0;
const _kPhasesShown = 30;
const _kColumns = 4;
const _kCellFontSize = 22.0;

int _phaseFromIndex(int index) => index + 1;
String _phaseLabel(int index) => _phaseFromIndex(index).toString();

/// Lets the player jump straight into any phase 1..[_kPhasesShown].
class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.levelSelect)),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(_kPad),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _kColumns,
                mainAxisSpacing: _kGridSpacing,
                crossAxisSpacing: _kGridSpacing,
              ),
              itemCount: _kPhasesShown,
              itemBuilder: (context, index) => _PhaseCell(
                phaseLabel: _phaseLabel(index),
                phaseNumber: _phaseFromIndex(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhaseCell extends StatelessWidget {
  const _PhaseCell({required this.phaseLabel, required this.phaseNumber});

  final String phaseLabel;
  final int phaseNumber;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => GameplayScreen(phase: phaseNumber),
        ),
      ),
      child: GameCard(
        padding: const EdgeInsets.all(_kCellPadding),
        child: Center(
          child: Text(
            phaseLabel,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: _kCellFontSize,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
