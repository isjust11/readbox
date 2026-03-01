import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_svg/svg.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/injection_container.dart';
import 'package:readbox/res/app_size.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/ui/screen/screen.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/common.dart';
import 'package:readbox/utils/shared_preference.dart';

class WordToPdfConverterScreen extends StatelessWidget {
  const WordToPdfConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConverterCubit>(),
      child: const WordToPdfConverterBody(),
    );
  }
}

class WordToPdfConverterBody extends StatefulWidget {
  const WordToPdfConverterBody({super.key});

  @override
  State<WordToPdfConverterBody> createState() => _WordToPdfConverterBodyState();
}

class _WordToPdfConverterBodyState extends State<WordToPdfConverterBody> {
  Future<void> _pickFile() async {
    // get file path from pdf scanner screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => const PdfScannerScreen(
              multiSelect: false,
              scanFormat: ScanFormatEnum.word,
            ),
      ),
    );

    // set selected file via cubit
    if (result != null && mounted) {
      context.read<ConverterCubit>().selectFile(File(result as String));
    }
  }

  Future<void> _convertToPdf() async {
    await context.read<ConverterCubit>().convertWordToPdf();
    if (mounted) {
      // lưu vào thư viện local khi convert thành công
      final filePath = context.read<ConverterCubit>().outputPath ?? '';
      final isAdded = await SharedPreferenceUtil.isBookAdded(filePath);

      if (!isAdded) {
        await SharedPreferenceUtil.addLocalBook(filePath);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<ConverterCubit, BaseState>(
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = context.read<ConverterCubit>();
        final selectedFile = cubit.selectedFile;
        final outputPath = cubit.outputPath;
        final isConverting = state is LoadingState;

        return BaseScreen(
          colorBg: colorScheme.surface,
          title: AppLocalizations.current.tools_word_to_pdf,
          messageNotify: CustomSnackBar<ConverterCubit>(
            fontSize: AppSize.fontSizeMedium,
            textColor: colorScheme.onPrimary,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon and description
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                Assets.icons.icDocx,
                                width: 28,
                                height: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.arrow_forward_ios, size: 16),
                          const SizedBox(width: 2),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.error.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                Assets.icons.icPdf,
                                width: 28,
                                height: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.current.tools_word_to_pdf_description,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: colorScheme.primary, size: AppSize.iconSizeMedium,),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.current.info,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: AppSize.fontSizeMedium,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• ${AppLocalizations.current.select_file}\n'
                        '• Click "${AppLocalizations.current.tools_convert_to_pdf}"\n'
                        '• PDF will be saved to app documents',
                        style: TextStyle(color: colorScheme.onSurfaceVariant,
                        fontSize: AppSize.fontSizeMedium,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Select file button
                ElevatedButton(
                  onPressed: isConverting ? null : _pickFile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.file_open, color: colorScheme.onPrimary),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.current.tools_select_word_file,
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Selected file info
                if (selectedFile != null) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.description,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  selectedFile.path.split('/').last,
                                  style: TextStyle(
                                    fontSize: AppSize.fontSizeLarge,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${AppLocalizations.current.size}: ${Common.formatFileSize(selectedFile.lengthSync())}',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Convert button
                  ElevatedButton.icon(
                    onPressed: isConverting ? null : _convertToPdf,
                    icon:
                        isConverting
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(Icons.sync),
                    label: Text(
                      isConverting
                          ? AppLocalizations.current.tools_converting
                          : AppLocalizations.current.tools_convert_to_pdf,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                ],
                // Output file info - tap to view PDF
                if (outputPath != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.green.shade50,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder:
                                (context) => PdfViewerScreen(
                                  fileUrl: outputPath,
                                  title: path.basename(outputPath),
                                ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.current.tools_saved_successfully,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              path.basename(outputPath),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.picture_as_pdf,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  AppLocalizations.current.tap_to_view,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
