import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/update_checker.dart';
import '../l10n/app_localizations.dart';

class UpdateDialog extends StatelessWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({super.key, required this.updateInfo});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      title: Row(
        children: [
          Icon(
            Icons.system_update,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.updateAvailable,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.updateCurrentVersion(updateInfo.currentVersion),
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.updateNewVersion(updateInfo.latestVersion),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              if (updateInfo.releaseNotes.isNotEmpty) ...[
                Text(
                  l10n.updateWhatsNew,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    updateInfo.releaseNotes,
                    style: const TextStyle(fontSize: 13, height: 1.5),
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.updateLater),
        ),
        FilledButton.icon(
          onPressed: () async {
            final url = Uri.parse(updateInfo.downloadUrl);
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          icon: const Icon(Icons.download, size: 18),
          label: Text(l10n.updateDownload),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
    );
  }

  /// Affiche le dialogue de mise à jour
  static Future<void> show(BuildContext context, UpdateInfo updateInfo) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateDialog(updateInfo: updateInfo),
    );
  }

  /// Vérifie et affiche le dialogue si une mise à jour est disponible
  static Future<void> checkAndShow(BuildContext context) async {
    final updateInfo = await UpdateChecker.checkForUpdate();
    if (updateInfo != null && context.mounted) {
      await show(context, updateInfo);
    }
  }
}
