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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.checklist_rounded,
                  size: 80,
                  color: Colors.grey.shade200,
                ),
                const SizedBox(height: 10),
                Text(
                  // Label "Aucune tâche disponible"
                  l10n.videTacheLab,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          itemCount: provider.tasks.length,
          separatorBuilder: (c, i) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final task = provider.tasks[index];
            return Container(
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: task.isDone,
                    activeColor: const Color(0xFF4CD964),
                    shape: const CircleBorder(),
                    side: BorderSide(color: Colors.grey.shade300, width: 2),
                    onChanged: (_) =>
                        context.read<TaskProvider>().toggleTaskStatus(task),
                  ),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.grey.shade300,
                    color: task.isDone
                        ? Colors.grey.shade400
                        : Theme.of(context).textTheme.titleLarge?.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: task.relatedCourseTitle != null
                    ? Text(
                        task.relatedCourseTitle!,
                        style: TextStyle(
                          // ignore: deprecated_member_use
                          color: const Color(0xFF6C63FF).withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : Text(
                        DateFormat('dd MMM').format(task.dueDate),
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red.shade200,
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
