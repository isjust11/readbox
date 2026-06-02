import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/widget/custom_snack_bar.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/ad_helper.dart';
import 'package:readbox/res/enum.dart';

class PopupAdWidget {
  static void showRewardedAdAndRunAction(
    BuildContext context,
    VoidCallback onReward,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          Navigator.pop(context); // Dismiss loading
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
          Navigator.pop(context); // Dismiss loading
          AppSnackBar.show(
            context,
            message: AppLocalizations.current.ad_load_failed,
            snackBarType: SnackBarType.error,
          );
        },
      ),
    );
  }

  static void showPrompt({
    required BuildContext context,
    required VoidCallback onReward,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.current.premium_feature_title),
            content: Text(AppLocalizations.current.premium_feature_desc),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.current.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  showRewardedAdAndRunAction(context, onReward);
                },
                child: Text(AppLocalizations.current.watch_ad),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, Routes.subscriptionPlanScreen);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: Text(AppLocalizations.current.upgrade_now),
              ),
            ],
          ),
    );
  }
}
