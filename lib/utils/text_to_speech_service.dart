import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'package:readbox/utils/language_detector.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service để quản lý Text-to-Speech cho ebook reading
class TextToSpeechService {
  static final TextToSpeechService _instance = TextToSpeechService._internal();
  factory TextToSpeechService() => _instance;
  TextToSpeechService._internal();

  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _isPaused = false;

  // Callbacks
  Function(String)? onSpeechStart;
  Function(String)? onSpeechComplete;
  Function(String)? onSpeechError;
  Function(double)? onSpeechProgress;
  /// Gọi khi TTS đọc đến từ/cụm: text (toàn bộ), start/end (vị trí ký tự), word (từ đang đọc)
  void Function(String text, int start, int end, String word)? onSpeechWordProgress;

  // Settings
  String _language = 'vi-VN';
  double _speechRate = 0.5; // 0.0 to 1.0
  double _volume = 1.0; // 0.0 to 1.0
  double _pitch = 1.0; // 0.5 to 2.0

  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;
  bool get isPaused => _isPaused;
  String get language => _language;
  double get speechRate => _speechRate;
  double get volume => _volume;
  double get pitch => _pitch;

  /// Khởi tạo TTS service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _flutterTts = FlutterTts();
      await loadSettings();
      // Setup callbacks
      _flutterTts!.setStartHandler(() {
        _isSpeaking = true;
        _isPaused = false;
        onSpeechStart?.call('');
      });

      _flutterTts!.setCompletionHandler(() {
        _isSpeaking = false;
        _isPaused = false;
        onSpeechComplete?.call('');
      });

      _flutterTts!.setErrorHandler((msg) {
        _isSpeaking = false;
        _isPaused = false;
        debugPrint('TTS Error: $msg');
        onSpeechError?.call(msg);
      });

      // Đánh dấu từ đang đọc (word boundary)
      _flutterTts!.setProgressHandler((String text, int start, int end, String word) {
        onSpeechWordProgress?.call(text, start, end, word);
      });

