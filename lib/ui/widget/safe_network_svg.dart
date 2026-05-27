import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class SafeNetworkSvg extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SafeNetworkSvg({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  State<SafeNetworkSvg> createState() => _SafeNetworkSvgState();
}

class _SafeNetworkSvgState extends State<SafeNetworkSvg> {
  Future<String>? _svgStringFuture;

  @override
  void initState() {
    super.initState();
    _svgStringFuture = _fetchSvgCode(widget.url);
  }

  // Tải thủ công nội dung XML của file SVG
  Future<String> _fetchSvgCode(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body; // Trả về chuỗi XML thuần
    }
    throw Exception('Lỗi tải SVG: ${response.statusCode}');
  }

  Widget _buildContent(String svgCode) {
    // Trích xuất ảnh base64 nhúng bên trong SVG vì flutter_svg không hỗ trợ tốt thẻ <image>
    final RegExp base64RegExp = RegExp(r'data:image\/[a-zA-Z]+;base64,([^"]+)');
    final match = base64RegExp.firstMatch(svgCode);
    if (match != null && match.groupCount >= 1) {
      final base64String = match.group(1)!;
      try {
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
        );
      } catch (e) {
        // Fallback to SvgPicture.string if decoding fails
      }
    }

    return SvgPicture.string(
      svgCode,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _svgStringFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            // Render SVG hoặc Base64 Image
            return _buildContent(snapshot.data!);
          } else if (snapshot.hasError) {
            // Trả về icon lỗi nếu không tải được ảnh
            return const Icon(Icons.broken_image, color: Colors.grey);
          }
        }
        // Hiển thị vòng xoay chờ tải dữ liệu
        return const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}
