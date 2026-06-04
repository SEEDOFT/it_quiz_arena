import 'package:flutter/material.dart';
import 'package:it_quiz_arena/core/app_constants.dart';
import 'package:it_quiz_arena/screens/home/home_screen.dart';
import 'package:it_quiz_arena/screens/login/login_screen.dart';
import 'package:it_quiz_arena/screens/onboarding/onboarding_screen.dart';
import 'splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late final SplashController _controller;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _controller = SplashController(
      onAuthenticated: _navigateToHome,
      onShowOnboarding: _navigateToOnboarding,
      onShowLogin: _navigateToLogin,
    );
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            numberOfQuestions: AppConstants.defaultQuestionCount,
            timePerQuestion: AppConstants.defaultTimePerQuestion,
          ),
        ),
      );
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _navigateToOnboarding() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.memory, size: 90, color: cs.primary),
                const SizedBox(height: 20),
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'v${AppConstants.appVersion}',
                  style: TextStyle(color: cs.outline, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
