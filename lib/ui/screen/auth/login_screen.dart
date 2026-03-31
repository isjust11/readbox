import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:local_auth/local_auth.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/injection_container.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/services/services.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/shared_preference.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => AuthCubit(repository: getIt.get<AuthRepository>()),
      child: LoginBody(),
    );
  }
}

class LoginBody extends StatefulWidget {
  const LoginBody({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginBody>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _rememberMe = false;
  BiometricType _biometricType = BiometricType.fingerprint;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _getRememberPassword();
    _checkBiometricAvailability();
  }

  Future<void> _getRememberPassword() async {
    _rememberMe = await SharedPreferenceUtil.getRememberPassword();
    if (_rememberMe) {
      final credentials = await BiometricAuthService.getStoredCredentials();
      _usernameController.text = credentials?["username"] ?? "";
      _passwordController.text = credentials?["password"] ?? "";
    }
    setState(() {});
  }

  Future<void> _checkBiometricAvailability() async {
    final capability = await BiometricAuthService.checkBiometricCapability();
    final enabled = await BiometricAuthService.isBiometricEnabledInApp();
    final biometricType = await BiometricAuthService.getAvailableBiometrics();
    if (biometricType.isNotEmpty) {
      _biometricType = biometricType.first;
    }
    setState(() {
      _biometricAvailable = capability == BiometricCapability.available;
      _biometricEnabled = enabled;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      BlocProvider.of<AuthCubit>(context).doLogin(
        username: _usernameController.text.trim().toLowerCase(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 1024;
    const double headerMaxWidth = 420;
    const double formMaxWidth = 520;

    return BaseScreen(
      hideAppBar: true,
      messageNotify: CustomSnackBar<AuthCubit>(),
      body: BlocListener<AuthCubit, BaseState>(
        listener: (context, state) {
          if (state is LoadedState) {
            getIt.get<UserInfoCubit>().getUserInfo();
            Navigator.pushReplacementNamed(context, Routes.mainScreen);
          }
        },
        child: Stack(
          children: [
            // Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColor,
                    Color(0xFF764ba2),
                    Color(0xFFf093fb),
                  ],
                ),
              ),
            ),

            // Main Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child:
                        isLargeScreen
                            ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Brand column
                                SizedBox(
                                  width: headerMaxWidth,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: _buildHeader(),
                                  ),
                                ),
                                // Form column
                                SizedBox(
                                  width: formMaxWidth,
                                  child: _buildLoginCard(theme),
                                ),
                              ],
                            )
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Logo/Title Section
                                _buildHeader(),
                                SizedBox(height: AppDimens.SIZE_24),
                                // Login Card
                                _buildLoginCard(theme),
                              ],
                            ),
                  ),
                ),
              ),
            ),

            // Loading Overlay
            BlocBuilder<AuthCubit, BaseState>(
              builder: (context, state) {
                if (state is LoadingState) {
                  return Container(
                    color: Colors.black45,
                    child: Center(
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Icon/Logo
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(Assets.images.appLogo.path, width: 60, height: 60),
        ),
        SizedBox(height: 12),

        // App Title
        Text(
          AppLocalizations.current.app_name,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          AppLocalizations.current.login_to_continue,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(ThemeData theme) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                AppLocalizations.current.welcome_back,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),

              // Username Field
              _buildUsernameField(),
              SizedBox(height: 20),

              // Password Field
              _buildPasswordField(),
              SizedBox(height: 20),

              // Login Button
              _biometricAvailable && _biometricEnabled
                  ? Row(
                    children: [
                      Expanded(child: _buildLoginButton()),
                      SizedBox(width: AppDimens.SIZE_12),
                      _buildBiometricLoginButton(),
                    ],
                  )
                  : _buildLoginButton(),
              // Remember and Forgot Password
              _buildRememberAndForgotPassword(),
              SizedBox(height: 12),

              // Social Login
              _buildSocialLogin(),
              SizedBox(height: 12),

              // Register Link
              _buildRegisterLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRememberAndForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              activeColor: AppColors.baseColor,
              checkColor: AppColors.white,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                  SharedPreferenceUtil.setRememberPassword(_rememberMe);
                });
              },
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _rememberMe = !_rememberMe;
                  SharedPreferenceUtil.setRememberPassword(_rememberMe);
                });
              },
              child: CustomTextLabel(
                AppLocalizations.current.remember_me,
                fontSize: AppDimens.SIZE_14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMediumGrey,
              ),
            ),
          ],
        ),
        Flexible(
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.forgotPassword,
                arguments: _usernameController.text.trim(),
              );
            },
            child: CustomTextLabel(
              AppLocalizations.current.forgot_password,
              fontSize: AppDimens.SIZE_14,
              fontWeight: FontWeight.w500,
              color: AppColors.baseColor,
              textAlign: TextAlign.end,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    final theme = Theme.of(context);
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: AppLocalizations.current.username,
        hintText: AppLocalizations.current.enter_username,
        prefixIcon: Icon(Icons.person_outline, color: theme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppLocalizations.current.please_enter_username;
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildPasswordField() {
    final theme = Theme.of(context);
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: AppLocalizations.current.password,
        hintText: AppLocalizations.current.enter_password,
        prefixIcon: Icon(Icons.lock_outline, color: theme.primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey.shade600,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.current.please_enter_password;
        }
        if (value.length < 6) {
          return AppLocalizations
              .current
              .password_must_be_at_least_6_characters;
        }
        return null;
      },
      onFieldSubmitted: (_) => _handleLogin(),
    );
  }

  Widget _buildLoginButton() {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: theme.primaryColor.withValues(alpha: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.current.login,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward_rounded, size: 20),
        ],
      ),
    );
  }

  Widget _buildRegisterLink() {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${AppLocalizations.current.no_account} ',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, Routes.registerScreen),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 4),
          ),
          child: Text(
            AppLocalizations.current.register_now,
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Đăng nhập bằng Apple (Chỉ hiện trên iOS)
            if (Theme.of(context).platform == TargetPlatform.iOS) ...[
              _buildCircularSocialButton(
                icon: Icon(Icons.apple, size: 28, color: Colors.white),
                backgroundColor: Colors.black,
                onPressed: () => context.read<AuthCubit>().doAppleLogin(),
              ),
              SizedBox(width: 20),
            ],
            // Đăng nhập bằng Google
            _buildCircularSocialButton(
              icon: SvgPicture.asset(
                Assets.icons.icGoogle,
                width: 24,
                height: 24,
              ),
              backgroundColor: Colors.white,
              borderColor: Colors.grey.shade300,
              onPressed: () => context.read<AuthCubit>().doGoogleLogin(),
            ),
            SizedBox(width: 20),
            // Đăng nhập bằng Facebook
            _buildCircularSocialButton(
              icon: SvgPicture.asset(
                Assets.icons.icFacebook,
                width: 24,
                height: 24,
              ),
              backgroundColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.2),
              onPressed: () => context.read<AuthCubit>().doFacebookLogin(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircularSocialButton({
    required Widget icon,
    required Color backgroundColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: borderColor != null ? Border.all(color: borderColor) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: icon),
      ),
    );
  }

  Widget _buildBiometricLoginButton() {
    return InkWell(
      onTap: () {
        context.read<AuthCubit>().doBiometricLogin();
      },
      child: Container(
        height: AppDimens.SIZE_48,
        width: AppDimens.SIZE_48,
        decoration: BoxDecoration(
          color: AppColors.lightBackgroundAlt,
          borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryBrand.withValues(alpha: 0.2),
              blurRadius: AppDimens.SIZE_4,
              offset: Offset(0, AppDimens.SIZE_2),
            ),
          ],
        ),
        child: Center(child: _buildBiometricIcon()),
      ),
    );
  }

  Widget _buildBiometricIcon() {
    if (_biometricType == BiometricType.face) {
      return SvgPicture.asset(
        Assets.icons.icFaceId,
        width: AppDimens.SIZE_20,
        height: AppDimens.SIZE_20,
      );
    }
    return Icon(
      Icons.fingerprint,
      size: AppDimens.SIZE_20,
      color: AppColors.gray,
    );
  }
}
