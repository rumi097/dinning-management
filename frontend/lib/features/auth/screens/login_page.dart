import 'package:flutter/material.dart';
import 'package:frontend/core/services/service_locator.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:frontend/core/widgets/app_text_field.dart';
import 'package:frontend/core/widgets/loading_overlay.dart';
import 'package:frontend/features/auth/screens/forgot_password_page.dart';
import 'package:frontend/features/auth/screens/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    // Simple email validation
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value)) {
      return 'Please enter a valid email';
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

  Future<void> _handleLogin() async {
    _clearErrors();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ServiceLocator.authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // Navigate based on role
      _navigateByRole(response.role);
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
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateByRole(String role) {
    final screen = _getScreenByRole(role);
    Navigator.of(context).pushReplacementNamed(screen);
  }

  String _getScreenByRole(String role) {
    switch (role.toUpperCase()) {
      case 'STUDENT':
        return '/student-home';
      case 'MEAL_MANAGER':
        return '/meal-manager-home';
      case 'DINING_MANAGER':
        return '/dining-manager-home';
      default:
        return '/home';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Signing in...',
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen ? 24 : 16,
                vertical: 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  SizedBox(
                    width: isWideScreen ? 500 : double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to your account to continue',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login Card
                  SizedBox(
                    width: isWideScreen ? 500 : double.infinity,
                    child: Card(
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
                                errorText: _emailError,
                                prefixIcon: Icon(
                                  Icons.email_outlined,
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
                                errorText: _passwordError,
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Forgot password link
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ForgotPasswordPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Forgot password?',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: scheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Login button
                              AppPrimaryButton(
                                text: 'Sign In',
                                onPressed: _handleLogin,
                                isLoading: _isLoading,
                                isEnabled: !_isLoading,
                              ),
                              const SizedBox(height: 16),

                              // Sign up link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const SignupPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Sign Up',
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
