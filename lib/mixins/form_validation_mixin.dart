import 'package:flutter/material.dart';

/// Mixin pour la gestion de la validation de formulaire en temps réel
mixin FormValidationMixin {
  late ValueNotifier<bool> isValidNotifier;
  late ValueNotifier<int> contentLengthNotifier;

  void initFormValidation() {
    isValidNotifier = ValueNotifier<bool>(false);
    contentLengthNotifier = ValueNotifier<int>(0);
  }

  void updateFormValidation(String titleText, String contentText) {
    final title = titleText.trim();
    final content = contentText.trim();
    isValidNotifier.value = title.isNotEmpty && content.isNotEmpty;
    contentLengthNotifier.value = contentText.length;
  }

  void disposeFormValidation() {
    isValidNotifier.dispose();
    contentLengthNotifier.dispose();
  }
}
