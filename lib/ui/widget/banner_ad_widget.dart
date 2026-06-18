import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:readbox/blocs/user_subscription_cubit.dart';
import 'package:readbox/utils/ad_helper.dart';
import 'package:readbox/utils/navigator.dart';

/// Banner quảng cáo đáy màn hình.
///
/// `AdWidget` là platform view — nếu không ẩn khi push màn full-screen khác,
/// native ad có thể vẽ đè lên route phía trên (vd. SubscriptionPlanScreen).
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  BannerAdWidgetState createState() => BannerAdWidgetState();
}

class BannerAdWidgetState extends State<BannerAdWidget> with RouteAware {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isRouteVisible = true;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.unsubscribe(this);
      appRouteObserver.subscribe(this, route);
      _isRouteVisible = route.isCurrent;
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _disposeAd();
    super.dispose();
  }

  @override
  void didPushNext() {
    _setRouteVisible(false);
  }

  @override
  void didPopNext() {
    _setRouteVisible(true);
  }

  void _setRouteVisible(bool visible) {
    if (_isRouteVisible == visible) return;
    setState(() => _isRouteVisible = visible);
    if (visible) {
      if (_bannerAd == null) _loadAd();
    } else {
      _disposeAd();
    }
  }

  void _loadAd() {
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _isLoaded = false;
            _bannerAd = null;
          });
        },
      ),
    )..load();
  }

  void _disposeAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
    if (!_isRouteVisible || !isCurrentRoute) {
      return const SizedBox.shrink();
    }

    final isFreeUser = context.read<UserSubscriptionCubit>().isFreeUser();
    if (!isFreeUser || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
