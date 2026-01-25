import 'package:html_unescape/html_unescape.dart';

class HtmlContentProcessor {
  /// Decode HTML entities to proper HTML
  static String decodeHtmlEntities(String htmlString) {
    if (htmlString.isEmpty) return '';

    // List of common HTML entities
    final Map<String, String> htmlEntities = {
      '&lt;': '<',
      '&gt;': '>',
      '&amp;': '&',
      '&quot;': '"',
      '&#39;': "'",
      '&nbsp;': ' ',
      '&copy;': '©',
      '&reg;': '®',
      '&trade;': '™',
      '&hellip;': '…',
      '&ndash;': '–',
      '&mdash;': '—',
      '&lsquo;': ''',
      '&rsquo;': ''',
      '&ldquo;': '"',
      '&rdquo;': '"',
      '&bull;': '•',
      '&middot;': '·',
    };

    String decoded = htmlString;

    // Replace HTML entities
    htmlEntities.forEach((entity, replacement) {
      decoded = decoded.replaceAll(entity, replacement);
    });

    return decoded;
  }

  /// Extract HTML content from pre/code blocks
  static String extractHtmlFromCodeBlock(String content) {
    if (content.isEmpty) return '';

    // Check if content is wrapped in <pre><code> tags
    final preCodeRegex = RegExp(
      r'<pre><code[^>]*>(.*?)</code></pre>',
      dotAll: true,
    );
    final match = preCodeRegex.firstMatch(content);

    if (match != null) {
      // Extract content from pre/code block
      String extractedContent = match.group(1) ?? '';

      // Decode HTML entities
      extractedContent = decodeHtmlEntities(extractedContent);

      return extractedContent;
    }

    // If not in pre/code block, just decode entities
    return decodeHtmlEntities(content);
  }

  /// Process HTML content for Flutter HTML widget
  static String processHtmlContent(String content) {
    if (content.isEmpty) return '';

    // First, try to extract from code blocks
    String processed = extractHtmlFromCodeBlock(content);

    // If no code block found, just decode entities
    if (processed == content) {
      processed = decodeHtmlEntities(content);
    }

    // Clean up any remaining issues
    processed = _cleanupHtml(processed);

    return processed;
  }

  /// Clean up HTML content
  static String _cleanupHtml(String html) {
    if (html.isEmpty) return '';

    // Remove any remaining encoded characters
    html = html.replaceAll(RegExp(r'&[a-zA-Z0-9#]+;'), '');

    // Fix common issues
    html = html.replaceAll(
      RegExp(r'\s+'),
      ' ',
    ); // Multiple spaces to single space
    html = html.trim();

    return html;
  }
  
   /// Strip HTML tags and convert to plain text
  /// Converts common HTML tags to plain text equivalents
  /// Also decodes HTML entities (&amp;, &lt;, &quot;, etc.)
  static String stripHtmlTags(String html) {
    if (html.isEmpty) return html;
    
    // First decode HTML entities
    String text = HtmlUnescape().convert(html);
    
    // Convert common HTML line breaks to newlines
    text = text
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<p\s+[^>]*>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<b>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<i>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<p>', caseSensitive: false), '');
    
    // Remove all remaining HTML tags
    text = text.replaceAll(RegExp(r'<[^>]+>'), '');
    
    // Clean up multiple consecutive newlines
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    
    // Trim whitespace
    return text.trim();
  }
  /// Check if content is HTML code block
  static bool isHtmlCodeBlock(String content) {
    return content.contains('<pre><code') && content.contains('</code></pre>');
  }

  /// Get content type
  static ContentType getContentType(String content) {
    if (content.isEmpty) return ContentType.empty;

    if (isHtmlCodeBlock(content)) {
      return ContentType.htmlCodeBlock;
    }

    if (content.contains('<html') ||
        content.contains('<body') ||
        content.contains('<div')) {
      return ContentType.html;
    }

    if (content.contains('<p>') ||
        content.contains('<h1>') ||
        content.contains('<h2>')) {
      return ContentType.html;
    }

    return ContentType.plainText;
  }
}

enum ContentType { empty, html, htmlCodeBlock, plainText }
