import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/service_locator.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:frontend/core/widgets/loading_overlay.dart';
import 'package:frontend/features/auth/models/signup_request.dart';
import 'package:frontend/features/auth/screens/reset_password_page.dart';

class OtpPage extends StatefulWidget {
  final String email;
  final String flowType; // 'signup' or 'forgot_password'
  final VoidCallback onSuccess;
  final SignupRequest? signupRequest; // Form data for signup flow

  const OtpPage({
    super.key,
    required this.email,
    required this.flowType,
    required this.onSuccess,
    this.signupRequest,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _otpFocusNodes;
  Timer? _resendTimer;

  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(6, (_) => TextEditingController());
    _otpFocusNodes = List.generate(6, (_) => FocusNode());
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _resendCountdown--);
      }
      if (_resendCountdown <= 0) {
        timer.cancel();
      }
    });
  }

  String _getOtpCode() {
    return _otpControllers.map((c) => c.text).join();
  }

  void _focusNextField(int index) {
    if (index < 5) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
    } else {
      _otpFocusNodes[index].unfocus();
    }
  }

  void _focusPreviousField(int index) {
    if (index > 0) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _getOtpCode();

    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter all 6 digits');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.flowType == 'signup') {
        // Step 1: Verify OTP
        final otpVerification = await ServiceLocator.authService
            .verifySignupOtp(widget.email, otp);

        if (!otpVerification.verified) {
          throw Exception('OTP verification failed');
        }

        if (!mounted) return;

        // Step 2: After OTP verification succeeds, send signup data to backend
        if (widget.signupRequest != null) {
          await ServiceLocator.authService.completeSignup(
            widget.signupRequest!,
          );
        }

        if (!mounted) return;

        // Step 3: Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Signup successful! Please login with your credentials.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Step 4: Redirect to login page
        Navigator.of(context).pushReplacementNamed('/login');
      } else if (widget.flowType == 'forgot_password') {
        final otpVerification = await ServiceLocator.authService.verifyResetOtp(
          widget.email,
          otp,
        );

        if (!otpVerification.verified) {
          throw Exception('OTP verification failed');
        }

        if (!mounted) return;

        // Navigate to reset password page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResetPasswordPage(email: widget.email),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResendOtp() async {
    setState(() => _isResending = true);

    try {
      if (widget.flowType == 'signup') {
        await ServiceLocator.authService.sendSignupOtp(widget.email);
      } else if (widget.flowType == 'forgot_password') {
        await ServiceLocator.authService.sendResetOtp(widget.email);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      _startResendTimer();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _clearOtp() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(title: const Text('Verify OTP'), centerTitle: true),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Verifying OTP...',
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen ? 24 : 16,
                vertical: 24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  SizedBox(
                    width: isWideScreen ? 500 : double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: scheme.primaryContainer,
                          ),
                          child: Icon(
                            Icons.mail_outline,
                            size: 40,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Verify Your Email',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 8),
                        RichTextSpan(
                          text:
                              'A verification code has been sent to\n${widget.email}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // OTP Input
                  SizedBox(
                    width: isWideScreen ? 500 : double.infinity,
                    child: Card(
                      elevation: 0,
                      color: scheme.surfaceContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // OTP boxes
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                6,
                                (index) => SizedBox(
                                  width: 50,
                                  child: TextField(
                                    controller: _otpControllers[index],
                                    focusNode: _otpFocusNodes[index],
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    inputFormatters: [],
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        _focusNextField(index);
                                      }
                                    },
                                    onSubmitted: (value) {
                                      if (value.isEmpty) {
                                        _focusPreviousField(index);
                                      }
                                    },
                                    decoration: InputDecoration(
                                      counterText: '',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: scheme.outlineVariant,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: scheme.outlineVariant,
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: scheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: scheme.surfaceContainer,
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Error message
                            if (_errorMessage != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: scheme.errorContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: scheme.error),
                                ),
                              ),
                            const SizedBox(height: 24),

                            // Verify button
                            AppPrimaryButton(
                              text: 'Verify',
                              onPressed: _handleVerifyOtp,
                              isLoading: _isLoading,
                              isEnabled: !_isLoading,
                              width: double.infinity,
                            ),
                            const SizedBox(height: 12),

                            // Clear button
                            OutlinedButton(
                              onPressed: _clearOtp,
                              child: const Text('Clear'),
                            ),
                            const SizedBox(height: 24),

                            // Resend section
                            Column(
                              children: [
                                Text(
                                  "Didn't receive the code?",
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                if (_resendCountdown > 0)
                                  Text(
                                    'Resend in ${_resendCountdown.toString().padLeft(2, '0')}s',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  )
                                else
                                  TextButton(
                                    onPressed: _isResending
                                        ? null
                                        : _handleResendOtp,
                                    child: _isResending
                                        ? SizedBox(
                                            height: 16,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    scheme.primary,
                                                  ),
                                            ),
                                          )
                                        : Text(
                                            'Resend OTP',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(
                                                  color: scheme.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper widget for rich text
class RichTextSpan extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  const RichTextSpan({
    required this.text,
    this.style,
    this.textAlign = TextAlign.left,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(text, textAlign: textAlign, style: style);
  }
}
