import 'package:flutter/material.dart';
import 'package:frontend/core/services/service_locator.dart';
import 'package:frontend/core/widgets/app_text_field.dart';
import 'package:frontend/core/widgets/loading_overlay.dart';
import 'package:frontend/features/auth/models/signup_request.dart';
import 'package:frontend/features/auth/screens/otp_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _emailController;
  late final TextEditingController _nameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _rollController;
  late final TextEditingController _phoneController;
  late final TextEditingController _roomController;

  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _rollController = TextEditingController();
    _phoneController = TextEditingController();
    _roomController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _rollController.dispose();
    _phoneController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateRoll(String? value) {
    if (value == null || value.isEmpty) {
      return 'Roll number is required';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    return null;
  }

  String? _validateRoom(String? value) {
    if (value == null || value.isEmpty) {
      return 'Room number is required';
    }
    return null;
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Step 1: Send OTP to email
      final email = _emailController.text.trim();
      await ServiceLocator.authService.sendSignupOtp(email);

      if (!mounted) return;

      // Step 2: Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent to your email'),
          backgroundColor: Colors.green,
        ),
      );

      // Step 3: Create SignupRequest with form data (saved locally, NOT sent yet)
      final request = SignupRequest(
        email: email,
        password: _passwordController.text,
        name: _nameController.text.trim(),
        roll: _rollController.text.isNotEmpty
            ? _rollController.text.trim()
            : null,
        phoneNo: _phoneController.text.isNotEmpty
            ? _phoneController.text.trim()
            : null,
        roomNo: _roomController.text.isNotEmpty
            ? _roomController.text.trim()
            : null,
      );

      if (!mounted) return;

      // Step 4: Navigate to OTP verification with form data
      // Data will be sent to backend AFTER OTP verification is successful
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OtpPage(
            email: email,
            flowType: 'signup',
            signupRequest: request, // Pass form data to OTP page
            onSuccess: () {
              // After OTP verification and signup, navigate to login
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send OTP: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(title: const Text('Create Account'), centerTitle: true),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Creating account...',
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen ? 24 : 16,
                vertical: 24,
              ),
              child: SizedBox(
                width: isWideScreen ? 500 : double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Join the Dining System',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your student account to access meal services',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Signup Card
                    Card(
                      elevation: 0,
                      color: scheme.surfaceContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Email field
                              AppTextField(
                                label: 'Email Address',
                                hint: 'your@email.com',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: _validateEmail,
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Name field
                              AppTextField(
                                label: 'Full Name',
                                hint: 'John Doe',
                                controller: _nameController,
                                validator: _validateName,
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Password field
                              AppTextField(
                                label: 'Password',
                                hint: '••••••••',
                                controller: _passwordController,
                                obscureText: true,
                                validator: _validatePassword,
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Confirm Password field
                              AppTextField(
                                label: 'Confirm Password',
                                hint: '••••••••',
                                controller: _confirmPasswordController,
                                obscureText: true,
                                validator: _validateConfirmPassword,
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Student Information
                              Text(
                                'Student Information',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: scheme.onSurface),
                              ),
                              const SizedBox(height: 12),

                              // Roll Number field
                              AppTextField(
                                label: 'Roll Number',
                                hint: 'e.g., 21-1234',
                                controller: _rollController,
                                validator: _validateRoll,
                                prefixIcon: Icon(
                                  Icons.badge_outlined,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Phone Number field
                              AppTextField(
                                label: 'Phone Number',
                                hint: '+880XXXXXXXXX',
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                validator: _validatePhone,
                                prefixIcon: Icon(
                                  Icons.phone_outlined,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Room Number field
                              AppTextField(
                                label: 'Room Number',
                                hint: '101',
                                controller: _roomController,
                                keyboardType: TextInputType.number,
                                validator: _validateRoom,
                                prefixIcon: Icon(
                                  Icons.door_sliding_outlined,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Terms checkbox
                              Row(
                                children: [
                                  Checkbox(
                                    value: _agreeToTerms,
                                    onChanged: (value) {
                                      setState(
                                        () => _agreeToTerms = value ?? false,
                                      );
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      'I agree to the Terms and Conditions',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Signup button
                              FilledButton(
                                onPressed: _isLoading ? null : _handleSignup,
                                child: _isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onPrimary,
                                              ),
                                        ),
                                      )
                                    : const Text('Create Account'),
                              ),
                              const SizedBox(height: 16),

                              // Login link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(
                                        context,
                                      ).pushReplacementNamed('/login');
                                    },
                                    child: Text(
                                      'Sign In',
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
      ),
    );
  }
}
