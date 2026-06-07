import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:it_quiz_arena/screens/login/login_controller.dart';
import 'package:it_quiz_arena/services/auth_service.dart';

void main() {
  setUp(() async {
    await dotenv.load(fileName: '.env');
    SharedPreferences.setMockInitialValues({});
    await AuthService().clearSession();
  });

  group('LoginController', () {
    test('initial state has no loading and no error', () {
      final ctrl = LoginController();

      expect(ctrl.isGoogleLoading, false);
      expect(ctrl.errorMessage, isNull);
      ctrl.dispose();
    });

    test('googleLogin sets loading state', () async {
      final ctrl = LoginController();

      expect(ctrl.isGoogleLoading, false);
      ctrl.googleLogin().catchError((_) => false);
      expect(ctrl.isGoogleLoading, true);
      // let the method complete async to avoid unhandled errors
      await Future.delayed(const Duration(milliseconds: 100));
      ctrl.dispose();
    });

    test('dispose cleans up without error', () {
      final ctrl = LoginController();

      expect(() => ctrl.dispose(), returnsNormally);
    });
  });
}
