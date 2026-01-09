import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/ui/widget/base_appbar.dart';
import 'package:readbox/ui/widget/base_screen.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/blocs/page_cubit.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:readbox/utils/html_style_helper.dart';
import 'package:readbox/utils/html_content_processor.dart';
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

class PrivacySecurityBody extends StatelessWidget {
  const PrivacySecurityBody({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<PageCubit>().getPageBySlug('securityandpravicy');
    return BaseScreen(
      customAppBar: _buildAppBar(context),
      colorTitle: Theme.of(context).colorScheme.surfaceContainerHighest,
      // stateWidget: CustomLoading<PageCubit>(
      //   message: AppLocalizations.current.loading,
      //   size: AppDimens.SIZE_32,
      // ),
      body: _buildBody(context),
    );
  }

  BaseAppBar _buildAppBar(BuildContext context) {
    return BaseAppBar(
      title: AppLocalizations.current.privacy_and_security,
      showBackButton: true,
      onBackTap: () => Navigator.pop(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<PageCubit, BaseState>(
      bloc: context.read<PageCubit>(),
      builder: (context, state) {
        if (state is LoadedState) {
          final rawContent = state.data.content ?? '';

          // Process HTML content to handle encoded entities and code blocks
          final processedContent = HtmlContentProcessor.processHtmlContent(
            rawContent,
          );

          if (processedContent.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.current.no_content_to_display,
                style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.colorTitle),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const ScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Html(
              data: processedContent,
              style: HtmlStyleHelper.getNewsContentStyle(),
            ),
          );
        }
        if (state is ErrorState) {
          return Center(
            child: Text(state.data.toString()),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
