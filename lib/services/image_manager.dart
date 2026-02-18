import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service de gestion centralisée des images
class ImageManager {
  static final ImageManager _instance = ImageManager._internal();

  factory ImageManager() {
    return _instance;
  }

  ImageManager._internal();

  final ImagePicker _picker = ImagePicker();

  /// Sélectionner des images depuis la galerie
  Future<List<String>> pickImagesFromGallery() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return [];
    return _copyImagesToAppDir(picked);
  }

  /// Capturer une image avec la caméra
  Future<String?> pickImageFromCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return null;
    final copied = await _copyImagesToAppDir([picked]);
    return copied.isEmpty ? null : copied.first;
  }

  /// Copier les images dans le répertoire de l'app
  Future<List<String>> _copyImagesToAppDir(List<XFile> files) async {
    final directory = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${directory.path}/notes');
    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }

    final List<String> paths = [];
    for (final file in files) {
      final fileName = file.path.split('/').last;
      final newPath =
          '${notesDir.path}/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final saved = await File(file.path).copy(newPath);
      paths.add(saved.path);
    }
    return paths;
  }

  /// Partager une image
  Future<void> shareImage(String imagePath, {required String text}) async {
    await Share.shareXFiles([XFile(imagePath)], text: text);
  }

  /// Partager plusieurs images
  Future<void> shareImages(
    List<String> imagePaths, {
    required String text,
  }) async {
    await Share.shareXFiles(
      imagePaths.map((p) => XFile(p)).toList(),
      text: text,
    );
  }
}
