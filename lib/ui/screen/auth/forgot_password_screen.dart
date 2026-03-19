import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/auth/auth_cubit.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/injection_container.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/res/resources.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/screen/auth/confirm_pin_screen.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final String? username;
  const ForgotPasswordScreen({super.key, this.username});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => AuthCubit(repository: getIt.get<AuthRepository>()),
      child: _ForgotPasswordBody(username: username),
    );
  }
}

class _ForgotPasswordBody extends StatefulWidget {
  final String? username;
  const _ForgotPasswordBody({this.username});

  @override
  State<_ForgotPasswordBody> createState() => _ForgotPasswordBodyState();
}

class _ForgotPasswordBodyState extends State<_ForgotPasswordBody>
    with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final verifyPinStatus = ValueNotifier<bool>(false);
  @override
  void dispose() {
    _usernameController.dispose();
    _animationController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.username ?? '';
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
    final username = _usernameController.text.trim();
    BlocProvider.of<AuthCubit>(context).forgotPassword(username: username);
  }

  void _resetPassword() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final username = BlocProvider.of<AuthCubit>(context).resetPasswordUsername;
    final newPassword = _newPasswordController.text.trim();
    final confirmNewPassword = _confirmNewPasswordController.text.trim();
    if (newPassword != confirmNewPassword) {
      AppSnackBar.show(
        context,
        message: AppLocalizations.current.passwords_do_not_match,
        snackBarType: SnackBarType.error,
      );
      return;
    }
    BlocProvider.of<AuthCubit>(
      context,
    ).resetPassword(username: username, newPassword: newPassword);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, BaseState>(
      listener: (context, state) async {
        if (state is LoadedState) {
          final code = state.data['code'];
          if (code == 'verify-pin') {
            BlocProvider.of<AuthCubit>(context).resetPasswordUsername =
                _usernameController.text.trim();
            final email = state.data['email'];
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ConfirmPinScreen(
                      email: email,
                      type: ConfirmPinType.forgotPassword,
                    ),
              ),
            );
            if (result == true) {
              verifyPinStatus.value = true;
            }
          } else if (code == 'reset-password') {
            final status = state.data['status'];
            if (status == 'success') {
              Navigator.pushReplacementNamed(context, Routes.loginScreen);
              AppSnackBar.show(
                context,
                message: AppLocalizations.current.reset_password_success,
                snackBarType: SnackBarType.success,
              );
            } else {
              final message = state.data['message'];
              AppSnackBar.show(
                context,
                message: message,
                snackBarType: SnackBarType.error,
              );
            }
          }
        }
      },
      child: BaseScreen(
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
                    Theme.of(context).primaryColor,
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
                              AppColors.primaryBlue,
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
                  child: ValueListenableBuilder(
                    valueListenable: verifyPinStatus,
                    builder: (context, value, child) {
                      return CustomTextLabel(
                        value
                            ? AppLocalizations.current.reset_password
                            : AppLocalizations.current.forgot_password,
                        fontSize: AppDimens.SIZE_24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      );
                    },
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
      child: ValueListenableBuilder(
        valueListenable: verifyPinStatus,
        builder: (context, value, child) {
          if (value) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNewPasswordField(),
                SizedBox(height: AppDimens.SIZE_16),
                _buildConfirmNewPasswordField(),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [_buildEmailField()],
            );
          }
        },
      ),
    );
  }

  Widget _buildNewPasswordField() {
    return TextFormField(
      controller: _newPasswordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: AppLocalizations.current.new_password,
        hintText: AppLocalizations.current.enter_new_password,
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Theme.of(context).primaryColor,
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
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
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
          return AppLocalizations.current.please_enter_password;
        }
        if (value.length < 6) {
          return AppLocalizations
              .current
              .password_must_be_at_least_6_characters;
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildConfirmNewPasswordField() {
    return TextFormField(
      controller: _confirmNewPasswordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: AppLocalizations.current.confirm_new_password,
        hintText: AppLocalizations.current.enter_confirm_new_password,
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Theme.of(context).primaryColor,
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
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
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
          return AppLocalizations.current.please_enter_confirm_password;
        }
        if (value != _newPasswordController.text) {
          return AppLocalizations.current.passwords_do_not_match;
        }
        return null;
      },
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _usernameController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: AppLocalizations.current.username,
        hintText: AppLocalizations.current.enter_username,
        prefixIcon: Icon(
          Icons.person_outline,
          color: Theme.of(context).primaryColor,
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
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
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
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildSendButton() {
    return ValueListenableBuilder(
      valueListenable: verifyPinStatus,
      builder: (context, value, child) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: AppColors.white,
            padding: EdgeInsets.symmetric(vertical: AppDimens.SIZE_16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
            ),
          ),
          onPressed: !value ? _sendCode : _resetPassword,
          child: CustomTextLabel(
            value
                ? AppLocalizations.current.reset_password
                : AppLocalizations.current.verify,
            fontSize: AppDimens.SIZE_16,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        );
      },
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
