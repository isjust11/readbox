import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/ui/screen/tools/word_to_pdf_converter_screen.dart';
import 'package:readbox/ui/screen/tools/document_scanner_screen.dart';
import 'package:readbox/ui/widget/base_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BaseScreen(
      title: AppLocalizations.current.tools,
      colorBg: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(AppDimens.SIZE_12),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: AppDimens.SIZE_12,
          mainAxisSpacing: AppDimens.SIZE_12,
          children: [
            _ToolCard(
              widgetIcon: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimens.SIZE_12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        Assets.icons.icDoc,
                        width: AppDimens.SIZE_28,
                        height: AppDimens.SIZE_28,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.SIZE_2),
                  Icon(Icons.arrow_forward_ios, size: 16),
                  const SizedBox(width: AppDimens.SIZE_2),
                  Container(
                    padding: const EdgeInsets.all(AppDimens.SIZE_12),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withValues(alpha: 0.1),
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
              title: AppLocalizations.current.tools_word_to_pdf,
              description:
                  AppLocalizations.current.tools_word_to_pdf_description,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WordToPdfConverterScreen(),
                  ),
                );
              },
            ),
            _ToolCard(
              widgetIcon: Container(
                padding: const EdgeInsets.all(AppDimens.SIZE_12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(Icons.document_scanner,
                size: AppDimens.SIZE_28,
                color: colorScheme.primary,
                ),
              ),
              title: AppLocalizations.current.tools_document_scanner,
              description:
                  AppLocalizations.current.tools_document_scanner_description,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DocumentScannerScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final Widget widgetIcon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ToolCard({
    required this.widgetIcon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.SIZE_12)),
      color: colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.SIZE_12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: widgetIcon,
              ),
              const SizedBox(height: AppDimens.SIZE_12),
              Flexible(fit: FlexFit.tight,child: Text(title, style: theme.textTheme.titleMedium),),
              const SizedBox(height: 4),
              Flexible(child: Text(
                description,
                style: TextStyle(
                  fontSize: AppDimens.SIZE_12,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
