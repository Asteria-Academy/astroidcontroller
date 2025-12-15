import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  static const String _bgmAsset = 'sounds/bgm/game_1mn8s_130bpm_LOOP.mp3';
  static const List<String> _sfxAssets = [
    'sounds/sfx/game_click_1.mp3',
    'sounds/sfx/game_click_2.mp3',
    'sounds/sfx/game_click_3.mp3',
    'sounds/sfx/game_click_4.mp3',
    'sounds/sfx/game_click_5.mp3',
  ];

  final AudioPlayer _bgmPlayer = AudioPlayer(playerId: 'bgm');
  AudioPlayer _sfxPlayer = AudioPlayer(playerId: 'sfx');
  final Random _rand = Random();

  bool _initialized = false;
  bool _bgmEnabled = true;
  bool _sfxEnabled = true;
  double _bgmVolume = 0.4;
  double _sfxVolume = 1.0;
  bool _isBgmPlaying = false;
  bool _contextsSet = false;
  bool _listenersBound = false;

  static final AudioContext _bgmContext = AudioContext(
    android: AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: true,
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.gain,
    ),
  );

  static final AudioContext _sfxContext = AudioContext(
    android: AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: false,
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.media,
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
    ),
  );

  Future<void> init({
    bool? bgmEnabled,
    double? bgmVolume,
    bool? sfxEnabled,
    double? sfxVolume,
  }) async {
    _bgmEnabled = bgmEnabled ?? _bgmEnabled;
    _sfxEnabled = sfxEnabled ?? _sfxEnabled;
    if (bgmVolume != null) _bgmVolume = bgmVolume;
    if (sfxVolume != null) _sfxVolume = sfxVolume;

    if (_initialized) {
      await _applyBgmState();
      return;
    }
    _initialized = true;

    await _setupAudioContexts();
    _bindBgmListeners();
    await _prepareBgmPlayer();
    await _prepareSfxPlayer();
    await _applyBgmState();
  }

  bool get isBgmEnabled => _bgmEnabled;
  bool get isSfxEnabled => _sfxEnabled;
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;

  Future<void> setBgmEnabled(bool enabled) async {
    _bgmEnabled = enabled;
    if (!enabled) {
      await _bgmPlayer.pause();
      _isBgmPlaying = false;
    } else {
      await _applyBgmState();
    }
  }

  Future<void> setSfxEnabled(bool enabled) async {
    _sfxEnabled = enabled;
    if (!enabled) {
      try {
        await _sfxPlayer.stop();
      } catch (_) {}
    }
  }

  Future<void> setBgmVolume(double value) async {
    _bgmVolume = value.clamp(0.0, 1.0);
    try {
      await _bgmPlayer.setVolume(_bgmVolume);
    } catch (_) {}

    if (!_bgmEnabled || _bgmVolume <= 0) {
      await _bgmPlayer.pause();
      _isBgmPlaying = false;
      return;
    }

    await _applyBgmState();
  }

  Future<void> setSfxVolume(double value) async {
    _sfxVolume = value.clamp(0.0, 1.0);
    try {
      await _sfxPlayer.setVolume(_sfxVolume);
    } catch (_) {}
  }

  Future<void> playClick() async {
    if (!_sfxEnabled || _sfxVolume <= 0 || _sfxAssets.isEmpty) return;
    await _setupAudioContexts();
    await _prepareSfxPlayer();
    try {
      final asset = _sfxAssets[_rand.nextInt(_sfxAssets.length)];
      debugPrint('[SFX] play request -> $asset vol=$_sfxVolume');
      await _sfxPlayer.stop();
      await _sfxPlayer.setVolume(_sfxVolume);
      await _sfxPlayer.play(AssetSource(asset));
    } catch (e) {
      debugPrint('[SFX] play failed: $e -> recreate player');
      try {
        await _sfxPlayer.dispose();
      } catch (_) {}
      _sfxPlayer = AudioPlayer(playerId: 'sfx');
      _contextsSet = false;
    }
  }

  Future<void> ensurePlaying() async {
    await _applyBgmState();
  }

  Future<void> resumeBgmIfEnabled() async {
    await _applyBgmState();
  }

  Future<void> pauseBgm() async {
    try {
      await _bgmPlayer.pause();
    } catch (_) {}
    _isBgmPlaying = false;
  }

  Future<void> dispose() async {
    await _bgmPlayer.stop();
    await _sfxPlayer.stop();
    await _bgmPlayer.dispose();
    await _sfxPlayer.dispose();
  }

  Future<void> _applyBgmState() async {
    if (!_bgmEnabled || _bgmVolume <= 0) {
      await _bgmPlayer.pause();
      _isBgmPlaying = false;
      return;
    }

    await _setupAudioContexts();
    await _playIfNeeded();
  }

  Future<void> _playIfNeeded() async {
    if (_isBgmPlaying && _bgmPlayer.state == PlayerState.playing) return;
    try {
      await _prepareBgmPlayer();
      await _bgmPlayer.play(AssetSource(_bgmAsset), volume: _bgmVolume);
      _isBgmPlaying = true;
    } catch (e) {
      debugPrint('[BGM] start failed: $e');
      _isBgmPlaying = false;
    }
  }

  Future<void> _setupAudioContexts() async {
    if (_contextsSet) return;
    try {
      await _bgmPlayer.setAudioContext(_bgmContext);
      await _sfxPlayer.setAudioContext(_sfxContext);
      _contextsSet = true;
    } catch (e) {
      debugPrint('[AudioContext] failed to apply: $e');
      _contextsSet = false;
    }
  }

  Future<void> _prepareBgmPlayer() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    await _bgmPlayer.setVolume(_bgmVolume);
  }

  Future<void> _prepareSfxPlayer() async {
    await _sfxPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    await _sfxPlayer.setReleaseMode(ReleaseMode.release);
    await _sfxPlayer.setVolume(_sfxVolume);
  }

  void _bindBgmListeners() {
    if (_listenersBound) return;
    _listenersBound = true;
    _bgmPlayer.onPlayerStateChanged.listen((state) {
      if (!_bgmEnabled || _bgmVolume <= 0) return;
      if (state == PlayerState.stopped ||
          state == PlayerState.completed ||
          state == PlayerState.paused) {
        _isBgmPlaying = false;
        _playIfNeeded();
      } else if (state == PlayerState.playing) {
        _isBgmPlaying = true;
      }
    });
    _bgmPlayer.onPlayerComplete.listen((_) {
      _isBgmPlaying = false;
      _playIfNeeded();
    });
  }
}
