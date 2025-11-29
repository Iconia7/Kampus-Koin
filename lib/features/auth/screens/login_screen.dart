// lib/features/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kampus_koin_app/features/auth/widgets/forgot_password_modal.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kampus_koin_app/core/widgets/loading_overlay.dart';
import '../providers/auth_notifier.dart';
import 'dart:ui'; // For BackdropFilter if needed, but we rely on clean shapes here

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // --- BIOMETRIC VARIABLES ---
  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _canCheckBiometrics = false;
  bool _hasSavedCredentials = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  // --- PRESERVED LOGIC ---
  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();
      final email = await _storage.read(key: 'bio_email');
      final password = await _storage.read(key: 'bio_password');
      
      print('--------------------------------');
      print('BIOMETRIC DEBUG:');
      print('Hardware Available: $canCheck');
      print('Device Supported: $isSupported');
      print('Saved Email: $email'); 
      print('--------------------------------');

      if (mounted) {
        setState(() {
          _canCheckBiometrics = canCheck && isSupported;
          _hasSavedCredentials = email != null && password != null;
        });
      }
    } catch (e) {
      print("Biometric Check Error: $e");
    }
  }

  Future<void> _authenticate() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to login to Kampus Koin',
        options: const AuthenticationOptions(
          biometricOnly: true, 
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        final email = await _storage.read(key: 'bio_email');
        final password = await _storage.read(key: 'bio_password');

        if (email != null && password != null && mounted) {
          _emailController.text = email;
          _passwordController.text = password;
          ref.read(authNotifierProvider.notifier).login(email, password);
        }
      }
    } catch (e) {
      print("Biometric Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric authentication failed')),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    // Error Listener
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      body: Stack(
        children: [
          // 1. Top Gradient Background
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
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
          
          // 2. Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Header Logo
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Kampus Koin',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your savings, unlock rewards.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    
                    const SizedBox(height: 40),

                    // Login Card
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Email Field
                          _buildModernTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hint: 'student@example.com',
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            colorScheme: colorScheme,
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          _buildModernTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            colorScheme: colorScheme,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey[400],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: true, // Allow full height if needed
                                  builder: (context) => const ForgotPasswordModal(),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Buttons Row
                          Row(
                            children: [
                              // Main Login Button
                              Expanded(
                                child: SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: authState.status == AuthStatus.loading
                                        ? null
                                        : () {
                                            authNotifier.login(
                                              _emailController.text.trim(),
                                              _passwordController.text.trim(),
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 4,
                                      shadowColor: colorScheme.primary.withOpacity(0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: authState.status == AuthStatus.loading
                                        ? const SizedBox(
                                            height: 24, width: 24,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          )
                                        : const Text(
                                            'Sign In',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                  ),
                                ),
                              ),

                              // Biometric Button (Conditional)
                              if (_canCheckBiometrics && _hasSavedCredentials) ...[
                                const SizedBox(width: 16),
                                SizedBox(
                                  height: 56,
                                  width: 56,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: _authenticate,
                                        child: Icon(
                                          Icons.fingerprint_rounded,
                                          color: colorScheme.primary,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "New to Kampus Koin? ",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (authState.status == AuthStatus.loading)
            const LoadingOverlay(message: 'Verifying credentials...'),
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
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}