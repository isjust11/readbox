import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _ToolCard(
              widgetIcon: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(Icons.document_scanner,
                size: 28,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: widgetIcon,
              ),
              const SizedBox(height: 12),
              Flexible(fit: FlexFit.tight,child: Text(title, style: theme.textTheme.titleMedium),),
              const SizedBox(height: 4),
              Flexible(child: Text(
                description,
                style: TextStyle(
                  fontSize: 12,
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
