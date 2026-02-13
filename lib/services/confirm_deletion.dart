import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

// Fonction utilitaire globale pour demander confirmation avant suppression
Future<bool> confirmDeletion(BuildContext context, String title) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        //message de confirmation localisé
        l10n.confirmSupprTitle,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(
        //message de confirmation localisé
        '"$title"\n${l10n.mess1} ${l10n.mess2}',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: Text(l10n.rejet, style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(l10n.supp),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
