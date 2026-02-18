# 🧪 Guide de Test de la Mise à Jour Automatique

## 📱 Comment tester la fonctionnalité

### ✨ **Méthode 1 : Simulation Intégrée (Plus Rapide)**

Cette méthode te permet de voir le dialogue immédiatement sans créer de release GitHub.

#### Étapes :

1. **Lance l'application**
   ```bash
   flutter run
   ```

2. **Navigue vers la page de test**
   - Clique sur l'icône ⚙️ (Settings) en haut à droite
   - En bas de la page profil, clique sur **"🧪 Test Mise à Jour"**

3. **Teste la simulation**
   - Tu verras une page avec des informations sur ta version actuelle
   - Clique sur **"🧪 Simuler une mise à jour"**
   - Un dialogue s'affichera avec une fausse version 2.0.0
   - Tu peux voir l'interface exacte que verront les utilisateurs !

4. **Vérifie le dialogue**
   - ✅ Il affiche la version actuelle vs la nouvelle version
   - ✅ Il affiche les release notes (nouveautés)
   - ✅ Il y a un bouton "Télécharger"
   - ✅ Il y a un bouton "Plus tard"

---

### 🚀 **Méthode 2 : Test Réel avec GitHub (Recommandé pour Validation Finale)**

Cette méthode teste le flux complet incluant l'API GitHub.

#### Étapes :

**1. Note ta version actuelle**
   - Dans le fichier `pubspec.yaml`, tu as : `version: 1.5.5+1`
   - Version actuelle = **1.5.5**

**2. Crée une release de test sur GitHub**

   a. **Va sur GitHub :**
      ```
      https://github.com/Ismael-sang98/Uni_Flow_app/releases/new
      ```

   b. **Remplis les champs :**
      - **Tag version :** `v1.5.6` (version supérieure à 1.5.5)
      - **Release title :** `Version 1.5.6 - Test Mise à Jour`
      - **Description (copie-colle) :**
      ```markdown
      ## 🧪 Release de Test
      
      Ceci est une release de test pour vérifier le système de mise à jour automatique.
      
      ### Test des nouveautés
      - ✨ Amélioration des performances
      - 🐛 Corrections de bugs mineurs
      - 🎨 Interface modernisée
      - ⚡ Optimisation de la batterie
      
      **Note :** Cette release est uniquement pour tester le système de notification de mise à jour.
      ```

   c. **Upload un APK (n'importe lequel pour le test) :**
      - Va dans `build/app/outputs/flutter-apk/`
      - Upload `app-arm64-v8a-release.apk`
      - Ou n'importe quel APK que tu as déjà buildé

   d. **Publie la release**
      - Clique sur **"Publish release"**

**3. Teste dans l'application**

   **Option A : Vérification automatique au démarrage**
   - Ferme complètement l'app (force quit)
   - Relance l'app
   - Attends 2-3 secondes
   - 🎉 Le dialogue devrait apparaître automatiquement !

   **Option B : Vérification manuelle depuis la page de test**
   - Ouvre l'app
   - Va dans Settings ⚙️ → "🧪 Test Mise à Jour"
   - Clique sur **"🔍 Vérifier sur GitHub"**
   - Le dialogue apparaîtra si une version supérieure existe

**4. Vérifie le comportement**
   - ✅ La version actuelle affichée = 1.5.5
   - ✅ La nouvelle version affichée = 1.5.6
   - ✅ Les release notes s'affichent correctement
   - ✅ Le bouton "Télécharger" ouvre le navigateur vers la release
   - ✅ Le bouton "Plus tard" ferme le dialogue

**5. Nettoie après le test**
   - Après le test, tu peux supprimer la release 1.5.6 sur GitHub
   - Ou la garder en mode "Draft" pour ne pas confondre les utilisateurs

---

## 🎯 Scénarios de Test

### ✅ Scénario 1 : Nouvelle version disponible
- **Configuration :** Release GitHub v1.5.6, App en v1.5.5
- **Résultat attendu :** Dialogue s'affiche avec option de téléchargement

### ✅ Scénario 2 : Déjà à jour
- **Configuration :** Release GitHub v1.5.5, App en v1.5.5
- **Résultat attendu :** Pas de dialogue, message "Vous avez la dernière version"

### ✅ Scénario 3 : Version locale plus récente (rare)
- **Configuration :** Release GitHub v1.5.4, App en v1.5.5
- **Résultat attendu :** Pas de dialogue (pas de downgrade)

### ✅ Scénario 4 : Pas de connexion Internet
- **Configuration :** Mode avion activé
- **Résultat attendu :** App continue de fonctionner normalement, pas d'erreur

---

## 📊 Checklist de Vérification

Lors de tes tests, vérifie que :

- [ ] Le dialogue s'affiche au bon moment (démarrage ou après 2 secondes)
- [ ] Les versions affichées sont correctes
- [ ] Les release notes s'affichent en Markdown formaté
- [ ] Le bouton "Télécharger" ouvre bien GitHub
- [ ] Le bouton "Plus tard" ferme le dialogue
- [ ] L'app ne crash pas en cas d'erreur réseau
- [ ] Le dialogue ne s'affiche pas si l'app est déjà à jour
- [ ] La page de test affiche correctement la version actuelle
- [ ] La simulation fonctionne sans connexion Internet

---

## 🐛 Problèmes Courants

### Le dialogue ne s'affiche pas
**Solutions :**
1. Vérifie que tu as bien créé une release avec une version supérieure
2. Attends quelques secondes après le lancement
3. Vérifie ta connexion Internet
4. Regarde les logs : `flutter run` pour voir les erreurs

### L'API GitHub retourne une erreur
**Solutions :**
1. Vérifie que le repo est bien public
2. Attends quelques minutes (cache GitHub)
3. Vérifie l'URL dans `update_checker.dart`

### Le téléchargement ne démarre pas
**Solutions :**
1. Vérifie que l'APK est bien uploadé dans la release
2. Le nom du fichier doit contenir `.apk`
3. Vérifie les permissions de téléchargement sur le téléphone

---

## 💡 Astuces

1. **Pendant le développement :** Utilise la simulation pour itérer rapidement
2. **Avant la release :** Teste avec une vraie release GitHub
3. **Pour débugger :** Regarde les logs dans `flutter run`
4. **Version de test :** Utilise toujours x.x.6 ou x.x.9 pour les tests (facile à repérer)

---

## 🎉 Résultat Final

Une fois validée, cette fonctionnalité permettra à tous tes utilisateurs de recevoir automatiquement une notification quand tu publies une nouvelle version, sans Google Play Store, totalement gratuitement ! 🚀
