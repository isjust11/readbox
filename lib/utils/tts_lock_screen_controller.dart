import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:readbox/utils/pdf_text_extractor.dart';
import 'package:readbox/utils/text_to_speech_service.dart';

/// Trạng thái TTS đang chạy nền (dùng cho floating mini-player toàn app).
enum TtsBackgroundStatus { idle, playing, paused, completed, error }

class TtsBackgroundInfo {
  final TtsBackgroundStatus status;
  final String bookTitle;
  final String? bookId;
  final int page;

  const TtsBackgroundInfo({
    required this.status,
    required this.bookTitle,
    this.bookId,
    this.page = 0,
  });

  static const TtsBackgroundInfo idle = TtsBackgroundInfo(
    status: TtsBackgroundStatus.idle,
    bookTitle: '',
  );

  bool get isActive =>
      status == TtsBackgroundStatus.playing ||
      status == TtsBackgroundStatus.paused;

  bool get isPlaying => status == TtsBackgroundStatus.playing;
  bool get isPaused => status == TtsBackgroundStatus.paused;

  TtsBackgroundInfo copyWith({
    TtsBackgroundStatus? status,
    String? bookTitle,
    String? bookId,
    int? page,
  }) {
    return TtsBackgroundInfo(
      status: status ?? this.status,
      bookTitle: bookTitle ?? this.bookTitle,
      bookId: bookId ?? this.bookId,
      page: page ?? this.page,
    );
  }
}

class TtsLockScreenController {
  TtsLockScreenController._();
  static final TtsLockScreenController instance = TtsLockScreenController._();

  AudioHandler? _handler;
  Future<void>? _initializing;
  _PdfBackgroundTtsRunner? _pdfBackgroundRunner;
  _EpubBackgroundTtsRunner? _epubBackgroundRunner;

  VoidCallback? onSkipForward;
  VoidCallback? onSkipBackward;
  VoidCallback? onRestartPage;

  /// Notifier toàn app cho floating TTS button. UI listen để show/hide
  /// nút điều khiển nhanh khi TTS đang chạy nền (đứng ở màn khác).
  final ValueNotifier<TtsBackgroundInfo> backgroundInfo =
      ValueNotifier<TtsBackgroundInfo>(TtsBackgroundInfo.idle);

