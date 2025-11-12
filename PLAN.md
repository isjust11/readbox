# Kế Hoạch Phát Triển Ứng Dụng Đọc và Quản Lý Ebook - ReadBox

## 📋 Tổng Quan Dự Án

Ứng dụng ReadBox là một ứng dụng Flutter để đọc và quản lý ebook với các tính năng:
- Quản lý thư viện sách (thêm, xóa, sắp xếp, tìm kiếm)
- Đọc sách với trải nghiệm tốt (điều hướng, bookmark, ghi chú)
- Quản lý metadata (tác giả, thể loại, đánh giá)
- Đồng bộ và lưu trữ local/cloud
- UI/UX hiện đại và thân thiện

---

## 🏗️ Kiến Trúc Hiện Tại

Dự án đã có:
- ✅ Clean Architecture (Domain, Data layers)
- ✅ BLoC pattern cho state management
- ✅ Dependency Injection (GetIt)
- ✅ Authentication (Login, Register)
- ✅ i18n support (Tiếng Việt, Tiếng Anh)
- ✅ Routing system
- ✅ Base widgets và utilities

---

## 📦 Các Bước Phát Triển

### **GIAI ĐOẠN 1: Thiết Lập Cơ Sở Hạ Tầng (Foundation)**

#### 1.1. Cài Đặt Dependencies Cần Thiết
- [ ] **epub_kitty** hoặc **flutter_epub** - Đọc file EPUB
- [ ] **pdfx** hoặc **syncfusion_flutter_pdfviewer** - Đọc file PDF
- [ ] **sqflite** hoặc **hive** - Database local để lưu metadata
- [ ] **path_provider** - Quản lý đường dẫn file
- [ ] **file_picker** - Chọn file từ thiết bị
- [ ] **permission_handler** - Quyền truy cập file
- [ ] **flutter_cache_manager** - Cache ảnh và tài nguyên
- [ ] **share_plus** - Chia sẻ sách (đã có)
- [ ] **flutter_tts** (tùy chọn) - Text-to-speech

#### 1.2. Cấu Trúc Thư Mục Domain Layer
```
lib/domain/
  ├── entities/
  │   ├── book_entity.dart
  │   ├── chapter_entity.dart
  │   ├── bookmark_entity.dart
  │   ├── reading_progress_entity.dart
  │   └── category_entity.dart
  ├── repositories/
  │   ├── book_repository.dart
  │   ├── library_repository.dart
  │   └── reading_repository.dart
  └── usecases/
      ├── book/
      │   ├── add_book_usecase.dart
      │   ├── delete_book_usecase.dart
      │   ├── get_book_list_usecase.dart
      │   └── search_books_usecase.dart
      ├── reading/
      │   ├── save_reading_progress_usecase.dart
      │   ├── get_reading_progress_usecase.dart
      │   └── save_bookmark_usecase.dart
      └── library/
          ├── organize_books_usecase.dart
          └── filter_books_usecase.dart
```

#### 1.3. Cấu Trúc Thư Mục Data Layer
```
lib/domain/data/
  ├── datasources/
  │   ├── local/
  │   │   ├── book_local_data_source.dart
  │   │   ├── library_local_data_source.dart
  │   │   └── reading_local_data_source.dart
  │   └── remote/ (nếu có backend)
  │       └── book_remote_data_source.dart
  ├── models/
  │   ├── book_model.dart
  │   ├── chapter_model.dart
  │   ├── bookmark_model.dart
  │   └── reading_progress_model.dart
  └── repositories/
      ├── book_repository_impl.dart
      ├── library_repository_impl.dart
      └── reading_repository_impl.dart
```

---

### **GIAI ĐOẠN 2: Core Features - Quản Lý Thư Viện**

#### 2.1. Entity và Model
- [ ] Tạo `BookEntity` với các thuộc tính:
  - id, title, author, description, coverImage
  - filePath, fileType (EPUB, PDF), fileSize
  - categories, tags, rating
  - dateAdded, lastRead, totalPages
  - isFavorite, isArchived

- [ ] Tạo `ChapterEntity` cho EPUB
- [ ] Tạo `BookmarkEntity`
- [ ] Tạo `ReadingProgressEntity`
- [ ] Tạo các Model tương ứng

