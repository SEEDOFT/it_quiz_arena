import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'core/app_constants.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'services/api_service.dart';
import 'services/audio_service.dart';
import 'services/auth_service.dart';
import 'services/connectivity_service.dart';
import 'services/settings_service.dart';
import 'widgets/connectivity_banner.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppThemeNotifier extends ChangeNotifier {
  static final AppThemeNotifier _instance = AppThemeNotifier._();
  factory AppThemeNotifier() => _instance;
  AppThemeNotifier._();

  String _themeMode = 'system';
  String get themeMode => _themeMode;

  Future<void> load() async {
    final settings = await SettingsService().load();
    _themeMode = settings.themeMode;
    notifyListeners();
  }

  void setTheme(String mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  await GoogleSignIn.instance.initialize(
    serverClientId: AppConstants.googleServerClientId,
  );

  await AuthService().init();
  await AudioService().init();
  ApiService.onUnauthorized = () async {
    await AuthService().clearSession();
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (_) => false,
    );
  };
  await AppThemeNotifier().load();
  await ConnectivityService().init();

  runApp(const ITQuizArenaApp());
}

class ITQuizArenaApp extends StatefulWidget {
  const ITQuizArenaApp({super.key});

  @override
  State<ITQuizArenaApp> createState() => _ITQuizArenaAppState();
}

class _ITQuizArenaAppState extends State<ITQuizArenaApp> {
  @override
  void initState() {
    super.initState();
    AppThemeNotifier().addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    AppThemeNotifier().removeListener(_onThemeChanged);
    AudioService().dispose();
    super.dispose();
  }

  ThemeData _getTheme() {
    final mode = AppThemeNotifier().themeMode;
    if (mode == 'dark') {
      return AppTheme.darkTheme();
    } else if (mode == 'light') {
      return AppTheme.lightTheme();
    }
    return SettingsService.isSystemDarkMode()
        ? AppTheme.darkTheme()
        : AppTheme.lightTheme();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      navigatorKey: navigatorKey,
      theme: _getTheme(),
      routes: AppRoutes.getRoutes(),
      home: const SplashScreen(),
      builder: (context, child) =>
          ConnectivityBanner(child: child ?? const SizedBox.shrink()),
    );
  }
}
