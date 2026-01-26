import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/utils/pdf_thumbnail_service.dart';

class AppDrawerInfo extends StatelessWidget {
  const AppDrawerInfo({super.key, required this.book});
  final BookModel book;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      book.title?? AppLocalizations.current.info,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Cover
                    Center(
                      child: Container(
                        width: 120,
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildBookCover(context, book),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    _buildInfoRow(
                      context,
                      AppLocalizations.current.title,
                      book.displayTitle,
                    ),
                    const SizedBox(height: 16),

                    // Author
                   book.author != null && book.author!.isNotEmpty ? Column(
                     children: [
                       _buildInfoRow(
                          context,
                            AppLocalizations.current.author,
                            book.author!,
                          ),
                          const SizedBox(height: 16),
                     ],
                   )
                    : const SizedBox(),

                    // Description
                    if (book.description != null &&
                        book.description!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoLabel(
                            context,
                            AppLocalizations.current.description,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            book.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // File Type
                    _buildInfoRow(
                      context,
                      AppLocalizations.current.file_type,
                      book.fileType?.name.toUpperCase() ?? 'PDF',
                      icon: Icons.picture_as_pdf,
                    ),
                    const SizedBox(height: 16),

                    // File Size
                    _buildInfoRow(
                      context,
                      AppLocalizations.current.file_size,
                      book.fileSizeFormatted,
                      icon: Icons.storage,
                    ),
                    const SizedBox(height: 16),

                    // Total Pages
                    _buildInfoRow(
                      context,
                      AppLocalizations.current.total_pages,
                      '${book.totalPages ?? 0} ${AppLocalizations.current.pages}',
                      icon: Icons.numbers,
                    ),
                    const SizedBox(height: 16),

                    // Publisher
                    if (book.publisher != null && book.publisher!.isNotEmpty)
                      Column(
                        children: [
                          _buildInfoRow(
                            context,
                            AppLocalizations.current.publisher,
                            book.publisher!,
                            icon: Icons.business,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // ISBN
                    if (book.isbn != null && book.isbn!.isNotEmpty)
                      Column(
                        children: [
                          _buildInfoRow(
                            context,
                            AppLocalizations.current.isbn,
                            book.isbn!,
                            icon: Icons.tag,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Language
                    if (book.language != null && book.language!.isNotEmpty)
                      Column(
                        children: [
                          _buildInfoRow(
                            context,
                            AppLocalizations.current.language,
                            book.language!,
                            icon: Icons.language,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // File Path
                    _buildInfoRow(
                      context,
                      AppLocalizations.current.file_path,
                      book.fileUrl ?? '',
                      icon: Icons.folder_outlined,
                      isFilePath: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoLabel(BuildContext context, String label) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
    bool isFilePath = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoLabel(context, label),
        const SizedBox(height: 6),
        isFilePath
            ? SelectableText(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
            : SelectableText(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
      ],
    );
  }

  Widget _buildBookCover(BuildContext context, BookModel book) {
    const w = 50.0;
    const h = 70.0;
    final color = Theme.of(context).colorScheme.outline;
    final decor = BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
    );

    if (book.fileType?.name != 'pdf') {
      return Container(
        width: w,
        height: h,
        decoration: decor,
        child: Icon(Icons.picture_as_pdf, color: color, size: 32),
      );
    }

    return FutureBuilder<Uint8List?>(
      future: PdfThumbnailService.getThumbnail(
        book.fileUrl!,
        width: 240,
        height: 300,
      ),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done && bytes != null) {
          return Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.memory(bytes, fit: BoxFit.cover),
          );
        }
        return Container(
          width: w,
          height: h,
          decoration: decor,
          child: Icon(Icons.picture_as_pdf, color: color, size: 32),
        );
      },
    );
  }
}
