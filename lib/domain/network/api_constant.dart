class ApiConstant {
  static final apiHost = "http://192.168.1.8:4000/";
  static final apiHostStorage = "http://192.168.1.8:3005";
  static final storageServiceUrl = "http://localhost:3005"; // Storage service URL
  static final login = "auth/login";
  static final register = "auth/register";
  static final getUserInfo = "";
  
  // Book endpoints
  static final getBooksPublic =  "books/public";
  static final getBooks =  "books/search";
  static final addBook = "books";
  static final updateBook = "books";
  static final deleteBook = "books";
  static final toggleFavorite = "books/favorite";
  
  // Chapter endpoints
  static final getChapters = "books";
  
  // Bookmark endpoints
  static final getBookmarks = "bookmarks";
  static final addBookmark = "bookmarks";
  static final deleteBookmark = "bookmarks";
  
  // Reading progress endpoints
  static final saveReadingProgress = "reading-progress";
  static final getReadingProgress = "reading-progress";

  // Admin endpoints
  static final uploadEbook = "upload/ebook";
  static final uploadCover = "upload/image";
  static final getCategories = "categories";
}
