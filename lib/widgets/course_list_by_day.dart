import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mon_temps/providers/course_provider.dart';
import 'package:mon_temps/widgets/course_card.dart';
import 'package:provider/provider.dart';
import '../constants/ui_constants.dart';
import '../l10n/app_localizations.dart';
import '../screens/api_settings_page.dart';

// --- LISTE DES COURS PAR JOUR ---
class CourseListByDay extends StatelessWidget {
  final int dayOfWeek;
  const CourseListByDay({super.key, required this.dayOfWeek});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<CourseProvider>(
      builder: (context, provider, child) {
        final dailyCourses = provider.courses
            .where((c) => c.dayOfWeeks == dayOfWeek)
            .toList();
        if (dailyCourses.isEmpty) {
          // Un jour vide est normal (pas de cours ce jour-là) ; on ne
          // propose la synchro que si l'emploi du temps est entièrement
          // vide ET qu'aucune synchro n'a jamais eu lieu, sinon ce message
          // s'afficherait à tort sur un simple jour "off".
          final hasNeverSynced =
              Hive.box('settings').get('last_sync_at') == null;
          if (provider.courses.isEmpty && hasNeverSynced) {
            return _EmptyScheduleState(l10n: l10n);
          }
          return Center(
            child: Text(
              l10n.videLab,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          itemCount: dailyCourses.length,
          itemBuilder: (context, index) =>
              // Affichage de la carte de cours
              CourseCard(course: dailyCourses[index]),
        );
      },
    );
  }
}

class _EmptyScheduleState extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptyScheduleState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: UIConstants.emptyStateIconSize,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: UIConstants.spacing12),
            Text(
              l10n.scheduleEmptyStateMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: UIConstants.fontSize15,
              ),
            ),
            SizedBox(height: UIConstants.spacing16),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ApiSettingsPage()),
              ),
              icon: const Icon(Icons.sync),
              label: Text(l10n.fullSyncButton),
            ),
          ],
        ),
      ),
    );
  }
}
