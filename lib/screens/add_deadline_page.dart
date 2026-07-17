import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../constants/ui_constants.dart';
import '../l10n/app_localizations.dart';
import '../models/deadline.dart';
import '../models/student_profile.dart';
import '../providers/deadlines_provider.dart';
import '../services/deadline_reminder_scheduler.dart';

/// Ajout/édition d'une échéance ponctuelle (examen, devoir, autre) —
/// contrairement à [Course], une seule date/heure précise, pas de
/// récurrence hebdomadaire.
class AddDeadlinePage extends StatefulWidget {
  final Deadline? deadlineToEdit;

  const AddDeadlinePage({super.key, this.deadlineToEdit});

  @override
  State<AddDeadlinePage> createState() => _AddDeadlinePageState();
}

class _AddDeadlinePageState extends State<AddDeadlinePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;

  bool get _isEditing => widget.deadlineToEdit != null;

  DeadlineType _type = DeadlineType.exam;
  DateTime _dueDate = DateTime.now();
  TimeOfDay _dueTime = const TimeOfDay(hour: 9, minute: 0);
  String? _selectedSubject;
  int? _reminderMinutesBefore = 60;
  List<String> _availableSubjects = [];

  @override
  void initState() {
    super.initState();
    final editing = widget.deadlineToEdit;
    _titleController = TextEditingController(text: editing?.title ?? '');
    _notesController = TextEditingController(text: editing?.notes ?? '');
    if (editing != null) {
      _type = editing.type;
      _dueDate = editing.dueAt;
      _dueTime = TimeOfDay.fromDateTime(editing.dueAt);
      _selectedSubject = editing.subject;
      _reminderMinutesBefore = editing.reminderMinutesBefore;
    } else {
      // Par défaut : demain à 9h, plus utile qu'"aujourd'hui" pour une
      // échéance qu'on ajoute généralement à l'avance.
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      _dueDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    }
    _loadSubjects();
  }

  void _loadSubjects() {
    final profile = Hive.box('settings').get('profile') as StudentProfile?;
    final subjects = <String>[...?profile?.subjects];
    final editingSubject = widget.deadlineToEdit?.subject;
    if (editingSubject != null && !subjects.contains(editingSubject)) {
      subjects.insert(0, editingSubject);
    }
    setState(() => _availableSubjects = subjects);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _dueTime);
    if (picked != null) setState(() => _dueTime = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final dueAt = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );

    final deadline = Deadline(
      id: widget.deadlineToEdit?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      type: _type,
      dueAt: dueAt,
      subject: _selectedSubject,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      reminderMinutesBefore: _reminderMinutesBefore,
    );

    final provider = context.read<DeadlinesProvider>();
    if (_isEditing) {
      await provider.updateDeadline(deadline);
    } else {
      await provider.addDeadline(deadline);
    }
    await scheduleDeadlineReminder(deadline, l10n);
    if (!mounted) return;
    Navigator.pop(context);
  }

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

  String _reminderLabel(AppLocalizations l10n, int? minutes) {
    if (minutes == null) return l10n.reminderNone;
    if (minutes < 60) return l10n.reminderMinutesBefore(minutes);
    if (minutes < 1440) return l10n.reminderHoursBefore(minutes ~/ 60);
    return l10n.reminderDaysBefore(minutes ~/ 1440);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editDeadlineTitle : l10n.addDeadlineTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.spacing16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deadlineTypeLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: UIConstants.spacing8),
              Wrap(
                spacing: 8,
                children: DeadlineType.values.map((type) {
                  final selected = _type == type;
                  return ChoiceChip(
                    label: Text(_typeLabel(l10n, type)),
                    avatar: Icon(_typeIcon(type), size: UIConstants.iconSize18),
                    selected: selected,
                    onSelected: (_) => setState(() => _type = type),
                  );
                }).toList(),
              ),
              const SizedBox(height: UIConstants.spacing16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.noteTitle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      UIConstants.borderRadius14,
                    ),
                  ),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l10n.requiredField
                    : null,
              ),
              const SizedBox(height: UIConstants.spacing16),
              if (_availableSubjects.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedSubject,
                  decoration: InputDecoration(
                    labelText: l10n.notesNotebook,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        UIConstants.borderRadius14,
                      ),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.deadlineNoSubject),
                    ),
                    ..._availableSubjects.map(
                      (s) => DropdownMenuItem(value: s, child: Text(s)),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedSubject = val),
                ),
                const SizedBox(height: UIConstants.spacing16),
              ],
              Text(
                l10n.deadlineDueDateLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: UIConstants.spacing8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(DateFormat('dd/MM/yyyy').format(_dueDate)),
                    ),
                  ),
                  const SizedBox(width: UIConstants.spacing8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time_outlined),
                      label: Text(_dueTime.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.spacing16),
              DropdownButtonFormField<int?>(
                initialValue: _reminderMinutesBefore,
                decoration: InputDecoration(
                  labelText: l10n.deadlineReminderLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      UIConstants.borderRadius14,
                    ),
                  ),
                ),
                items: [null, 15, 60, 60 * 24, 60 * 24 * 3]
                    .map(
                      (minutes) => DropdownMenuItem(
                        value: minutes,
                        child: Text(_reminderLabel(l10n, minutes)),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _reminderMinutesBefore = val),
              ),
              const SizedBox(height: UIConstants.spacing16),
              TextFormField(
                controller: _notesController,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: l10n.deadlineNotesLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      UIConstants.borderRadius14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: UIConstants.spacing24),
              SizedBox(
                width: double.infinity,
                height: UIConstants.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
