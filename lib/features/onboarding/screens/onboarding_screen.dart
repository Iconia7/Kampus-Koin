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
    
    const bodyStyle = TextStyle(
      fontSize: 17.0,
      height: 1.5,
      color: Color(0xFF64748B),
      fontWeight: FontWeight.w400,
    );
    
    final pageDecoration = PageDecoration(
      titleTextStyle: const TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
        height: 1.2,
        letterSpacing: -0.5,
      ),
      bodyTextStyle: bodyStyle,
      bodyPadding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
      pageColor: Colors.white,
      imagePadding: const EdgeInsets.only(top: 100),
      imageFlex: 3,
      bodyFlex: 2,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IntroductionScreen(
          globalBackgroundColor: Colors.white,
          allowImplicitScrolling: true,
          
          pages: [
            PageViewModel(
              title: "Save Small,\nWin Big",
              body: "Don't have the full cash? Pay 25% now and unlock your dream laptop or phone immediately.",
              image: _buildModernImage(
                Icons.savings_rounded,
                const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Track Your\nGoals",
              body: "Set savings goals, deposit via M-Pesa, and watch your progress grow in real-time.",
              image: _buildModernImage(
                Icons.trending_up_rounded,
                const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Build Your\nKoin Score",
              body: "Every deposit and repayment earns you points. A higher score unlocks better deals.",
              image: _buildModernImage(
                Icons.workspace_premium_rounded,
                const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
          
          skip: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: const Text(
              'Skip',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                fontSize: 16,
              ),
            ),
          ),
          
          next: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          done: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          
          dotsDecorator: DotsDecorator(
            size: const Size(10.0, 10.0),
            color: const Color(0xFFE2E8F0),
            activeColor: colorScheme.primary,
            activeSize: const Size(28.0, 10.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
          
          controlsMargin: const EdgeInsets.all(24),
          controlsPadding: const EdgeInsets.all(8),
        ),
      ),
    );
  }

  Widget _buildModernImage(IconData icon, Gradient gradient) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow circle
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  gradient.colors.first.withOpacity(0.1),
                  gradient.colors.first.withOpacity(0.0),
                ],
              ),
            ),
          ),
          // Middle decorative circle
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  gradient.colors.first.withOpacity(0.15),
                  gradient.colors.last.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Main icon container with gradient
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 80,
              color: Colors.white,
            ),
          ),
          // Subtle highlight
          Positioned(
            top: 55,
            right: 75,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
        ], 
      ),
    );
  }
}