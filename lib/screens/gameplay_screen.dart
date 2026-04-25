import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/level_params.dart';
import '../core/game_rules.dart';
import '../core/game_state.dart';
import '../core/level_generator.dart';
import '../ds/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../widgets/game_renderer.dart';
import '../widgets/score_chip.dart';
import 'game_over_screen.dart';
import 'level_complete_screen.dart';

const _kHudPadding = 12.0;
const _kHudRowGap = 8.0;
const _kPauseSize = 36.0;
const _kMaxFrameDt = 0.05;
const _kBestKey = 'rising_ball_best_score';

/// Gameplay screen — drives the physics ticker and renders the world.
class GameplayScreen extends StatefulWidget {
  const GameplayScreen({required this.phase, super.key});

  final int phase;

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen>
    with SingleTickerProviderStateMixin {
  late final RisingBallParams _params;
  late final RisingBallRules _rules;
  late final ValueNotifier<RisingBallState> _state;
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  int _horizontal = 0;
  final ValueNotifier<bool> _paused = ValueNotifier<bool>(false);
  bool _navigated = false;

  ui.Image? _ballImage;
  ui.Image? _platformImage;
  ui.Image? _spikeImage;
  ui.Image? _backgroundImage;

  @override
  void initState() {
    super.initState();
    _params = RisingBallParams.fromPhase(widget.phase);
    _rules = RisingBallRules(_params);
    const generator = RisingBallLevelGenerator();
    _state = ValueNotifier<RisingBallState>(generator.generate(_params));
    _ticker = createTicker(_onTick)..start();
    _loadImages();
  }

  Future<void> _loadImages() async {
    _ballImage = await _loadAsset('assets/sprites/ball.png');
    _platformImage = await _loadAsset('assets/sprites/platform.png');
    _spikeImage = await _loadAsset('assets/sprites/spike.png');
    _backgroundImage = await _loadAsset('assets/sprites/background.png');
    if (mounted) {
      _state.value = _state.value.copyWith();
    }
  }

  Future<ui.Image> _loadAsset(String path) async {
    final data = await rootBundle.load(path);
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  void _onTick(Duration now) {
    if (_paused.value) {
      _lastTick = now;
      return;
    }
    if (_lastTick == Duration.zero) {
      _lastTick = now;
      return;
    }
    final dtMs = (now - _lastTick).inMilliseconds.toDouble();
    _lastTick = now;
    final dtSec = dtMs / 1000.0;
    final clampedDt = dtSec > _kMaxFrameDt ? _kMaxFrameDt : dtSec;
    final newState = _rules.applyMove(
      _state.value,
      RisingBallMove(horizontal: _horizontal, dt: clampedDt),
    );
    _state.value = newState;
    if (newState.isOver && !_navigated) {
      _navigated = true;
      _onGameEnded(newState);
    }
  }

  Future<void> _onGameEnded(RisingBallState end) async {
    final prefs = await SharedPreferences.getInstance();
    final prevBest = prefs.getInt(_kBestKey) ?? 0;
    if (end.score > prevBest) {
      await prefs.setInt(_kBestKey, end.score);
    }
    if (!mounted) return;
    if (end.isWon) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => LevelCompleteScreen(
            score: end.score,
            phase: end.phase,
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => GameOverScreen(score: end.score, phase: end.phase),
        ),
      );
    }
  }

  void _onLeftDown(_) {
    _horizontal = -1;
  }

  void _onRightDown(_) {
    _horizontal = 1;
  }

  void _onRelease(_) {
    _horizontal = 0;
  }

  void _togglePause() {
    _paused.value = !_paused.value;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _state.dispose();
    _paused.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: ValueListenableBuilder<RisingBallState>(
                valueListenable: _state,
                builder: (context, state, _) {
                  return GameRenderer(
                    state: state,
                    worldWidth: _params.worldWidth,
                    worldHeight: _params.worldHeight,
                    ballRadius: _params.ballRadius,
                    ballImage: _ballImage,
                    platformImage: _platformImage,
                    spikeImage: _spikeImage,
                    backgroundImage: _backgroundImage,
                  );
                },
              ),
            ),
            // Touch zones — left half / right half of screen.
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: Listener(
                      behavior: HitTestBehavior.translucent,
                      onPointerDown: _onLeftDown,
                      onPointerUp: _onRelease,
                      onPointerCancel: _onRelease,
                      child: Container(
                        key: const Key('game-left-zone'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Listener(
                      behavior: HitTestBehavior.translucent,
                      onPointerDown: _onRightDown,
                      onPointerUp: _onRelease,
                      onPointerCancel: _onRelease,
                      child: Container(
                        key: const Key('game-right-zone'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: _kHudPadding,
              left: _kHudPadding,
              right: _kHudPadding,
              child: ValueListenableBuilder<RisingBallState>(
                valueListenable: _state,
                builder: (context, state, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ScoreChip(
                        label: loc.score,
                        value: state.score.toString(),
                        icon: Icons.flash_on,
                      ),
                      const SizedBox(width: _kHudRowGap),
                      ScoreChip(
                        label: loc.phase,
                        value: state.phase.toString(),
                        icon: Icons.layers_rounded,
                      ),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              bottom: _kHudPadding,
              right: _kHudPadding,
              child: ValueListenableBuilder<bool>(
                valueListenable: _paused,
                builder: (context, paused, _) {
                  return Material(
                    color: AppColors.background,
                    shape: const CircleBorder(),
                    elevation: 4,
                    child: IconButton(
                      iconSize: _kPauseSize,
                      icon: Icon(
                        paused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        color: AppColors.secondary,
                      ),
                      onPressed: _togglePause,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: _kHudPadding,
              left: _kHudPadding,
              child: ScoreChip(
                label: loc.controlsHint,
                value: loc.tapToStart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
