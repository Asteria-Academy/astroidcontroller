import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'router/app_router.dart';
import 'l10n/app_localizations.dart';
import 'services/preferences_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  void _loadLocale() {
    final savedLanguage = PreferencesService.instance.getSavedLanguage();

    if (savedLanguage != null) {
      // User has explicitly chosen a language
      setState(() {
        _locale = Locale(savedLanguage);
      });
    } else {
      // First time - detect device language
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final languageCode = deviceLocale.languageCode;

      // Check if device language is Indonesian, otherwise default to English
      final selectedLanguage = (languageCode == 'id') ? 'id' : 'en';

      // Save the detected language for future use
      PreferencesService.instance.setLanguage(selectedLanguage);

      setState(() {
        _locale = Locale(selectedLanguage);
      });
    }
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
}
