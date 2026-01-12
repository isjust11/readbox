# 🚨 Fix: SERVICE_NOT_AVAILABLE Error

## ❌ Lỗi

```
java.io.IOException: java.util.concurrent.ExecutionException: 
java.io.IOException: SERVICE_NOT_AVAILABLE
```

**Xảy ra khi:** Get FCM token trong `auth_cubit.dart`

---

## 🔍 Nguyên nhân

1. **Google Play Services không có** trên device/emulator
2. **Google Play Services quá cũ** (< version 20.x)
3. **Internet không khả dụng**
4. **Google Play Services bị disabled**
5. **Emulator không có Play Store**

---

## ✅ Đã Fix

### Update 1: Added Retry Logic

File: `lib/blocs/auth/auth_cubit.dart`

**Thay đổi:**
- ✅ Retry 3 lần nếu fail
- ✅ Timeout 10s cho mỗi attempt
- ✅ Wait 2-4-6 giây giữa các retry
- ✅ Log chi tiết để debug
- ✅ Detect SERVICE_NOT_AVAILABLE error

**Code mới:**
```dart
Future<String?> _getFCMToken() async {
  for (int attempt = 1; attempt <= 3; attempt++) {
    try {
      final token = await _messaging.getToken()
        .timeout(Duration(seconds: 10));
      if (token != null) return token;
      await Future.delayed(Duration(seconds: attempt * 2));
    } catch (e) {
      if (e.toString().contains('SERVICE_NOT_AVAILABLE')) {
        print('Google Play Services not available!');
      }
    }
  }
  return null;
}
```

---

## 🔧 Giải pháp

### Solution 1: Check Device/Emulator

#### Bạn đang dùng gì?

**A. Android Emulator:**

```bash
# 1. Check có Play Store không?
# Mở emulator → Tìm icon "Play Store" trong app drawer

# 2. Nếu KHÔNG có Play Store:
# → PHẢI TẠO EMULATOR MỚI!

# Android Studio → Device Manager → Create Virtual Device
# Chọn device có LOGO PLAY STORE (ví dụ: Pixel 6)
# Download system image có Play Store
```

**B. Real Android Device:**

```bash
# Settings → Apps → Tìm "Google Play services"

# Nếu có:
# → Click vào → Check version (nên >= 20.x.x)
# → Nếu cũ: Play Store → Update

# Nếu không có:
# → Device không support (hiếm gặp)
```

---

### Solution 2: Check Internet

```bash
# Test trên device/emulator:
# 1. Mở Chrome/Browser
# 2. Vào google.com
# 3. Nếu không load được → Fix internet trước

# Emulator internet issue:
# Settings → Network & Internet → Check Wifi
# Hoặc restart emulator
```

---

### Solution 3: Update Google Play Services

```bash
# Trên device/emulator:
1. Mở Play Store
2. Tìm "Google Play services"
3. Nếu có "Update" button → Click Update
4. Chờ update xong
5. Restart app và thử lại
```

---

### Solution 4: Clear Google Play Services Cache

```bash
Settings → Apps → Google Play services
→ Storage → Clear Cache (không phải Clear Data)
→ Restart app
```

---

### Solution 5: Hot Restart App

```bash
# Trong terminal đang chạy app:
# Press 'r' để hot restart

# Hoặc:
flutter run
```

---

## 📋 Testing Checklist

Sau khi apply fix, test lại:

### Expected Logs (Success):
```
🔍 Attempting to get FCM token...
   Attempt 1/3...
✅ FCM token retrieved: eyJhbGciOiJFUzI1NiIs...
```

### Expected Logs (Still Failing):
```
🔍 Attempting to get FCM token...
   Attempt 1/3...
   ❌ Attempt 1 failed: SERVICE_NOT_AVAILABLE
   ⚠️ Google Play Services not available!
   → Check if device has Google Play Services
   Attempt 2/3...
   ❌ Attempt 2 failed: SERVICE_NOT_AVAILABLE
   Attempt 3/3...
   ❌ Attempt 3 failed: SERVICE_NOT_AVAILABLE
❌ Failed to get FCM token after 3 attempts
```

**Nếu vẫn fail sau 3 attempts:**
→ Chắc chắn là Google Play Services issue!

---

## 🎯 Quick Fix Steps

### CÁCH NHANH NHẤT:

