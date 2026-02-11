import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:mon_temps/l10n/app_localizations.dart';
import 'package:mon_temps/screens/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mon_temps/screens/welcome_page.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Vérification de l'existence d'un profil utilisateur
    final profileBox = Hive.box('settings');
    final hasProfile = profileBox.get('profile') != null;

    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Application Title
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      //l10n.appTitle,
      // --- INTERNATIONALISATION ---
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('fr'), Locale('tr')],

      themeMode: themeProvider.themeMode,

      // --- THÉME CLAIRE ---
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          primary: const Color(0xFF6C63FF),
          secondary: const Color(0xFFFF6584),
          surface: const Color(0xFFF4F6F8),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6C63FF),
          foregroundColor: Colors.white,
        ),
      ),

      // --- THÉME FONCÉE ---
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.fromSeed(
          //brightness: Brightness.dark, --- IGNORE ---
          brightness: Brightness.dark,
          seedColor: const Color(0xFF6C63FF),
          primary: const Color(0xFF8E84FF),
          surface: const Color(0xFF1E1E2C),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E2C),
          foregroundColor: Colors.white,
        ),
      ),

      home: hasProfile ? HomePage() : WelcomePage(),
    );
  }
}
