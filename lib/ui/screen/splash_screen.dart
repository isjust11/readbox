import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/services/secure_storage_service.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:device_info_plus/device_info_plus.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _SplashState();
  }
}

class _SplashState extends State<SplashScreen> with TickerProviderStateMixin {
  final SecureStorageService _secureStorage = SecureStorageService();
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _rotateController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  String _appVersion = '1.0.0';
  @override
  void initState() {
    super.initState();
    _initDeviceInfo();
    // Scale animation for logo
    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Fade animation for text
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Rotate animation for icon
    _rotateController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    // Start animations
    _scaleController.forward();
    Future.delayed(Duration(milliseconds: 300), () {
      _fadeController.forward();
      _rotateController.forward();
    });

    SchedulerBinding.instance.addPostFrameCallback((_) => openScreen(context));
  }
  
  Future<void> _initDeviceInfo() async {
    final deviceInfo = await DeviceInfoPlugin().deviceInfo;
    if (deviceInfo is AndroidDeviceInfo) {
      _appVersion = deviceInfo.version.toString();
    } else if (deviceInfo is IosDeviceInfo) {
      _appVersion = deviceInfo.systemVersion.toString();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated circles background
              _buildAnimatedBackground(),
              
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Image.asset(Assets.images.appLogo.path, width: 80, height: 80),
                      ),
                    ),
                    
                    SizedBox(height: 40),
                    
                    // App Name with fade animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.current.app_name,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: 2.0,
                              shadows: [
                                Shadow(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                                  offset: Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            AppLocalizations.current.library,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 60),
                    
                    // Loading indicator
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildLoadingIndicator(),
                    ),
                  ],
                ),
              ),
              
              // Version at bottom
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Version $_appVersion',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: _buildFloatingCircle(250, Colors.white.withValues(alpha: 0.05)),
        ),
        Positioned(
          bottom: -150,
          left: -150,
          child: _buildFloatingCircle(300, Colors.white.withValues(alpha: 0.05)),
        ),
        Positioned(
          top: 100,
          left: -50,
          child: _buildFloatingCircle(150, Colors.white.withValues(alpha: 0.03)),
        ),
      ],
    );
  }

  Widget _buildFloatingCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          SizedBox(height: 16),
          Text(
            AppLocalizations.current.loading,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  openScreen(BuildContext context) async {
    // Migrate dữ liệu cũ từ SharedPreferences sang SecureStorage (chỉ chạy 1 lần)
    try {
      await _secureStorage.migrateFromSharedPreferences();
    } catch (e) {
      print('⚠️ Migration failed, but app will continue: $e');
    }

    await Future.delayed(Duration(milliseconds: 2500));

    // Khi không có internet: xem ebook chế độ local, không cần đăng nhập
    try {
      final results = await Connectivity().checkConnectivity();
      final hasInternet = results.isNotEmpty &&
          !(results.length == 1 && results.first == ConnectivityResult.none);
      if (!hasInternet && context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.localLibraryScreen,
          (route) => false,
        );
        return;
      }
    } catch (_) {
      // Nếu không kiểm tra được (permission, v.v.) coi như có mạng, đi tiếp logic token
    }

    // Có internet: kiểm tra token để quyết định đăng nhập hay vào app
    final hasToken = await _secureStorage.hasToken();
    if (!context.mounted) return;
    if (!hasToken) {
      Navigator.pushNamedAndRemoveUntil(context, Routes.loginScreen, (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, Routes.mainScreen, (route) => false);
    }
  }
}
