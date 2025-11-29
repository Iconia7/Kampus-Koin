import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _onIntroEnd(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Consistent text styles
    final titleStyle = TextStyle(
      fontSize: 28.0,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF0F172A), // Dark slate
      letterSpacing: -0.5,
      fontFamily: Theme.of(context).textTheme.headlineLarge?.fontFamily,
    );
    
    final bodyStyle = TextStyle(
      fontSize: 16.0,
      height: 1.5,
      color: const Color(0xFF64748B), // Slate 500
      fontWeight: FontWeight.w500,
      fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
    );

    // Page decoration template
    final pageDecoration = PageDecoration(
      titleTextStyle: titleStyle,
      bodyTextStyle: bodyStyle,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      pageColor: Colors.transparent, // Transparent to show scaffold background
      imagePadding: const EdgeInsets.only(top: 80, bottom: 24),
      imageFlex: 3,
      bodyFlex: 2,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Background Decoration (Top Right Circle)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.05),
              ),
            ),
          ),
          // 2. Background Decoration (Bottom Left Circle)
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.secondary.withOpacity(0.05),
              ),
            ),
          ),

          // 3. The Intro Screen
          SafeArea(
            child: IntroductionScreen(
              globalBackgroundColor: Colors.transparent, // Important for stack
              allowImplicitScrolling: true,
              infiniteAutoScroll: false,
              
              pages: [
                // Page 1: Savings
                PageViewModel(
                  title: "Small Savings,\nBig Wins",
                  body: "Pay 25% upfront and unlock your dream laptop or phone instantly. We bridge the gap.",
                  image: _buildModernImage(
                    Icons.savings_rounded,
                    const [Color(0xFF10B981), Color(0xFF059669)], // Emerald
                  ),
                  decoration: pageDecoration,
                ),
                
                // Page 2: Tracking
                PageViewModel(
                  title: "Track Your\nProgress",
                  body: "Set goals, deposit via M-Pesa, and watch your savings grow in real-time.",
                  image: _buildModernImage(
                    Icons.insights_rounded,
                    const [Color(0xFF3B82F6), Color(0xFF2563EB)], // Blue
                  ),
                  decoration: pageDecoration,
                ),
                
                // Page 3: Rewards
                PageViewModel(
                  title: "Boost Your\nKoin Score",
                  body: "Earn points with every deposit. A higher Koin Score unlocks premium deals.",
                  image: _buildModernImage(
                    Icons.military_tech_rounded,
                    const [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber
                  ),
                  decoration: pageDecoration,
                ),
              ],
              
              onDone: () => _onIntroEnd(context),
              onSkip: () => _onIntroEnd(context),
              showSkipButton: true,
              skipOrBackFlex: 0,
              nextFlex: 0,
              showBackButton: false,
              back: const Icon(Icons.arrow_back),
              
              // --- Custom Button Styles ---
              
              // Skip Button
              skip: Text(
                'Skip',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
              ),
              
              // Next Button (Arrow)
              next: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ),
              
              // Done Button (Full "Get Started" Pill)
              done: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Get Started',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ),
              
              // Dots styling
              dotsDecorator: DotsDecorator(
                size: const Size(10.0, 10.0),
                color: Colors.grey[300]!,
                activeColor: colorScheme.primary,
                activeSize: const Size(22.0, 10.0),
                activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for the 3D-ish Icon
  Widget _buildModernImage(IconData icon, List<Color> colors) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Outer Glow
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  colors.first.withOpacity(0.1),
                  colors.first.withOpacity(0.0),
                ],
              ),
            ),
          ),
          // 2. Middle Ring
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.first.withOpacity(0.05),
              border: Border.all(
                color: colors.first.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          // 3. Main Gradient Circle
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 70,
              color: Colors.white,
            ),
          ),
          // 4. Specular Highlight (Shininess)
          Positioned(
            top: 45,
            right: 45,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.0),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}