import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:readbox/utils/text_to_speech_service.dart';

class TtsLockScreenController {
  TtsLockScreenController._();
  static final TtsLockScreenController instance = TtsLockScreenController._();

  AudioHandler? _handler;
  Future<void>? _initializing;

  Future<void> initialize() async {
    if (_handler != null) return;
    if (_initializing != null) {
      await _initializing;
      return;
    }

    _initializing = _doInitialize();
    try {
      await _initializing;
    } finally {
      _initializing = null;
    }
  }

  Future<void> _doInitialize() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    _handler = await AudioService.init(
      builder: () => _TtsAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'readbox_tts_channel',
        androidNotificationChannelName: 'Readbox TTS',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  }

  Future<bool> _ensureInitializedSafe() async {
    if (_handler != null) return true;
    try {
      await initialize().timeout(const Duration(seconds: 5));
      return _handler != null;
    } catch (e) {
      debugPrint('[TTS LockScreen] init skipped: $e');
      return false;
    }
  }

  Future<void> startReadingSession({
    required String bookTitle,
    required int page,
    required String text,
  }) async {
    if (!await _ensureInitializedSafe()) return;
    final handler = _handler;
    if (handler is! _TtsAudioHandler) return;
    await handler.setReadingContext(
      bookTitle: bookTitle,
      page: page,
      text: text,
    );
    await handler.setPlayingState();
  }

  Future<void> updateWordProgress({
    required String fullText,
    required int start,
    required int end,
  }) async {
    if (_handler == null && !await _ensureInitializedSafe()) return;
    final handler = _handler;
    if (handler is! _TtsAudioHandler) return;
    await handler.updateWordProgress(
      fullText: fullText,
      start: start,
      end: end,
    );
  }

  Future<void> markCompleted() async {
    if (_handler == null) return;
    final handler = _handler;
    if (handler is! _TtsAudioHandler) return;
    await handler.setCompletedState();
  }

  Future<void> markError(String message) async {
    if (_handler == null) return;
    final handler = _handler;
    if (handler is! _TtsAudioHandler) return;
    await handler.setErrorState(message);
  }

  Future<void> stop() async {
    await _handler?.stop();
  }
}

class _TtsAudioHandler extends BaseAudioHandler {
  final TextToSpeechService _ttsService = TextToSpeechService();

  String _bookTitle = '';
  String _fullText = '';
  int _page = 1;
  int _wordStart = 0;
  int _wordEnd = 0;

  Future<void> setReadingContext({
    required String bookTitle,
    required int page,
    required String text,
  }) async {
    _bookTitle = bookTitle;
    _page = page;
    _fullText = text;
    _wordStart = 0;
    _wordEnd = 0;

    mediaItem.add(
      MediaItem(
        id: 'tts-$page-${DateTime.now().millisecondsSinceEpoch}',
        title: _bookTitle,
        artist: 'Page $_page',
        album: _shorten(text),
      ),
    );
  }

  Future<void> updateWordProgress({
    required String fullText,
    required int start,
    required int end,
  }) async {
    _fullText = fullText;
    _wordStart = start.clamp(0, _fullText.length);
    _wordEnd = end.clamp(0, _fullText.length);

    final snippet = _currentSnippet();
    final current = mediaItem.value;
    if (current == null) return;

    mediaItem.add(
      current.copyWith(
        album: snippet,
      ),
    );
  }

  Future<void> setPlayingState() async {
    playbackState.add(
      playbackState.value.copyWith(
        controls: const [
          MediaControl.pause,
          MediaControl.stop,
        ],
        processingState: AudioProcessingState.ready,
        playing: true,
      ),
    );
  }

  Future<void> setCompletedState() async {
    playbackState.add(
      playbackState.value.copyWith(
        controls: const [
          MediaControl.play,
          MediaControl.stop,
        ],
        processingState: AudioProcessingState.completed,
        playing: false,
      ),
    );
  }

  Future<void> setErrorState(String message) async {
    debugPrint('[TTS LockScreen] Error: $message');
    playbackState.add(
      playbackState.value.copyWith(
        controls: const [
          MediaControl.play,
          MediaControl.stop,
        ],
        processingState: AudioProcessingState.error,
        playing: false,
      ),
    );
  }

  @override
  Future<void> play() async {
    if (_fullText.isEmpty) return;

    final start = _wordEnd.clamp(0, _fullText.length);
    final remaining = _fullText.substring(start).trim();
    final toSpeak = remaining.isEmpty ? _fullText : remaining;

    await _ttsService.speak(toSpeak);
    await setPlayingState();
  }

  @override
  Future<void> pause() async {
    await _ttsService.pause();
    playbackState.add(
      playbackState.value.copyWith(
        controls: const [
          MediaControl.play,
          MediaControl.stop,
        ],
        processingState: AudioProcessingState.ready,
        playing: false,
      ),
    );
  }

  @override
  Future<void> stop() async {
    await _ttsService.stop();
    playbackState.add(
      playbackState.value.copyWith(
        controls: const [
          MediaControl.play,
        ],
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
  }

  String _currentSnippet() {
    if (_fullText.isEmpty) return '';
    final start = _wordStart.clamp(0, _fullText.length);
    final end = _wordEnd.clamp(0, _fullText.length);

    if (start >= end) {
      return _shorten(_fullText);
    }

    final current = _fullText.substring(start, end);
    return _shorten(current);
  }

  String _shorten(String text) {
    const maxLen = 140;
    final cleaned = text.replaceAll('\n', ' ').trim();
    if (cleaned.length <= maxLen) return cleaned;
    return '${cleaned.substring(0, maxLen)}...';
  }
}
