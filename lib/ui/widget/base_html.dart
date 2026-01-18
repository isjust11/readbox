import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:flutter_html/flutter_html.dart';
class BaseHtml extends StatelessWidget {
  final String html;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  const BaseHtml({super.key, required this.html, this.style, this.maxLines, this.overflow});
    /// Kiểm tra xem text có chứa HTML tags không
  bool _containsHtmlTags(String text) {
    final htmlTagRegex = RegExp(r'<[^>]+>');
    return htmlTagRegex.hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    return _buildTextWithHtml(context, html, TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[800]));
  }

   Widget _buildTextWithHtml(
    BuildContext context,
    String text,
    TextStyle style, {
    int maxLines = 2,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    final decodedText = HtmlUnescape().convert(text);
    
    // Nếu có HTML tags, dùng Html widget
    if (_containsHtmlTags(decodedText)) {
      final fontSize = style.fontSize ?? 16.0;
      final lineHeight = 1.3;
      final maxHeight = fontSize * lineHeight * maxLines;
      
      return SizedBox(
        height: maxHeight,
        child: ClipRect(
          child: Html(
            data: decodedText,
            style: {
              "body": Style(
                fontSize: FontSize(fontSize),
                fontWeight: style.fontWeight ?? FontWeight.normal,
                color: style.color ?? Theme.of(context).colorScheme.onSurface,
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                lineHeight: LineHeight(lineHeight),
              ),
              "p": Style(
                fontSize: FontSize(fontSize),
                fontWeight: style.fontWeight ?? FontWeight.normal,
                color: style.color ?? Theme.of(context).colorScheme.onSurface,
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                lineHeight: LineHeight(lineHeight),
              ),
              "strong": Style(
                fontWeight: FontWeight.bold,
                color: style.color ?? Theme.of(context).colorScheme.onSurface,
              ),
              "b": Style(
                fontWeight: FontWeight.bold,
                color: style.color ?? Theme.of(context).colorScheme.onSurface,
              ),
              "em": Style(
                fontStyle: FontStyle.italic,
                color: style.color ?? Theme.of(context).colorScheme.onSurface,
              ),
              "i": Style(
                fontStyle: FontStyle.italic,
                color: style.color ?? Theme.of(context).colorScheme.onSurface,
              ),
            },
            shrinkWrap: true,
          ),
        ),
      );
    }
    
    // Nếu không có HTML tags, chỉ dùng Text với decoded entities
    return Text(
      decodedText,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

}