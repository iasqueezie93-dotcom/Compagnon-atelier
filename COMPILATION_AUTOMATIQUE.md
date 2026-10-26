# Compilation automatique — Compagnon Atelier Reboot (test Android ARM64)

Cette archive contient une action GitHub prête à compiler une **APK debug installable et signée avec la clé de test Android**. L'action est définie dans `.github/workflows/build-test-apk.yml`.

## Sans ChatGPT Work

1. Crée un dépôt GitHub **privé** (les adresses atelier ne doivent pas être publiées).
2. Dépose le **contenu du dossier** `CompagnonAtelier_Reboot/` à la racine du dépôt, y compris le dossier caché `.github/` (un outil Git local convient mieux à une interface qui masque les fichiers cachés).
3. Ouvre l'onglet **Actions**, choisis **Compiler APK de test ARM64**, puis **Run workflow**.
4. Quand la construction aboutit, récupère l'artefact **CompagnonAtelier_Reboot_TEST_ARM64**. Le ZIP téléchargé par GitHub contient `CompagnonAtelier_Reboot_TEST_ARM64.apk` et `SHA256_APK.txt`.
5. Sur le Galaxy A17, autorise l'installation depuis le gestionnaire de fichiers si demandé, puis installe l'APK.

La première exécution téléchargera Flutter, Java/Gradle et les dépendances sur GitHub (pas sur ce poste). Si elle échoue, le journal Actions indique la cause exacte.

## Réseau et sécurité

- Le test est **en lecture seule** sur les API Feu Vert; les diagnostics et activités restent sur le téléphone.
- Le centre n'est confirmé que lorsque `whoami` répond avec un code valide, depuis un réseau autorisé.
- Ne partage ni captures d'OR nominatives, ni journaux réseau sensibles dans un dépôt public.
- L'archive est uniquement **un projet source préparé**, pas une APK déjà compilée ou testée sur téléphone.
- La signature debug est prévue pour un test privé, pas pour distribuer l'application en production.
