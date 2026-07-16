import 'dart:io';
import 'package:flutter/material.dart';

/// Affiche un visualiseur plein écran (zoom + légendes) pour une liste d'images,
/// en démarrant sur [initialPath].
Future<void> showImagePreviewDialog(
  BuildContext context, {
  required List<String> imagePaths,
  required String initialPath,
  Map<String, String> imageCaptions = const {},
}) {
  return showDialog(
    context: context,
    useSafeArea: false,
    builder: (dialogContext) => _ImagePreviewDialog(
      imagePaths: imagePaths,
      initialPath: initialPath,
      imageCaptions: imageCaptions,
    ),
  );
}

/// Widget dédié (plutôt qu'un `PageController` créé/disposé manuellement
/// autour de `showDialog`) : `dispose()` n'est appelé par Flutter qu'une fois
/// le widget réellement retiré de l'arbre, après l'animation de fermeture du
/// dialogue — un dispose manuel juste après `await showDialog(...)` entre en
/// course avec cette animation et provoque une erreur d'utilisation d'un
/// contrôleur déjà disposé.
class _ImagePreviewDialog extends StatefulWidget {
  final List<String> imagePaths;
  final String initialPath;
  final Map<String, String> imageCaptions;

  const _ImagePreviewDialog({
    required this.imagePaths,
    required this.initialPath,
    required this.imageCaptions,
  });

  @override
  State<_ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<_ImagePreviewDialog> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.imagePaths.indexOf(widget.initialPath);
    _pageController = PageController(
      initialPage: initialIndex < 0 ? 0 : initialIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
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
        body: PageView.builder(
          controller: _pageController,
          itemCount: widget.imagePaths.length,
          itemBuilder: (context, index) {
            final imagePath = widget.imagePaths[index];
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: InteractiveViewer(
                      maxScale: 5.0,
                      minScale: 1.0,
                      child: Image.file(File(imagePath), fit: BoxFit.contain),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.black87,
                  child: Text(
                    widget.imageCaptions[imagePath] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
