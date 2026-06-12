import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PdfCacheManager {
  static const key = 'pdfCacheKey';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 15),
      maxNrOfCacheObjects: 3, // Keep only the 3 most recently accessed
    ),
  );
}
