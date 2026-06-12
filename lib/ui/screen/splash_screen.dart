import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/services/secure_storage_service.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/shared_preference.dart';

// Mô tả một tính năng hiển thị trên splash
class _FeatureItem {
  final String svgPath;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String description;

  const _FeatureItem({
    required this.svgPath,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
  });
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<StatefulWidget> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> with TickerProviderStateMixin {
  final SecureStorageService _secureStorage = SecureStorageService();

  late AnimationController _logoController;
  late AnimationController _contentController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;
  int _currentFeaturePage = 0;
  bool _isFirstLogin = false;
  bool _hasAgreedPolicy = false;
  bool _isPolicyChecked = false;

  bool _isReady = false;
  String? _nextRoute;

  List<_FeatureItem> get _features => _buildFeatures();

  static List<_FeatureItem> _buildFeatures() {
    final l = AppLocalizations.current;
    return [
      _FeatureItem(
        svgPath: Assets.icons.icGlobal,
        iconColor: Color(0xFF5C6BC0),
        iconBg: Color(0xFFE8EAF6),
        title: l.splash_feature_discover_title,
        description: l.splash_feature_discover_desc,
      ),
      _FeatureItem(
        svgPath: Assets.icons.icLibrary,
        iconColor: Color(0xFF00897B),
        iconBg: Color(0xFFE0F2F1),
        title: l.splash_feature_read_title,
        description: l.splash_feature_read_desc,
      ),
      _FeatureItem(
        svgPath: Assets.icons.icAiBrain,
        iconColor: Colors.lightBlueAccent,
        iconBg: Colors.white,
        title: l.splash_feature_ai_tts_title,
        description: l.splash_feature_ai_tts_desc,
      ),
      _FeatureItem(
        svgPath: Assets.icons.icRobotic,
        iconColor: Color(0xFF8E24AA),
        iconBg: Color(0xFFF3E5F5),
        title: l.splash_feature_ai_title,
        description: l.splash_feature_ai_desc,
      ),
      _FeatureItem(
        svgPath: Assets.icons.icStorage,
        iconColor: Color(0xFFE53935),
        iconBg: Color(0xFFFFEBEE),
        title: l.splash_feature_offline_title,
        description: l.splash_feature_offline_desc,
      ),
      _FeatureItem(
        svgPath: Assets.icons.icFavorite,
        iconColor: Color(0xFFF57C00),
        iconBg: Color(0xFFFFF3E0),
        title: l.splash_feature_library_title,
        description: l.splash_feature_library_desc,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _contentController.forward();
    });

    // Auto-scroll features every 6.4s
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 6400), (_) {
      if (!mounted) return;
      final next = (_currentFeaturePage + 1) % _features.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });

