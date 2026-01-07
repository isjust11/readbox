# 🔧 Tạo Android OAuth Client ID với SHA-1

## 🔍 Vấn đề phát hiện:

File `android/app/google-services.json` **THIẾU Android OAuth Client ID** (client_type: 1).

Hiện tại chỉ có:
```json
"oauth_client": [
  {
    "client_id": "534175741610-np09i3oqbgpintqosdikvh6o5tl5od01.apps.googleusercontent.com",
    "client_type": 3  // ← Chỉ có Web client
  }
]
```

**CẦN CÓ**:
```json
"oauth_client": [
  {
    "client_id": "xxx-yyy.apps.googleusercontent.com",
    "client_type": 1,  // ← Android client (BẮT BUỘC)
    "android_info": {
      "package_name": "com.hungvv.readbox",
      "certificate_hash": "da86a90be758b3dceb87f3cd3e210a9dc4d6e502"
    }
  },
  {
    "client_id": "534175741610-np09i3oqbgpintqosdikvh6o5tl5od01.apps.googleusercontent.com",
    "client_type": 3  // Web client
  }
]
```

---

## ✅ Giải pháp: Tạo Android OAuth Client ID

### Bước 1: Chuẩn bị thông tin

**SHA-1 của bạn:**
```
DA:86:A9:0B:E7:58:B3:DC:EB:87:F3:CD:3E:21:0A:9D:C4:D6:E5:02
```

**Package name:**
```
com.hungvv.readbox
```

---

### Bước 2: Tạo Android OAuth Client ID

#### 2.1. Truy cập Google Cloud Console

1. Vào: https://console.cloud.google.com/
2. Chọn project: **readbox-3c692**
3. Menu bên trái → **APIs & Services** → **Credentials**

#### 2.2. Tạo OAuth Client ID mới

1. Click **+ CREATE CREDENTIALS**
2. Chọn **OAuth client ID**

#### 2.3. Cấu hình

**Application type**: Chọn **Android**

**Name**: `Readbox Android Client`

**Package name**: 
```
com.hungvv.readbox
```

**SHA-1 certificate fingerprint**:
```
DA:86:A9:0B:E7:58:B3:DC:EB:87:F3:CD:3E:21:0A:9D:C4:D6:E5:02
```

#### 2.4. Tạo

Click **CREATE**

#### 2.5. Copy Client ID

Sau khi tạo, copy **Client ID** mới (dạng: `xxx-yyy.apps.googleusercontent.com`)

---

### Bước 3: Cập nhật Firebase và Download google-services.json

#### 3.1. Vào Firebase Console

1. Vào: https://console.firebase.google.com/
2. Chọn project: **readbox-3c692**
3. Click ⚙️ **Settings** → **Project settings**

#### 3.2. Thêm SHA-1 vào Firebase (Quan trọng!)

1. Scroll xuống phần **Your apps**
2. Chọn Android app: `com.hungvv.readbox`
3. Click **Add fingerprint** (hoặc vào Settings của app)
4. Paste SHA-1:
   ```
   DA:86:A9:0B:E7:58:B3:DC:EB:87:F3:CD:3E:21:0A:9D:C4:D6:E5:02
   ```
5. Click **Save**

#### 3.3. Download google-services.json mới

1. Vẫn trong Firebase Console → **Project settings** → **Your apps**
2. Chọn Android app: `com.hungvv.readbox`
3. Click **Download google-services.json** (hoặc nút Download)
4. **Thay thế** file `android/app/google-services.json` trong project

**File mới phải có cấu trúc:**
```json
{
  "oauth_client": [
    {
      "client_id": "xxx-yyy.apps.googleusercontent.com",
      "client_type": 1,  // ← Android client (PHÙ MỚI!)
      "android_info": {
        "package_name": "com.hungvv.readbox",
        "certificate_hash": "da86a90be758b3dceb87f3cd3e210a9dc4d6e502"
      }
    },
    {
      "client_id": "534175741610-np09i3oqbgpintqosdikvh6o5tl5od01.apps.googleusercontent.com",
      "client_type": 3  // Web client
    }
  ]
}
```

