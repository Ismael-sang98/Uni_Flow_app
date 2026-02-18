import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import '../models/course.dart';
import '../models/student_profile.dart'; // Pour lire les matières
import '../providers/course_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart'; // Pour les notifications (si besoin)

class AddCoursePage extends StatefulWidget {
  final Course? courseToEdit; // Si on veut modifier un cours existant
  const AddCoursePage({super.key, this.courseToEdit});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.courseToEdit != null;

  // On n'a plus besoin de _titleController car c'est un dropdown
  late TextEditingController _locationController;

  // Variables pour les autres champs
  int _selectedDay = 1;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  int _selectedColor = 0xFFF44336;

  String? _selectedSubject; // La matière choisie
  List<String> _availableSubjects = []; // La liste venant du profil

  final List<int> _colors = [
    0xFFF44336, // Red
    0xFFE91E63, // Pink
    0xFF9C27B0, // Purple
    0xFF673AB7, // Deep Purple
    0xFF3F51B5, // Indigo
    0xFF2196F3, // Blue
    0xFF00BCD4, // Cyan
    0xFF009688, // Teal
    0xFF4CAF50, // Green
    0xFF8BC34A, // Light Green
    0xFFFFC107, // Amber
    0xFFFF9800, // Orange
    0xFFFF5722, // Deep Orange
    0xFF795548, // Brown
  ];

  @override
  void initState() {
    super.initState();
    _loadSubjectsFromProfile();

    if (_isEditing) {
      _initializeForEdit(widget.courseToEdit!);
    } else {
      _initializeDefaults();
    }
  }

  void _initializeForEdit(Course course) {
    _locationController = TextEditingController(text: course.location);
    _selectedDay = course.dayOfWeeks;
    _selectedColor = course.color;
    _startTime = TimeOfDay.fromDateTime(course.startTime);
    _endTime = TimeOfDay.fromDateTime(course.endTime);
    _selectedSubject = course.title;
  }

  void _initializeDefaults() {
    _locationController = TextEditingController();
    _selectedDay = 1; // Lundi
    _startTime = const TimeOfDay(hour: 8, minute: 0);
    _endTime = const TimeOfDay(hour: 10, minute: 0);
    _selectedColor = 0xFFF44336;
  }

