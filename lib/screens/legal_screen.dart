import 'package:auricapri_games_common/auricapri_games_common.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Wraps the shared `LegalScreen` from `auricapri_games_common` so the
/// game name is injected from one place.
class GameLegalScreen extends StatelessWidget {
  const GameLegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return LegalScreen(gameName: loc.appTitle);
  }
}
