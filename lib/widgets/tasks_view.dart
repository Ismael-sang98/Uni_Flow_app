import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mon_temps/providers/task_provider.dart';
import 'package:mon_temps/services/confirm_deletion.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

// --- VUE DES TÂCHES ---
class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        if (provider.tasks.isEmpty) {
          final colorScheme = Theme.of(context).colorScheme;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.checklist_rounded,
                  size: 72,
                  // ignore: deprecated_member_use
                  color: colorScheme.primary.withOpacity(0.2),
                ),
                const SizedBox(height: 12),
                Text(
                  // Label "Aucune tâche disponible"
                  l10n.videTacheLab,
                  style: TextStyle(
                    // ignore: deprecated_member_use
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          itemCount: provider.tasks.length,
          separatorBuilder: (c, i) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final task = provider.tasks[index];
            final colorScheme = Theme.of(context).colorScheme;
            return Card(
              elevation: 0,
              color: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                leading: Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    value: task.isDone,
                    activeColor: colorScheme.primary,
                    shape: const CircleBorder(),
                    side: BorderSide(
                      // ignore: deprecated_member_use
                      color: colorScheme.outline.withOpacity(0.5),
                      width: 2,
                    ),
                    onChanged: (_) =>
                        context.read<TaskProvider>().toggleTaskStatus(task),
                  ),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                    // ignore: deprecated_member_use
                    decorationColor: colorScheme.outline.withOpacity(0.4),
                    color: task.isDone
                        // ignore: deprecated_member_use
                        ? colorScheme.onSurface.withOpacity(0.5)
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: task.relatedCourseTitle != null
                    ? Text(
                        task.relatedCourseTitle!,
                        style: TextStyle(
                          // ignore: deprecated_member_use
                          color: colorScheme.primary.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : Text(
                        DateFormat('dd MMM').format(task.dueDate),
                        style: TextStyle(
                          // ignore: deprecated_member_use
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    // ignore: deprecated_member_use
                    color: colorScheme.error.withOpacity(0.7),
                  ),
                  onPressed: () async {
                    // --- CONFIRMATION AVANT SUPPRESSION ---
                    final confirmed = await confirmDeletion(
                      context,
                      task.title,
                    );
                    if (confirmed && context.mounted) {
                      context.read<TaskProvider>().deleteTask(task.id);
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