#### 2.2. Local Data Source
- [ ] Setup database (SQLite hoặc Hive)
- [ ] Implement CRUD operations cho Book
- [ ] Implement search và filter
- [ ] Implement file management (copy, delete files)

#### 2.3. Repository Implementation
- [ ] Implement `BookRepository`
- [ ] Implement `LibraryRepository`
- [ ] Handle errors và exceptions

#### 2.4. BLoC/Cubit
- [ ] `LibraryCubit` - Quản lý danh sách sách
- [ ] `BookDetailCubit` - Chi tiết sách
- [ ] `SearchCubit` - Tìm kiếm sách
- [ ] `CategoryCubit` - Quản lý thể loại

#### 2.5. UI Screens
- [ ] **LibraryScreen** - Màn hình thư viện chính
  - Grid/List view
  - Sort options (theo tên, ngày thêm, tác giả)
  - Filter (thể loại, đã đọc/chưa đọc, yêu thích)
  - Search bar
  
- [ ] **BookDetailScreen** - Chi tiết sách
  - Hiển thị metadata
  - Nút đọc sách
  - Nút thêm vào yêu thích
  - Xóa sách
  - Chia sẻ

- [ ] **AddBookScreen** - Thêm sách mới
  - File picker
  - Import từ thư mục
  - Drag & drop (desktop)

---

### **GIAI ĐOẠN 3: Reader Features - Đọc Sách**

#### 3.1. EPUB Reader
- [ ] Setup EPUB parser
- [ ] Render HTML content
- [ ] Navigation (next/previous chapter, page)
- [ ] Table of contents
- [ ] Text selection và highlight
- [ ] Bookmark functionality
- [ ] Reading progress tracking

#### 3.2. PDF Reader
- [ ] Setup PDF viewer
- [ ] Page navigation
- [ ] Zoom in/out
- [ ] Bookmark
- [ ] Reading progress

#### 3.3. Reader Settings
- [ ] Font size adjustment
- [ ] Font family selection
- [ ] Theme (light/dark/sepia)
- [ ] Line spacing
- [ ] Margin adjustment
- [ ] Brightness control

#### 3.4. Reader UI
- [ ] **ReaderScreen** - Màn hình đọc chính
  - Toolbar (ẩn/hiện khi tap)
  - Progress indicator
  - Chapter navigation
  - Settings panel
  - Bookmark button
  
- [ ] **ReaderSettingsBottomSheet** - Cài đặt đọc
- [ ] **TableOfContentsDrawer** - Mục lục
- [ ] **BookmarkListScreen** - Danh sách bookmark

#### 3.5. BLoC/Cubit
- [ ] `ReaderCubit` - Quản lý trạng thái đọc
- [ ] `ReaderSettingsCubit` - Cài đặt đọc
- [ ] `BookmarkCubit` - Quản lý bookmark

---

### **GIAI ĐOẠN 4: Advanced Features**

#### 4.1. Metadata Management
- [ ] Extract metadata từ file (EPUB metadata, PDF info)
- [ ] Edit metadata (title, author, description)
- [ ] Cover image extraction/editing
- [ ] Categories và tags management

#### 4.2. Statistics & Analytics
- [ ] Reading statistics screen
  - Số sách đã đọc
  - Tổng thời gian đọc
  - Sách đang đọc
  - Reading streak
  - Pages read per day/week/month

#### 4.3. Organization
- [ ] Collections/Shelves - Tạo bộ sưu tập
- [ ] Tags system
- [ ] Custom sorting
- [ ] Archive feature

#### 4.4. Search & Discovery
- [ ] Full-text search trong sách
- [ ] Search trong metadata
- [ ] Recent searches
- [ ] Search suggestions

---

### **GIAI ĐOẠN 5: Data Persistence & Sync**

#### 5.1. Local Storage
- [ ] Database schema design
- [ ] Migration strategy
- [ ] Backup/Restore local data
- [ ] Cache management

#### 5.2. Cloud Sync (Optional - nếu có backend)
- [ ] Authentication với backend
- [ ] Upload/download books
- [ ] Sync reading progress
- [ ] Sync bookmarks
- [ ] Conflict resolution

