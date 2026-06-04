import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPageModel {
  final IconData icon;
  final String title;
  final String body;

  OnboardingPageModel({
    required this.icon,
    required this.title,
    required this.body,
  });
}

class OnboardingController extends ChangeNotifier {
  final PageController pageController = PageController();
  int currentPage = 0;
  final VoidCallback onFinished;

  final List<OnboardingPageModel> pages = [
    OnboardingPageModel(
      icon: Icons.psychology,
      title: 'Test Your Knowledge',
      body: 'Challenge yourself with thousands of IT questions.',
    ),
    OnboardingPageModel(
      icon: Icons.emoji_events,
      title: 'Climb The Ranks',
      body: 'Earn XP and level up through all IT ranks.',
    ),
    OnboardingPageModel(
      icon: Icons.timer,
      title: 'Beat The Clock',
      body: 'Answer before time runs out.',
    ),
  ];

  OnboardingController({required this.onFinished});

  void onPageChanged(int index) {
    currentPage = index;
    notifyListeners();
  }

  void next() async {
    if (currentPage == pages.length - 1) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_done', true);
      onFinished();
      return;
    }

    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
