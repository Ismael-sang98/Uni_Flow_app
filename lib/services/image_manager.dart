import 'dart:io';
import 'package:file_picker/file_picker.dart' as fp;
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
    final picked = await _picker.pickMultiImage(
      imageQuality: 70,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (picked.isEmpty) return [];
    return _copyImagesToAppDir(picked);
  }

  /// Capturer une image avec la caméra
  Future<String?> pickImageFromCamera() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (picked == null) return null;
    final copied = await _copyImagesToAppDir([picked]);
    return copied.isEmpty ? null : copied.first;
  }

  Future<List<String>> pickAttachments() async {
    final result = await fp.FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: false,
      type: fp.FileType.custom,
      allowedExtensions: [
        'pdf',
        'txt',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'xls',
        'xlsx',
      ],
    );

    if (result == null || result.files.isEmpty) {
      return [];
    }

    final paths = result.files.map((f) => f.path).whereType<String>().toList();
    if (paths.isEmpty) return [];
    return _copyFilesToAppDir(paths, subfolder: 'attachments');
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

  Future<List<String>> _copyFilesToAppDir(
    List<String> sourcePaths, {
    required String subfolder,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final targetDir = Directory('${directory.path}/$subfolder');
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final List<String> savedPaths = [];
    for (final sourcePath in sourcePaths) {
      final file = File(sourcePath);
      if (!await file.exists()) continue;
      final fileName = sourcePath.split('/').last;
      final newPath =
          '${targetDir.path}/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final saved = await file.copy(newPath);
      savedPaths.add(saved.path);
    }
    return savedPaths;
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
