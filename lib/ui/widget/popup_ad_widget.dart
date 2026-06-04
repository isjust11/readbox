import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/widget/custom_snack_bar.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/ad_helper.dart';
import 'package:readbox/res/enum.dart';

class PopupAdWidget {
  static const Duration _adLoadTimeout = Duration(seconds: 20);

  static void _dismissLoadingDialog(
    BuildContext context, {
    required bool Function() isOpen,
    required void Function(bool) setOpen,
  }) {
    if (!context.mounted || !isOpen()) return;
    setOpen(false);
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  static void showRewardedAdAndRunAction(
    BuildContext context,
    VoidCallback onReward,
  ) {
    var isLoadingDialogOpen = true;

    void dismissLoading() {
      _dismissLoadingDialog(
        context,
        isOpen: () => isLoadingDialogOpen,
        setOpen: (value) => isLoadingDialogOpen = value,
      );
    }

    void showLoadFailed() {
      if (!context.mounted) return;
      AppSnackBar.show(
        context,
        message: AppLocalizations.current.ad_load_failed,
        snackBarType: SnackBarType.error,
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder:
          (_) => Center(
            child:
                Platform.isIOS
                    ? const CupertinoActivityIndicator()
                    : const CircularProgressIndicator(),
          ),
    );

    var loadFinished = false;

    Timer(_adLoadTimeout, () {
      if (loadFinished) return;
      loadFinished = true;
      dismissLoading();
      showLoadFailed();
    });

    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          if (loadFinished) {
            ad.dispose();
            return;
          }
          loadFinished = true;
          dismissLoading();

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (RewardedAd ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
              ad.dispose();
            },
          );
          ad.show(
            onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
              onReward();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (loadFinished) return;
          loadFinished = true;
          dismissLoading();
          showLoadFailed();
        },
      ),
    );
  }

  static void showPrompt({
    required BuildContext context,
    required VoidCallback onReward,
  }) {
    final parentContext = context;

    showDialog(
      context: parentContext,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(AppLocalizations.current.premium_feature_title),
            content: Text(AppLocalizations.current.premium_feature_desc),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(AppLocalizations.current.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!parentContext.mounted) return;
                    showRewardedAdAndRunAction(parentContext, onReward);
                  });
                },
                child: Text(AppLocalizations.current.watch_ad),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pushNamed(
                    parentContext,
                    Routes.subscriptionPlanScreen,
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(parentContext).colorScheme.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: Text(AppLocalizations.current.upgrade_now),
              ),
            ],
          ),
    );
  }
}
