import 'package:flutter/foundation.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;

/// Số ký tự tối thiểu để nhận diện ngôn ngữ ổn định
const int _minTextLengthForDetection = 50;

/// Map mã ISO 639-1 (từ langdetect) sang locale TTS (BCP-47)
/// Thường dùng cho flutter_tts
const Map<String, String> _langToTtsLocale = {
  'vi': 'vi-VN',
  'en': 'en-US',
  'ja': 'ja-JP',
  'ko': 'ko-KR',
  'zh-cn': 'zh-CN',
  'zh-tw': 'zh-TW',
  'fr': 'fr-FR',
  'de': 'de-DE',
  'es': 'es-ES',
  'it': 'it-IT',
  'pt': 'pt-BR',
  'ru': 'ru-RU',
  'ar': 'ar',
  'th': 'th-TH',
  'id': 'id-ID',
  'nl': 'nl-NL',
  'pl': 'pl-PL',
  'tr': 'tr-TR',
  'hi': 'hi-IN',
  'bn': 'bn-IN',
  'ta': 'ta-IN',
  'te': 'te-IN',
  'mr': 'mr-IN',
  'gu': 'gu-IN',
  'kn': 'kn-IN',
  'ml': 'ml-IN',
  'pa': 'pa-IN',
  'fa': 'fa-IR',
  'he': 'he-IL',
  'uk': 'uk-UA',
  'cs': 'cs-CZ',
  'ro': 'ro-RO',
  'hu': 'hu-HU',
  'el': 'el-GR',
  'sv': 'sv-SE',
  'da': 'da-DK',
  'fi': 'fi-FI',
  'no': 'nb-NO',
};

bool _initialized = false;

/// Khởi tạo language detector (gọi 1 lần khi app start)
Future<void> initLanguageDetector() async {
  if (_initialized) return;
  try {
    await langdetect.initLangDetect();
    _initialized = true;
    debugPrint('Language detector initialized');
  } catch (e) {
    debugPrint('Language detector init error: $e');
  }
}

/// Nhận diện ngôn ngữ từ text và trả về locale dùng cho TTS.
/// Cần ít nhất [_minTextLengthForDetection] ký tự để nhận diện.
/// Returns: locale (vd: vi-VN, en-US) hoặc null nếu không đủ text / lỗi.
Future<String?> detectTtsLocale(String text) async {
  if (text.isEmpty || text.trim().length < _minTextLengthForDetection) {
    return null;
  }
  try {
    if (!_initialized) await initLanguageDetector();
    final lang = langdetect.detect(text.trim());
    if (lang.isEmpty) return null;
    return _langToTtsLocale[lang.toLowerCase()] ?? _toTtsLocaleFallback(lang);
  } catch (e) {
    debugPrint('Language detection error: $e');
    return null;
  }
}

/// Fallback khi không có trong map
String? _toTtsLocaleFallback(String lang) {
  final lower = lang.toLowerCase();
  if (lower == 'en') return 'en-US';
  if (lower == 'zh' || lower.startsWith('zh')) return 'zh-CN';
  return null; // Không đoán, để TTS dùng ngôn ngữ hiện tại
}
