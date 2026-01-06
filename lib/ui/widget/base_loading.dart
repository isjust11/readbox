import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scale_size/scale_size.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/res/resources.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/ui/widget/custom_text_label.dart';

class CustomLoading<T extends Cubit<BaseState>> extends StatelessWidget {
  final String? message;
  final bool showMessage;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final double? size;
  final bool Function(BaseState state)? loadingState;
  final bool Function(BaseState state)? errorState;
  final bool Function(BaseState state)? emptyState;
  final Function()? onRefresh;

  const CustomLoading({
    super.key,
    this.message,
    this.showMessage = true,
    this.backgroundColor = const Color.fromRGBO(0, 0, 0, 0.4),
    this.indicatorColor = AppColors.baseColor,
    this.size,
    this.loadingState,
    this.errorState,
    this.emptyState,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBlocResult<T, BaseState>(
      message: AppLocalizations.current.loading,
      showMessage: showMessage,
      backgroundColor: backgroundColor,
      indicatorColor: indicatorColor,
      size: size,
      loadingState: (state) => state is LoadingState,
      errorState: (state) => state is ErrorState,
      emptyState: (state) => state is EmptyState,
      onRefresh: onRefresh,
    );
  }
}

// Custom Circular Loading Indicator with smooth animation

/// CustomLoading widget that works with both Bloc and Cubit
/// Usage with Bloc:
/// CustomBlocLoading<NewsBloc, NewsState>(
///   loadingState: (state) => state is NewsLoading,
///   message: 'Đang tải tin tức...',
/// )
///
/// Usage with Cubit:
/// CustomBlocLoading<AuthCubit, BaseState>(
///   loadingState: (state) => state is LoadingState,
///   message: 'Đang xử lý...',
/// )
class CustomBlocResult<B extends StateStreamable<S>, S>
    extends StatelessWidget {
  final String? message;
  final bool showMessage;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final double? size;
  final bool Function(S state) loadingState;
  final bool Function(S state)? errorState;
  final bool Function(S state)? emptyState;
  final Function()? onRefresh;
  const CustomBlocResult({
    super.key,
    this.message,
    this.showMessage = true,
    this.backgroundColor,
    this.indicatorColor,
    this.size,
    required this.loadingState,
    this.errorState,
    this.emptyState,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      builder: (_, state) {
        if (loadingState(state)) {
          return LoadingAnimationWidget.threeArchedCircle(
            color: indicatorColor ?? AppColors.baseColor,
            size: size ?? AppDimens.SIZE_32,
          );
        }
        if (errorState != null && errorState!(state)) {
          return _buildErrorContent(context);
        }
        if (emptyState != null && emptyState!(state)) {
          return _buildEmptyContent(context);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      child: ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Column(
              children: [
                SvgPicture.asset(
                  Assets.icons.icFolderEmpty,
                  width: 64.sw,
                  height: 64.sw,
                  colorFilter: ColorFilter.mode(
                    AppColors.textDark.withValues(alpha: 0.6),
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(height: AppDimens.SIZE_16),
                CustomTextLabel(
                  AppLocalizations.current.empty,
                  fontSize: AppDimens.SIZE_16,
                  color: AppColors.textDark.withValues(alpha: 0.6),
                ),
                SizedBox(height: AppDimens.SIZE_8),
                CustomTextLabel(
                  AppLocalizations.current.pullToRefresh,
                  fontSize: AppDimens.SIZE_14,
                  color: AppColors.textDark.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    final state = context.read<B>().state as dynamic;
    final messageError = state.message;
    return RefreshIndicator(
      onRefresh: () => onRefresh?.call(),
      child: ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.sw,
                  color: AppColors.errorRed,
                ),
                SizedBox(height: AppDimens.SIZE_16),
                CustomTextLabel(
                  AppLocalizations.current.error,
                  fontSize: AppDimens.SIZE_16,
                  color: AppColors.errorRed,
                ),
                SizedBox(height: AppDimens.SIZE_8),
                CustomTextLabel(
                  messageError,
                  fontSize: AppDimens.SIZE_14,
                  color: AppColors.textDark.withValues(alpha: 0.6),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimens.SIZE_16),
                ElevatedButton(
                  onPressed: () {
                    onRefresh?.call();
                  },
                  child: CustomTextLabel(
                    AppLocalizations.current.tryAgain,
                    fontSize: AppDimens.SIZE_14,
                    color: AppColors.colorTitle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
