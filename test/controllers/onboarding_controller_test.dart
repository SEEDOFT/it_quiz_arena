import 'package:flutter_test/flutter_test.dart';
import 'package:it_quiz_arena/screens/onboarding/onboarding_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('OnboardingController', () {
    test('starts on page 0', () {
      final ctrl = OnboardingController(onFinished: () {});

      expect(ctrl.currentPage, 0);
      expect(ctrl.pages.length, 3);
      ctrl.dispose();
    });

    test('onPageChanged updates currentPage', () {
      final ctrl = OnboardingController(onFinished: () {});

      ctrl.onPageChanged(1);
      expect(ctrl.currentPage, 1);

      ctrl.onPageChanged(2);
      expect(ctrl.currentPage, 2);
      ctrl.dispose();
    });

    test('next on last page marks onboarding_done and calls onFinished', () async {
      var finished = false;
      final ctrl = OnboardingController(onFinished: () => finished = true);

      ctrl.currentPage = 2;
      ctrl.next();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(finished, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboarding_done'), true);
      ctrl.dispose();
    });

    test('dispose cleans up without error', () {
      final ctrl = OnboardingController(onFinished: () {});

      expect(() => ctrl.dispose(), returnsNormally);
    });
  });
}
