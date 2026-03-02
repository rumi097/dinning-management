import 'package:flutter/material.dart';
import 'package:frontend/core/services/service_locator.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:frontend/core/widgets/app_text_field.dart';
import 'package:frontend/core/widgets/loading_overlay.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ServiceLocator.authService.resetPassword(
        widget.email,
        _passwordController.text,
        _confirmPasswordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to login
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(title: const Text('Set New Password'), centerTitle: true),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Resetting password...',
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
                  SizedBox(
                    width: isWideScreen ? 500 : double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create New Password',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter a new password for your account',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Reset Password Card
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
                              // Password icon
                              Center(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: scheme.primaryContainer,
                                  ),
                                  child: Icon(
                                    Icons.lock_outline,
                                    size: 40,
                                    color: scheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Password field
                              AppTextField(
                                label: 'New Password',
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

                              // Reset button
                              AppPrimaryButton(
                                text: 'Reset Password',
                                onPressed: _handleResetPassword,
                                isLoading: _isLoading,
                                isEnabled: !_isLoading,
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