  void _publish(TtsBackgroundInfo info) {
    if (backgroundInfo.value.status == info.status &&
        backgroundInfo.value.bookId == info.bookId &&
        backgroundInfo.value.bookTitle == info.bookTitle &&
        backgroundInfo.value.page == info.page) {
      return;
    }
    backgroundInfo.value = info;
  }

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
      builder: () => _TtsAudioHandler(this),
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
    String? bookId,
  }) async {
    _publish(
      TtsBackgroundInfo(
        status: TtsBackgroundStatus.playing,
        bookTitle: bookTitle,
        bookId: bookId,
        page: page,
      ),
    );
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

  /// Bàn giao đọc PDF liên tục từ `PdfViewerScreen` sang controller toàn app.
  /// Dùng khi user back khỏi màn PDF nhưng vẫn muốn TTS tiếp tục dưới nền.
  Future<void> continuePdfInBackground({
    required Uint8List pdfBytes,
    required String bookTitle,
    required int currentPage,
    required int totalPages,
    String? bookId,
  }) async {
    _pdfBackgroundRunner?.cancel();
    _pdfBackgroundRunner = _PdfBackgroundTtsRunner(
      controller: this,
      pdfBytes: pdfBytes,
      bookTitle: bookTitle,
      bookId: bookId,
      nextPage: currentPage + 1,
      totalPages: totalPages,
    );
    _pdfBackgroundRunner!.attachToCurrentSpeech();
  }

  /// Bàn giao đọc EPUB liên tục từ `EpubViewerScreen` sang controller toàn app.
  /// Dùng khi user back khỏi màn EPUB nhưng vẫn muốn TTS tiếp tục dưới nền.
  Future<void> continueEpubInBackground({
    required List<String> paragraphs,
    required String bookTitle,
    required int nextParagraphIndex,
    String? bookId,
  }) async {
    _pdfBackgroundRunner?.cancel();
    _pdfBackgroundRunner = null;
    _epubBackgroundRunner?.cancel();
    _epubBackgroundRunner = _EpubBackgroundTtsRunner(
      controller: this,
      paragraphs: paragraphs,
      bookTitle: bookTitle,
      nextParagraphIndex: nextParagraphIndex,
      bookId: bookId,
    );
    _epubBackgroundRunner!.attachToCurrentSpeech();
  }


  /// Cho UI gọi để pause/resume/stop TTS từ floating mini-player.
  Future<void> pauseFromUi() async {
    final handler = _handler;
    if (handler is! _TtsAudioHandler) return;
    await handler.pause();
    _publish(backgroundInfo.value.copyWith(status: TtsBackgroundStatus.paused));
  }

  Future<void> resumeFromUi() async {
    final handler = _handler;
    if (handler is! _TtsAudioHandler) return;
    await handler.play();
    _publish(
      backgroundInfo.value.copyWith(status: TtsBackgroundStatus.playing),
    );
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

  /// Báo TTS engine hoàn tất 1 page. KHÔNG publish `idle` vì khi đang đọc liên
  /// tục, viewer sẽ gọi tiếp `startReadingSession` cho page kế. Nếu publish
  /// idle ở đây, mini-player sẽ tắt rồi bật lại → người dùng tưởng TTS đã dừng.
  /// Khi hết sách, viewer phải gọi `stop()` để dứt khoát đóng session.
  Future<void> markCompleted() async {
    if (_handler == null) return;
    final handler = _handler;
    if (handler is! _TtsAudioHandler) return;
    await handler.setCompletedState();
  }

  /// Báo lỗi engine. Cũng KHÔNG publish idle: nhiều flow viewer xử lý lỗi bằng
  /// cách skip sang page kế (vẫn tiếp tục đọc), nên giữ session active. Viewer
  /// nào quyết định không tiếp tục cần gọi thêm `stop()`.
  Future<void> markError(String message) async {
    if (_handler == null) return;
    final handler = _handler;
    if (handler is! _TtsAudioHandler) return;
    await handler.setErrorState(message);
  }

  Future<void> stop() async {
    _pdfBackgroundRunner?.cancel();
    _pdfBackgroundRunner = null;
    _epubBackgroundRunner?.cancel();
    _epubBackgroundRunner = null;
    _publish(TtsBackgroundInfo.idle);
    await _handler?.stop();
  }
}

class _EpubBackgroundTtsRunner {
  _EpubBackgroundTtsRunner({
    required this.controller,
    required this.paragraphs,
    required this.bookTitle,
    required this.nextParagraphIndex,
    this.bookId,
  });

  final TtsLockScreenController controller;
  final List<String> paragraphs;
  final String bookTitle;
  final String? bookId;
  int nextParagraphIndex;

  final TextToSpeechService _ttsService = TextToSpeechService();
  bool _cancelled = false;
  bool _readingNext = false;

  void attachToCurrentSpeech() {
    _ttsService.onSpeechWordProgress = (
      String text,
      int start,
      int end,
      String word,
    ) {
      controller.updateWordProgress(fullText: text, start: start, end: end);
    };

    _ttsService.onSpeechComplete = (_) {
      _readNextParagraph();
    };

    _ttsService.onSpeechError = (error) {
      debugPrint('[EPUB Background TTS] $error');
      _readNextParagraph();
    };
  }

  void cancel() {
    _cancelled = true;
  }

  Future<void> _readNextParagraph() async {
    if (_cancelled || _readingNext) return;
    _readingNext = true;

    try {
      while (!_cancelled && nextParagraphIndex < paragraphs.length) {
        final paragraphToRead = nextParagraphIndex;
        nextParagraphIndex++;

        final paragraphText = paragraphs[paragraphToRead].trim();
        if (_cancelled) return;
        if (paragraphText.isEmpty) {
          continue;
        }

        await _ttsService.setLanguageFromText(paragraphText);
        if (_cancelled) return;

        await controller.startReadingSession(
          bookTitle: bookTitle,
          page: paragraphToRead + 1,
          text: paragraphText,
          bookId: bookId,
        );
        attachToCurrentSpeech();
        await _ttsService.speak(paragraphText);
        return;
      }

      await controller.stop();
    } catch (e) {
      debugPrint('[EPUB Background TTS] read next failed: $e');
      await controller.stop();
    } finally {
      _readingNext = false;
    }
  }
}


class _PdfBackgroundTtsRunner {
  _PdfBackgroundTtsRunner({
    required this.controller,
    required this.pdfBytes,
    required this.bookTitle,
    required this.nextPage,
    required this.totalPages,
    this.bookId,
  });

  final TtsLockScreenController controller;
  final Uint8List pdfBytes;
  final String bookTitle;
  final String? bookId;
  int nextPage;
  final int totalPages;

  final TextToSpeechService _ttsService = TextToSpeechService();
  bool _cancelled = false;
  bool _readingNext = false;

  void attachToCurrentSpeech() {
    _ttsService.onSpeechWordProgress = (
      String text,
      int start,
      int end,
      String word,
    ) {
      controller.updateWordProgress(fullText: text, start: start, end: end);
    };

    _ttsService.onSpeechComplete = (_) {
      _readNextPage();
    };

    _ttsService.onSpeechError = (error) {
      debugPrint('[PDF Background TTS] $error');
      _readNextPage();
    };
  }

  void cancel() {
    _cancelled = true;
  }

  Future<void> _readNextPage() async {
    if (_cancelled || _readingNext) return;
    _readingNext = true;

    try {
      while (!_cancelled && nextPage <= totalPages) {
        final pageToRead = nextPage;
        nextPage++;

        final (text, _) = await PdfTextExtractorService.extractTextAndBounds(
          pdfBytes,
          pageToRead - 1,
        );
        final pageText = text?.trim();
        if (_cancelled) return;
        if (pageText == null || pageText.isEmpty) {
          continue;
        }

        await _ttsService.setLanguageFromText(pageText);
        if (_cancelled) return;

        await controller.startReadingSession(
          bookTitle: bookTitle,
          page: pageToRead,
          text: pageText,
          bookId: bookId,
        );
        attachToCurrentSpeech();
        await _ttsService.speak(pageText);
        return;
      }

      await controller.stop();
    } catch (e) {
      debugPrint('[PDF Background TTS] read next failed: $e');
      await controller.stop();
    } finally {
      _readingNext = false;
    }
  }
}

class _TtsAudioHandler extends BaseAudioHandler {
  final TextToSpeechService _ttsService = TextToSpeechService();
  final TtsLockScreenController _controller;

  _TtsAudioHandler(this._controller);

  String _bookTitle = '';
  String _fullText = '';
  int _page = 1;
  int _wordStart = 0;
  int _wordEnd = 0;

  static const _skipForward = MediaControl(
    androidIcon: 'drawable/audio_service_fast_forward',
    label: 'Forward',
    action: MediaAction.fastForward,
  );

  static const _skipBackward = MediaControl(
    androidIcon: 'drawable/audio_service_rewind',
    label: 'Backward',
    action: MediaAction.rewind,
  );

  static const _restart = MediaControl(
    androidIcon: 'drawable/audio_service_skip_to_previous',
    label: 'Restart',
    action: MediaAction.skipToPrevious,
  );

  List<MediaControl> get _playingControls => const [
    _skipBackward,
    MediaControl.pause,
    _skipForward,
  ];

  List<MediaControl> get _pausedControls => const [
    _restart,
    MediaControl.play,
    _skipForward,
  ];

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

    final duration = Duration(milliseconds: text.length);

    mediaItem.add(
      MediaItem(
        id: 'tts-$page-${DateTime.now().millisecondsSinceEpoch}',
        title: _bookTitle,
        artist: 'Page $_page',
        album: _shorten(text),
        duration: duration,
      ),
    );
  }

  Future<void> updateWordProgress({
    required String fullText,
    required int start,
    required int end,
  }) async {
    _fullText = fullText;
    _wordStart = start.clamp(0, _fullText.length).toInt();
    _wordEnd = end.clamp(0, _fullText.length).toInt();

    final snippet = _currentSnippet();
    final current = mediaItem.value;
    if (current == null) return;

    mediaItem.add(current.copyWith(album: snippet));

    playbackState.add(
      playbackState.value.copyWith(
        updatePosition: Duration(milliseconds: _wordStart),
      ),
    );
  }

  Future<void> setPlayingState() async {
    playbackState.add(
      playbackState.value.copyWith(
        controls: _playingControls,
        systemActions: const {
          MediaAction.fastForward,
          MediaAction.rewind,
          MediaAction.skipToPrevious,
        },
        processingState: AudioProcessingState.ready,
        playing: true,
        updatePosition: Duration(milliseconds: _wordStart),
      ),
    );
  }

  Future<void> setCompletedState() async {
    playbackState.add(
      playbackState.value.copyWith(
        controls: _pausedControls,
        processingState: AudioProcessingState.completed,
        playing: false,
      ),
    );
  }

  Future<void> setErrorState(String message) async {
    debugPrint('[TTS LockScreen] Error: $message');
    playbackState.add(
      playbackState.value.copyWith(
        controls: _pausedControls,
        processingState: AudioProcessingState.error,
        playing: false,
      ),
    );
  }

  @override
  Future<void> play() async {
    if (_fullText.isEmpty) return;

    final start = _wordEnd.clamp(0, _fullText.length).toInt();
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
        controls: _pausedControls,
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
        controls: const [MediaControl.play],
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
  }

  @override
  Future<void> fastForward() async {
    _controller.onSkipForward?.call();
  }

  @override
  Future<void> rewind() async {
    _controller.onSkipBackward?.call();
  }

  @override
  Future<void> skipToPrevious() async {
    _controller.onRestartPage?.call();
  }

  String _currentSnippet() {
    if (_fullText.isEmpty) return '';
    final start = _wordStart.clamp(0, _fullText.length).toInt();
    final end = _wordEnd.clamp(0, _fullText.length).toInt();

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
