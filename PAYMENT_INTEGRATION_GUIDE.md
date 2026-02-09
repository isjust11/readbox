# 🚀 Hướng Dẫn Tích Hợp Thanh Toán Online - ReadBox

## 📋 Tổng quan

Tài liệu này hướng dẫn chi tiết cách tích hợp thanh toán online (VNPay, MoMo, ZaloPay) cho ứng dụng ReadBox.

## 🔄 Luồng thanh toán

```
User chọn gói → Chọn phương thức → API tạo payment → Mở WebView → User thanh toán
    ↓                                                                      ↓
IPN webhook verify ← Payment Gateway → Callback về app
    ↓                                       ↓
Activate subscription              Hiển thị kết quả
```

---

## 🛠️ PHẦN 1: BACKEND SETUP

### Bước 1: Đăng ký tài khoản VNPay Sandbox

1. Truy cập: https://sandbox.vnpayment.vn/
2. Đăng ký tài khoản test
3. Lấy thông tin:
   - `TMN_CODE`: Mã merchant
   - `HASH_SECRET`: Secret key để tạo secure hash

### Bước 2: Cấu hình môi trường

Cập nhật file `.env`:

```env
# VNPay Configuration
VNPAY_TMN_CODE=YOUR_TMN_CODE_HERE
VNPAY_HASH_SECRET=YOUR_HASH_SECRET_HERE
VNPAY_URL=https://sandbox.vnpayment.vn/paymentv2/vpcpay.html
VNPAY_RETURN_URL=http://localhost:4000/payment/vnpay/callback
VNPAY_IPN_URL=https://your-domain.com/payment/vnpay/ipn
```

**Lưu ý:**
- `VNPAY_RETURN_URL`: URL callback cho app (có thể là localhost khi test)
- `VNPAY_IPN_URL`: URL webhook PHẢI là domain public (dùng ngrok cho local test)

### Bước 3: Cài đặt dependencies

```bash
cd codebase-admin
npm install crypto moment qs uuid
npm install @types/crypto-js --save-dev
```

### Bước 4: Chạy migration database

Thêm các field mới vào entity `Payment`:
- `planId` (nullable)
- `gatewayTransactionId` (nullable)
- `paymentUrl` (text, nullable)
- `ipAddress` (nullable)
- `paidAt` (nullable)

```bash
npm run migration:generate -- src/migrations/AddPaymentFields
npm run migration:run
```

### Bước 5: Đăng ký services và controllers

Trong `app.module.ts`:

```typescript
import { VNPayService } from './services/vnpay.service';
import { PaymentService } from './services/payment.service';
import { PaymentController } from './controllers/payment/payment.controller';

@Module({
  imports: [...],
  controllers: [
    ...,
    PaymentController,
  ],
  providers: [
    ...,
    VNPayService,
    PaymentService,
  ],
})
export class AppModule {}
```

### Bước 6: Test Backend API

Sử dụng Postman:

**1. Tạo payment:**
```http
POST http://localhost:4000/payment/create
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json

{
  "planId": 1,
  "paymentMethod": "vnpay",
  "bankCode": "VNBANK"
}
```

Response:
```json
{
  "paymentId": 1,
  "transactionId": "TXN1738988234ABC123",
  "paymentUrl": "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?...",
  "amount": 99000
}
```

**2. Kiểm tra trạng thái:**
```http
GET http://localhost:4000/payment/TXN1738988234ABC123/status
Authorization: Bearer YOUR_JWT_TOKEN
```

### Bước 7: Test IPN với ngrok (local)

```bash
# Cài ngrok: https://ngrok.com/
ngrok http 4000
```

Lấy URL public (VD: `https://abc123.ngrok.io`) và cập nhật `.env`:
```env
VNPAY_IPN_URL=https://abc123.ngrok.io/payment/vnpay/ipn
```

---

## 📱 PHẦN 2: FLUTTER APP SETUP

### Bước 1: Cài đặt packages

```bash
cd readbox
flutter pub add webview_flutter url_launcher
```

### Bước 2: Cấu hình Android

`android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
  <application>
    <!-- ... -->
    
    <!-- Deep link cho payment callback -->
    <activity android:name=".MainActivity">
      <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        
        <!-- Scheme cho callback -->
        <data
          android:scheme="readbox"
          android:host="payment" />
      </intent-filter>
    </activity>
  </application>
  
  <!-- Permission internet -->
  <uses-permission android:name="android.permission.INTERNET" />
</manifest>
```

### Bước 3: Cấu hình iOS

`ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>com.readbox.app</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>readbox</string>
    </array>
  </dict>
</array>

<!-- WebView -->
<key>io.flutter.embedded_views_preview</key>
<true/>
```

### Bước 4: Test Flow trong app

**Flow test:**
1. Mở app → Cài đặt → Gói dịch vụ
2. Chọn gói → Chọn phương thức thanh toán (VNPay)
3. WebView mở → Nhập thông tin thẻ test VNPay:
   - Số thẻ: `9704198526191432198`
   - Tên: `NGUYEN VAN A`
   - Ngày phát hành: `07/15`
   - Mật khẩu OTP: `123456`
