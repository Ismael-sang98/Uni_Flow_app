# 📱 Guide de Mise à Jour de l'Application

## Comment publier une nouvelle version sur GitHub

### 1️⃣ Modifier la version dans `pubspec.yaml`

```yaml
version: 1.5.2+2  # Augmenter le numéro de version
```

**Format:** `MAJOR.MINOR.PATCH+BUILD`
- `1.5.2` = Version visible par l'utilisateur (1.5.1 → 1.5.2)
- `+2` = Build number (doit toujours augmenter : 1 → 2 → 3...)

### 2️⃣ Builder les APKs

```bash
# Nettoyer et préparer
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter gen-l10n

# Builder les APKs
flutter build apk --release --split-per-abi
```

Les APKs seront dans : `build/app/outputs/flutter-apk/`

### 3️⃣ Créer une Release sur GitHub

1. **Aller sur GitHub**
   - https://github.com/Ismael-sang98/Uni_Flow_app/releases/new

2. **Remplir les champs**
   - **Tag version:** `v1.5.2` (même version que pubspec.yaml)
   - **Release title:** `Version 1.5.2 - Nom de la mise à jour`
   - **Description:** Liste des nouveautés (Markdown)

3. **Uploader les APKs**
   - Drag & drop les 3 fichiers APK :
     - `app-armeabi-v7a-release.apk`
     - `app-arm64-v8a-release.apk`
     - `app-x86_64-release.apk`

4. **Publier**
   - Cliquer sur "Publish release"

### 4️⃣ Format des Release Notes (exemple)

```markdown
## 🎉 Nouveautés

- ✨ Nouvelle fonctionnalité X
- 🐛 Correction du bug Y
- 🎨 Amélioration de l'interface Z

## 📥 Téléchargement

Choisissez le bon APK pour votre téléphone :
- **arm64-v8a** : Téléphones récents (recommandé)
- **armeabi-v7a** : Anciens téléphones
- **x86_64** : Émulateurs
```

### 5️⃣ Vérification

Après publication, l'app vérifiera automatiquement les mises à jour au démarrage et affichera un dialogue aux utilisateurs.

---

## 🔄 Exemple de Cycle de Mise à Jour

**Situation:** Tu veux ajouter une nouvelle fonctionnalité

1. **Développer** la fonctionnalité
2. **Tester** sur l'émulateur/téléphone
3. **Modifier** `pubspec.yaml` : `1.5.1+1` → `1.5.2+2`
4. **Commit & Push** sur GitHub
5. **Builder** les APKs avec `flutter build apk --release --split-per-abi`
6. **Créer** une release sur GitHub avec tag `v1.5.2`
7. **Uploader** les 3 APKs
8. **Publier** → Les utilisateurs seront notifiés automatiquement! 🎉

---

## 🎯 Bonnes Pratiques

- ✅ **Toujours augmenter** la version avant de builder
- ✅ **Tag Git** = `v` + Version du pubspec.yaml (ex: `v1.5.2`)
- ✅ **Release notes claires** pour informer les utilisateurs
- ✅ **Tester** avant de publier
- ❌ **Ne jamais** réutiliser le même numéro de version

---

## 📊 Historique des Versions

| Version | Date | Changements |
|---------|------|-------------|
| 1.5.1 | 18/02/2026 | Notes Library avec support d'images |
| 1.5.0 | ... | Système de notifications |
| 1.0.0 | ... | Version initiale |
