import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Affiche un dialogue de légende pour une image et retourne le texte saisi
/// (chaîne vide si l'utilisateur passe l'étape, null si annulé).
Future<String?> showImageCaptionDialog(
  BuildContext context, {
  required String imagePath,
  String? initialCaption,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController(text: initialCaption ?? '');
  try {
    return await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
              controller: controller,
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
            onPressed: () => Navigator.pop(dialogContext, ''),
            child: Text(l10n.skip),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              Navigator.pop(dialogContext, value);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  } finally {
    controller.dispose();
  }
}
