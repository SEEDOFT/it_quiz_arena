import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:it_quiz_arena/core/app_constants.dart';
import 'package:it_quiz_arena/screens/home/home_screen.dart';

import 'login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController();
  }

  Future<void> _handleGoogleLogin() async {
    final success = await _controller.googleLogin();
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(
            numberOfQuestions: AppConstants.defaultQuestionCount,
            timePerQuestion: AppConstants.defaultTimePerQuestion,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    Icon(Icons.computer, size: 100, color: cs.primary),
                    const SizedBox(height: 32),
                    Text(
                      AppConstants.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Test your IT knowledge, climb the ranks,\nand become a legend',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.outline, fontSize: 15, height: 1.4),
                    ),
                    const Spacer(flex: 1),
                    if (_controller.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _controller.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: cs.error, fontSize: 13),
                        ),
                      ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _controller.isGoogleLoading ? null : _handleGoogleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        icon: _controller.isGoogleLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black87,
                                ),
                              )
                            : SvgPicture.asset(
                                AppConstants.googleLogo,
                                height: 24,
                                width: 24,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.login, color: Colors.black87),
                              ),
                        label: Text(
                          _controller.isGoogleLoading ? 'Signing in...' : 'Sign in with Google',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
