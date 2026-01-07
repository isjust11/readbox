

import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInConfig {
  // Cấu hình Google Sign-In
  // Sử dụng client ID từ google-services.json

  // Web Client ID (dùng cho server-side verification)
  // Lấy từ Google Cloud Console → OAuth 2.0 Client IDs → Web application
  static const String webClientId =
      '534175741610-np09i3oqbgpintqosdikvh6o5tl5od01.apps.googleusercontent.com';

  // Android Client ID (từ google-services.json)
  // Lấy từ google-services.json → oauth_client → client_id
  static const String androidClientId =
      '534175741610-np09i3oqbgpintqosdikvh6o5tl5od01.apps.googleusercontent.com';

  // Cấu hình GoogleSignIn instance
  static GoogleSignIn get googleSignIn => GoogleSignIn(
    scopes: ['email', 'profile'],
    // Android: Client ID sẽ được đọc từ google-services.json
    // Web: Sử dụng webClientId cho web platform
    serverClientId: webClientId, // Cần thiết cho server-side verification
  );

  // Hướng dẫn cấu hình:
  // 1. Tạo project trên Google Cloud Console
  // 2. Enable Google Sign-In API
  // 3. Tạo OAuth 2.0 credentials:
  //    - Android: Thêm package name và SHA-1 fingerprint
  //    - iOS: Thêm bundle identifier
  // 4. Download google-services.json cho Android
  // 5. Download GoogleService-Info.plist cho iOS
  // 6. Thêm các file này vào project Flutter
}
