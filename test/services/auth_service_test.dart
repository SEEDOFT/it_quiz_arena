import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:it_quiz_arena/services/auth_service.dart';

void main() {
  group('AuthService', () {
    late AuthService auth;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      auth = AuthService();
    });

    test('init loads empty state when no prefs', () async {
      await auth.init();
      expect(auth.isAuthenticated, false);
      expect(auth.token, null);
      expect(auth.user, null);
    });

    test('init loads token and user from prefs', () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'test-token',
        'auth_user': '{"name": "Test", "email": "test@test.com"}',
      });
      auth = AuthService();
      await auth.init();

      expect(auth.isAuthenticated, true);
      expect(auth.token, 'test-token');
      expect(auth.user!['name'], 'Test');
    });

    test('isAuthenticated false when token missing', () async {
      SharedPreferences.setMockInitialValues({
        'auth_user': '{"name": "Test"}',
      });
      auth = AuthService();
      await auth.init();

      expect(auth.isAuthenticated, false);
    });

    test('isAuthenticated false when user missing', () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'token',
      });
      auth = AuthService();
      await auth.init();

      expect(auth.isAuthenticated, false);
    });

    test('updateUser updates in-memory and persists', () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'token',
        'auth_user': '{"name": "Old"}',
      });
      auth = AuthService();
      await auth.init();

      auth.updateUser({'name': 'New', 'email': 'new@test.com'});

      expect(auth.user!['name'], 'New');

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('auth_user');
      expect(saved, contains('New'));
    });

    test('logout clears token and user', () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'token',
        'auth_user': '{"name": "Test"}',
      });
      auth = AuthService();
      await auth.init();

      await auth.logout();

      expect(auth.isAuthenticated, false);
      expect(auth.token, null);
      expect(auth.user, null);
    });

    test('clearSession clears without API call', () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'token',
        'auth_user': '{"name": "Test"}',
      });
      auth = AuthService();
      await auth.init();

      await auth.clearSession();

      expect(auth.isAuthenticated, false);
    });

    test('authHeaders includes Authorization when token present', () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'my-token',
        'auth_user': '{}',
      });
      auth = AuthService();
      await auth.init();

      final headers = auth.authHeaders;

      expect(headers['Authorization'], 'Bearer my-token');
      expect(headers['Content-Type'], 'application/json');
    });

    test('authHeaders excludes Authorization when no token', () async {
      await auth.init();
      final headers = auth.authHeaders;

      expect(headers.containsKey('Authorization'), false);
    });
  });
}
