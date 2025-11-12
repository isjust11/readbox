import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('readbox.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Books table
    await db.execute('''
      CREATE TABLE books (
        id TEXT PRIMARY KEY,
        title TEXT,
        author TEXT,
        description TEXT,
        coverImagePath TEXT,
        filePath TEXT NOT NULL,
        fileType TEXT,
        fileSize INTEGER,
        categories TEXT,
        tags TEXT,
        rating REAL,
        dateAdded TEXT,
        lastRead TEXT,
        totalPages INTEGER,
        isFavorite INTEGER DEFAULT 0,
        isArchived INTEGER DEFAULT 0,
        publisher TEXT,
        isbn TEXT,
        language TEXT
      )
    ''');

    // Chapters table
    await db.execute('''
      CREATE TABLE chapters (
        id TEXT PRIMARY KEY,
        bookId TEXT NOT NULL,
        title TEXT,
        orderIndex INTEGER,
        content TEXT,
        startPage INTEGER,
        endPage INTEGER,
        href TEXT,
        FOREIGN KEY (bookId) REFERENCES books (id) ON DELETE CASCADE
      )
    ''');

    // Bookmarks table
    await db.execute('''
      CREATE TABLE bookmarks (
        id TEXT PRIMARY KEY,
        bookId TEXT NOT NULL,
        chapterId TEXT,
        title TEXT,
        note TEXT,
        pageNumber INTEGER,
        position TEXT,
        createdAt TEXT,
        highlightedText TEXT,
        FOREIGN KEY (bookId) REFERENCES books (id) ON DELETE CASCADE
      )
    ''');

    // Reading progress table
    await db.execute('''
      CREATE TABLE reading_progress (
        id TEXT PRIMARY KEY,
        bookId TEXT NOT NULL UNIQUE,
        chapterId TEXT,
        currentPage INTEGER,
        currentPosition TEXT,
        progress REAL,
        lastUpdated TEXT,
        totalReadingTime INTEGER,
        FOREIGN KEY (bookId) REFERENCES books (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_books_filePath ON books(filePath)');
    await db.execute('CREATE INDEX idx_books_isFavorite ON books(isFavorite)');
    await db.execute('CREATE INDEX idx_books_isArchived ON books(isArchived)');
    await db.execute('CREATE INDEX idx_chapters_bookId ON chapters(bookId)');
    await db.execute('CREATE INDEX idx_bookmarks_bookId ON bookmarks(bookId)');
    await db.execute('CREATE INDEX idx_reading_progress_bookId ON reading_progress(bookId)');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

