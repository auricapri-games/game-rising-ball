import 'package:flutter/widgets.dart';

/// Lightweight in-house l10n. Strings live in [_pt] / [_en] / [_es]; the
/// public surface is `AppLocalizations.of(context).<key>` so the
/// `no_hardcoded_strings` lint stays happy and adding locales is one map away.
class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('pt'),
    Locale('en'),
    Locale('es'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final l = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return l ?? AppLocalizations(const Locale('pt'));
  }

  Map<String, String> get _strings {
    switch (locale.languageCode) {
      case 'en':
        return _en;
      case 'es':
        return _es;
      default:
        return _pt;
    }
  }

  String _t(String key) => _strings[key] ?? _pt[key] ?? key;

  String get appTitle => _t('appTitle');
  String get appTagline => _t('appTagline');
  String get play => _t('play');
  String get levelSelect => _t('levelSelect');
  String get settings => _t('settings');
  String get removeAds => _t('removeAds');
  String get legal => _t('legal');
  String get bestScore => _t('bestScore');
  String get score => _t('score');
  String get phase => _t('phase');
  String get tapToStart => _t('tapToStart');
  String get gameOver => _t('gameOver');
  String get youWin => _t('youWin');
  String get tryAgain => _t('tryAgain');
  String get backHome => _t('backHome');
  String get nextPhase => _t('nextPhase');
  String get sound => _t('sound');
  String get music => _t('music');
  String get vibration => _t('vibration');
  String get version => _t('version');
  String get removeAdsTitle => _t('removeAdsTitle');
  String get removeAdsBody => _t('removeAdsBody');
  String get monthly => _t('monthly');
  String get yearly => _t('yearly');
  String get phaseLabel => _t('phaseLabel');
  String get controlsHint => _t('controlsHint');
  String get pause => _t('pause');
  String get resume => _t('resume');
}

const _pt = <String, String>{
  'appTitle': 'Rising Ball',
  'appTagline': 'Sobe pulando de plataforma em plataforma',
  'play': 'JOGAR',
  'levelSelect': 'Escolher fase',
  'settings': 'Ajustes',
  'removeAds': 'Remover anuncios',
  'legal': 'Termos e privacidade',
  'bestScore': 'Recorde',
  'score': 'Pontuacao',
  'phase': 'Fase',
  'tapToStart': 'Toque na lateral para mover',
  'gameOver': 'Fim de jogo',
  'youWin': 'Voce subiu!',
  'tryAgain': 'Tentar de novo',
  'backHome': 'Voltar ao menu',
  'nextPhase': 'Proxima fase',
  'sound': 'Som',
  'music': 'Musica',
  'vibration': 'Vibracao',
  'version': 'Versao',
  'removeAdsTitle': 'Sem anuncios para sempre',
  'removeAdsBody': 'Apoie a fabrica e jogue tranquilo. Compra unica '
      'liberada via loja oficial.',
  'monthly': 'Mensal',
  'yearly': 'Anual',
  'phaseLabel': 'Fase',
  'controlsHint': 'Esquerda / Direita: deslize ou toque',
  'pause': 'Pausar',
  'resume': 'Continuar',
};

const _en = <String, String>{
  'appTitle': 'Rising Ball',
  'appTagline': 'Bounce up platform by platform',
  'play': 'PLAY',
  'levelSelect': 'Select level',
  'settings': 'Settings',
  'removeAds': 'Remove ads',
  'legal': 'Terms & privacy',
  'bestScore': 'Best',
  'score': 'Score',
  'phase': 'Level',
  'tapToStart': 'Tap a side to move',
  'gameOver': 'Game over',
  'youWin': 'You climbed!',
  'tryAgain': 'Try again',
  'backHome': 'Back to menu',
  'nextPhase': 'Next level',
  'sound': 'Sound',
  'music': 'Music',
  'vibration': 'Vibration',
  'version': 'Version',
  'removeAdsTitle': 'No ads, forever',
  'removeAdsBody': 'Support the factory and play distraction-free. '
      'Single in-app purchase from the official store.',
  'monthly': 'Monthly',
  'yearly': 'Yearly',
  'phaseLabel': 'Level',
  'controlsHint': 'Left / Right: swipe or tap',
  'pause': 'Pause',
  'resume': 'Resume',
};

const _es = <String, String>{
  'appTitle': 'Rising Ball',
  'appTagline': 'Sube saltando plataforma a plataforma',
  'play': 'JUGAR',
  'levelSelect': 'Elegir nivel',
  'settings': 'Ajustes',
  'removeAds': 'Quitar anuncios',
  'legal': 'Terminos y privacidad',
  'bestScore': 'Record',
  'score': 'Puntuacion',
  'phase': 'Nivel',
  'tapToStart': 'Toca un lado para moverte',
  'gameOver': 'Fin del juego',
  'youWin': 'Has subido!',
  'tryAgain': 'Intentar de nuevo',
  'backHome': 'Volver al menu',
  'nextPhase': 'Siguiente nivel',
  'sound': 'Sonido',
  'music': 'Musica',
  'vibration': 'Vibracion',
  'version': 'Version',
  'removeAdsTitle': 'Sin anuncios para siempre',
  'removeAdsBody': 'Apoya la fabrica y juega tranquilo. Compra unica '
      'desde la tienda oficial.',
  'monthly': 'Mensual',
  'yearly': 'Anual',
  'phaseLabel': 'Nivel',
  'controlsHint': 'Izquierda / Derecha: desliza o toca',
  'pause': 'Pausar',
  'resume': 'Continuar',
};

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any(
        (l) => l.languageCode == locale.languageCode,
      );

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
