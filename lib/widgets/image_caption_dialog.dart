import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Affiche un dialogue de légende pour une image et retourne le texte saisi
/// (chaîne vide si l'utilisateur passe l'étape, null si annulé).
Future<String?> showImageCaptionDialog(
  BuildContext context, {
  required String imagePath,
  String? initialCaption,
}) {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) =>
        _ImageCaptionDialog(initialCaption: initialCaption),
  );
}

/// Widget dédié (plutôt qu'un `TextEditingController` créé/disposé
/// manuellement autour de `showDialog`) : `dispose()` n'est appelé par
/// Flutter qu'une fois le widget réellement retiré de l'arbre, après
/// l'animation de fermeture du dialogue — un dispose manuel juste après
/// `await showDialog(...)` entre en course avec cette animation et provoque
/// "TextEditingController was used after being disposed".
class _ImageCaptionDialog extends StatefulWidget {
  final String? initialCaption;

  const _ImageCaptionDialog({this.initialCaption});

  @override
  State<_ImageCaptionDialog> createState() => _ImageCaptionDialogState();
}

class _ImageCaptionDialogState extends State<_ImageCaptionDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCaption ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.noteImageCaptionTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.noteImageCaptionLabel} (${l10n.optional})',
            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: l10n.noteImageCaptionHint,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, ''),
          child: Text(l10n.skip),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
