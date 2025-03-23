import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gridguardian/firebase_options.dart';
import 'package:gridguardian/screens/onboarding_screen.dart';
import 'package:gridguardian/screens/error_fallback_screen.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:gridguardian/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logger = Logger();
  SharedPreferences? prefs;
  FirebaseApp? firebaseApp;

  try {
    // Initialize critical dependencies first
    prefs = await SharedPreferences.getInstance();
    firebaseApp = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.i('Firebase initialized successfully!');
  } catch (e, stackTrace) {
    logger.e('Critical initialization error', error: e, stackTrace: stackTrace);
    runApp(ErrorFallbackScreen(error: e, stackTrace: stackTrace));
    return;
  }

  // Initialize theme provider with preferences
  final themeProvider = ThemeProvider(prefs);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        Provider.value(value: firebaseApp),
        Provider.value(value: logger),
        // Add other providers here
      ],
      child: const GridGuardianApp(),
    ),
  );
}

class GridGuardianApp extends StatelessWidget {
  const GridGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Grid Guardian',
          debugShowCheckedModeBanner: false,
          theme: ThemeProvider.lightTheme,
          darkTheme: ThemeProvider.darkTheme,
          themeMode: themeProvider.currentThemeMode,
          home: const OnboardingScreen(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(themeProvider.textScaleFactor),
            ),
            child: child!,
          ),
          navigatorObservers: [
            Provider.of<Logger>(context).observer,
          ],
        );
      },
    );
  }
}

// Logger extension for navigation observing
extension LoggerNavigationObserver on Logger {
  NavigatorObserver get observer => _LoggerNavigatorObserver(this);
}

class _LoggerNavigatorObserver extends NavigatorObserver {
  final Logger _logger;

  _LoggerNavigatorObserver(this._logger);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logger.d('Navigated to: ${route.settings.name}');
  }
}
