import 'package:flutter/material.dart';
import 'package:mon_temps/widgets/course_list_by_day.dart';
import '../l10n/app_localizations.dart';

// --- VUE DU PLANNING HEBDOMADAIRE ---
class WeeklyScheduleView extends StatelessWidget {
  const WeeklyScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Jours de la semaine en français (abréviations)
    final List<String> days = [
      l10n.jAb1,
      l10n.jAb2,
      l10n.jAb3,
      l10n.jAb4,
      l10n.jAb5,
      l10n.jAb6,
      l10n.jAb7,
    ];
    // Index initial basé sur le jour actuel (0 = Lundi, 6 = Dimanche)
    final int today = DateTime.now().weekday;
    // DateTime.weekday retourne 1 pour Lundi jusqu'à 7 pour Dimanche
    final int initialIndex = today - 1;

    // Contrôleur d'onglets pour gérer les vues par jour
    return DefaultTabController(
      length: 7,
      initialIndex: initialIndex,
      child: Column(
        children: [
          const SizedBox(height: 15),
          SizedBox(
            height: 45,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: const Color(0xFF6C63FF),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              tabs: days
                  .map(
                    (day) => Tab(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(day),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: TabBarView(
              children: List.generate(
                7,
                // --- VUE DES COURS PAR JOUR ---
                (index) => CourseListByDay(dayOfWeek: index + 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
