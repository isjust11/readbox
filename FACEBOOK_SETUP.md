# Hướng dẫn cấu hình Facebook Login

## Bước 1: Tạo Facebook App

1. Truy cập [Facebook Developers](https://developers.facebook.com/)
2. Đăng nhập và vào **My Apps**
3. Click **Create App**
4. Chọn loại app phù hợp (Consumer hoặc Business)
5. Điền thông tin app:
   - **App Name**: ReadBox
   - **App Contact Email**: email của bạn
6. Click **Create App**

## Bước 2: Cấu hình Facebook Login

1. Trong Dashboard app, click **Add Product**
2. Tìm và thêm **Facebook Login**
3. Chọn platform **Android**

## Bước 3: Lấy thông tin cần thiết

### Facebook App ID và Client Token

1. Vào **Settings > Basic**
2. Copy **App ID** (ví dụ: `1234567890123456`)
3. Click **Show** bên cạnh **App Secret** để xem
4. Tìm **Client Token** (có thể cần tạo mới nếu chưa có)

### Package Name và Key Hash

1. **Package Name**: `com.hungvv.readbox` (đã có trong build.gradle.kts)

2. **Key Hash** - Lấy từ debug keystore:
```bash
# Windows (PowerShell)
keytool -exportcert -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore | openssl sha1 -binary | openssl base64

# Khi được hỏi password, nhập: android
```

3. Dán **Key Hash** vào phần cấu hình Android trong Facebook Dashboard

## Bước 4: Cập nhật strings.xml

Mở file `android/app/src/main/res/values/strings.xml` và thay thế:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">ReadBox</string>
    
    <!-- Thay YOUR_FACEBOOK_APP_ID bằng App ID thực tế -->
    <string name="facebook_app_id">1234567890123456</string>
    
    <!-- Thay YOUR_FACEBOOK_CLIENT_TOKEN bằng Client Token thực tế -->
    <string name="facebook_client_token">abcdef1234567890abcdef1234567890</string>
    
    <!-- Thay YOUR_FACEBOOK_APP_ID bằng App ID thực tế (thêm fb ở đầu) -->
    <string name="fb_login_protocol_scheme">fb1234567890123456</string>
</resources>
```

**Ví dụ thực tế:**
- Nếu App ID là `534175741610`
- Client Token là `abc123def456`

```xml
<string name="facebook_app_id">534175741610</string>
<string name="facebook_client_token">abc123def456</string>
<string name="fb_login_protocol_scheme">fb534175741610</string>
```

## Bước 5: Cấu hình iOS (nếu cần)

Mở file `ios/Runner/Info.plist` và thêm:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fb1234567890123456</string>
    </array>
  </dict>
</array>

<key>FacebookAppID</key>
<string>1234567890123456</string>

<key>FacebookClientToken</key>
<string>abc123def456</string>

<key>FacebookDisplayName</key>
<string>ReadBox</string>

<key>LSApplicationQueriesSchemes</key>
<array>
  <string>fbapi</string>
  <string>fb-messenger-share-api</string>
  <string>fbauth2</string>
  <string>fbshareextension</string>
</array>
```

## Bước 6: Build lại app

```bash
# Clean project
flutter clean

# Get dependencies
flutter pub get

# Rebuild app
flutter run
```

## Troubleshooting

### "No implementation found for method login"
- Đảm bảo đã cập nhật `strings.xml` với App ID thực
- Chạy `flutter clean` và rebuild

### "Invalid key hash"
- Kiểm tra lại Key Hash đã đúng chưa
- Đảm bảo dùng đúng keystore (debug hoặc release)
- Có thể thêm nhiều Key Hash cho cả debug và release

### "App not setup"
- Kiểm tra App ID và Client Token đã đúng
- Đảm bảo Facebook App đang ở chế độ Development hoặc Live
- Kiểm tra package name khớp với cấu hình

### Testing
- Với Development mode: chỉ tài khoản được thêm vào Roles có thể test
- Thêm tester: **Roles > Test Users** hoặc **Roles > Administrators**

## Resources

- [Facebook Login for Android](https://developers.facebook.com/docs/facebook-login/android)
- [flutter_facebook_auth package](https://pub.dev/packages/flutter_facebook_auth)
