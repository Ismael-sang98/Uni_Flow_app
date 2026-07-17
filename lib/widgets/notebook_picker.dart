import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';
import '../l10n/app_localizations.dart';
import '../utils/notebook_color.dart';

/// Sélecteur de cahier sous forme de puces colorées (une couleur stable par
/// cahier, voir notebookColorFor) au lieu d'un simple menu déroulant texte —
/// on voit d'un coup d'œil à quel cahier une note appartient, comme les
/// onglets colorés d'un vrai classeur.
class NotebookPicker extends StatelessWidget {
  final List<String> availableNotebooks;
  final String? selected;
  final ValueChanged<String> onSelected;

  const NotebookPicker({
    super.key,
    required this.availableNotebooks,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (availableNotebooks.isEmpty) {
      return Text(
        l10n.notesNoNotebook,
        style: TextStyle(color: Colors.grey.shade500),
      );
    }

    // Wrap plutôt qu'une liste horizontale : avec un ListView, le cahier
    // pré-sélectionné (ex: en arrivant depuis NotebookNotesPage) peut être
    // hors-écran sans indice visuel qu'il faut scroller pour le voir. Un
    // Wrap garde tous les cahiers visibles d'un coup — le nombre de cahiers
    // reste petit (dérivé des matières du profil) donc pas de souci de
    // hauteur.
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableNotebooks.map((notebook) {
        final color = notebookColorFor(notebook);
        final isSelected = notebook == selected;
        return ChoiceChip(
          label: Text(notebook),
          selected: isSelected,
          onSelected: (_) => onSelected(notebook),
          showCheckmark: false,
          avatar: CircleAvatar(backgroundColor: color, radius: 6),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : null,
          ),
          selectedColor: color,
          backgroundColor: color.withValues(alpha: UIConstants.opacity12),
          side: BorderSide.none,
        );
      }).toList(),
    );
  }
}