---

### **GIAI ĐOẠN 6: UI/UX Enhancement**

#### 6.1. Design System
- [ ] Color scheme cho reader
- [ ] Typography system
- [ ] Icon set
- [ ] Animation transitions

#### 6.2. Responsive Design
- [ ] Tablet layout
- [ ] Desktop layout (nếu support)
- [ ] Adaptive UI components

#### 6.3. Accessibility
- [ ] Screen reader support
- [ ] High contrast mode
- [ ] Font scaling
- [ ] Keyboard navigation

---

### **GIAI ĐOẠN 7: Performance & Optimization**

#### 7.1. Performance
- [ ] Lazy loading cho danh sách sách
- [ ] Image caching
- [ ] Memory management
- [ ] File parsing optimization

#### 7.2. Testing
- [ ] Unit tests cho usecases
- [ ] Widget tests cho UI components
- [ ] Integration tests cho flows chính

---

### **GIAI ĐOẠN 8: Polish & Release**

#### 8.1. Final Touches
- [ ] Error handling improvements
- [ ] Loading states
- [ ] Empty states
- [ ] Onboarding flow

#### 8.2. Documentation
- [ ] Code documentation
- [ ] User guide (nếu cần)
- [ ] README update

#### 8.3. Release Preparation
- [ ] App icons và splash screen
- [ ] Store listings
- [ ] Privacy policy
- [ ] Terms of service

---

## 🎯 Ưu Tiên Phát Triển (MVP)

### MVP - Minimum Viable Product
1. ✅ Authentication (đã có)
2. ⭐ Thêm sách từ file (EPUB, PDF)
3. ⭐ Hiển thị thư viện sách
4. ⭐ Đọc sách cơ bản (EPUB)
5. ⭐ Lưu tiến độ đọc
6. ⭐ Bookmark
7. ⭐ Tìm kiếm sách

### Phase 2 - Enhanced Features
- PDF reader
- Reader settings (font, theme)
- Statistics
- Collections
- Full-text search

### Phase 3 - Advanced Features
- Cloud sync
- Metadata editing
- Advanced organization
- Social features (nếu có)

---

## 📝 Notes & Considerations

### Technical Decisions
- **Database**: SQLite (sqflite) cho structured data, Hive cho simple key-value
- **File Format Support**: Bắt đầu với EPUB, sau đó thêm PDF
- **State Management**: Tiếp tục dùng BLoC/Cubit
- **Architecture**: Giữ Clean Architecture hiện tại

### Challenges
- EPUB parsing có thể phức tạp (HTML rendering, CSS)
- PDF rendering performance trên mobile
- Memory management với nhiều sách lớn
- File permission trên Android/iOS

### Dependencies Cần Thêm
```yaml
dependencies:
  # EPUB Reader
  epubx: ^3.0.0  # hoặc flutter_epub: ^x.x.x
  
  # PDF Reader
  pdfx: ^2.0.0  # hoặc syncfusion_flutter_pdfviewer
  
  # Database
  sqflite: ^2.3.0
  path_provider: ^2.1.0
  
  # File Management
  file_picker: ^6.1.1
  permission_handler: ^11.0.0
  
  # Utilities
  flutter_cache_manager: ^3.3.1
  path: ^1.8.3
  uuid: ^4.0.0
```

---

## 🚀 Bắt Đầu Ngay

### Bước Đầu Tiên (Ngay Bây Giờ)
1. Cài đặt dependencies cần thiết
2. Tạo BookEntity và BookModel
3. Setup database schema
4. Tạo LibraryScreen cơ bản
5. Implement file picker để thêm sách

---

## 📊 Timeline Ước Tính

- **Giai đoạn 1-2**: 2-3 tuần (Foundation + Library Management)
- **Giai đoạn 3**: 2-3 tuần (Reader Features)
- **Giai đoạn 4-5**: 2-3 tuần (Advanced Features + Sync)
- **Giai đoạn 6-8**: 1-2 tuần (Polish + Release)

**Tổng cộng**: ~7-11 tuần cho MVP hoàn chỉnh

---

*Kế hoạch này có thể được điều chỉnh dựa trên tiến độ và yêu cầu thực tế.*

