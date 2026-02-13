import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import 'add_course_page.dart';
import '../l10n/app_localizations.dart';

class CourseDetailsPage extends StatelessWidget {
  final String courseId;

  const CourseDetailsPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<CourseProvider>(
      builder: (context, provider, child) {
        // On cherche la version la plus récente du cours dans le provider
        // (au cas où on vient de le modifier)
        final Course? course = provider.courses
            .where((c) => c.id == courseId)
            .firstOrNull;

        // Si le cours a été supprimé entre temps (cas rare), on ferme la page
        if (course == null) {
          return Scaffold(body: Center(child: Text(l10n.courseNotFound)));
        }

        final color = Color(course.color);
        final timeFormat = DateFormat.Hm();

        // Petite astuce pour avoir le nom du jour en français
        final List<String> days = [
          l10n.j1,
          l10n.j2,
          l10n.j3,
          l10n.j4,
          l10n.j5,
          l10n.j6,
          l10n.j7,
        ];
        final String dayName = days[course.dayOfWeeks - 1];

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.courseDetails),
            backgroundColor: color,
            foregroundColor: Colors.white,
            actions: [
              // Bouton supprimer directement ici aussi
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _confirmDelete(context, provider, course);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // En-tête coloré avec le titre
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.school, size: 60, color: Colors.white54),
                      const SizedBox(height: 20),
                      Text(
                        course.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          dayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Informations détaillées
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        icon: Icons.access_time,
                        label: l10n.hrs,
                        value:
                            "${timeFormat.format(course.startTime)} - ${timeFormat.format(course.endTime)}",
                        color: color,
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow(
                        icon: Icons.location_on,
                        label: l10n.location,
                        value: course.location?.isNotEmpty == true
                            ? course.location!
                            : l10n.labLocation,
                        color: color,
                      ),
                      // Vous pouvez ajouter d'autres infos ici (Professeur, Description...)
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Le bouton pour passer en mode MODIFICATION
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddCoursePage(courseToEdit: course),
                ),
              );
            },
            icon: const Icon(Icons.edit),
            // label: const Text("Modifier"), --- IGNORE ---
            label: Text(l10n.btMod),
            backgroundColor: color,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  // Widget helper pour les lignes d'info
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }

  void _confirmDelete(
    BuildContext context,
    CourseProvider provider,
    Course course,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmSupprTitle),
        content: Text(l10n.deleteCourseMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.rejet),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteCourse(course.id);
              Navigator.pop(ctx); // Ferme dialogue
              Navigator.pop(context); // Ferme page détails
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.supp),
          ),
        ],
      ),
    );
  }
}
