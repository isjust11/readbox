# 🔑 Hướng dẫn lấy SHA-1 để sửa lỗi Google Sign-In 12500

## ⚠️ Vấn đề hiện tại:

Lỗi `ApiException: 12500` do **thiếu SHA-1 fingerprint** trong Google Cloud Console.

---

## 📋 Các bước thực hiện:

### Bước 1: Cài đặt Java JDK (Nếu chưa có)

Kiểm tra Java:
```bash
java -version
```

Nếu báo lỗi "Unable to locate a Java Runtime", cài Java:

```bash
# Cài Zulu OpenJDK 17 (khuyến nghị cho Flutter/Android)
brew install --cask zulu@17

# Hoặc cài Oracle JDK
brew install --cask temurin
```

Sau khi cài, kiểm tra lại:
```bash
java -version
```

---

### Bước 2: Lấy SHA-1 từ Debug Keystore

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Kết quả sẽ hiển thị:**
```
Alias name: androiddebugkey
Creation date: ...
Entry type: PrivateKeyEntry
Certificate fingerprints:
     SHA1: AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD
     SHA256: ...
```

**📝 Copy toàn bộ chuỗi SHA1** (dạng: `AA:BB:CC:DD:...`)

Ví dụ: `3B:4C:5D:6E:7F:8A:9B:0C:1D:2E:3F:4A:5B:6C:7D:8E:9F:0A:1B:2C`

---

### Bước 3: Thêm SHA-1 vào Google Cloud Console

#### 3.1. Truy cập Google Cloud Console

1. Vào: https://console.cloud.google.com/
2. Chọn project: **readbox-3c692**
3. Menu bên trái → **APIs & Services** → **Credentials**

#### 3.2. Tìm Android OAuth Client ID

Tìm trong danh sách **OAuth 2.0 Client IDs**:
- **Type**: Android
- **Package name**: `com.hungvv.readbox`

Nếu **KHÔNG TÌM THẤY** Android OAuth Client → Xem **Bước 4** để tạo mới.

#### 3.3. Thêm SHA-1 vào Client ID hiện có

1. Click vào Android OAuth Client ID
2. Scroll xuống phần **SHA-1 certificate fingerprints**
3. Click **+ ADD FINGERPRINT**
4. Paste SHA-1 vừa copy (dạng: `AA:BB:CC:DD:...`)
5. Click **SAVE**

**⚠️ LƯU Ý**: Đợi **2-5 phút** để Google sync cấu hình!

---

### Bước 4: (Nếu chưa có Android OAuth Client) Tạo mới

#### 4.1. Tạo Android OAuth Client ID

1. **Google Cloud Console** → **Credentials**
2. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
3. **Application type**: **Android**
4. **Name**: `Readbox Android Client`
5. **Package name**: `com.hungvv.readbox`
6. **SHA-1 certificate fingerprint**: Paste SHA-1 vừa lấy
7. Click **CREATE**

#### 4.2. Lấy Client ID mới

Sau khi tạo, copy **Client ID** (dạng: `xxx-yyy.apps.googleusercontent.com`)

#### 4.3. Cập nhật vào Firebase Console

1. Vào **Firebase Console**: https://console.firebase.google.com/
2. Chọn project **readbox-3c692**
3. Click ⚙️ **Settings** → **Project settings**
4. Tab **General** → Scroll xuống **Your apps**
5. Chọn Android app (`com.hungvv.readbox`)
6. Click **Download google-services.json** (hoặc nút Download)
7. **Thay thế** file `android/app/google-services.json` trong project

---

### Bước 5: Clean và Rebuild App

```bash
cd /Users/username/develops/readbox/readbox

# Clean project
flutter clean

# Get dependencies
flutter pub get

# Rebuild và run
flutter run
```

**⚠️ QUAN TRỌNG**: 
- Phải **uninstall app cũ** trên device/emulator
- Cài **app mới** sau khi rebuild

---

### Bước 6: Kiểm tra lại

1. Uninstall app cũ trên device/emulator
2. Run app mới: `flutter run`
3. Thử Google Sign-In

---

## 🔍 Debug nếu vẫn lỗi:

### Kiểm tra Package Name khớp:

**1. File**: `android/app/build.gradle.kts`
```kotlin
applicationId = "com.hungvv.readbox"
```

**2. File**: `android/app/src/main/kotlin/com/hungvv/readbox/MainActivity.kt`
```kotlin
package com.hungvv.readbox
```

**3. Google Cloud Console → Android OAuth Client**:
```
Package name: com.hungvv.readbox
```

**4. File**: `android/app/google-services.json`
```json
{
  "android_client_info": {
    "package_name": "com.hungvv.readbox"
  }
}
```

✅ **Tất cả phải KHỚP NHAU!**

### Kiểm tra SHA-1 đã được thêm:

1. Google Cloud Console → Credentials
2. Click vào Android OAuth Client ID
3. Xem phần **SHA-1 certificate fingerprints**
4. Đảm bảo SHA-1 của bạn có trong list

### Kiểm tra Google Sign-In API đã enable:

1. Google Cloud Console → **APIs & Services** → **Library**
2. Tìm: **"Google Sign-In API"** hoặc **"Identity Toolkit API"**
3. Nếu chưa enable → Click **ENABLE**

---

## 📝 Checklist hoàn chỉnh:

- [ ] Đã cài Java JDK (test bằng `java -version`)
- [ ] Đã lấy được SHA-1 từ debug keystore
- [ ] Đã thêm SHA-1 vào Google Cloud Console (Android OAuth Client)
- [ ] Đã Save trong Google Cloud Console
- [ ] Đã đợi 2-5 phút để Google sync
- [ ] Package name khớp: `com.hungvv.readbox` ở mọi nơi
- [ ] Google Sign-In API đã được enable
- [ ] Đã download lại `google-services.json` từ Firebase (nếu tạo client mới)
- [ ] Đã clean và rebuild: `flutter clean && flutter run`
- [ ] Đã uninstall app cũ trên device/emulator
- [ ] Đã cài app mới và test

---

## 💡 Lưu ý quan trọng:

1. **SHA-1 là BẮT BUỘC** - Không có SHA-1 → Lỗi 12500
2. **Phải đợi Google sync** - Thường mất 2-5 phút
3. **Phải uninstall app cũ** - App cũ có thể cache cấu hình cũ
4. **Package name phải khớp** - Sai package name → Lỗi

---

## 🔗 Tham khảo:

- Google Sign-In Setup: https://developers.google.com/identity/sign-in/android/start
- SHA-1 Guide: https://developers.google.com/android/guides/client-auth

