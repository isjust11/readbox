# ⚡ Sửa nhanh lỗi 12500 - THIẾU Android OAuth Client

## 🎯 Vấn đề phát hiện:

File `android/app/google-services.json` **CHỈ CÓ Web Client**, **THIẾU Android Client**!

```json
"oauth_client": [
  {
    "client_id": "534175741610-np09i3oqbgpintqosdikvh6o5tl5od01.apps.googleusercontent.com",
    "client_type": 3  // ← CHỈ CÓ Web client (type 3)
  }
]
```

**ĐÂY LÀ NGUYÊN NHÂN GÂY LỖI 12500!**

---

## ✅ Giải pháp nhanh:

### SHA-1 của bạn:
```
DA:86:A9:0B:E7:58:B3:DC:EB:87:F3:CD:3E:21:0A:9D:C4:D6:E5:02
```

---

### Bước 1: Tạo Android OAuth Client

1. **Vào Google Cloud Console**:
   https://console.cloud.google.com/apis/credentials?project=readbox-3c692

2. **Click CREATE CREDENTIALS** → **OAuth client ID**

3. **Điền thông tin**:
   - **Application type**: `Android`
   - **Name**: `Readbox Android Client`
   - **Package name**: `com.hungvv.readbox`
   - **SHA-1 certificate fingerprint**: 
     ```
     DA:86:A9:0B:E7:58:B3:DC:EB:87:F3:CD:3E:21:0A:9D:C4:D6:E5:02
     ```

4. **Click CREATE**

---

### Bước 2: Thêm SHA-1 vào Firebase

1. **Vào Firebase Console**:
   https://console.firebase.google.com/project/readbox-3c692/settings/general

2. **Scroll xuống "Your apps"** → Chọn Android app: `com.hungvv.readbox`

3. **Click "Add fingerprint"** (hoặc vào Settings icon)

4. **Paste SHA-1**:
   ```
   DA:86:A9:0B:E7:58:B3:DC:EB:87:F3:CD:3E:21:0A:9D:C4:D6:E5:02
   ```

5. **Save**

---

### Bước 3: Download google-services.json MỚI

1. **Vẫn trong Firebase Console** → **Project settings** → **Your apps**

2. **Chọn Android app**: `com.hungvv.readbox`

3. **Click icon "Download google-services.json"** (hoặc nút Download)

4. **Thay thế file** `android/app/google-services.json`

---

### Bước 4: Kiểm tra file mới

Mở `android/app/google-services.json`, **PHẢI CÓ**:

```json
{
  "oauth_client": [
    {
      "client_id": "xxx-yyy.apps.googleusercontent.com",
      "client_type": 1,  // ← PHẢI CÓ Android client (type 1)!
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

**Nếu KHÔNG CÓ `client_type: 1`** → Quay lại Bước 1!

---

### Bước 5: Clean và Rebuild

```bash
cd /Users/username/develops/readbox/readbox
flutter clean
flutter pub get
flutter run
```

**⚠️ Uninstall app cũ** trên device/emulator trước khi run!

---

### Bước 6: Test

1. Uninstall app cũ
2. Run app mới
3. Thử Google Sign-In

---

## 📋 Checklist nhanh:

- [ ] Tạo Android OAuth Client trong Google Cloud Console
- [ ] Package name: `com.hungvv.readbox`
- [ ] SHA-1: `DA:86:A9:0B:E7:58:B3:DC:EB:87:F3:CD:3E:21:0A:9D:C4:D6:E5:02`
- [ ] Thêm SHA-1 vào Firebase Console
- [ ] Download `google-services.json` mới
- [ ] File mới có `client_type: 1` (Android client)
- [ ] Thay thế file cũ
- [ ] `flutter clean && flutter run`
- [ ] Uninstall app cũ và test

---

## 💡 Tóm tắt:

**Vấn đề**: Chỉ có Web OAuth Client, thiếu Android OAuth Client

**Nguyên nhân**: Google Sign-In trên Android **BẮT BUỘC** phải có Android OAuth Client (client_type: 1)

**Giải pháp**: 
1. Tạo Android OAuth Client với SHA-1
2. Download `google-services.json` mới
3. Rebuild app

---

## 🔗 Links nhanh:

- Google Cloud Credentials: https://console.cloud.google.com/apis/credentials?project=readbox-3c692
- Firebase Console: https://console.firebase.google.com/project/readbox-3c692/settings/general

