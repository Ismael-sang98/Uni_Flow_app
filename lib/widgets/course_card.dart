import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mon_temps/models/course.dart';
import 'package:mon_temps/screens/course_details_page.dart';
import 'package:mon_temps/l10n/app_localizations.dart';

// --- CARTE DE COURS ---
class CourseCard extends StatelessWidget {
  final Course course;
  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final color = Color(course.color);
    final timeFormat = DateFormat.Hm();
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        // Au clic, on ouvre la page d'ajout MAIS on lui passe le cours actuel
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseDetailsPage(
              courseId: course.id,
            ), // <-- C'est ici la magie
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 18,
                child: Container(color: color),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: color,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "${timeFormat.format(course.startTime)} - ${timeFormat.format(course.endTime)}",
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          course.location?.isNotEmpty == true
                              ? course.location!
                              : l10n.labLocation, // Affiche "Lieu non spécifié" si location est vide ou nulle
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
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
    );
  }
}
