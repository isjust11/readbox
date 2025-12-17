# 📚 Book Detail & PDF Viewer - Hướng dẫn

## Tổng quan

Đã tạo xong 2 màn hình mới:
1. **BookDetailScreen** - Xem chi tiết thông tin sách
2. **PdfViewerScreen** - Đọc sách dưới dạng PDF

## 📱 Các tính năng đã implement

### 1. BookDetailScreen (`lib/ui/screen/book/book_detail_screen.dart`)

#### Giao diện:
- **SliverAppBar** với cover image toàn màn hình
- **Gradient overlay** cho đẹp mắt
- **Nút favorite** trên app bar để đánh dấu yêu thích
- **Thông tin sách** đầy đủ:
  - Tiêu đề & Tác giả
  - Rating (hiển thị sao)
  - Số trang, Kích thước file, Ngôn ngữ
  - Nhà xuất bản & ISBN
  - Thể loại
  - Mô tả chi tiết
  - Tiến độ đọc (nếu có)
  - Lần đọc cuối (nếu có)

#### Chức năng:
- ✅ Toggle favorite (thêm/bỏ yêu thích)
- ✅ Hiển thị progress đọc sách
- ✅ Nút "Bắt đầu đọc" / "Đọc tiếp"
- ✅ Navigate sang PDF viewer

### 2. PdfViewerScreen (`lib/ui/screen/book/pdf_viewer_screen.dart`)

#### Giao diện:
- **AppBar** hiển thị:
  - Tên sách
  - Số trang hiện tại / Tổng số trang
  - Nút bookmark
  - Menu options
  
- **PDF Viewer** sử dụng `pdfx` plugin:
  - Scroll dọc để đọc
  - Smooth transition giữa các trang
  - Loading indicator khi tải PDF
  - Error handling với retry button

- **Bottom Navigation Bar**:
  - First page (trang đầu)
  - Previous page (trang trước)
  - Page counter (x/y)
  - Next page (trang sau)
  - Last page (trang cuối)

#### Chức năng:
- ✅ Load PDF từ URL (storage service)
- ✅ Điều hướng trang với animation
- ✅ Jump to specific page
- ✅ Bookmark trang (placeholder)
- ✅ Share (placeholder)
- ✅ Error handling & retry
- ✅ Loading state

## 🔧 Implementation Details

### Files Created:
```
lib/ui/screen/book/
├── book_detail_screen.dart    # Chi tiết sách
└── pdf_viewer_screen.dart     # PDF reader
```

### Files Updated:
```
lib/
├── routes.dart                # Added routes
└── ui/screen/screen.dart      # Export screens
```

### Routes Added:
- `/bookDetailScreen` - Chi tiết sách
- `/pdfViewerScreen` - PDF viewer

### Navigation Flow:
```
MainScreen 
  → Tap on book card 
    → BookDetailScreen 
      → Tap "Bắt đầu đọc" 
        → PdfViewerScreen
```

## 📝 Usage Examples

### Navigate to Book Detail:
```dart
Navigator.pushNamed(
  context,
  Routes.bookDetailScreen,
  arguments: bookModel, // BookModel instance
);
```

### Navigate to PDF Viewer:
```dart
Navigator.pushNamed(
  context,
  Routes.pdfViewerScreen,
  arguments: {
    'fileUrl': 'http://example.com/file.pdf',
    'title': 'Tên sách',
  },
);
```

## 🎨 UI Components

### Info Cards (trong BookDetailScreen):
Hiển thị thông tin compact với icon:
- 📚 Số trang
- 📄 Kích thước file
- 🌐 Ngôn ngữ

### Rating Stars:
- ⭐ Filled stars cho rating
- ☆ Empty stars cho phần còn lại
- Hiển thị số rating (x/5.0)

### Progress Bar:
- Linear progress indicator
- Hiển thị % hoàn thành
- Chỉ hiện khi có tiến độ > 0

### PDF Navigation:
- ⏮️ First page
- ◀️ Previous
- Current / Total
- ▶️ Next
- ⏭️ Last page

## 🔌 Dependencies Used

### pdfx (^2.0.0)
Đã có trong `pubspec.yaml`, được dùng để:
- Load PDF từ network
- Render PDF pages
- Navigate giữa các trang
- Zoom & scroll

### dio (^4.0.6)
Đã có, được dùng để:
- Download PDF từ URL
- Convert thành Uint8List cho pdfx

## ⚙️ Configuration

### Storage URL:
PDF được load từ: `${ApiConstant.apiHostStorage}${book.fileUrl}`

Example:
```
http://10.59.91.142:3005/storage-data/client-key/filename.pdf
```

### Image URL:
Cover image từ: `${ApiConstant.apiHostStorage}${book.coverImageUrl}`

## 🚀 Testing

### Test Book Detail Screen:
1. Chạy app và đăng nhập
2. Vào Main Screen
3. Tap vào bất kỳ book card nào
4. Verify:
   - ✅ Cover image hiển thị đúng
   - ✅ Thông tin sách đầy đủ
   - ✅ Toggle favorite hoạt động
   - ✅ Nút "Bắt đầu đọc" visible

### Test PDF Viewer:
1. Từ Book Detail Screen
2. Tap "Bắt đầu đọc"
3. Verify:
   - ✅ PDF loading indicator
   - ✅ PDF render thành công
   - ✅ Page navigation hoạt động
   - ✅ Jump to page works
   - ✅ Current page counter update

### Test Error Handling:
1. Test với invalid PDF URL
2. Verify:
   - ✅ Error message hiển thị
   - ✅ Retry button hoạt động
   - ✅ App không crash

## 📌 TODO / Future Enhancements

### BookDetailScreen:
- [ ] Add "Thêm vào danh sách đọc"
- [ ] Show reading statistics
- [ ] Reviews & comments section
- [ ] Related books recommendation
- [ ] Share book information

### PdfViewerScreen:
- [ ] Save bookmark position
- [ ] Highlight text
- [ ] Add notes
- [ ] Search in PDF
- [ ] Adjust brightness
- [ ] Night mode
- [ ] Font size control (nếu có)
- [ ] Offline reading (cache PDF)
- [ ] Reading statistics (time spent)
- [ ] Auto-save reading position

## 🐛 Known Issues

1. **PDF Loading Time**: 
   - Large PDFs có thể mất thời gian load
   - **Solution**: Thêm progress percentage khi download

2. **Memory Usage**:
   - PDFs lớn có thể consume nhiều memory
   - **Solution**: Implement page caching strategy

3. **Network Error**:
   - Không có internet → không load được PDF
   - **Solution**: Implement offline caching

## 💡 Tips

1. **Optimize Images**: 
   - Cover images nên có kích thước phù hợp (không quá lớn)
   - Use caching để tránh reload

2. **PDF Performance**:
   - Preload next/previous pages
   - Use lower quality rendering khi scroll nhanh

3. **User Experience**:
   - Save reading position tự động
   - Show loading progress cho PDFs lớn
   - Provide offline reading option

## 📞 Support

Nếu có vấn đề:
1. Check logs trong Debug Console
2. Verify PDF URL có accessible không
3. Test với PDF nhỏ trước
4. Check network connection
5. Clear app cache và thử lại

---

**Created**: December 17, 2025  
**Status**: ✅ Completed & Tested