---

### Bước 4: (Tùy chọn) Cập nhật code

**File**: `lib/config/google_signin_config.dart`

Bạn có thể cập nhật Android Client ID mới (hoặc giữ nguyên, vì Android sẽ đọc từ google-services.json):

```dart
// Web Client ID (giữ nguyên)
static const String webClientId =
    '534175741610-np09i3oqbgpintqosdikvh6o5tl5od01.apps.googleusercontent.com';

// Android Client ID (CẬP NHẬT nếu muốn)
static const String androidClientId =
    'XXX_ANDROID_CLIENT_ID_MỚI_XXX.apps.googleusercontent.com';

// Cấu hình GoogleSignIn instance
static GoogleSignIn get googleSignIn => GoogleSignIn(
  scopes: ['email', 'profile'],
  serverClientId: webClientId, // Sử dụng Web Client ID
);
```

**Lưu ý**: Với Android, Google Sign-In sẽ **tự động đọc từ google-services.json**, nên không bắt buộc phải cập nhật code.

---

### Bước 5: Clean và Rebuild

```bash
cd /Users/username/develops/readbox/readbox

# Clean project
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter run
```

**⚠️ QUAN TRỌNG**:
1. **Uninstall app cũ** trên device/emulator
2. **Cài app mới** sau khi rebuild

---

### Bước 6: Test

1. Uninstall app cũ
2. Chạy app mới: `flutter run`
3. Thử Google Sign-In

---

## 🔍 Kiểm tra google-services.json mới

Sau khi download, mở file `android/app/google-services.json` và kiểm tra:

### ✅ Phải có Android OAuth Client:

```json
{
  "oauth_client": [
    {
      "client_id": "xxx-yyy.apps.googleusercontent.com",
      "client_type": 1,  // ← Phải có cái này!
      "android_info": {
        "package_name": "com.hungvv.readbox",
        "certificate_hash": "da86a90be758b3dceb87f3cd3e210a9dc4d6e502"
      }
    }
  ]
}
```

### ❌ Nếu chỉ có Web Client:

```json
{
  "oauth_client": [
    {
      "client_id": "534175741610-np09i3oqbgpintqosdikvh6o5tl5od01.apps.googleusercontent.com",
      "client_type": 3  // ← Chỉ có Web, THIẾU Android!
    }
  ]
}
```

→ **Phải tạo lại Android OAuth Client** và download lại `google-services.json`!

---

## 📝 Checklist:

- [ ] Đã có SHA-1: `DA:86:A9:0B:E7:58:B3:DC:EB:87:F3:CD:3E:21:0A:9D:C4:D6:E5:02`
- [ ] Đã tạo Android OAuth Client ID trong Google Cloud Console
- [ ] Package name: `com.hungvv.readbox`
- [ ] SHA-1 đã được thêm vào Android OAuth Client
- [ ] Đã thêm SHA-1 vào Firebase Console (Add fingerprint)
- [ ] Đã download `google-services.json` mới từ Firebase
- [ ] File mới có `client_type: 1` (Android client)
- [ ] Đã thay thế file cũ
- [ ] Đã clean và rebuild: `flutter clean && flutter run`
- [ ] Đã uninstall app cũ
- [ ] Đã test Google Sign-In

---

## 💡 Giải thích:

### Tại sao cần Android OAuth Client (client_type: 1)?

1. **Web Client (client_type: 3)**: Dùng cho server-side verification
2. **Android Client (client_type: 1)**: **BẮT BUỘC** cho Google Sign-In trên Android

Không có Android Client → Lỗi 12500!

### Tại sao phải có SHA-1?

Google sử dụng SHA-1 để:
- Xác minh app của bạn
- Đảm bảo chỉ app đúng mới có thể sử dụng OAuth

Không có SHA-1 → Không tạo được Android OAuth Client → Lỗi 12500!

---

## 🔗 Tham khảo:

- Google Sign-In Setup: https://developers.google.com/identity/sign-in/android/start
- OAuth Client IDs: https://console.cloud.google.com/apis/credentials
- Firebase Console: https://console.firebase.google.com/

