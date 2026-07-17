import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../constants/ui_constants.dart';
import '../l10n/app_localizations.dart';
import '../mixins/form_validation_mixin.dart';
import '../models/student_profile.dart';
import '../models/study_note.dart';
import '../providers/notes_provider.dart';
import '../services/image_manager.dart';
import '../utils/notebook_color.dart';
import '../widgets/image_caption_dialog.dart';
import '../widgets/image_grid_widget.dart';
import '../widgets/image_preview_dialog.dart';
import '../widgets/notebook_picker.dart';
import '../widgets/ruled_paper_background.dart';
import '../widgets/tag_input_field.dart';

class AddNotePage extends StatefulWidget {
  final String? initialNotebook;

  const AddNotePage({super.key, this.initialNotebook});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> with FormValidationMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<String> _imagePaths = [];
  final List<String> _attachmentPaths = [];
  final Map<String, String> _imageCaptions = {};
  List<String> _tags = [];
  final ImageManager _imageManager = ImageManager();
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.initialNotebook;
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

    if (_selectedSubject == null || _selectedSubject!.trim().isEmpty) {
      _showErrorSnackBar(l10n.notesNotebookRequired);
      return;
    }

    final newNote = StudyNote(
      id: const Uuid().v4(),
      title: title,
      content: content,
      subject: _selectedSubject!.trim(),
      createdAt: DateTime.now(),
      tags: _tags,
      imagePaths: _imagePaths,
      attachmentPaths: _attachmentPaths,
      imageCaptions: _imageCaptions,
    );

