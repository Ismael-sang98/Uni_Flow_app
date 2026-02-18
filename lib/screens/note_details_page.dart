import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/ui_constants.dart';
import '../l10n/app_localizations.dart';
import '../mixins/form_validation_mixin.dart';
import '../models/student_profile.dart';
import '../models/study_note.dart';
import '../providers/notes_provider.dart';
import '../services/confirm_deletion.dart';
import '../services/image_manager.dart';
import '../widgets/image_grid_widget.dart';

// ignore_for_file: deprecated_member_use

class NoteDetailsPage extends StatefulWidget {
  final StudyNote note;

  const NoteDetailsPage({super.key, required this.note});

  @override
  State<NoteDetailsPage> createState() => _NoteDetailsPageState();
}

class _NoteDetailsPageState extends State<NoteDetailsPage>
    with FormValidationMixin {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  final ImageManager _imageManager = ImageManager();
  String? _selectedSubject;
  bool _isEditing = false;
  List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _tagsController = TextEditingController(text: widget.note.tags.join(', '));
    _selectedSubject = widget.note.subject;
    _imagePaths = List<String>.from(widget.note.imagePaths);
    initFormValidation();
    isValidNotifier.value = true;
    contentLengthNotifier.value = _contentController.text.length;
    _titleController.addListener(_onFormChanged);
    _contentController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    updateFormValidation(_titleController.text, _contentController.text);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFormChanged);
    _contentController.removeListener(_onFormChanged);
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    disposeFormValidation();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final updatedNote = StudyNote(
      id: widget.note.id,
      title: title,
      content: content,
      subject: _selectedSubject,
      createdAt: widget.note.createdAt,
      updatedAt: DateTime.now(),
      tags: tags,
      imagePaths: _imagePaths,
    );

    await context.read<NotesProvider>().updateNote(updatedNote);
    if (!mounted) return;
    setState(() => _isEditing = false);
  }

  Future<void> _deleteNote() async {
    final confirmed = await confirmDeletion(context, widget.note.title);
    if (!confirmed) return;
    if (!mounted) return;
    await context.read<NotesProvider>().deleteNote(widget.note.id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsBox = Hive.box('settings');
    final profile = settingsBox.get('profile') as StudentProfile?;
    final List<String> availableSubjects = profile?.subjects ?? [];
    final createdAt = DateFormat('dd/MM/yyyy').format(widget.note.createdAt);
    final updatedAt = widget.note.updatedAt == null
        ? null
        : DateFormat('dd/MM/yyyy').format(widget.note.updatedAt!);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.noteDetails),
        actions: [
          if (_isEditing)
            ValueListenableBuilder<bool>(
              valueListenable: isValidNotifier,
              builder: (context, isValid, _) {
                return IconButton(
                  onPressed: isValid ? _saveNote : null,
                  icon: const Icon(Icons.save_outlined),
                  tooltip: l10n.save,
                );
              },
            )
          else
            IconButton(
              onPressed: _toggleEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.editNote,
            ),
          IconButton(
            onPressed: _deleteNote,
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.supp,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditing) ...[
              _buildEditHeader(l10n, availableSubjects),
              const SizedBox(height: 16),
              _buildContentEditor(l10n),
              const SizedBox(height: 16),
              _buildTagsEditor(l10n),
              const SizedBox(height: 16),
              _buildImagesEditor(l10n),
            ] else ...[
              _buildDisplayHeader(l10n, createdAt, updatedAt),
              const SizedBox(height: 16),
              _buildContentViewer(),
              if (_tagsController.text.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildTagChips(),
              ],
              if (_imagePaths.isNotEmpty) ...[
                const SizedBox(height: 16),
                ImageGridWidget(
                  imagePaths: _imagePaths,
                  isEditable: false,
                  emptyMessage: l10n.noImagesYet,
                  onImageTap: _showImagePreview,
                  onShareTap: _shareImage,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayHeader(
    AppLocalizations l10n,
    String createdAt,
    String? updatedAt,
  ) {
    final subject = _selectedSubject?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _titleController.text,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (subject != null && subject.isNotEmpty)
              _buildPill(icon: Icons.school_rounded, label: subject),
            _buildPill(
              icon: Icons.calendar_today_rounded,
              label: l10n.noteCreatedAt(createdAt),
            ),
            if (updatedAt != null)
              _buildPill(
                icon: Icons.update_rounded,
                label: l10n.noteUpdatedAt(updatedAt),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditHeader(
    AppLocalizations l10n,
    List<String> availableSubjects,
  ) {
    return Column(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: isValidNotifier,
          builder: (context, isValid, _) {
            final titleEmpty = _titleController.text.trim().isEmpty;
            return TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.noteTitle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: titleEmpty
                        ? Colors.red.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3),
                  ),
                ),
                suffixIcon: titleEmpty
                    ? const Icon(Icons.clear, color: Colors.red, size: 20)
                    : const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedSubject,
          decoration: InputDecoration(
            labelText: l10n.noteSubject,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          items: availableSubjects.isEmpty
              ? null
              : availableSubjects
                    .map(
                      (title) =>
                          DropdownMenuItem(value: title, child: Text(title)),
                    )
                    .toList(),
          onChanged: (val) => setState(() => _selectedSubject = val),
          hint: availableSubjects.isEmpty ? Text(l10n.noSubjectsDefined) : null,
        ),
      ],
    );
  }

  Widget _buildContentViewer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SelectableText(
        _contentController.text,
        style: const TextStyle(height: 1.5, fontSize: 15),
      ),
    );
  }

  Widget _buildContentEditor(AppLocalizations l10n) {
    return ValueListenableBuilder<bool>(
      valueListenable: isValidNotifier,
      builder: (context, isValid, _) {
        final contentEmpty = _contentController.text.trim().isEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _contentController,
              minLines: 8,
              maxLines: null,
              decoration: InputDecoration(
                labelText: l10n.noteContent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: contentEmpty
                        ? Colors.red.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: contentLengthNotifier,
                  builder: (context, length, _) {
                    return Text(
                      l10n.charactersCount(length),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    );
                  },
                ),
                if (contentEmpty)
                  Text(
                    l10n.requiredField,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTagsEditor(AppLocalizations l10n) {
    return TextField(
      controller: _tagsController,
      decoration: InputDecoration(
        labelText: l10n.noteTags,
        helperText: l10n.noteTagsHelp,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildTagChips() {
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildImagesEditor(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.noteImages,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                final newImages = await _imageManager.pickImagesFromGallery();
                if (newImages.isEmpty) return;
                setState(() => _imagePaths.addAll(newImages));
              },
              icon: const Icon(
                Icons.photo_library_outlined,
                size: UIConstants.iconSize18,
              ),
              label: Text(l10n.addFromGallery),
            ),
            const SizedBox(width: UIConstants.spacing8),
            IconButton(
              tooltip: l10n.addFromCamera,
              onPressed: () async {
                final newImage = await _imageManager.pickImageFromCamera();
                if (newImage == null) return;
                setState(() => _imagePaths.add(newImage));
              },
              icon: const Icon(Icons.photo_camera_outlined),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacing8),
        ImageGridWidget(
          imagePaths: _imagePaths,
          isEditable: true,
          emptyMessage: l10n.noImagesYet,
          onDeleteTap: (path) => setState(() => _imagePaths.remove(path)),
          onImageTap: _showImagePreview,
          onShareTap: _shareImage,
        ),
      ],
    );
  }

  void _showImagePreview(String path) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: Colors.black87,
            elevation: 0,
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: InteractiveViewer(
              maxScale: 5.0,
              minScale: 1.0,
              child: Image.file(File(path), fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _shareImage(String path) {
    final l10n = AppLocalizations.of(context)!;
    _imageManager.shareImage(path, text: l10n.shareNoteImage);
  }
}