4. Thanh toán thành công → Callback về app → Hiển thị kết quả

---

## 🧪 TESTING

### Test Cases

#### 1. Thanh toán thành công
- Chọn gói → VNPay → Nhập thông tin đúng → OTP → Success
- ✅ Payment status = `completed`
- ✅ UserSubscription status = `active`
- ✅ ExpiresAt được set đúng

#### 2. Thanh toán thất bại
- Chọn gói → VNPay → Nhập sai OTP hoặc hủy
- ✅ Payment status = `failed`
- ✅ Không tạo subscription

#### 3. Timeout
- Chọn gói → Mở WebView → Không thao tác trong 15 phút
- ✅ Payment expired
- ✅ Cho phép thử lại

#### 4. Duplicate IPN
- Backend nhận 2 lần IPN với cùng transactionId
- ✅ Chỉ xử lý 1 lần (check payment.status !== 'pending')

#### 5. Fake callback
- User fake URL callback với status=success
- ✅ Backend IPN verify hash → Chỉ activate khi IPN hợp lệ

### Thẻ test VNPay Sandbox

| Ngân hàng | Số thẻ | Tên | Ngày | OTP |
|-----------|--------|-----|------|-----|
| NCB | 9704198526191432198 | NGUYEN VAN A | 07/15 | 123456 |
| VietinBank | 9704198526191432198 | NGUYEN VAN B | 07/15 | 123456 |

---

## 🔐 BẢO MẬT

### 1. Không tin tưởng callback từ app
- ✅ Chỉ dựa vào IPN webhook để activate subscription
- ✅ Callback về app chỉ để hiển thị UI

### 2. Verify signature
- ✅ Luôn verify `vnp_SecureHash` với HASH_SECRET
- ✅ Kiểm tra amount, orderId khớp với DB

### 3. HTTPS
- ✅ Production PHẢI dùng HTTPS cho IPN URL
- ✅ Không expose HASH_SECRET ra ngoài

### 4. Rate limiting
- ✅ Giới hạn số lần tạo payment / user / phút
- ✅ Tránh spam API

### 5. Logging
- ✅ Log tất cả IPN request (để audit)
- ✅ Không log HASH_SECRET

---

## 🚀 GO LIVE

### Checklist Production

#### Backend
- [ ] Đổi VNPAY_URL sang production: `https://pay.vnpayment.vn/vpcpay.html`
- [ ] Cập nhật VNPAY_TMN_CODE và HASH_SECRET thật
- [ ] VNPAY_IPN_URL là HTTPS domain thật
- [ ] VNPAY_RETURN_URL về app scheme: `readbox://payment/result`
- [ ] Enable rate limiting
- [ ] Setup logging & monitoring (Sentry, LogRocket)
- [ ] Test trên môi trường staging trước

#### Frontend
- [ ] Test deep link trên thiết bị thật (Android + iOS)
- [ ] Test WebView trên nhiều phiên bản OS
- [ ] Handle network error gracefully
- [ ] Add analytics tracking (payment_initiated, payment_success, payment_failed)

#### VNPay
- [ ] Đăng ký merchant production
- [ ] Ký hợp đồng
- [ ] Cung cấp IPN URL production
- [ ] Whitelist domain/IP của server

---

## 🆘 TROUBLESHOOTING

### Lỗi "Invalid Signature"
- ✅ Check HASH_SECRET đúng chưa
- ✅ Params có đúng thứ tự alphabet không
- ✅ Encoding UTF-8

### IPN không được gọi
- ✅ IPN URL phải public (không localhost)
- ✅ Port 443 (HTTPS) hoặc 80 (HTTP - sandbox)
- ✅ Check firewall, security group

### WebView không mở
- ✅ Check permission INTERNET
- ✅ iOS: `io.flutter.embedded_views_preview = true`
- ✅ Payment URL có valid không

### Callback không về app
- ✅ Deep link scheme đã config chưa (`readbox://`)
- ✅ Test với `adb shell am start -a android.intent.action.VIEW -d "readbox://payment/result?status=success"`

---

## 📞 HỖ TRỢ

### VNPay
- Hotline: 1900 55 55 77
- Email: support@vnpay.vn
- Docs: https://sandbox.vnpayment.vn/apis/

### Team
- Backend: [Backend dev contact]
- Mobile: [Mobile dev contact]
- DevOps: [DevOps contact]

---

## 📚 TÀI LIỆU THAM KHẢO

- [VNPay API Documentation](https://sandbox.vnpayment.vn/apis/)
- [Flutter WebView Plugin](https://pub.dev/packages/webview_flutter)
- [Deep Linking Flutter](https://docs.flutter.dev/ui/navigation/deep-linking)
- [NestJS Payment Best Practices](https://docs.nestjs.com/)

---

**Lưu ý:** Tài liệu này được cập nhật lần cuối: 2026-02-09
