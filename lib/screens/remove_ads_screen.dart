import 'package:flutter/material.dart';

import '../ds/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../widgets/game_card.dart';
import '../widgets/gradient_background.dart';
import '../widgets/primary_button.dart';

const _kPad = 24.0;
const _kSpacing = 18.0;
const _kIconSize = 84.0;
const _kTitleSize = 28.0;
const _kPriceSize = 22.0;

/// Static remove-ads pitch — no real billing. Pricing copy lives in the
/// store listing; this screen is the in-app discovery surface.
class RemoveAdsScreen extends StatelessWidget {
  const RemoveAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.removeAds)),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(_kPad),
            child: Column(
              children: [
                const SizedBox(height: _kSpacing),
                const Icon(
                  Icons.workspace_premium_rounded,
                  size: _kIconSize,
                  color: AppColors.secondary,
                ),
                const SizedBox(height: _kSpacing),
                Text(
                  loc.removeAdsTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: _kTitleSize,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: _kSpacing),
                Text(
                  loc.removeAdsBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                GameCard(
                  child: Column(
                    children: [
                      Text(
                        loc.monthly,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: _kPriceSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: _kSpacing),
                      Text(
                        loc.yearly,
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: _kPriceSize,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: _kSpacing),
                GamePrimaryButton(
                  label: loc.removeAds,
                  icon: Icons.shopping_bag_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
