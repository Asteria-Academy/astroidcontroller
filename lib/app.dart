import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'router/app_router.dart';
import 'l10n/app_localizations.dart';
import 'services/preferences_service.dart';
import 'services/sound_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  final _lifecycleObserver = _AppLifecycleObserver();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    _loadLocale();
    SoundService.instance.ensurePlaying();
  }

  void _loadLocale() {
    final prefs = PreferencesService.instance;
    final savedLanguage = prefs.getSavedLanguage();

    if (savedLanguage != null) {
      setState(() {
        _locale = Locale(savedLanguage);
      });
    } else {
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      
      final supportedLanguages = AppLocalizations.supportedLocales.map((l) => l.languageCode);
      String languageToSet = 'en'; 
      if (supportedLanguages.contains(deviceLocale.languageCode)) {
        languageToSet = deviceLocale.languageCode;
      }

      prefs.setLanguage(languageToSet);

      setState(() {
        _locale = Locale(languageToSet);
      });
    }
  }

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Astroid Remote',
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('id'), // Bahasa Indonesia
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
        primaryColor: Colors.deepPurpleAccent,
        fontFamily: GoogleFonts.poppins().fontFamily,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: AppRoutes.splash, // Start with splash screen
      onGenerateRoute: onGenerateRoute,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }
}

class _AppLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        SoundService.instance.resumeBgmIfEnabled();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        SoundService.instance.pauseBgm();
        break;
    }
  }
}
