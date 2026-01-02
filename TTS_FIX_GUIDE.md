# Hướng Dẫn Sửa Lỗi TTS trên iOS

## Lỗi gặp phải:
```
Query for com.apple.MobileAsset.VoiceServices.GryphonVoice failed: 2
IPCAUClient.cpp:139   IPCAUClient: can't connect to server (-66748)
```

## Nguyên nhân:
Lỗi này xảy ra trên iOS Simulator hoặc thiết bị iOS khi:
1. Không có giọng đọc tiếng Việt được cài đặt
2. TTS service chưa được cấu hình đúng cho iOS
3. Thiếu permissions trong Info.plist

## Giải pháp đã áp dụng:

### 1. Cập nhật `text_to_speech_service.dart`
- Thêm cấu hình iOS audio category
- Kiểm tra ngôn ngữ có sẵn trước khi sử dụng
- Fallback sang tiếng Anh nếu tiếng Việt không có
- Xử lý lỗi tốt hơn

### 2. Cập nhật `ios/Runner/Info.plist`
Đã thêm permissions:
```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs access to speech recognition for text-to-speech features</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for text-to-speech features</string>
```

### 3. Cài đặt giọng đọc tiếng Việt trên iOS

#### Trên iOS Simulator:
1. Mở Settings app trong simulator
2. Vào **Accessibility** → **Spoken Content** → **Voices**
3. Chọn **Vietnamese** → Download giọng đọc
4. Chờ download hoàn tất
5. Restart app

#### Trên thiết bị iOS thật:
1. Mở **Settings** → **Accessibility**
2. Vào **Spoken Content** → **Voices**
3. Chọn **Vietnamese** → Download
4. Hoặc: **Settings** → **General** → **Language & Region** → **Add Language** → Chọn Vietnamese

## Cách test:

### 1. Clean và rebuild:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

### 2. Kiểm tra log:
Khi khởi động app, check console log:
```
TTS Service initialized successfully
Available languages: [en-US, vi-VN, ...]
Using Vietnamese voice
```

Nếu thấy:
```
Vietnamese not available, fallback to English
```
→ Cần cài giọng đọc tiếng Việt (xem hướng dẫn trên)

### 3. Test trong app:
- Vào menu → "Demo Text-to-Speech"
- Chọn đoạn văn
- Nhấn "Bắt đầu đọc"
- Nếu vẫn lỗi, check console để xem lỗi cụ thể

## Các giải pháp khác nếu vẫn lỗi:

### Giải pháp 1: Dùng giọng mặc định của hệ thống
Trong `text_to_speech_service.dart`, thay đổi:
```dart
String _language = 'en-US'; // Thay vì 'vi-VN'
```

### Giải pháp 2: Kiểm tra và chọn giọng cụ thể
Thêm code để list và chọn giọng:
```dart
final voices = await _flutterTts!.getVoices;
print('Available voices: $voices');

// Chọn giọng cụ thể
if (voices != null && voices.isNotEmpty) {
  await _flutterTts!.setVoice({"name": "Karen", "locale": "en-AU"});
}
```

### Giải pháp 3: Test trên thiết bị thật
Simulator có thể có hạn chế về TTS. Test trên thiết bị iOS thật để kết quả chính xác hơn.

### Giải pháp 4: Kiểm tra version iOS
TTS hoạt động tốt nhất trên iOS 13+. Kiểm tra:
```bash
flutter doctor -v
```

## Lưu ý:
- Lỗi này thường chỉ xảy ra lần đầu khởi động
- Sau khi cài giọng đọc, app sẽ hoạt động bình thường
- Trên Android không có vấn đề này
- Có thể cần restart simulator sau khi download giọng

## Debug tips:
```dart
// Thêm vào initialize() để debug
print('Platform: ${defaultTargetPlatform}');
print('Languages: ${await _flutterTts!.getLanguages}');
print('Voices: ${await _flutterTts!.getVoices}');
print('Default voice: ${await _flutterTts!.getDefaultVoice}');
```

## Tham khảo:
- [flutter_tts documentation](https://pub.dev/packages/flutter_tts)
- [iOS TTS setup guide](https://developer.apple.com/documentation/avfoundation/speech_synthesis)

