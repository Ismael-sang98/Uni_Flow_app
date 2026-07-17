import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/ui_constants.dart';
import '../l10n/app_localizations.dart';
import '../models/deadline.dart';
import '../providers/deadlines_provider.dart';
import '../services/confirm_deletion.dart';
import 'add_deadline_page.dart';

class DeadlineDetailsPage extends StatelessWidget {
  final String deadlineId;

  const DeadlineDetailsPage({super.key, required this.deadlineId});

  String _typeLabel(AppLocalizations l10n, DeadlineType type) {
    switch (type) {
      case DeadlineType.exam:
        return l10n.deadlineTypeExam;
      case DeadlineType.homework:
        return l10n.deadlineTypeHomework;
      case DeadlineType.other:
        return l10n.deadlineTypeOther;
    }
  }

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

  Future<void> _delete(BuildContext context, Deadline deadline) async {
    final confirmed = await confirmDeletion(context, deadline.title);
    if (!confirmed) return;
    if (!context.mounted) return;
    await context.read<DeadlinesProvider>().deleteDeadline(deadline.id);
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Selector plutôt que Consumer : ne reconstruit que si CETTE échéance
    // change vraiment (voir CourseDetailsPage pour le même principe).
    return Selector<DeadlinesProvider, Deadline?>(
      selector: (_, provider) =>
          provider.deadlines.where((d) => d.id == deadlineId).firstOrNull,
      builder: (context, deadline, child) {
        if (deadline == null) {
          return Scaffold(body: Center(child: Text(l10n.deadlineNotFound)));
        }

        final isLate =
            !deadline.isCompleted && deadline.dueAt.isBefore(DateTime.now());
        final color = isLate
            ? Colors.redAccent
            : (deadline.isCompleted ? Colors.grey : const Color(0xFF6C63FF));

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.deadlineDetailsTitle),
            backgroundColor: color,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddDeadlinePage(deadlineToEdit: deadline),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(context, deadline),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(UIConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_typeIcon(deadline.type), color: color),
                    const SizedBox(width: UIConstants.spacing8),
                    Text(
                      _typeLabel(l10n, deadline.type),
                      style: TextStyle(color: color, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: UIConstants.spacing12),
                Text(
                  deadline.title,
                  style: const TextStyle(
                    fontSize: UIConstants.fontSize22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: UIConstants.spacing12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: UIConstants.iconSize18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: UIConstants.spacing8),
                    Text(
                      DateFormat('dd/MM/yyyy à HH:mm').format(deadline.dueAt),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
                if (deadline.subject != null &&
                    deadline.subject!.isNotEmpty) ...[
                  const SizedBox(height: UIConstants.spacing8),
                  Row(
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: UIConstants.iconSize18,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: UIConstants.spacing8),
                      Text(
                        deadline.subject!,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ],
                if (deadline.notes != null && deadline.notes!.isNotEmpty) ...[
                  const SizedBox(height: UIConstants.spacing16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(UIConstants.spacing16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(
                        UIConstants.borderRadius16,
                      ),
                    ),
                    child: Text(deadline.notes!),
                  ),
                ],
                const SizedBox(height: UIConstants.spacing24),
                SizedBox(
                  width: double.infinity,
                  height: UIConstants.buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: () => context
                        .read<DeadlinesProvider>()
                        .toggleCompleted(deadline.id),
                    icon: Icon(
                      deadline.isCompleted
                          ? Icons.replay_outlined
                          : Icons.check_circle_outline,
                    ),
                    label: Text(
                      deadline.isCompleted
                          ? l10n.deadlineMarkIncomplete
                          : l10n.deadlineMarkComplete,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
