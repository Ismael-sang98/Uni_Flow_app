import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mon_temps/screens/profile_page.dart';
import 'package:mon_temps/services/notification_service.dart';
import '../l10n/app_localizations.dart';

// --- PAGE DE BIENVENUE ---
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const String appVersion = "1.7.0";
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final isMediumScreen = screenSize.height >= 600 && screenSize.height < 800;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: screenSize.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: isLandscape
              ? _buildLandscapeLayout(context, l10n, appVersion)
              : _buildPortraitLayout(context, l10n, appVersion, isMediumScreen),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    AppLocalizations l10n,
    String appVersion,
    bool isMediumScreen,
  ) {
    final contentSpacing = isMediumScreen ? 20.0 : 30.0;
    final buttonHeight = 56.0;

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Image.asset(
                          'assets/icon_bienvenue.png',
                          width: 140,
                          height: 140,
                        ),
                      ),
                      SizedBox(height: contentSpacing),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          l10n.welcomeTitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: isMediumScreen ? 26 : 32,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          l10n.welcomeSubtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: isMediumScreen ? 13 : 15,
                          ),
                        ),
                      ),
                      SizedBox(height: isMediumScreen ? 30.0 : 50.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: () async {
                              await NotificationService().requestPermissions();
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProfilePage(),
                                  ),
                                );
                              }
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            children: [
              Text(
                l10n.versionLabel(appVersion),
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.madeWithLoveBy,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  Text(
                    "Ismaël Sanogo",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    AppLocalizations l10n,
    String appVersion,
  ) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'assets/icon_bienvenue.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.welcomeTitle,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          l10n.welcomeSubtitle,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        SizedBox(
                          width: 180,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              await NotificationService().requestPermissions();
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProfilePage(),
                                  ),
                                );
                              }
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
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.versionLabel(appVersion),
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
                const SizedBox(width: 16.0),
                Text(
                  l10n.madeWithLoveBy,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
                Text(
                  "Ismaël Sanogo",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
