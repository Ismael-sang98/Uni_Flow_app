import 'package:flutter/material.dart';

/// Palette partagée avec les couleurs de cours (voir add_course_page.dart) —
/// même famille visuelle pour que cahiers et cours se sentent cohérents.
const List<int> kNotebookColors = [
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

/// Couleur déterministe pour un cahier donné (même nom -> toujours même
/// couleur, sans avoir à stocker quoi que ce soit — les cahiers restent un
/// concept dérivé, voir NotesProvider.notebooks).
Color notebookColorFor(String? notebookName) {
  final name = notebookName?.trim() ?? '';
  if (name.isEmpty) return const Color(0xFF6C63FF);
  final index = name.toLowerCase().hashCode.abs() % kNotebookColors.length;
  return Color(kNotebookColors[index]);
}
