# Atelier Companion — Compilation GitHub Actions

Cette archive contient uniquement le **projet Flutter indépendant** (données fictives), et **pas** l'APK professionnelle Feu Vert.

## Structure à copier à la racine du dépôt GitHub

- `atelier_companion/` : application Flutter; le dossier Android est créé pendant la compilation
- `.github/workflows/build-atelier-companion.yml` : workflow GitHub Actions
- `GUIDE_GITHUB.md` : ce guide

## Depuis Termux (dans un dépôt Git autorisé)

1. Télécharge `ATELIER_COMPANION_GITHUB_PRET.zip` dans le dossier Download du téléphone.
2. Exécute ces commandes (le nom est important) :

```bash
pkg install unzip git -y
cd ~/Compagnon-atelier
unzip -o '/storage/emulated/0/Download/ATELIER_COMPANION_GITHUB_PRET.zip' -d .
git status
git add atelier_companion .github/workflows/build-atelier-companion.yml GUIDE_GITHUB.md
git commit -m 'Ajouter application Flutter indépendante et build Android ARM64'
git pull --rebase origin main
git push origin main
```

Avant un push, confirme que tu as le droit de publier le contenu de ce dépôt. L'archive préparée ne comprend aucune APK professionnelle. Si la commande `git pull --rebase` rencontre un conflit, ne fais pas de `push --force` : demande de l'aide.

## Lancer la compilation

Sur GitHub, ouvre **Actions** → **Compiler Atelier Companion (Android ARM64)** → **Run workflow**.
Un push sur `main` avec un changement dans `atelier_companion/` déclenche aussi le workflow.
Quand le workflow est vert : ouvre l'exécution → **Artifacts** → télécharge **Atelier-Companion-Android-ARM64** → extrais le ZIP de l'artifact pour récupérer l'APK.

## Informations importantes

- Flutter **3.47.9**, Java 17, Android ARM64.
- `flutter create` génère les fichiers Android lors du build.
- La dépendance `intl` a été ajustée à `any` pour respecter le versionnage imposé par `flutter_localizations`.
- Identifiant Android projet neuf : `com.atelier.atelier_companion`.
- Le build utilise la signature de test par défaut du projet Flutter généré. Une mise à jour installée depuis un autre build peut demander de désinstaller l'ancienne version (la désinstallation efface ses données locales).
- Cette version fonctionne avec des **données de démonstration**. La caméra réelle, la torche physique et l'OCR restent à implémenter.
- Ce ZIP a été préparé et contrôlé structurellement, mais **aucune compilation Flutter n'a été exécutée localement** faute du SDK Flutter dans cet environnement. Le workflow GitHub constitue le test de compilation réel.
- Si le dépôt contient une APK tierce non autorisée, la retirer d'un commit ultérieur **ne la supprime pas de l'historique**. Utiliser idéalement un dépôt propre pour ce projet indépendant.
