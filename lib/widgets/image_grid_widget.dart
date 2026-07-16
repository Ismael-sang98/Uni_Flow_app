import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';

/// Widget réutilisable pour afficher une grille d'images avec options
class ImageGridWidget extends StatelessWidget {
  final List<String> imagePaths;
  final Map<String, String> imageCaptions;
  final bool isEditable;
  final Function(String path)? onImageTap;
  final Function(String path)? onDeleteTap;
  final Function(String path)? onShareTap;
  final Function(String path)? onEditCaptionTap;
  final String emptyMessage;

  const ImageGridWidget({
    super.key,
    required this.imagePaths,
    this.imageCaptions = const {},
    required this.emptyMessage,
    this.isEditable = false,
    this.onImageTap,
    this.onDeleteTap,
    this.onShareTap,
    this.onEditCaptionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePaths.isEmpty) {
      return _buildEmptyState(context);
    }

    return Wrap(
      spacing: UIConstants.spacing8,
      runSpacing: UIConstants.spacing8,
      children: imagePaths
          .map((path) => _buildImageTile(context, path))
          .toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Text(
      emptyMessage,
      style: TextStyle(
        fontSize: UIConstants.fontSize12,
        // ignore: deprecated_member_use
        color: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: UIConstants.opacity60),
      ),
    );
  }

  Widget _buildImageTile(BuildContext context, String path) {
    final caption = imageCaptions[path]?.trim() ?? '';
    return SizedBox(
      width: UIConstants.imageThumbnailSize,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              InkWell(
                onTap: () => onImageTap?.call(path),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    UIConstants.borderRadius12,
                  ),
                  child: Image.file(
                    File(path),
                    width: UIConstants.imageThumbnailSize,
                    height: UIConstants.imageThumbnailSize,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (isEditable)
                Positioned(
                  bottom: UIConstants.spacing8 / 2,
                  left: UIConstants.spacing8 / 2,
                  child: InkWell(
                    onTap: () => onEditCaptionTap?.call(path),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: UIConstants.iconSize12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (isEditable)
                _buildDeleteButton(path)
              else
                _buildShareButton(path),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: UIConstants.opacity60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(String path) {
    return Positioned(
      top: UIConstants.spacing8 / 2,
      right: UIConstants.spacing8 / 2,
      child: InkWell(
        onTap: () => onDeleteTap?.call(path),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close,
            size: UIConstants.iconSize12,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildShareButton(String path) {
    return Positioned(
      bottom: UIConstants.spacing8 / 2,
      left: UIConstants.spacing8 / 2,
      child: InkWell(
        onTap: () => onShareTap?.call(path),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.share,
            size: UIConstants.iconSize12,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
