import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/ui_constants.dart';
import '../l10n/app_localizations.dart';
import '../models/deadline.dart';
import '../providers/deadlines_provider.dart';
import '../screens/deadline_details_page.dart';

enum _DeadlineFilter { upcoming, late, completed }

/// Vue "Échéances" (examens/devoirs/autres) — onglet dédié à côté de
/// Planning et Bibliothèque de notes, avec 3 filtres (à venir/en retard/
/// terminées) plutôt que mélangé avec les cours récurrents.
class DeadlinesView extends StatefulWidget {
  const DeadlinesView({super.key});

  @override
  State<DeadlinesView> createState() => _DeadlinesViewState();
}

class _DeadlinesViewState extends State<DeadlinesView> {
  _DeadlineFilter _filter = _DeadlineFilter.upcoming;

  IconData _typeIcon(DeadlineType type) {
    switch (type) {
      case DeadlineType.exam:
        return Icons.school_outlined;
      case DeadlineType.homework:
        return Icons.edit_note_outlined;
      case DeadlineType.other:
        return Icons.event_outlined;
    }
  }

  /// Libellé relatif ("Aujourd'hui", "Demain", "Dans 5 jours", "En retard de
  /// 2 jours") plutôt qu'une simple date — plus lisible pour juger de
  /// l'urgence d'un coup d'œil, cohérent avec l'aperçu validé pour ce choix
  /// de design.
  String _relativeDueLabel(AppLocalizations l10n, DateTime dueAt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueAt.year, dueAt.month, dueAt.day);
    final diffDays = due.difference(today).inDays;

    if (diffDays == 0) return l10n.deadlineDueToday;
    if (diffDays == 1) return l10n.deadlineDueTomorrow;
    if (diffDays > 1) return l10n.deadlineDueInDays(diffDays);
    return l10n.deadlineOverdueDays(-diffDays);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: SegmentedButton<_DeadlineFilter>(
            segments: [
              ButtonSegment(
                value: _DeadlineFilter.upcoming,
                label: Text(l10n.deadlinesFilterUpcoming),
              ),
              ButtonSegment(
                value: _DeadlineFilter.late,
                label: Text(l10n.deadlinesFilterLate),
              ),
              ButtonSegment(
                value: _DeadlineFilter.completed,
                label: Text(l10n.deadlinesFilterCompleted),
              ),
            ],
            selected: {_filter},
            onSelectionChanged: (selected) =>
                setState(() => _filter = selected.first),
          ),
        ),
        Expanded(
          child: Consumer<DeadlinesProvider>(
            builder: (context, provider, _) {
              final deadlines = switch (_filter) {
                _DeadlineFilter.upcoming => provider.upcoming,
                _DeadlineFilter.late => provider.late,
                _DeadlineFilter.completed => provider.completed,
              };

              if (deadlines.isEmpty) {
                final message = switch (_filter) {
                  _DeadlineFilter.upcoming => l10n.deadlinesEmptyUpcoming,
                  _DeadlineFilter.late => l10n.deadlinesEmptyLate,
                  _DeadlineFilter.completed => l10n.deadlinesEmptyCompleted,
                };
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.spacing24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_available_outlined,
                          size: UIConstants.emptyStateIconSize,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: UIConstants.spacing12),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: UIConstants.fontSize15,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                itemCount: deadlines.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: UIConstants.spacing12),
                itemBuilder: (context, index) {
                  final deadline = deadlines[index];
                  final isLate =
                      !deadline.isCompleted &&
                      deadline.dueAt.isBefore(DateTime.now());
                  final color = deadline.isCompleted
                      ? Colors.grey
                      : (isLate ? Colors.redAccent : const Color(0xFF6C63FF));

                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(
                        UIConstants.borderRadius16,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: UIConstants.opacity04,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(
                          16,
                          8,
                          8,
                          8,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DeadlineDetailsPage(deadlineId: deadline.id),
                          ),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.15),
                          child: Icon(_typeIcon(deadline.type), color: color),
                        ),
                        title: Text(
                          deadline.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            decoration: deadline.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          deadline.isCompleted
                              ? DateFormat('dd/MM/yyyy').format(deadline.dueAt)
                              : _relativeDueLabel(l10n, deadline.dueAt),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            deadline.isCompleted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: color,
                          ),
                          onPressed: () => context
                              .read<DeadlinesProvider>()
                              .toggleCompleted(deadline.id),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
