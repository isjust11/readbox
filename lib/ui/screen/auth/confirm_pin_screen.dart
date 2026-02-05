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
import 'package:readbox/res/enum.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/widget/widget.dart';

class ConfirmPinScreen extends StatelessWidget {
  final String email;
  final String? phone;
  const ConfirmPinScreen({super.key, required this.email, this.phone});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(repository: getIt.get<AuthRepository>()),
        ),
      ],
      child: ConfirmPinBody(email: email, phone: phone),
    );
  }
}

class ConfirmPinBody extends StatefulWidget {
  final String email;
  final String? phone;
  const ConfirmPinBody({super.key, required this.email, this.phone});

  @override
  ConfirmPinBodyState createState() => ConfirmPinBodyState();
}

class ConfirmPinBodyState extends State<ConfirmPinBody> with SingleTickerProviderStateMixin {
  final List<TextEditingController> _pinControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Resend PIN timer variables
  Timer? _resendTimer;
  int _resendCountdown = 60;
  bool _canResend = false;

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
      _verifyPin();
    }
  }

  void _verifyPin() {
    String pin = _pinControllers.map((c) => c.text).join();
    if (pin.length == 4) {
      BlocProvider.of<AuthCubit>(context).verifyPin(
        email: widget.email,
        pin: pin,
      );
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
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthCubit, BaseState>(
            listener: (context, state) {
              if (state is LoadedState) {
                getIt.get<UserInfoCubit>().getUserInfo();
                Navigator.pushReplacementNamed(context, Routes.loginScreen);
                AppSnackBar.show(
                  context,
                  message: AppLocalizations.current.authentication_success,
                  snackBarType: SnackBarType.success,
                );
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
          BlocListener<AuthCubit, BaseState>(
            listener: (context, state) {
              if (state is LoadedState) {
                AppSnackBar.show(
                  context,
                  message: AppLocalizations.current.pin_resend_success,
                  snackBarType: SnackBarType.success,
                );
              } else if (state is ErrorState) {
                AppSnackBar.show(
                  context,
                  message: BlocUtils.getMessageError(state.data),
                  snackBarType: SnackBarType.error,
                );
                // Reset timer even on error so user can try again
                setState(() {
                  _canResend = true;
                  _resendCountdown = 0;
                });
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
                    Color(0xFF667eea),
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Header
                              _buildHeader(),
                              SizedBox(height: 50),
                              
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
                          padding: EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF667eea),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                AppLocalizations.current.verifying_pin,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
          child: Icon(
            Icons.lock_rounded,
            size: 50,
            color: Color(0xFF667eea),
          ),
        ),
        SizedBox(height: 20),
        
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // PIN Input Fields
            _buildPinInputs(),
            SizedBox(height: 32),
            
            // Verify Button
            _buildVerifyButton(),
            SizedBox(height: 16),
            
            // Clear Button
            _buildClearButton(),
            SizedBox(height: 8),
            
            // Resend PIN Button
            _buildResendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPinInputs() {
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
            cursorColor: Color(0xFF667eea),
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667eea),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
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
                borderSide: BorderSide(color: Color(0xFF667eea), width: 1),
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
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            onChanged: (value) => _handlePinChanged(index, value),
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton() {
    return ElevatedButton(
      onPressed: _verifyPin,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 4,
        padding: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        shadowColor: Color(0xFF667eea).withValues(alpha: 0.5),
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
  }

  Widget _buildClearButton() {
    return TextButton(
      onPressed: _clearPin,
      child: Text(
        AppLocalizations.current.clear_and_reenter,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildResendButton() {
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
                  color: Color(0xFF667eea).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.refresh,
                      size: 16,
                      color: Color(0xFF667eea),
                    ),
                    SizedBox(width: 4),
                    Text(
                      AppLocalizations.current.resend_pin,
                      style: TextStyle(
                        color: Color(0xFF667eea),
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