1. **Kiểm tra emulator:**
   ```
   Device có icon "Play Store"? 
   → YES: Continue step 2
   → NO: Tạo emulator mới với Play Store
   ```

2. **Hot restart app:**
   ```bash
   # Press 'r' trong terminal
   # Hoặc: flutter run
   ```

3. **Login lại:**
   ```
   App sẽ tự retry 3 lần để get token
   Check logs xem có token không
   ```

4. **Nếu vẫn lỗi:**
   ```bash
   # Tạo emulator MỚI với Play Store
   # Android Studio → Tools → Device Manager
   # Create Virtual Device → Chọn device có logo Play Store
   ```

---

## 🔍 Advanced Debugging

### Add More Debug Info

Thêm vào `auth_cubit.dart` (tạm thời):

```dart
import 'dart:io';

Future<String?> _getFCMToken() async {
  // Check platform
  print('📱 Platform: ${Platform.operatingSystem}');
  print('📱 Version: ${Platform.operatingSystemVersion}');
  
  // Check Firebase initialized
  print('🔥 Firebase apps: ${Firebase.apps.length}');
  
  // Your existing code...
}
```

### Check Google Play Services from ADB

```bash
# Check if Google Play Services installed
adb shell pm list packages | findstr google

# Should see:
# package:com.google.android.gms (Google Play Services)
```

---

## 💡 Pro Tips

### 1. Luôn dùng Emulator có Play Store
```
✅ Pixel 6 (with Play Store)
✅ Pixel 5 (with Play Store)
❌ Pixel 6 (without Play Store)
```

### 2. Test trên Real Device
Real device thường ít lỗi hơn emulator

### 3. Check Firebase Console
Firebase Console → Cloud Messaging → Verify enabled

### 4. Network Issue?
```dart
// Test network connectivity
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivity = await Connectivity().checkConnectivity();
print('Network: $connectivity');
```

---

## 📊 Common Scenarios

### Scenario A: Emulator không có Play Store
**Symptoms:**
- SERVICE_NOT_AVAILABLE error
- Không thấy Play Store icon
- Google Play Services app không có

**Fix:**
- Tạo emulator mới WITH Play Store
- KHÔNG THỂ add Play Store vào emulator cũ

### Scenario B: Internet Issue
**Symptoms:**
- Timeout after 10s
- SERVICE_NOT_AVAILABLE sau khi timeout

**Fix:**
- Check wifi/mobile data
- Restart emulator
- Test browser xem có internet không

### Scenario C: Google Play Services Outdated
**Symptoms:**
- SERVICE_NOT_AVAILABLE
- Google Play Services version < 20.x

**Fix:**
- Play Store → Update Google Play Services
- Restart device
- Retry

---

## ✅ Verification

### Success Criteria:

1. **No more SERVICE_NOT_AVAILABLE error**
2. **Token retrieved within 10s**
3. **Login successful with token sent to backend**
4. **Can receive notifications**

### Test Flow:

```bash
1. Start app
2. Login
3. Check logs for FCM token
4. Verify token sent to backend
5. Send test notification
6. Verify notification received
```

---

## 🆘 If Still Not Working

### Last Resort:

1. **Create NEW emulator:**
   - Android Studio → Device Manager
   - Create Virtual Device
   - Choose Pixel 6 API 33 (with Play Store)
   - Download system image if needed
   - Launch and test

2. **Test on Real Device:**
   - Enable USB debugging
   - Connect to computer
   - `flutter run`
   - Should work better than emulator

3. **Check Firebase Project:**
   - Firebase Console → readbox-3c692
   - Cloud Messaging → Verify enabled
   - Check quota/limits

4. **Clean Everything:**
   ```bash
   flutter clean
   flutter pub get
   cd android
   gradlew clean
   cd ..
   flutter run
   ```

---

## 📞 Summary

**Problem:** SERVICE_NOT_AVAILABLE when getting FCM token

**Root Cause:** Google Play Services không available hoặc internet issue

**Solution:** 
1. ✅ Added retry logic (3 attempts)
2. Use emulator WITH Play Store
3. Ensure internet connection
4. Update Google Play Services

**Expected Result:** Token retrieved successfully within 3 attempts

---

**Status:** ✅ Code Updated  
**Next:** Test lại và check logs  
**Time:** ~10 minutes

Good luck! 🚀
