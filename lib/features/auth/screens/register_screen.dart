// lib/features/auth/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_notifier.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Scale animation for logo
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _studentIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitRegister() {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // 1. Validate the form
    if (_formKey.currentState!.validate()) {
      // 2. Call the notifier
      ref
          .read(authNotifierProvider.notifier)
          .register(
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      body: Stack(
        children: [
          Stack(
            children: [
              // Animated gradient background
              AnimatedGradientBackground(),

              // Floating circles decoration
              ...List.generate(
                3,
                (index) => FloatingCircle(size: size, index: index),
              ),

              // Main content
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Animated logo/icon
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.secondary,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_add_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Glass morphism card
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
                                            colors: [
                                              colorScheme.primary,
                                              colorScheme.secondary,
                                            ],
                                          ).createShader(bounds),
                                      child: Text(
                                        'Create Account',
                                        style: textTheme.displayLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Let\'s get you started!',
                                      style: textTheme.bodyLarge?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    // Form Fields
                                    AnimatedFormField(
                                      controller: _nameController,
                                      label: 'FULL NAME',
                                      hint: 'John Doe',
                                      icon: Icons.person_outline,
                                      delay: 100,
                                      validator: (value) =>
                                          (value == null || value.isEmpty)
                                          ? 'Please enter your name'
                                          : null,
                                    ),

                                    const SizedBox(height: 20),

                                    AnimatedFormField(
                                      controller: _emailController,
                                      label: 'EMAIL ADDRESS',
                                      hint: 'student@daystar.ac.ke',
                                      icon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      delay: 200,
                                      validator: (value) =>
                                          (value == null ||
                                              !value.contains('@'))
                                          ? 'Please enter a valid email'
                                          : null,
                                    ),

                                    const SizedBox(height: 20),

                                    AnimatedFormField(
                                      controller: _phoneController,
                                      label: 'PHONE NUMBER',
                                      hint: '254712345678',
                                      icon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                      delay: 300,
                                      validator: (value) =>
                                          (value == null || value.length < 10)
                                          ? 'Enter a valid phone number (254...)'
                                          : null,
                                    ),

                                    const SizedBox(height: 20),

                                    AnimatedFormField(
                                      controller: _studentIdController,
                                      label: 'STUDENT ID (OPTIONAL)',
                                      hint: 'DSU123456',
                                      icon: Icons.school_outlined,
                                      delay: 400,
                                    ),

                                    const SizedBox(height: 20),

                                    AnimatedFormField(
                                      controller: _passwordController,
                                      label: 'PASSWORD',
                                      hint: '••••••••',
                                      icon: Icons.lock_outline,
                                      obscureText: _obscurePassword,
                                      delay: 500,
                                      validator: (value) =>
                                          (value == null || value.length < 6)
                                          ? 'Password must be at least 6 characters'
                                          : null,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Error Message
                                    if (authState.status == AuthStatus.error &&
                                        authState.errorMessage != null)
                                      Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: colorScheme.error.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: colorScheme.error
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              color: colorScheme.error,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                authState.errorMessage!,
                                                style: TextStyle(
                                                  color: colorScheme.error,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    // Register Button
                                    AnimatedRegisterButton(
                                      isLoading: isLoading,
                                      onPressed: _submitRegister,
                                    ),

                                    const SizedBox(height: 24),

                                    // Login Link
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Already have an account?",
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => context.pop(),
                                          child: ShaderMask(
                                            shaderCallback: (bounds) =>
                                                LinearGradient(
                                                  colors: [
                                                    colorScheme.primary,
                                                    colorScheme.secondary,
                                                  ],
                                                ).createShader(bounds),
                                            child: const Text(
                                              'Log In',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
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
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: colorScheme.primary),
                      const SizedBox(height: 16),
                      const Text(
                        'Creating account...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Reuse the same components from login screen
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({super.key});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF667eea),
                  const Color(0xFF764ba2),
                  _controller.value,
                )!,
                Color.lerp(
                  const Color(0xFF764ba2),
                  const Color(0xFFF093FB),
                  _controller.value,
                )!,
                Color.lerp(
                  const Color(0xFFF093FB),
                  const Color(0xFF667eea),
                  _controller.value,
                )!,
              ],
            ),
          ),
        );
      },
    );
  }
}

class FloatingCircle extends StatefulWidget {
  final Size size;
  final int index;

  const FloatingCircle({super.key, required this.size, required this.index});

  @override
  State<FloatingCircle> createState() => _FloatingCircleState();
}

class _FloatingCircleState extends State<FloatingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 4 + widget.index * 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final positions = [
      {'top': 0.1, 'left': -0.1, 'size': 150.0},
      {'top': 0.6, 'right': -0.1, 'size': 200.0},
      {'top': 0.3, 'left': 0.1, 'size': 100.0},
    ];

    final pos = positions[widget.index];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top:
              (pos['top'] as double) * widget.size.height +
              (_controller.value * 50 - 25),
          left: pos.containsKey('left')
              ? (pos['left'] as double) * widget.size.width
              : null,
          right: pos.containsKey('right')
              ? (pos['right'] as double) * widget.size.width
              : null,
          child: Container(
            width: pos['size'] as double,
            height: pos['size'] as double,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final int delay;
  final String? Function(String?)? validator;

  const AnimatedFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.delay = 0,
    this.validator,
  });

  @override
  State<AnimatedFormField> createState() => _AnimatedFormFieldState();
}

class _AnimatedFormFieldState extends State<AnimatedFormField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(_animation),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Focus(
              onFocusChange: (focused) {
                setState(() => _isFocused = focused);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isFocused
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300]!,
                    width: _isFocused ? 2 : 1,
                  ),
                  boxShadow: _isFocused
                      ? [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: TextFormField(
                  controller: widget.controller,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  validator: widget.validator,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    prefixIcon: Icon(widget.icon),
                    suffixIcon: widget.suffixIcon,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedRegisterButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const AnimatedRegisterButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<AnimatedRegisterButton> createState() => _AnimatedRegisterButtonState();
}

class _AnimatedRegisterButtonState extends State<AnimatedRegisterButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'CREATE ACCOUNT',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