    await context.read<NotesProvider>().addNote(newNote);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Ne reconstruit cette page que si la liste des cahiers change vraiment,
    // pas à chaque notification du provider (ex: édition d'une autre note).
    return Selector<NotesProvider, List<String>>(
      selector: (_, provider) => provider.notebooks,
      shouldRebuild: (previous, next) => !listEquals(previous, next),
      builder: (context, providerNotebooks, _) {
        final settingsBox = Hive.box('settings');
        final profile = settingsBox.get('profile') as StudentProfile?;
        final availableSubjects = <String>{
          ...(profile?.subjects ?? <String>[]),
          ...providerNotebooks,
        }.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

        return _buildScaffold(l10n, availableSubjects);
      },
    );
  }

  Widget _buildScaffold(AppLocalizations l10n, List<String> availableSubjects) {
    final accentColor = notebookColorFor(_selectedSubject);

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
            Text(
              l10n.notesNotebook,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: UIConstants.fontSize12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: UIConstants.opacity70),
              ),
            ),
            const SizedBox(height: UIConstants.spacing8),
            NotebookPicker(
              availableNotebooks: availableSubjects,
              selected: _selectedSubject,
              onSelected: (value) => setState(() => _selectedSubject = value),
            ),
            const SizedBox(height: UIConstants.spacing24),
            ValueListenableBuilder<bool>(
              valueListenable: isValidNotifier,
              builder: (context, isValid, _) {
                final titleEmpty = _titleController.text.trim().isEmpty;
                return TextField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontSize: UIConstants.fontSize22,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.noteTitle,
                    filled: false,
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: titleEmpty
                            ? Colors.red.withValues(alpha: UIConstants.opacity30)
                            : accentColor.withValues(alpha: UIConstants.opacity60),
                        width: 2,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 2),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: UIConstants.spacing16),
            _buildPaperContentEditor(l10n, accentColor),
            const SizedBox(height: UIConstants.spacing16),
            Text(
              l10n.noteTags,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: UIConstants.fontSize12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: UIConstants.opacity70),
              ),
            ),
            const SizedBox(height: UIConstants.spacing8),
            TagInputField(
              initialTags: _tags,
              onChanged: (tags) => _tags = tags,
            ),
            const SizedBox(height: UIConstants.spacing16),
            _buildAttachmentsSection(l10n),
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
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: accentColor.withValues(
                      alpha: UIConstants.opacity30,
                    ),
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

  /// Zone de contenu façon page de cahier : lignes horizontales + marge
  /// rouge derrière le TextField, hauteur de ligne du texte calée sur
  /// l'espacement des lignes dessinées pour que le texte "pose" dessus.
  Widget _buildPaperContentEditor(AppLocalizations l10n, Color accentColor) {
    return ValueListenableBuilder<bool>(
      valueListenable: isValidNotifier,
      builder: (context, isValid, _) {
        final contentEmpty = _contentController.text.trim().isEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 220),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(UIConstants.borderRadius14),
                border: Border.all(
                  color: contentEmpty
                      ? Colors.red.withValues(alpha: UIConstants.opacity30)
                      : accentColor.withValues(alpha: UIConstants.opacity30),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(UIConstants.borderRadius14),
                child: RuledPaperBackground(
                  accentColor: accentColor,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(36, 8, 12, 8),
                    child: TextField(
                      controller: _contentController,
                      minLines: 8,
                      maxLines: null,
                      style: const TextStyle(fontSize: 16, height: 1.75),
                      decoration: InputDecoration(
                        hintText: l10n.noteContent,
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
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
                        fontSize: UIConstants.fontSize12,
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: UIConstants.opacity60),
                      ),
                    );
                  },
                ),
                if (contentEmpty)
                  Text(
                    l10n.requiredField,
                    style: TextStyle(
                      fontSize: UIConstants.fontSize12,
                      color: Colors.red.withValues(
                        alpha: UIConstants.opacity70,
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
                for (final path in newImages) {
                  if (!mounted) return;
                  final caption = await showImageCaptionDialog(
                    context,
                    imagePath: path,
                  );
                  if (caption == null) continue; // User clicked Cancel
                  _imageCaptions[path] = caption; // caption can be empty
                  _imagePaths.add(path);
                }
                if (!mounted) return;
                setState(() {});
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
                if (newImage == null || !mounted) return;
                final caption = await showImageCaptionDialog(
                  context,
                  imagePath: newImage,
                );
                if (!mounted || caption == null) return; // User clicked Cancel
                setState(() {
                  _imageCaptions[newImage] = caption; // caption can be empty
                  _imagePaths.add(newImage);
                });
              },
              icon: const Icon(Icons.photo_camera_outlined),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacing8),
        ImageGridWidget(
          imagePaths: _imagePaths,
          imageCaptions: _imageCaptions,
          isEditable: true,
          emptyMessage: l10n.noImagesYet,
          onDeleteTap: (path) => setState(() {
            _imagePaths.remove(path);
            _imageCaptions.remove(path);
          }),
          onImageTap: (path) => showImagePreviewDialog(
            context,
            imagePaths: _imagePaths,
            initialPath: path,
            imageCaptions: _imageCaptions,
          ),
          onEditCaptionTap: (path) async {
            final updated = await showImageCaptionDialog(
              context,
              imagePath: path,
              initialCaption: _imageCaptions[path],
            );
            if (!mounted || updated == null) return;
            setState(() => _imageCaptions[path] = updated);
          },
          onShareTap: _shareImage,
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.noteFiles,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                final files = await _imageManager.pickAttachments();
                if (files.isEmpty) return;
                setState(() => _attachmentPaths.addAll(files));
              },
              icon: const Icon(Icons.attach_file),
              label: Text(l10n.noteAddFile),
            ),
          ],
        ),
        if (_attachmentPaths.isEmpty)
          Text(
            l10n.noteNoFiles,
            style: TextStyle(
              fontSize: UIConstants.fontSize12,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: UIConstants.opacity60),
            ),
          )
        else
          ..._attachmentPaths.map(
            (path) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: Text(
                p.basename(path),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                onPressed: () => setState(() => _attachmentPaths.remove(path)),
                icon: const Icon(Icons.delete_outline),
              ),
            ),
          ),
      ],
    );
  }

  void _shareImage(String path) {
    final l10n = AppLocalizations.of(context)!;
    _imageManager.shareImage(path, text: l10n.shareNoteImage);
  }
}
