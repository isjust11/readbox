import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/auth/auth_cubit.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/injection_container.dart';
import 'package:readbox/res/resources.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => AuthCubit(repository: getIt.get<AuthRepository>()),
      child: const _ForgotPasswordBody(),
    );
  }
}

class _ForgotPasswordBody extends StatefulWidget {
  const _ForgotPasswordBody();

  @override
  State<_ForgotPasswordBody> createState() => _ForgotPasswordBodyState();
}

class _ForgotPasswordBodyState extends State<_ForgotPasswordBody>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _animationController.forward();
  }

  void _sendCode() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final email = _emailController.text.trim();
    BlocProvider.of<AuthCubit>(context).forgotPassword(email: email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, BaseState>(
      listener: (context, state) {
      },
      child: BaseScreen(
        stateWidget: CustomLoading<AuthCubit>(
          size: AppDimens.SIZE_32,
          message: AppLocalizations.current.loading,
          backgroundColor: Colors.black.withValues(alpha: 0.4),
          indicatorColor: AppColors.baseColor,
        ),
        messageNotify: CustomSnackBar<AuthCubit>(),
        hideAppBar: true,
        body: Stack(
          children: [
            Container(
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
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [_buildHeader(), _buildContent()],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.SIZE_24,
          vertical: 32,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: CustomTextLabel(
                    AppLocalizations.current.forgot_password,
                    fontSize: AppDimens.SIZE_24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: AppDimens.SIZE_32),
                _buildForm(),
                SizedBox(height: AppDimens.SIZE_24),
                _buildSendButton(),
                SizedBox(height: AppDimens.SIZE_24),
                _buildBackToLogin(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: AppDimens.SIZE_80,
            height: AppDimens.SIZE_80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_reset,
              size: AppDimens.SIZE_40,
              color: AppColors.baseColor,
            ),
          ),
          SizedBox(height: AppDimens.SIZE_24),

          // Optional helper text
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEmailField(),
        ],
      ),
    );
  }

   Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: AppLocalizations.current.email,
        hintText: AppLocalizations.current.enter_email,
        prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF667eea)),
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
          borderSide: BorderSide(color: Color(0xFF667eea), width: 2),
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
          return AppLocalizations.current.please_enter_email;
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return AppLocalizations.current.invalid_email;
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildSendButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF667eea),
        foregroundColor: AppColors.white,
        padding: EdgeInsets.symmetric(vertical: AppDimens.SIZE_16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
        ),
      ),
      onPressed: _sendCode,
      child: CustomTextLabel(
        AppLocalizations.current.resend_code,
        fontSize: AppDimens.SIZE_16,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
    );
  }

  Widget _buildBackToLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomTextLabel(
          AppLocalizations.current.back_to_login,
          fontSize: AppDimens.SIZE_14,
          fontWeight: FontWeight.w500,
          color: AppColors.textMediumGrey,
        ),
        SizedBox(width: AppDimens.SIZE_4),
        InkWell(
          onTap: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          child: CustomTextLabel(
            AppLocalizations.current.login,
            fontSize: AppDimens.SIZE_14,
            fontWeight: FontWeight.w600,
            color: AppColors.baseColor,
          ),
        ),
      ],
    );
  }
}