  // C'est ici qu'on récupère les matières du profil
  void _loadSubjectsFromProfile() {
    final box = Hive.box('settings');
    final profile = box.get('profile') as StudentProfile?;

    if (profile != null && profile.subjects.isNotEmpty) {
      setState(() {
        _availableSubjects = profile.subjects;

        if (widget.courseToEdit == null) {
          // Si on est en mode création, on sélectionne la première matière par défaut
          _selectedSubject =
              _availableSubjects[0]; // Sélectionner le premier par défaut
        }
      });
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  // Fonction pour formater la date de notification de manière plus conviviale
  String _formatDate(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inMinutes < 60) {
      return l10n.notificationInMinutes(difference.inMinutes);
    } else if (difference.inHours < 24) {
      final remainingMinutes = difference.inMinutes % 60;
      return l10n.notificationInHoursMinutes(
        difference.inHours,
        remainingMinutes,
      );
    } else {
      final List<String> jours = [
        l10n.jAb1,
        l10n.jAb2,
        l10n.jAb3,
        l10n.jAb4,
        l10n.jAb5,
        l10n.jAb6,
        l10n.jAb7,
      ];
      final jourNom = jours[date.weekday - 1];
      final minute = date.minute.toString().padLeft(2, '0');
      return l10n.notificationOnDate(
        jourNom,
        date.day,
        date.month,
        date.hour,
        minute,
      );
    }
  }

  Future<void> _promptExactAlarmIfNeeded() async {
    if (!Platform.isAndroid) return;

    final l10n = AppLocalizations.of(context)!;

    final PermissionStatus status = await Permission.scheduleExactAlarm
        .request();
    if (!status.isGranted && context.mounted) {
      await showDialog<void>(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.exactAlarmTitle),
          content: Text(l10n.exactAlarmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.later),
            ),
            ElevatedButton(
              onPressed: () async {
                await openAppSettings();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(l10n.openSettings),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _promptNotificationPermissionIfNeeded() async {
    if (!Platform.isAndroid) return;

    final l10n = AppLocalizations.of(context)!;

    final PermissionStatus status = await Permission.notification.request();
    if (!status.isGranted && context.mounted) {
      await showDialog<void>(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.notificationPermissionTitle),
          content: Text(l10n.notificationPermissionMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.later),
            ),
            ElevatedButton(
              onPressed: () async {
                await openAppSettings();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(l10n.openSettings),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _ensureNotificationPermissions() async {
    await _promptNotificationPermissionIfNeeded();
    await _promptExactAlarmIfNeeded();
  }

  Future<void> _saveCourse() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSubject == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectASubject)));
      return;
    }

    final now = DateTime.now();
    DateTime startDateTime = _buildDateTimeForToday(now, _startTime);
    final DateTime endDateTime = _buildDateTimeForToday(now, _endTime);

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.endTimeMustBeAfterStartTime)));
      return;
    }

    startDateTime = _adjustToNextSelectedDay(now, startDateTime);

    final course = _buildCourse(startDateTime, endDateTime);
    _persistCourse(course, l10n);
    await _scheduleNotification(course, startDateTime, l10n);

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  DateTime _buildDateTimeForToday(DateTime now, TimeOfDay time) {
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  DateTime _adjustToNextSelectedDay(DateTime now, DateTime startDateTime) {
    int daysUntilNextCourse = (_selectedDay - now.weekday + 7) % 7;
    if (daysUntilNextCourse == 0 && startDateTime.isBefore(now)) {
      daysUntilNextCourse = 7;
    }

    return startDateTime.add(Duration(days: daysUntilNextCourse));
  }

  Course _buildCourse(DateTime startDateTime, DateTime endDateTime) {
    final String id = widget.courseToEdit?.id ?? const Uuid().v4();
    return Course(
      id: id,
      title: _selectedSubject!,
      location: _locationController.text,
      dayOfWeeks: _selectedDay,
      color: _selectedColor,
      startTime: startDateTime,
      endTime: endDateTime,
    );
  }

  void _persistCourse(Course course, AppLocalizations l10n) {
    if (_isEditing) {
      Provider.of<CourseProvider>(
        // ignore: use_build_context_synchronously
        context,
        listen: false,
      ).updateCourse(course);
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.courseUpdated)));
      return;
    }

    // ignore: use_build_context_synchronously
    Provider.of<CourseProvider>(context, listen: false).addCourse(course);
    ScaffoldMessenger.of(
      // ignore: use_build_context_synchronously
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.courseAdded)));
  }

  Future<void> _scheduleNotification(
    Course course,
    DateTime startDateTime,
    AppLocalizations l10n,
  ) async {
    try {
      await _ensureNotificationPermissions();

      // On programme la notification 15 minutes avant le début du cours
      final notificationTime = startDateTime.subtract(
        const Duration(minutes: 10),
      );

      final int notificationId = NotificationService.notificationIdFromCourseId(
        course.id,
      );
      final String locationSuffix = course.location?.isNotEmpty == true
          ? l10n.courseReminderLocationSuffix(course.location!)
          : '';

      if (notificationTime.isAfter(DateTime.now())) {
        await NotificationService().scheduleWeeklyNotification(
          id: notificationId,
          title: l10n.courseReminderTitle,
          body: l10n.courseReminderBody(course.title, locationSuffix),
          scheduledDate: notificationTime,
        );

        await NotificationService().showInstantNotification(
          title: l10n.weeklyNotificationScheduled,
          body: l10n.weeklyReminderMessage(
            course.title,
            _formatDate(notificationTime),
          ),
        );
      } else {
        await NotificationService().showInstantNotification(
          title: l10n.courseTooClose,
          body: l10n.courseTooCloseMessage(course.title),
        );
      }
    } catch (e) {
      debugPrint('Notification scheduling error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.notificationError(e.toString())),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_availableSubjects.isEmpty) {
      return _buildNoSubjectsScaffold(l10n);
    }

    return _buildFormScaffold(l10n);
  }

  Scaffold _buildNoSubjectsScaffold(AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addCourse)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 60,
                color: Colors.orange,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.noSubjectMnessage,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(l10n.noSubjectExplanation, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.goBack),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Scaffold _buildFormScaffold(AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l10n.editCours : l10n.addCourse)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubjectDropdown(l10n),
              const SizedBox(height: 16),
              _buildLocationField(l10n),
              const SizedBox(height: 16),
              _buildDayDropdown(l10n),
              const SizedBox(height: 16),
              _buildTimeRow(l10n),
              const SizedBox(height: 16),
              _buildColorPicker(l10n),
              const SizedBox(height: 30),
              _buildSaveButton(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedSubject,
      decoration: InputDecoration(
        labelText: l10n.mt,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        prefixIcon: Icon(Icons.book),
      ),
      items: _availableSubjects.map((String subject) {
        return DropdownMenuItem<String>(value: subject, child: Text(subject));
      }).toList(),
      onChanged: (val) => setState(() => _selectedSubject = val),
    );
  }

  Widget _buildLocationField(AppLocalizations l10n) {
    return TextFormField(
      controller: _locationController,
      decoration: InputDecoration(
        labelText: l10n.location,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        prefixIcon: Icon(Icons.location_on),
      ),
    );
  }

  Widget _buildDayDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<int>(
      initialValue: _selectedDay,
      decoration: InputDecoration(
        labelText: l10n.day,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        prefixIcon: Icon(Icons.calendar_today),
      ),
      items: [
        DropdownMenuItem(value: 1, child: Text(l10n.j1)),
        DropdownMenuItem(value: 2, child: Text(l10n.j2)),
        DropdownMenuItem(value: 3, child: Text(l10n.j3)),
        DropdownMenuItem(value: 4, child: Text(l10n.j4)),
        DropdownMenuItem(value: 5, child: Text(l10n.j5)),
        DropdownMenuItem(value: 6, child: Text(l10n.j6)),
        DropdownMenuItem(value: 7, child: Text(l10n.j7)),
      ],
      onChanged: (v) => setState(() => _selectedDay = v!),
    );
  }

  Widget _buildTimeRow(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: Text(l10n.startLab),
            subtitle: Text(_startTime.format(context)),
            leading: const Icon(Icons.access_time),
            onTap: () => _selectTime(true),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ListTile(
            title: Text(l10n.endLab),
            subtitle: Text(_endTime.format(context)),
            leading: const Icon(Icons.access_time_filled),
            onTap: () => _selectTime(false),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectColor,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 6,
          children: _colors.map((color) {
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: CircleAvatar(
                backgroundColor: Color(color),
                radius: 25,
                child: _selectedColor == color
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _saveCourse,
        icon: const Icon(Icons.save),
        label: Text(_isEditing ? l10n.save : l10n.savePlan),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
