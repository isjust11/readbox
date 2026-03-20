import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/injection_container.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/widget/widget.dart';

enum ConfirmPinType { verify, forgotPassword }

class ConfirmPinScreen extends StatelessWidget {
  final String email;
  final String? phone;
  final ConfirmPinType? type;
  const ConfirmPinScreen({
    super.key,
    required this.email,
    this.phone,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(repository: getIt.get<AuthRepository>()),
        ),
      ],
      child: ConfirmPinBody(email: email, phone: phone, type: type),
    );
  }
}

class ConfirmPinBody extends StatefulWidget {
  final String email;
  final String? phone;
  final ConfirmPinType? type;
  const ConfirmPinBody({super.key, required this.email, this.phone, this.type});

  @override
  ConfirmPinBodyState createState() => ConfirmPinBodyState();
}

class ConfirmPinBodyState extends State<ConfirmPinBody>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _pinControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Resend PIN timer variables
  Timer? _resendTimer;
  int _resendCountdown = 60;
  bool _canResend = false;
  ValueNotifier<bool> _canSubmit = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Auto focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });

    // Start resend timer
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _animationController.dispose();
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handlePinChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto submit when all 4 digits are entered
    if (index == 3 && value.length == 1) {
      _canSubmit.value = true;
    } else {
      _canSubmit.value = false;
    }
  }

  void _verifyPin() {
    String pin = _pinControllers.map((c) => c.text).join();
    if (pin.length == 4) {
      BlocProvider.of<AuthCubit>(
        context,
      ).verifyPin(email: widget.email, pin: pin);
    }
  }

  void _clearPin() {
    for (var controller in _pinControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 60;
      _canResend = false;
    });

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _resendPin() {
    if (_canResend) {
      BlocProvider.of<AuthCubit>(context).resendPin(email: widget.email);
      _startResendTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 1024;
    const double headerMaxWidth = 420;
    const double formMaxWidth = 520;

    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthCubit, BaseState>(
            listener: (context, state) {
              if (state is LoadedState) {
                // Backend trả về Map với code và message
                if (state.data is Map<String, dynamic>) {
                  final result = state.data as Map<String, dynamic>;
                  final code = result['code'];

                  if (code == 'verify') {
                    // Xác thực thành công
                    if (widget.type == ConfirmPinType.forgotPassword) {
                      Navigator.pop(context, true);
                    } else {
                      Navigator.pushReplacementNamed(
                        context,
                        Routes.loginScreen,
                      );
                    }
                    AppSnackBar.show(
                      context,
                      message:
                          result['message'] ??
                          AppLocalizations.current.authentication_success,
                      snackBarType: SnackBarType.success,
                    );
                  } else if (code == 'resend') {
                    // Gửi mã PIN mới thành công
                    _startResendTimer();
                    AppSnackBar.show(
                      context,
                      message:
                          result['message'] ??
                          AppLocalizations.current.pin_resend_success,
                      snackBarType: SnackBarType.success,
                    );
                  } else {
                    // Xác thực thất bại
                    _clearPin();
                    AppSnackBar.show(
                      context,
                      message:
                          result['message'] ??
                          AppLocalizations.current.pin_verification_failed,
                      snackBarType: SnackBarType.error,
                    );
                  }
                } else {
                  // Fallback: nếu data không phải Map (backward compatibility)
                  _clearPin();
                  AppSnackBar.show(
                    context,
                    message: AppLocalizations.current.pin_verification_failed,
                    snackBarType: SnackBarType.error,
                  );
                }
              } else if (state is ErrorState) {
                AppSnackBar.show(
                  context,
                  message: BlocUtils.getMessageError(state.data),
                  snackBarType: SnackBarType.error,
                );
                _clearPin();
              }
            },
          ),
        ],
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
              child: Column(
                children: [
                  // Back Button
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

                  // Scrollable Content
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: isLargeScreen
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: headerMaxWidth,
                                      child: _buildHeader(),
                                    ),
                                    const SizedBox(width: 32),
                                    SizedBox(
                                      width: formMaxWidth,
                                      child: _buildPinCard(),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Header
                                    _buildHeader(),
                                    SizedBox(height: AppDimens.SIZE_24),
                                    // PIN Input Card
                                    _buildPinCard(),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
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

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Icon
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
          child: Icon(Icons.pin_rounded, size: 50, color: theme.primaryColor),
        ),
        SizedBox(height: 16),

        // Title
        Text(
          AppLocalizations.current.verify_pin,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        SizedBox(height: 12),
        Text(
          AppLocalizations.current.enter_pin_4_digits_sent_to_email,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          widget.email,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildPinCard() {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: EdgeInsets.all(AppDimens.SIZE_16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // PIN Input Fields
            _buildPinInputs(),
            SizedBox(height: AppDimens.SIZE_16),

            // Verify Button
            _buildVerifyButton(),
            SizedBox(height: AppDimens.SIZE_16),

            // Resend PIN Button
            _buildResendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPinInputs() {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        return Container(
          width: 50,
          height: 60,
          margin: EdgeInsets.only(right: 4),
          child: TextField(
            controller: _pinControllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            cursorColor: theme.primaryColor,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.primaryColor, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red.shade300, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red, width: 1),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
            ),
            onChanged: (value) => _handlePinChanged(index, value),
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton() {
    final theme = Theme.of(context);
    return ValueListenableBuilder(
      valueListenable: _canSubmit,
      builder: (context, value, child) {
        return ElevatedButton(
          onPressed: value ? _verifyPin : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: value ? theme.primaryColor : Colors.grey,
            foregroundColor: Colors.white,
            elevation: 4,
            padding: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            shadowColor: theme.primaryColor.withValues(alpha: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.current.verify,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.check_circle_outline, size: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResendButton() {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_canResend)
            Text(
              '${AppLocalizations.current.resend_pin_in} $_resendCountdown ${AppLocalizations.current.seconds}',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            InkWell(
              onTap: _resendPin,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 16, color: theme.primaryColor),
                    SizedBox(width: 4),
                    Text(
                      AppLocalizations.current.resend_pin,
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
