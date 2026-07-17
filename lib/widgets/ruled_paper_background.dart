import 'package:flutter/material.dart';

/// Fond "papier ligné" façon cahier : lignes horizontales régulières +
/// marge verticale rouge, dessinés derrière [child]. Utilisé pour habiller
/// la zone de contenu d'une note à l'écriture comme à la lecture.
class RuledPaperBackground extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final double lineHeight;

  const RuledPaperBackground({
    super.key,
    required this.child,
    required this.accentColor,
    this.lineHeight = 28,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      painter: _RuledPaperPainter(
        lineColor: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06),
        marginColor: accentColor.withValues(alpha: 0.35),
        lineHeight: lineHeight,
      ),
      child: child,
    );
  }
}

class _RuledPaperPainter extends CustomPainter {
  final Color lineColor;
  final Color marginColor;
  final double lineHeight;

  _RuledPaperPainter({
    required this.lineColor,
    required this.marginColor,
    required this.lineHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    for (double y = lineHeight; y < size.height; y += lineHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final marginPaint = Paint()
      ..color = marginColor
      ..strokeWidth = 1.5;
    const marginX = 28.0;
    canvas.drawLine(Offset(marginX, 0), Offset(marginX, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant _RuledPaperPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.marginColor != marginColor ||
        oldDelegate.lineHeight != lineHeight;
  }
}
