import 'dart:io';
import 'package:flutter/material.dart';

/// Affiche un visualiseur plein écran (zoom + légendes) pour une liste d'images,
/// en démarrant sur [initialPath].
Future<void> showImagePreviewDialog(
  BuildContext context, {
  required List<String> imagePaths,
  required String initialPath,
  Map<String, String> imageCaptions = const {},
}) async {
  final initialIndex = imagePaths.indexOf(initialPath);
  final pageController = PageController(
    initialPage: initialIndex < 0 ? 0 : initialIndex,
  );

  try {
    await showDialog(
      context: context,
      useSafeArea: false,
      builder: (dialogContext) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            backgroundColor: Colors.black87,
            elevation: 0,
          ),
          backgroundColor: Colors.black,
          body: PageView.builder(
            controller: pageController,
            itemCount: imagePaths.length,
            itemBuilder: (context, index) {
              final imagePath = imagePaths[index];
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
                      imageCaptions[imagePath] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  } finally {
    pageController.dispose();
  }
}
