

import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInConfig {
  // Cấu hình Google Sign-In
  // Sử dụng client ID từ google-services.json

  // Web Client ID (dùng cho server-side verification)
  static const String webClientId =
      '228679159711-906v3nfof3sibkre59r394gv44al416o.apps.googleusercontent.com';

  // Android Client ID (từ google-services.json)
  static const String androidClientId =
      '228679159711-k41tgofkrglamkn6khb79ttp772ej4ir.apps.googleusercontent.com';

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
