// lib/features/auth/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kampus_koin_app/core/widgets/loading_overlay.dart';
import '../providers/auth_notifier.dart';
import 'package:flutter/gestures.dart';
import 'package:kampus_koin_app/core/constants/legal_content.dart';
import 'package:kampus_koin_app/core/widgets/legal_page.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _studentIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitRegister() {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Privacy Policy'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      ref.read(authNotifierProvider.notifier).register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            admno: _studentIdController.text.trim().isEmpty
                ? null
                : _studentIdController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      body: Stack(
        children: [
          // 1. Top Gradient Header
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
          ),

          // 2. Back Button (SafeArea)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const Text(
                      'Back to Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Header Text (On top of gradient)
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join Kampus Koin today.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Registration Form Card
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildModernTextField(
                              controller: _nameController,
                              label: 'Full Name',
                              hint: 'John Doe',
                              icon: Icons.person_outline_rounded,
                              colorScheme: colorScheme,
                              validator: (value) => (value == null || value.isEmpty)
                                  ? 'Please enter your name'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            _buildModernTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'student@example.com',
                              icon: Icons.email_outlined,
                              colorScheme: colorScheme,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => (value == null || !value.contains('@'))
                                  ? 'Please enter a valid email'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            _buildModernTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              hint: '0712345678',
                              icon: Icons.phone_outlined,
                              colorScheme: colorScheme,
                              keyboardType: TextInputType.phone,
                              validator: (value) => (value == null || value.length < 10)
                                  ? 'Enter a valid phone number'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            _buildModernTextField(
                              controller: _studentIdController,
                              label: 'Student ID (Optional)',
                              hint: 'DSU-001',
                              icon: Icons.school_outlined,
                              colorScheme: colorScheme,
                            ),
                            const SizedBox(height: 20),

                            _buildModernTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              colorScheme: colorScheme,
                              obscureText: _obscurePassword,
                              validator: (value) => (value == null || value.length < 6)
                                  ? 'Min 6 characters'
                                  : null,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey[400],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Terms Checkbox
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _agreedToTerms,
                                    activeColor: colorScheme.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    onChanged: (value) {
                                      setState(() => _agreedToTerms = value!);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'I agree to the ',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
                                      children: [
                                        TextSpan(
                                          text: 'Terms of Service',
                                          style: TextStyle(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const LegalPage(
                                                    title: 'Terms of Service',
                                                    content: LegalContent.termsOfService,
                                                  ),
                                                ),
                                              );
                                            },
                                        ),
                                        const TextSpan(text: ' and '),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: TextStyle(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const LegalPage(
                                                    title: 'Privacy Policy',
                                                    content: LegalContent.privacyPolicy,
                                                  ),
                                                ),
                                              );
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: authState.status == AuthStatus.loading
                                    ? null
                                    : _submitRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shadowColor: colorScheme.primary.withOpacity(0.4),
                                  disabledBackgroundColor: Colors.grey[300],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: authState.status == AuthStatus.loading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Bottom Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.pop(),
                                  child: Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (authState.status == AuthStatus.loading)
            const LoadingOverlay(message: 'Creating your account...'),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ColorScheme colorScheme,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(icon, color: colorScheme.primary.withOpacity(0.6), size: 22),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF5F7FA), // Very light grey fill
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}