import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../constants/ui_constants.dart';
import '../l10n/app_localizations.dart';
import '../mixins/form_validation_mixin.dart';
import '../models/student_profile.dart';
import '../models/study_note.dart';
import '../providers/notes_provider.dart';
import '../services/image_manager.dart';
import '../widgets/image_grid_widget.dart';

// ignore_for_file: deprecated_member_use

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> with FormValidationMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final List<String> _imagePaths = [];
  final ImageManager _imageManager = ImageManager();
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    initFormValidation();
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: UIConstants.snackBarDuration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final l10n = AppLocalizations.of(context)!;

    if (title.isEmpty || content.isEmpty) {
      _showErrorSnackBar(l10n.noteRequiredFields);
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final newNote = StudyNote(
      id: const Uuid().v4(),
      title: title,
      content: content,
      subject: _selectedSubject,
      createdAt: DateTime.now(),
      tags: tags,
      imagePaths: _imagePaths,
    );

    await context.read<NotesProvider>().addNote(newNote);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsBox = Hive.box('settings');
    final profile = settingsBox.get('profile') as StudentProfile?;
    final List<String> availableSubjects = profile?.subjects ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addNote)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          UIConstants.spacing16,
          UIConstants.spacing16,
          UIConstants.spacing16,
          UIConstants.spacing24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: isValidNotifier,
              builder: (context, isValid, _) {
                final titleEmpty = _titleController.text.trim().isEmpty;
                return TextField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.noteTitle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        UIConstants.borderRadius14,
                      ),
                      borderSide: BorderSide(
                        color: titleEmpty
                            ? Colors.red.withOpacity(UIConstants.opacity30)
                            : Colors.green.withOpacity(UIConstants.opacity30),
                      ),
                    ),
                    suffixIcon: titleEmpty
                        ? const Icon(
                            Icons.clear,
                            color: Colors.red,
                            size: UIConstants.iconSize20,
                          )
                        : const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: UIConstants.iconSize20,
                          ),
                  ),
                );
              },
            ),
            const SizedBox(height: UIConstants.spacing16),
            DropdownButtonFormField<String>(
              initialValue: _selectedSubject,
              decoration: InputDecoration(
                labelText: l10n.noteSubject,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    UIConstants.borderRadius14,
                  ),
                ),
              ),
              items: availableSubjects.isEmpty
                  ? null
                  : availableSubjects
                        .map(
                          (title) => DropdownMenuItem(
                            value: title,
                            child: Text(title),
                          ),
                        )
                        .toList(),
              onChanged: (val) => setState(() => _selectedSubject = val),
              hint: availableSubjects.isEmpty
                  ? Text(l10n.noSubjectsDefined)
                  : null,
            ),
            const SizedBox(height: UIConstants.spacing16),
            ValueListenableBuilder<bool>(
              valueListenable: isValidNotifier,
              builder: (context, isValid, _) {
                final contentEmpty = _contentController.text.trim().isEmpty;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _contentController,
                      textInputAction: TextInputAction.newline,
                      minLines: 8,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: l10n.noteContent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            UIConstants.borderRadius14,
                          ),
                          borderSide: BorderSide(
                            color: contentEmpty
                                ? Colors.red.withOpacity(UIConstants.opacity30)
                                : Colors.green.withOpacity(
                                    UIConstants.opacity30,
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacing8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder<int>(
                          valueListenable: contentLengthNotifier,
                          builder: (context, length, _) {
                            return Text(
                              l10n.charactersCount(length),
                              style: TextStyle(
                                fontSize: UIConstants.fontSize12,
                                color: Theme.of(context).colorScheme.onSurface
                                    .withOpacity(UIConstants.opacity60),
                              ),
                            );
                          },
                        ),
                        if (contentEmpty)
                          Text(
                            l10n.requiredField,
                            style: TextStyle(
                              fontSize: UIConstants.fontSize12,
                              color: Colors.red.withOpacity(
                                UIConstants.opacity70,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: UIConstants.iconSize16,
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: UIConstants.spacing16),
            TextField(
              controller: _tagsController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.noteTags,
                helperText: l10n.noteTagsHelp,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    UIConstants.borderRadius14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: UIConstants.spacing16),
            _buildImagesSection(l10n),
          ],
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: isValidNotifier,
        builder: (context, isValid, _) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                UIConstants.spacing16,
                0,
                UIConstants.spacing16,
                UIConstants.spacing16,
              ),
              child: SizedBox(
                height: UIConstants.buttonHeight,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isValid ? _saveNote : null,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l10n.save),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        UIConstants.borderRadius16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagesSection(AppLocalizations l10n) {
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

  void _shareImage(String path) {
    final l10n = AppLocalizations.of(context)!;
    _imageManager.shareImage(path, text: l10n.shareNoteImage);
  }
}
