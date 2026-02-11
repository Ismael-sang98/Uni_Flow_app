import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider with ChangeNotifier {
  // On récupère la boîte 'settings' (déjà ouverte dans le main)
  final Box _box = Hive.box('settings');

  // 1. On récupère la valeur brute (Vrai ou Faux)
  bool get isDarkMode => _box.get('isDarkMode', defaultValue: false);

  // 2. C'EST CE BOUT DE CODE QUI MANQUAIT !
  // On transforme le booléen en ThemeMode pour le MaterialApp
  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // 3. La fonction pour changer de thème
  void toggleTheme(bool isOn) {
    _box.put('isDarkMode', isOn); // Sauvegarde
    notifyListeners();            // Mise à jour de l'app
  }
}