    SchedulerBinding.instance.addPostFrameCallback(
      (_) => _prepareNavigation(context),
    );
    checkFirstLogin();
  }

  Future<void> checkFirstLogin() async {
    // check first login
    _isFirstLogin = await SharedPreferenceUtil.getFirstLogin();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return BaseScreen(
      hideAppBar: true,
      useSafeAreaTop: false,
      useSafeAreaBottom: false,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.08),
              colorScheme.surface,
              colorScheme.primaryContainer.withValues(alpha: 0.18),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildDecorativeBlobs(colorScheme),
              Column(
                children: [
                  const Spacer(flex: 2),
                  _buildLogoSection(colorScheme),
                  const SizedBox(height: 12),
                  _buildAppName(colorScheme),
                  const SizedBox(height: 36),
                  _buildFeatureCarousel(colorScheme),
                  const SizedBox(height: 20),
                  _buildDotIndicator(colorScheme),
                  const Spacer(flex: 3),
                  _buildLoadingSection(colorScheme),
                  const SizedBox(height: 32),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeBlobs(ColorScheme cs) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primary.withValues(alpha: 0.07),
            ),
          ),
        ),
        Positioned(
          bottom: -120,
          left: -100,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.tertiary.withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          top: 160,
          left: -60,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.secondary.withValues(alpha: 0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection(ColorScheme cs) {
    return ScaleTransition(
      scale: _logoScale,
      child: FadeTransition(
        opacity: _logoFade,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: cs.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.08),
                blurRadius: 48,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Image.asset(Assets.images.appLogo.path, width: 70, height: 70),
        ),
      ),
    );
  }

  Widget _buildAppName(ColorScheme cs) {
    return FadeTransition(
      opacity: _logoFade,
      child: Column(
        children: [
          BaseShaderMask(
            colors: [cs.primary, cs.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            child: Text(
              AppLocalizations.current.app_name,
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color:
                    Colors
                        .white, // Cần có màu (thường là trắng) để blendMode hoạt động đúng
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.current.library,
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCarousel(ColorScheme cs) {
    return FadeTransition(
      opacity: _contentFade,
      child: SlideTransition(
        position: _contentSlide,
        child: SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentFeaturePage = i),
            itemCount: _features.length,
            itemBuilder: (context, index) {
              return _buildFeatureCard(_features[index], cs);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(_FeatureItem feature, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: feature.iconColor.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(
                feature.svgPath,
                width: 38,
                height: 38,
                colorFilter: ColorFilter.mode(
                  feature.iconColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            feature.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            feature.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withValues(alpha: 0.55),
              height: 1.55,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(ColorScheme cs) {
    return FadeTransition(
      opacity: _contentFade,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_features.length, (i) {
          final isActive = i == _currentFeaturePage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: isActive ? cs.primary : cs.primary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(99),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoadingSection(ColorScheme cs) {
    return FadeTransition(
      opacity: _contentFade,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder:
            (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
        child: _isReady ? _buildContinueButton(cs) : _buildSpinner(cs),
      ),
    );
  }

  Widget _buildSpinner(ColorScheme cs) {
    return Column(
      key: const ValueKey('spinner'),
      children: [
        SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              cs.primary.withValues(alpha: 0.7),
            ),
            backgroundColor: cs.primary.withValues(alpha: 0.12),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.current.loading,
          style: TextStyle(
            fontSize: 13,
            color: cs.onSurface.withValues(alpha: 0.45),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(ColorScheme cs) {
    return Column(
      key: const ValueKey('button'),
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!_hasAgreedPolicy)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _isPolicyChecked,
                    onChanged: (val) {
                      setState(() {
                        _isPolicyChecked = val ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 12),
                      children: [
                        TextSpan(
                          text: AppLocalizations.current.policy_agreement_part1,
                        ),
                        TextSpan(
                          text: AppLocalizations.current.terms_of_use,
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushNamed(
                                    context,
                                    Routes.privacySecurityScreen,
                                  );
                                },
                        ),
                        TextSpan(
                          text: AppLocalizations.current.policy_agreement_part3,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          width: 220,
          child: FilledButton.icon(
            onPressed:
                (!_hasAgreedPolicy && !_isPolicyChecked) ? null : _navigate,
            icon: const Icon(Icons.arrow_forward_rounded, size: 20),
            label: Text(
              AppLocalizations.current.splash_get_started,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  void _navigate() async {
    if (!mounted || _nextRoute == null) return;
    if (!_hasAgreedPolicy) {
      await SharedPreferenceUtil.setAgreedPolicy(true);
      _hasAgreedPolicy = true;
    }
    Navigator.pushNamedAndRemoveUntil(context, _nextRoute!, (route) => false);
  }

  Future<void> _prepareNavigation(BuildContext context) async {
    _isFirstLogin = await SharedPreferenceUtil.getFirstLogin();
    _hasAgreedPolicy = await SharedPreferenceUtil.hasAgreedPolicy();

    // Migrate dữ liệu cũ từ SharedPreferences sang SecureStorage (chỉ chạy 1 lần)
    try {
      await _secureStorage.migrateFromSharedPreferences();
    } catch (e) {
      debugPrint('⚠️ Migration failed, but app will continue: $e');
    }

    // Khi không có internet: xem ebook chế độ local, không cần đăng nhập
    try {
      final results = await Connectivity().checkConnectivity();
      final hasInternet =
          results.isNotEmpty &&
          !(results.length == 1 && results.first == ConnectivityResult.none);
      if (!hasInternet) {
        if (mounted) {
          setState(() {
            _nextRoute = Routes.localLibraryScreen;
            _isReady = true;
          });
        }
        return;
      }
    } catch (_) {
      // Nếu không kiểm tra được (permission, v.v.) coi như có mạng, đi tiếp logic token
    }

    // Có internet: kiểm tra token để quyết định đăng nhập hay vào app
    if (!context.mounted) return;
    final isTokenValid = await context.read<AuthCubit>().verifyToken();
    if (!mounted) return;
    if (_isFirstLogin == false && isTokenValid) {
      if (_hasAgreedPolicy) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.mainScreen,
          (route) => false,
        );
        return;
      }
    }
    SharedPreferenceUtil.saveFirstLogin(false);
    setState(() {
      _nextRoute = isTokenValid ? Routes.mainScreen : Routes.loginScreen;
      _isReady = true;
    });
  }
}
