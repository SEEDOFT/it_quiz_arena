import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:it_quiz_arena/core/app_constants.dart';
import 'package:it_quiz_arena/services/auth_service.dart';

class LoginController extends ChangeNotifier {
  bool isGoogleLoading = false;
  String? errorMessage;

  Future<bool> googleLogin() async {
    isGoogleLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: AppConstants.googleServerClientId,
      );

      final completer = Completer<String?>();

      late StreamSubscription<GoogleSignInAuthenticationEvent> subscription;
      subscription = GoogleSignIn.instance.authenticationEvents.listen((event) {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          subscription.cancel();
          completer.complete(event.user.authentication.idToken);
        }
      });

      try {
        await GoogleSignIn.instance.authenticate();

        final idToken = await completer.future.timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            subscription.cancel();
            return null;
          },
        );

        if (idToken == null || idToken.isEmpty) {
          errorMessage = 'Failed to get ID token';
          isGoogleLoading = false;
          notifyListeners();
          return false;
        }

        await AuthService().loginWithGoogle(idToken);

        isGoogleLoading = false;
        notifyListeners();
        return true;
      } catch (e) {
        subscription.cancel();
        rethrow;
      }
    } on GoogleSignInException catch (e) {
      errorMessage = switch (e.code) {
        GoogleSignInExceptionCode.canceled => 'Sign-in cancelled',
        GoogleSignInExceptionCode.interrupted => 'Sign-in interrupted',
        GoogleSignInExceptionCode.clientConfigurationError =>
          'Configuration error — set googleServerClientId in app_constants.dart',
        GoogleSignInExceptionCode.providerConfigurationError =>
          e.description ?? 'Provider configuration error',
        GoogleSignInExceptionCode.uiUnavailable => 'UI unavailable',
        GoogleSignInExceptionCode.userMismatch => 'User mismatch',
        GoogleSignInExceptionCode.unknownError =>
          'Error (${e.description ?? "unknown"})',
      };
      isGoogleLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Error: ${e.toString()}';
      isGoogleLoading = false;
      notifyListeners();
      return false;
    }
  }
}
