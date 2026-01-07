# 🔧 Sửa lỗi Google Sign-In: ApiException 12500 (DEVELOPER_ERROR)

## 🐛 Lỗi hiện tại:

```
I/flutter (14037): ❌ Google Sign-In Error: PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 12500: , null, null)
I/flutter (14037): ❌ Error type: PlatformException
I/flutter (14037): ⚠️ DEVELOPER_ERROR (12500) - Cấu hình OAuth không đúng
```

**Nguyên nhân chính**: **THIẾU SHA-1 fingerprint** trong Google Cloud Console

---

## ✅ Giải pháp nhanh:

### Bước 1: Lấy SHA-1 Fingerprint

#### Cách 1: Dùng keytool (Khuyến nghị)

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Tìm dòng SHA1**, ví dụ:
```
SHA1: AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD
```

**Copy chuỗi SHA1** (dạng: `AA:BB:CC:DD:...`)

#### Cách 2: Dùng Gradle (nếu Java hoạt động)

```bash
cd android
./gradlew signingReport
```

---

### Bước 2: Thêm SHA-1 vào Google Cloud Console

1. **Truy cập Google Cloud Console**:
   - URL: https://console.cloud.google.com/
   - Chọn project: **readbox-3c692**

2. **Vào Credentials**:
   - Menu bên trái → **APIs & Services** → **Credentials**

3. **Tìm Android OAuth Client ID**:
   - Tìm OAuth 2.0 Client ID loại **"Android"**
   - Package name: `com.hungvv.readbox`

4. **Click vào để Edit**

5. **Thêm SHA-1**:
   - Scroll xuống phần **SHA-1 certificate fingerprints**
   - Click **+ ADD FINGERPRINT**
   - Paste SHA-1 fingerprint (dạng: `AA:BB:CC:DD:...`)
   - Click **Save**

**⚠️ Quan trọng**: Phải **Save** thay đổi!

---

### Bước 3: Đợi vài phút để Google sync

Google cần thời gian để sync cấu hình mới (1-5 phút).

---

### Bước 4: Clean và Rebuild App

```bash
cd /Users/username/develops/readbox/readbox
flutter clean
flutter pub get
flutter run
```

**Lưu ý**: Phải **uninstall app cũ** trước khi install app mới.

---

### Bước 5: Thử lại Google Sign-In

1. Uninstall app cũ trên device/emulator
2. Install app mới (qua `flutter run`)
3. Thử Google Sign-In

---

## 🔍 Kiểm tra thêm:

### 1. Kiểm tra Package Name khớp:

**File**: `android/app/build.gradle.kts`
```kotlin
applicationId = "com.hungvv.readbox"
```

**File**: `android/app/src/main/kotlin/com/hungvv/readbox/MainActivity.kt`
```kotlin
package com.hungvv.readbox
```

**Google Cloud Console → Credentials → Android OAuth Client:**
```
Package name: com.hungvv.readbox
```

✅ **Phải khớp ở tất cả các nơi!**

### 2. Kiểm tra google-services.json:

**File**: `android/app/google-services.json`
```json
{
  "android_client_info": {
    "package_name": "com.hungvv.readbox"
  }
}
```

### 3. Kiểm tra Google Sign-In API đã enable:

1. Google Cloud Console → **APIs & Services** → **Library**
2. Tìm: **"Google Sign-In API"** hoặc **"Identity Toolkit API"**
3. Đảm bảo: **ENABLED**

---

## 📝 Checklist:

- [ ] Đã lấy được SHA-1 fingerprint từ debug keystore
- [ ] Đã thêm SHA-1 vào Google Cloud Console
- [ ] Đã Save thay đổi trong Google Cloud Console
- [ ] Đã đợi 1-5 phút để Google sync
- [ ] Package name khớp: `com.hungvv.readbox`
- [ ] Google Sign-In API đã được enable
- [ ] Đã clean và rebuild app: `flutter clean && flutter run`
- [ ] Đã uninstall app cũ và install app mới

---

## 🐛 Nếu vẫn lỗi:

### Tạo Android OAuth Client ID mới (với SHA-1):

1. **Google Cloud Console** → **Credentials** → **+ CREATE CREDENTIALS** → **OAuth client ID**

2. **Application type**: Android

3. **Name**: `Readbox Android Client` (hoặc tên bất kỳ)

4. **Package name**: `com.hungvv.readbox`

5. **SHA-1 certificate fingerprint**: Paste SHA-1 vừa lấy

6. Click **CREATE**

7. **Copy Client ID** mới tạo

8. **Cập nhật vào code**:

**File**: `lib/config/google_signin_config.dart`
```dart
static const String androidClientId = 
    'YOUR_NEW_ANDROID_CLIENT_ID.apps.googleusercontent.com';
```

9. **Download lại google-services.json**:
   - Firebase Console → Project Settings → Your apps
   - Download `google-services.json` mới
   - Thay thế file `android/app/google-services.json`

10. **Rebuild**:
```bash
flutter clean
flutter pub get
flutter run
```

---

## 💡 Lưu ý quan trọng:

1. **SHA-1 là BẮT BUỘC** cho Google Sign-In trên Android
2. **Mỗi keystore có 1 SHA-1 riêng**:
   - Debug keystore: Dùng cho development
   - Release keystore: Dùng cho production (khi publish lên Play Store)
3. **Cần thêm CẢ 2 SHA-1** (debug và release) vào Google Cloud Console
4. **Sau khi thêm SHA-1**, phải **đợi vài phút** để Google sync
5. **Phải uninstall app cũ** trước khi install app mới

---

## 🔗 Tài liệu tham khảo:

- Google Sign-In Setup: https://developers.google.com/identity/sign-in/android/start
- SHA-1 Guide: https://developers.google.com/android/guides/client-auth
- Error 12500: https://stackoverflow.com/questions/tagged/google-signin+developer-error