      // iOS specific: Enable shared instance
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _flutterTts!.setSharedInstance(true);
        await _flutterTts!.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.defaultMode,
        );
      }

      // Kiểm tra ngôn ngữ có sẵn
      final languages = await _flutterTts!.getLanguages; 
      debugPrint('Available languages: $languages');
      
      // Thử set tiếng Việt, nếu không có thì fallback sang tiếng Anh
      bool viSupported = languages.toString().contains('vi');
      if (viSupported) {
        await _flutterTts!.setLanguage(_language);
        debugPrint('Using Vietnamese voice');
      } else {
        _language = 'en-US';
        await _flutterTts!.setLanguage(_language);
        debugPrint('Vietnamese not available, fallback to English');
      }

      // set voice 
      

      _isInitialized = true;
      debugPrint('TTS Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing TTS: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _speechRate = prefs.getDouble('tts_speech_rate') ?? 0.5;
    _volume = prefs.getDouble('tts_volume') ?? 1.0;
    _pitch = prefs.getDouble('tts_pitch') ?? 1.0;
    await _flutterTts!.setSpeechRate(_speechRate);
    await _flutterTts!.setVolume(_volume);
    await _flutterTts!.setPitch(_pitch);
  }

  /// Đọc text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (text.isEmpty) return;

    try {
      await _flutterTts!.speak(text);
      _isSpeaking = true;
      _isPaused = false;
    } catch (e) {
      debugPrint('Error speaking: $e');
      onSpeechError?.call(e.toString());
    }
  }

  /// Dừng đọc
  Future<void> stop() async {
    if (!_isInitialized) return;

    try {
      await _flutterTts!.stop();
      _isSpeaking = false;
      _isPaused = false;
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
  }

  /// Tạm dừng đọc
  Future<void> pause() async {
    if (!_isInitialized || !_isSpeaking) return;

    try {
      await _flutterTts!.pause();
      _isPaused = true;
    } catch (e) {
      debugPrint('Error pausing TTS: $e');
    }
  }

  /// Tiếp tục đọc
  Future<void> resume() async {
    if (!_isInitialized || !_isPaused) return;

    try {
      // FlutterTts không có resume trực tiếp, cần implement custom
      // Tạm thời dùng stop và speak lại
      _isPaused = false;
    } catch (e) {
      debugPrint('Error resuming TTS: $e');
    }
  }

  /// Nhận diện ngôn ngữ từ text và chuyển TTS sang ngôn ngữ đó (cho ebook)
  Future<void> setLanguageFromText(String text) async {
    final locale = await detectTtsLocale(text);
    if (locale != null) {
      await setLanguage(locale);
    }
  }

  /// Đặt ngôn ngữ
  Future<void> setLanguage(String language) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final result = await _flutterTts!.setLanguage(language);
      if (result == 1) {
        _language = language;
      } else {
        debugPrint('Language $language not supported');
      }
    } catch (e) {
      debugPrint('Error setting language: $e');
    }
  }

  /// Đặt tốc độ đọc (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    if (rate < 0.0 || rate > 1.0) {
      debugPrint('Speech rate must be between 0.0 and 1.0');
      return;
    }

    _speechRate = rate;
    if (_isInitialized) {
      await _flutterTts!.setSpeechRate(rate);
    }
  }

  /// Đặt âm lượng (0.0 to 1.0)
  Future<void> setVolume(double vol) async {
    if (vol < 0.0 || vol > 1.0) {
      debugPrint('Volume must be between 0.0 and 1.0');
      return;
    }

    _volume = vol;
    if (_isInitialized) {
      await _flutterTts!.setVolume(vol);
    }
  }

  /// Đặt cao độ giọng nói (0.5 to 2.0)
  Future<void> setPitch(double p) async {
    if (p < 0.5 || p > 2.0) {
      debugPrint('Pitch must be between 0.5 and 2.0');
      return;
    }

    _pitch = p;
    if (_isInitialized) {
      await _flutterTts!.setPitch(p);
    }
  }

  /// Lấy danh sách ngôn ngữ hỗ trợ
  Future<List<dynamic>> getLanguages() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      return await _flutterTts!.getLanguages;
    } catch (e) {
      debugPrint('Error getting languages: $e');
      return [];
    }
  }

  /// Lấy danh sách giọng nói
  Future<List<dynamic>> getVoices() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      return await _flutterTts!.getVoices;
    } catch (e) {
      debugPrint('Error getting voices: $e');
      return [];
    }
  }

  /// Đặt giọng nói cụ thể
  Future<void> setVoice(Map<String, String> voiceMap) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _flutterTts!.setVoice(voiceMap);
    } catch (e) {
      debugPrint('Error setting voice: $e');
    }
  }

  /// Đọc text với callback khi hoàn thành (dùng cho đọc liên tục)
  Future<void> speakWithCallback(String text, {Function()? onComplete}) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (text.isEmpty) {
      onComplete?.call();
      return;
    }

    // Lưu callback tạm thời
    final originalComplete = onSpeechComplete;
    onSpeechComplete = (String message) {
      originalComplete?.call(message);
      onComplete?.call();
    };

    try {
      await _flutterTts!.speak(text);
      _isSpeaking = true;
      _isPaused = false;
    } catch (e) {
      debugPrint('Error speaking: $e');
      onSpeechError?.call(e.toString());
      onComplete?.call();
    }
  }

  /// Đọc danh sách text liên tục (dùng cho đọc nhiều trang)
  Future<void> speakMultiple(List<String> texts, {Function(int)? onPageComplete}) async {
    if (texts.isEmpty) return;

    for (int i = 0; i < texts.length; i++) {
      if (!_isSpeaking) break; // Dừng nếu user đã stop

      await speakWithCallback(texts[i], onComplete: () {
        onPageComplete?.call(i);
      });

      // Chờ đến khi hoàn thành trước khi đọc tiếp
      while (_isSpeaking) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  /// Giải phóng tài nguyên
  void dispose() {
    if (_flutterTts != null) {
      _flutterTts!.stop();
      _flutterTts = null;
    }
    _isInitialized = false;
    _isSpeaking = false;
    _isPaused = false;
  }
}

