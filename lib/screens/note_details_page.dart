import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
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
  final ImageManager _imageManager = ImageManager();
  String? _selectedSubject;
  bool _isEditing = false;
  bool _isPinned = false;
  List<String> _imagePaths = [];
  List<String> _attachmentPaths = [];
  Map<String, String> _imageCaptions = {};
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _tags = List<String>.from(widget.note.tags);
    _selectedSubject = widget.note.subject;
    _isPinned = widget.note.isPinned;
    _imagePaths = List<String>.from(widget.note.imagePaths);
    _attachmentPaths = List<String>.from(widget.note.attachmentPaths);
    _imageCaptions = Map<String, String>.from(widget.note.imageCaptions);
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

    // Note: Image captions are now optional - validation removed

    final updatedNote = StudyNote(
      id: widget.note.id,
      title: title,
      content: content,
      subject: _selectedSubject,
      createdAt: widget.note.createdAt,
      updatedAt: DateTime.now(),
      tags: _tags,
      imagePaths: _imagePaths,
      attachmentPaths: _attachmentPaths,
      imageCaptions: _imageCaptions,
      isPinned: _isPinned,
    );

    await context.read<NotesProvider>().updateNote(updatedNote);
    if (!mounted) return;
    setState(() => _isEditing = false);
  }

  Future<void> _togglePin() async {
    await context.read<NotesProvider>().togglePin(widget.note.id);
    if (!mounted) return;
    setState(() => _isPinned = !_isPinned);
  }

  Future<void> _deleteNote() async {
    final l10n = AppLocalizations.of(context)!;
    // Capturés avant le pop : le messenger appartient à l'écran parent (donc
    // reste valide après la fermeture de cette page), et le provider est un
    // ChangeNotifier applicatif dont la référence n'a pas besoin de context.
    final messenger = ScaffoldMessenger.of(context);
    final notesProvider = context.read<NotesProvider>();
    final noteId = widget.note.id;

    await notesProvider.softDeleteNote(noteId);
    if (!mounted) return;
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.noteMovedToTrashMessage),
        duration: UIConstants.snackBarDuration,
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () => notesProvider.restoreNote(noteId),
        ),
      ),
    );
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
        final createdAt = DateFormat(
          'dd/MM/yyyy',
        ).format(widget.note.createdAt);
        final updatedAt = widget.note.updatedAt == null
            ? null
            : DateFormat('dd/MM/yyyy').format(widget.note.updatedAt!);

        return _buildScaffold(l10n, availableSubjects, createdAt, updatedAt);
      },
    );
  }

  Widget _buildScaffold(
    AppLocalizations l10n,
    List<String> availableSubjects,
    String createdAt,
    String? updatedAt,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.noteDetails),
        actions: [
          IconButton(
            onPressed: _togglePin,
            icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            tooltip: _isPinned ? l10n.noteUnpin : l10n.notePin,
          ),
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
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildTagChips(),
              ],
              if (_imagePaths.isNotEmpty) ...[
                const SizedBox(height: 16),
                ImageGridWidget(
                  imagePaths: _imagePaths,
                  imageCaptions: _imageCaptions,
                  isEditable: false,
                  emptyMessage: l10n.noImagesYet,
                  onImageTap: (path) => showImagePreviewDialog(
                    context,
                    imagePaths: _imagePaths,
                    initialPath: path,
                    imageCaptions: _imageCaptions,
                  ),
                  onShareTap: _shareImage,
                ),
              ],
              if (_attachmentPaths.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildAttachmentsViewer(l10n),
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
              _buildPill(
                icon: Icons.school_rounded,
                label: subject,
                color: notebookColorFor(subject),
              ),
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
    final accentColor = notebookColorFor(_selectedSubject);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: isValidNotifier,
          builder: (context, isValid, _) {
            final titleEmpty = _titleController.text.trim().isEmpty;
            return TextField(
              controller: _titleController,
              style: const TextStyle(
                fontSize: UIConstants.fontSize22,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: l10n.noteTitle,
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
        const SizedBox(height: 16),
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
      ],
    );
  }

  Widget _buildContentViewer() {
    final accentColor = notebookColorFor(_selectedSubject);
    return ClipRRect(
      borderRadius: BorderRadius.circular(UIConstants.borderRadius16),
      child: RuledPaperBackground(
        accentColor: accentColor,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(36, 16, 16, 16),
          color: Theme.of(context).cardColor,
          child: SelectableText(
            _contentController.text,
            style: const TextStyle(height: 1.75, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildContentEditor(AppLocalizations l10n) {
    final accentColor = notebookColorFor(_selectedSubject);
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

  Widget _buildTagsEditor(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.noteTagsHelp,
          style: TextStyle(
            fontSize: UIConstants.fontSize12,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: UIConstants.opacity60),
          ),
        ),
        const SizedBox(height: UIConstants.spacing8),
        TagInputField(
          initialTags: _tags,
          onChanged: (tags) => _tags = tags,
        ),
      ],
    );
  }

  Widget _buildTagChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: UIConstants.opacity12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: UIConstants.fontSize12,
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
            if (!mounted || updated == null) return; // User clicked Cancel
            setState(() => _imageCaptions[path] = updated);
          },
          onShareTap: _shareImage,
        ),
        if (_attachmentPaths.isNotEmpty)
          ..._attachmentPaths.map(
            (path) => ListTile(
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

  Widget _buildPill({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final pillColor = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: pillColor.withValues(alpha: UIConstants.opacity12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: UIConstants.iconSize14, color: pillColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: UIConstants.fontSize12,
              color: pillColor,
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

  Widget _buildAttachmentsViewer(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.noteFiles,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ..._attachmentPaths.map(
          (path) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.insert_drive_file_outlined),
            title: Text(
              p.basename(path),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => OpenFilex.open(path),
          ),
        ),
      ],
    );
  }
}
