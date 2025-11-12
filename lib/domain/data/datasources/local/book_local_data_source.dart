import 'package:sqflite/sqflite.dart';
import 'package:readbox/domain/data/datasources/local/database_helper.dart';
import 'package:readbox/domain/data/models/models.dart';

class BookLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Book operations
  Future<String> insertBook(BookModel book) async {
    final db = await _dbHelper.database;
    await db.insert(
      'books',
      book.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return book.id!;
  }

  Future<List<BookModel>> getAllBooks({
    bool? isFavorite,
    bool? isArchived,
    String? searchQuery,
  }) async {
    final db = await _dbHelper.database;
    String query = 'SELECT * FROM books WHERE 1=1';
    List<dynamic> args = [];

    if (isFavorite != null) {
      query += ' AND isFavorite = ?';
      args.add(isFavorite ? 1 : 0);
    }

    if (isArchived != null) {
      query += ' AND isArchived = ?';
      args.add(isArchived ? 1 : 0);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query += ' AND (title LIKE ? OR author LIKE ? OR description LIKE ?)';
      final searchPattern = '%$searchQuery%';
      args.addAll([searchPattern, searchPattern, searchPattern]);
    }

    query += ' ORDER BY dateAdded DESC';

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, args);
    return List.generate(maps.length, (i) => BookModel.fromJson(maps[i]));
  }

  Future<BookModel?> getBookById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return BookModel.fromJson(maps.first);
  }

  Future<BookModel?> getBookByFilePath(String filePath) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'filePath = ?',
      whereArgs: [filePath],
    );

    if (maps.isEmpty) return null;
    return BookModel.fromJson(maps.first);
  }

  Future<int> updateBook(BookModel book) async {
    final db = await _dbHelper.database;
    return await db.update(
      'books',
      book.toJson(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<int> deleteBook(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleFavorite(String id, bool isFavorite) async {
    final db = await _dbHelper.database;
    return await db.update(
      'books',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Chapter operations
  Future<String> insertChapter(ChapterModel chapter) async {
    final db = await _dbHelper.database;
    await db.insert(
      'chapters',
      {
        ...chapter.toJson(),
        'orderIndex': chapter.order, // Map order to orderIndex for DB
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return chapter.id!;
  }

  Future<List<ChapterModel>> getChaptersByBookId(String bookId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chapters',
      where: 'bookId = ?',
      whereArgs: [bookId],
      orderBy: 'orderIndex ASC',
    );

    return List.generate(maps.length, (i) {
      final json = maps[i];
      json['order'] = json['orderIndex']; // Map back to order
      return ChapterModel.fromJson(json);
    });
  }

  Future<int> deleteChaptersByBookId(String bookId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'chapters',
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
  }

  // Bookmark operations
  Future<String> insertBookmark(BookmarkModel bookmark) async {
    final db = await _dbHelper.database;
    await db.insert(
      'bookmarks',
      bookmark.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return bookmark.id!;
  }

  Future<List<BookmarkModel>> getBookmarksByBookId(String bookId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookmarks',
      where: 'bookId = ?',
      whereArgs: [bookId],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) => BookmarkModel.fromJson(maps[i]));
  }

  Future<int> deleteBookmark(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'bookmarks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Reading progress operations
  Future<String> insertOrUpdateReadingProgress(ReadingProgressModel progress) async {
    final db = await _dbHelper.database;
    await db.insert(
      'reading_progress',
      progress.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return progress.id!;
  }

  Future<ReadingProgressModel?> getReadingProgressByBookId(String bookId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reading_progress',
      where: 'bookId = ?',
      whereArgs: [bookId],
    );

    if (maps.isEmpty) return null;
    return ReadingProgressModel.fromJson(maps.first);
  }

  Future<int> deleteReadingProgress(String bookId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'reading_progress',
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
  }
}

