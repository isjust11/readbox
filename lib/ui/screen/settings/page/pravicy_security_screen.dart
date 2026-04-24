import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/ui/widget/base_screen.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/blocs/page_cubit.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/injection_container.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt.get<PageCubit>(),
      child: PrivacySecurityBody(),
    );
  }
}

class PrivacySecurityBody extends StatefulWidget {
  const PrivacySecurityBody({super.key});

  @override
  State<PrivacySecurityBody> createState() => _PrivacySecurityBodyState();
}

class _PrivacySecurityBodyState extends State<PrivacySecurityBody> {
  WebViewController? _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    context.read<PageCubit>().getPageBySlug('privateAndSecurity');
  }

  void _initWebView(String linkPages) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(isDark ? const Color(0xFF1a1a1a) : Colors.white)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (_) {
                if (mounted) setState(() => _isLoading = false);
              },
            ),
          )
          ..loadRequest(Uri.parse(linkPages));
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen<PageCubit>(
      autoHandleState: true,
      title: AppLocalizations.current.privacy_and_security,
      colorTitle: Theme.of(context).colorScheme.surfaceContainerHighest,
      body: _buildBody(context),
      colorBg: Theme.of(context).colorScheme.surface,
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<PageCubit, BaseState>(
      bloc: context.read<PageCubit>(),
      builder: (context, state) {
        if (state is LoadedState) {
          final linkPages = state.data.linkPages ?? '';

          if (linkPages.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.current.no_content_to_display,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      Theme.of(context).textTheme.bodyMedium?.color ??
                      AppColors.colorTitle,
                ),
              ),
            );
          }

          if (_webViewController == null) {
            _initWebView(linkPages);
          }

          return Stack(
            children: [
              if (_webViewController != null)
                WebViewWidget(controller: _webViewController!),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
