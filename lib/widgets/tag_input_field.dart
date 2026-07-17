import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';
import '../l10n/app_localizations.dart';

/// Saisie de tags sous forme de puces (au lieu d'un champ texte séparé par
/// des virgules) : on tape un mot puis Entrée/virgule/espace le transforme
/// en puce retirable. Plus visuel et moins sujet aux erreurs de format que
/// l'ancien TextField "virgule".
class TagInputField extends StatefulWidget {
  final List<String> initialTags;
  final ValueChanged<List<String>> onChanged;

  const TagInputField({
    super.key,
    required this.initialTags,
    required this.onChanged,
  });

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  late List<String> _tags;
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tags = List<String>.from(widget.initialTags);
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _commitPendingText() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;
    if (!_tags.contains(raw)) {
      setState(() => _tags.add(raw));
      widget.onChanged(_tags);
    }
    _controller.clear();
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
    widget.onChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacing12,
        vertical: UIConstants.spacing8,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(UIConstants.borderRadius14),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final tag in _tags)
            Chip(
              label: Text(tag),
              onDeleted: () => _removeTag(tag),
              backgroundColor: colorScheme.primary.withValues(
                alpha: UIConstants.opacity12,
              ),
              labelStyle: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: UIConstants.fontSize12,
              ),
              deleteIconColor: colorScheme.primary,
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
            ),
          SizedBox(
            width: 120,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: _tags.isEmpty ? l10n.noteTags : l10n.noteTagsAddMore,
              ),
              onSubmitted: (_) {
                _commitPendingText();
                _focusNode.requestFocus();
              },
              onChanged: (value) {
                if (value.endsWith(',') || value.endsWith(' ')) {
                  _controller.text = value.substring(0, value.length - 1);
                  _commitPendingText();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
