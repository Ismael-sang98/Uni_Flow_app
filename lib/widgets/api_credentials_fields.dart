import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Champs de saisie URL de base du backend + clé API (X-API-Key), avec
/// validation et bascule affichage/masquage de la clé. Doit être placé à
/// l'intérieur d'un [Form] (les [TextFormField] se rattachent au [Form]
/// ancêtre le plus proche, peu importe l'imbrication).
///
/// Utilisé par `ApiSettingsPage` et par le flux d'onboarding "Configurer
/// depuis mon compte OBS".
class ApiCredentialsFields extends StatefulWidget {
  final TextEditingController baseUrlController;
  final TextEditingController apiKeyController;

  const ApiCredentialsFields({
    super.key,
    required this.baseUrlController,
    required this.apiKeyController,
  });

  @override
  State<ApiCredentialsFields> createState() => _ApiCredentialsFieldsState();
}

class _ApiCredentialsFieldsState extends State<ApiCredentialsFields> {
  bool _obscureApiKey = true;

  String? _validateBaseUrl(String? value) {
    final l10n = AppLocalizations.of(context)!;
    final text = value?.trim() ?? '';
    if (text.isEmpty) return l10n.requiredField;
    final uri = Uri.tryParse(text);
    if (uri == null || !uri.isAbsolute || !uri.scheme.startsWith('http')) {
      return l10n.apiSettingsInvalidUrl;
    }
    return null;
  }

  String? _validateApiKey(String? value) {
    final l10n = AppLocalizations.of(context)!;
    return (value == null || value.trim().isEmpty) ? l10n.requiredField : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.baseUrlController,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            labelText: l10n.apiSettingsBaseUrlLabel,
            hintText: l10n.apiSettingsBaseUrlHint,
            prefixIcon: const Icon(Icons.link),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          ),
          validator: _validateBaseUrl,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.apiKeyController,
          obscureText: _obscureApiKey,
          decoration: InputDecoration(
            labelText: l10n.apiSettingsApiKeyLabel,
            hintText: l10n.apiSettingsApiKeyHint,
            prefixIcon: const Icon(Icons.vpn_key_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureApiKey
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          ),
          validator: _validateApiKey,
        ),
      ],
    );
  }
}
