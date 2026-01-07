# 🔧 Sửa lỗi Google Sign-In: ApiException 8 (INTERNAL_ERROR)

## 🐛 Lỗi:

```
com.google.android.gms.common.api.ApiException: 8
```

**Nguyên nhân**: `INTERNAL_ERROR` - Thường do:
1. **Google Services plugin chưa được apply**
2. **SHA-1 fingerprint chưa được thêm** vào Google Cloud Console
3. **Google Play Services chưa được cập nhật** trên device
4. **Package name không khớp** giữa app và Firebase project
5. **Client ID không khớp** giữa code và google-services.json

---

## ✅ Giải pháp - Các bước chi tiết:

### Bước 1: Kiểm tra Google Services Plugin

**Đã được sửa tự động** - Kiểm tra:

**File**: `android/settings.gradle.kts`
```kotlin
plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false
}
```

**File**: `android/app/build.gradle.kts`
```kotlin
plugins {
    id("com.google.gms.google-services")  // ← Phải có dòng này
}
```

### Bước 2: Kiểm tra Client ID khớp nhau

**File**: `lib/config/google_signin_config.dart`
```dart
static const String androidClientId = 
    '534175741610-np09i3oqbgpintqosdikvh6o5tl5od01.apps.googleusercontent.com';
```

**File**: `android/app/google-services.json`
```json
{
  "oauth_client": [{
    "client_id": "534175741610-np09i3oqbgpintqosdikvh6o5tl5od01.apps.googleusercontent.com"
  }]
}
```

✅ **Phải KHỚP NHAU!**

### Bước 3: Lấy SHA-1 Fingerprint và thêm vào Google Cloud Console

```bash
cd android
./gradlew signingReport
```

Copy SHA1 (dạng: `AA:BB:CC:DD:...`)

1. Vào **Google Cloud Console**: https://console.cloud.google.com/
2. Chọn project: `readbox-3c692`
3. **APIs & Services** → **Credentials**
4. Tìm Android OAuth Client ID: `534175741610-np09i3oqbgpintqosdikvh6o5tl5od01.apps.googleusercontent.com`
5. Click **Edit**
6. Scroll xuống **SHA-1 certificate fingerprints**
7. Click **+ ADD FINGERPRINT**
8. Paste SHA-1 → **Save**

### Bước 4: Kiểm tra Package Name khớp

**File**: `android/app/build.gradle.kts`
```kotlin
applicationId = "com.hungvv.readbox"
```

**File**: `android/app/google-services.json`
```json
{
  "android_client_info": {
    "package_name": "com.hungvv.readbox"  // ← Phải khớp
  }
}
```

✅ **Phải KHỚP NHAU!**

### Bước 5: Kiểm tra Google Sign-In API đã Enable

1. Google Cloud Console → **APIs & Services** → **Library**
2. Tìm **"Google Sign-In API"** hoặc **"Identity Toolkit API"**
3. Đảm bảo đã **Enable**

### Bước 6: Clean và Rebuild

```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

### Bước 7: Kiểm tra Google Play Services trên Device

**Trên Android Emulator:**
- Đảm bảo dùng **Google Play** image (không phải Google APIs)
- Vào **Settings** → **Apps** → **Google Play Services**
- Kiểm tra version, update nếu cần

**Trên Device thật:**
- Vào **Play Store** → Update **Google Play Services**

---

## 🔍 Debug Checklist:

- [ ] Google Services plugin đã được apply trong `build.gradle.kts`
- [ ] Client ID trong code khớp với `google-services.json`
- [ ] Package name: `com.hungvv.readbox` khớp ở mọi nơi
- [ ] SHA-1 fingerprint đã được thêm vào Google Cloud Console
- [ ] Google Sign-In API đã được enable
- [ ] Đã clean và rebuild app
- [ ] Google Play Services đã được cập nhật trên device
- [ ] Đã uninstall app cũ và cài app mới

---

## 🐛 Nếu vẫn lỗi:

### 1. Kiểm tra Logs:

App sẽ log chi tiết khi có lỗi:
```
❌ Google Sign-In Error: ...
⚠️ INTERNAL_ERROR (8) - Có thể do:
   1. Google Play Services chưa được cập nhật
   2. SHA-1 fingerprint chưa được thêm vào Google Cloud Console
   3. Package name không khớp: com.hungvv.readbox
   4. google-services.json chưa đúng hoặc chưa được sync
   5. Google Sign-In API chưa được enable
```

### 2. Kiểm tra lại toàn bộ:

1. **Lấy SHA-1 mới:**
   ```bash
   cd android
   ./gradlew signingReport
   ```

2. **Verify SHA-1 đã được thêm:**
   - Google Cloud Console → Credentials → Android OAuth Client
   - Kiểm tra SHA-1 có trong list không

3. **Download lại google-services.json:**
   - Firebase Console → Project Settings
   - Download `google-services.json` mới
   - Thay thế file cũ

4. **Rebuild hoàn toàn:**
   ```bash
   flutter clean
   rm -rf android/.gradle
   rm -rf android/build
   flutter pub get
   flutter run
   ```

---

## 📝 Các thay đổi đã thực hiện:

1. ✅ Thêm Google Services plugin vào `settings.gradle.kts`
2. ✅ Thêm Google Services plugin vào `app/build.gradle.kts`
3. ✅ Cập nhật Client ID trong `google_signin_config.dart` cho khớp
4. ✅ Cải thiện error handling để log chi tiết lỗi code 8

---

## 🔗 Tài liệu tham khảo:

- Google Sign-In Setup: https://developers.google.com/identity/sign-in/android/start
- Error Codes: https://developers.google.com/android/reference/com/google/android/gms/common/api/CommonStatusCodes

