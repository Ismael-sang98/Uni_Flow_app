import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mon_temps/screens/profile_page.dart';
import '../l10n/app_localizations.dart';

// --- PAGE DE BIENVENUE ---
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
          ),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 90),
                Container(
                  padding: const EdgeInsets.all(35),
                  child: Image.asset(
                    'assets/icon_bienvenue.png',
                    width: 150,
                    height: 150,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  // Utilisation de la localisation pour le titre de bienvenue
                  l10n.welcomeTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  // Utilisation de la localisation pour le sous-titre de bienvenue
                  l10n.welcomeSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 170),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 40,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfilePage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4834D4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        l10n.getStartedButton,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    children: [
                      Text(
                        "Version 1.0.0",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Made with ❤️ by ",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            "Ismaël Sanogo", // Mets ton nom ici !
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).primaryColor, // Ton bleu/violet
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
