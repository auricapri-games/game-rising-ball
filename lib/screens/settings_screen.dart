import 'dart:async';

import 'package:auricapri_games_common/auricapri_games_common.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ds/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../widgets/gradient_background.dart';
import 'legal_screen.dart';

const _kListPad = 16.0;
const _kVerticalGap = 12.0;
const _kIconColor = AppColors.secondary;
const _kSoundKey = 'rising_ball_sound_on';
const _kMusicKey = 'rising_ball_music_on';
const _kVibrationKey = 'rising_ball_vibration_on';

/// Settings screen — sound/music/vibration toggles + legal entry.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ValueNotifier<bool> _sound = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _music = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _vibration = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _sound.value = prefs.getBool(_kSoundKey) ?? true;
    _music.value = prefs.getBool(_kMusicKey) ?? true;
    _vibration.value = prefs.getBool(_kVibrationKey) ?? true;
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _onSound(bool v) {
    _sound.value = v;
    unawaited(_save(_kSoundKey, v));
  }

  void _onMusic(bool v) {
    _music.value = v;
    unawaited(_save(_kMusicKey, v));
  }

  void _onVibration(bool v) {
    _vibration.value = v;
    unawaited(_save(_kVibrationKey, v));
  }

  @override
  void dispose() {
    _sound.dispose();
    _music.dispose();
    _vibration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: _kListPad),
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: _sound,
                builder: (_, v, __) => _ToggleTile(
                  icon: Icons.volume_up_rounded,
                  label: loc.sound,
                  value: v,
                  onChanged: _onSound,
                ),
              ),
              const SizedBox(height: _kVerticalGap),
              ValueListenableBuilder<bool>(
                valueListenable: _music,
                builder: (_, v, __) => _ToggleTile(
                  icon: Icons.music_note_rounded,
                  label: loc.music,
                  value: v,
                  onChanged: _onMusic,
                ),
              ),
              const SizedBox(height: _kVerticalGap),
              ValueListenableBuilder<bool>(
                valueListenable: _vibration,
                builder: (_, v, __) => _ToggleTile(
                  icon: Icons.vibration_rounded,
                  label: loc.vibration,
                  value: v,
                  onChanged: _onVibration,
                ),
              ),
              const SizedBox(height: _kVerticalGap),
              const LocalStorageNotice(),
              LegalLink(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const GameLegalScreen(),
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

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _kListPad),
      child: ListTile(
        leading: Icon(icon, color: _kIconColor),
        title: Text(
          label,
          style: const TextStyle(color: AppColors.text),
        ),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}
