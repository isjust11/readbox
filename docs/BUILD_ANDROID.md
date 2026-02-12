# Hướng dẫn build app Readbox lên Android

Tài liệu này mô tả các bước build ứng dụng Flutter Readbox cho Android (APK/AAB) và thiết lập CI/CD tự động.

---

## 1. Yêu cầu môi trường

- **Flutter SDK** (phiên bản tương thích với `pubspec.yaml`, ví dụ 3.7.x)
- **Android Studio** hoặc Android SDK (command line)
- **Java 11** (đã cấu hình trong project)

Kiểm tra:

```bash
flutter doctor
flutter doctor -v
```

Đảm bảo có ít nhất: Flutter, Android toolchain.

---

## 2. Build bản Debug (chạy thử / test)

### APK debug

```bash
flutter pub get
flutter build apk --debug
```

File ra: `build/app/outputs/flutter-apk/app-debug.apk`

### Chạy trực tiếp trên thiết bị/emulator

```bash
flutter run
# hoặc
flutter run --release
```

---

## 3. Build bản Release (phân phối / Play Store)

### Bước 3.1: Tạo keystore (chỉ làm một lần)

Trên Windows (PowerShell hoặc CMD):

```bash
keytool -genkey -v -keystore android/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Điền thông tin (tên, tổ chức, mật khẩu). **Lưu ý:**

- Đặt mật khẩu và lưu lại an toàn.
- File `upload-keystore.jks` và `key.properties` **không** được commit lên Git (đã có trong `.gitignore`).

### Bước 3.2: Tạo file `key.properties`

Tạo file `android/key.properties` (nằm trong thư mục `android/`, cùng cấp với `app/`):

```properties
storePassword=<mật khẩu keystore>
keyPassword=<mật khẩu key>
keyAlias=upload
storeFile=upload-keystore.jks
```

- `storeFile`: tên file keystore (nếu đặt trong `android/` thì chỉ cần tên file như trên).

Project đã cấu hình sẵn: khi có `android/key.properties`, bản release sẽ dùng keystore này; khi không có (ví dụ CI không cấu hình secret), release sẽ fallback sang debug signing.

### Bước 3.3: Build release

```bash
flutter pub get
flutter clean
flutter build apk --release
# hoặc build AAB (khuyến nghị cho Play Store)
flutter build appbundle --release
```

- **APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **AAB**: `build/app/outputs/bundle/release/app-release.aab`

Dùng AAB khi upload lên Google Play Console.

---

## 4. Tăng version / build number

Trong `pubspec.yaml`:

```yaml
version: 1.0.0+1   # 1.0.0 = versionName, 1 = versionCode (build number)
```

Hoặc khi build:

```bash
flutter build appbundle --release --build-name=1.0.0 --build-number=2
```

---

## 5. CI/CD với GitHub Actions

Repo đã có workflow mẫu: **`.github/workflows/android-build.yml`**

### 5.1 Chạy tự động

- **Build APK + AAB** mỗi khi push lên nhánh `main` hoặc `develop`, hoặc khi tạo Pull Request.
- Artifact (APK/AAB) được upload vào job, có thể tải từ tab **Actions** của repo.

### 5.2 Build có ký release trên CI (tùy chọn)

Để CI build bản **release đã ký** (dùng cho đăng lên Play Store hoặc phân phối nội bộ):

1. **Tạo keystore** (như bước 3.1) và file `key.properties` (bước 3.2) trên máy local.
2. **Mã hóa base64 keystore** (để đưa vào GitHub Secret):

   Windows (PowerShell):

   ```powershell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("android\upload-keystore.jks")) | Set-Content keystore.base64.txt
   ```

   Linux/macOS:

   ```bash
   base64 android/upload-keystore.jks | tr -d '\n' > keystore.base64.txt
   ```

3. **Thêm GitHub Secrets** cho repo (Settings → Secrets and variables → Actions):

   | Secret name        | Mô tả                          |
   |--------------------|---------------------------------|
   | `ANDROID_KEYSTORE_BASE64` | Nội dung file `keystore.base64.txt` |
   | `ANDROID_KEYSTORE_PASSWORD` | `storePassword` trong key.properties |
   | `ANDROID_KEY_PASSWORD`     | `keyPassword` trong key.properties  |
   | `ANDROID_KEY_ALIAS`        | `keyAlias` (thường là `upload`)     |

4. Trong workflow, bỏ comment / bật phần **“Decode keystore and create key.properties”** và dùng các secret trên. Workflow mẫu đã có chỗ để bạn gắn bước này vào.

Sau khi cấu hình, workflow sẽ build bản release đã ký và artifact tải về có thể dùng để upload Play Store.

### 5.3 Chạy workflow thủ công

- Vào **Actions** → chọn workflow **Android Build** → **Run workflow**, chọn nhánh rồi chạy.

---

## 6. Tóm tắt lệnh thường dùng

| Mục đích              | Lệnh |
|------------------------|------|
| Build APK debug        | `flutter build apk --debug` |
| Build APK release      | `flutter build apk --release` |
| Build AAB release      | `flutter build appbundle --release` |
| Chạy trên thiết bị     | `flutter run` hoặc `flutter run --release` |
| Kiểm tra môi trường     | `flutter doctor -v` |

---

## 7. Lưu ý bảo mật

- **Không** commit `android/key.properties` và `android/*.keystore` (đã nằm trong `.gitignore`).
- Trên CI chỉ dùng **GitHub Secrets** (hoặc biến môi trường bảo mật tương đương) cho mật khẩu và keystore.
- Nếu dùng Google Sign-In / Firebase, nhớ thêm SHA-1 của **release keystore** vào Firebase Console (xem `docs/GET_SHA1_FOR_GOOGLE_SIGNIN.md`).

Lấy SHA-1 của release keystore:

```bash
keytool -list -v -keystore android/upload-keystore.jks -alias upload
```

Sau đó thêm fingerprint vào Firebase project của app.
