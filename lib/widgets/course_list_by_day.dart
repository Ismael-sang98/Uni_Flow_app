import 'package:flutter/material.dart';
import 'package:mon_temps/providers/course_provider.dart';
import 'package:mon_temps/widgets/course_card.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

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
          return Center(
            child: Text(
              // Message lorsque aucun cours n'est prévu ce jour-là
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
