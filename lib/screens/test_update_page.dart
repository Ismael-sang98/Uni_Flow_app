import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/update_checker.dart';
import '../widgets/update_dialog.dart';
import '../l10n/app_localizations.dart';

/// Page de test pour la fonctionnalité de mise à jour
class TestUpdatePage extends StatefulWidget {
  const TestUpdatePage({super.key});

  @override
  State<TestUpdatePage> createState() => _TestUpdatePageState();
}

class _TestUpdatePageState extends State<TestUpdatePage> {
  String _status = '';
  String _currentVersion = '';
  String _latestVersion = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentVersion();
  }

  Future<void> _loadCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _currentVersion = packageInfo.version;
        _status = AppLocalizations.of(context)!.updateReadyToTest;
      });
    }
  }

  Future<void> _checkForUpdate() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
      _status = l10n.updateChecking;
    });

    try {
      final updateInfo = await UpdateChecker.checkForUpdate();

      if (!mounted) return;

      if (updateInfo != null) {
        setState(() {
          _latestVersion = updateInfo.latestVersion;
          _status = l10n.updateAvailableStatus;
          _isLoading = false;
        });

        // Afficher le dialogue
        await UpdateDialog.show(context, updateInfo);
      } else {
        setState(() {
          _status = l10n.updateUpToDate;
          _latestVersion = _currentVersion;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = l10n.updateError(e.toString());
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _simulateUpdate() async {
    final l10n = AppLocalizations.of(context)!;

    // Simuler une mise à jour disponible
    final fakeUpdate = UpdateInfo(
      currentVersion: _currentVersion,
      latestVersion: '2.0.0',
      downloadUrl: 'https://github.com/Ismael-sang98/Uni_Flow_app/releases',
      releaseNotes: l10n.updateSimulationNote,
    );

    if (!mounted) return;
    await UpdateDialog.show(context, fakeUpdate);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.updateTestTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Informations
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.updateInfo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      l10n.updateCurrentVersionLabel,
                      _currentVersion,
                    ),
                    _buildInfoRow(
                      l10n.updateLatestVersionLabel,
                      _latestVersion,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(
                        fontSize: 14,
                        color: _status.contains('✅')
                            ? Colors.green
                            : _status.contains('❌')
                            ? Colors.red
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.updateHowToTest,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.updateTestInstructions(_currentVersion),
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Boutons de test
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _simulateUpdate,
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.updateSimulate),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _isLoading ? null : _checkForUpdate,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(l10n.updateCheckGitHub),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 24),

            // Informations GitHub
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.updateGitHubRelease,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.updateReleaseInstructions,
                      style: const TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
