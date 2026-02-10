import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/ui/widget/base_screen.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String transactionId;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.transactionId,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            _checkCallbackUrl(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Kiểm tra URL callback custom scheme từ backend
            if (request.url.startsWith('readbox://payment/result')) {
              _handleCallback(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkCallbackUrl(String url) {
    if (url.startsWith('readbox://payment/result')) {
      _handleCallback(url);
    }
  }

  void _handleCallback(String url) {
    final uri = Uri.parse(url);
    final status = uri.queryParameters['status'];
    final message = uri.queryParameters['message'];
    final transactionId = uri.queryParameters['transactionId'] ?? widget.transactionId;

    // Pop về màn subscription và truyền kết quả
    Navigator.of(context).pop({
      'status': status,
      'message': message,
      'transactionId': transactionId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: AppLocalizations.current.payment,
      colorTitle: Theme.of(context).colorScheme.onSurface,
      colorBg: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
