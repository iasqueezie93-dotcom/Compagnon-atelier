# Rapport de tentative de compilation — 26 octobre 2026

## Résultat

- **APK Reboot produite ici : NON**.
- **APK d'origine : présente**, distincte du nouveau projet ; elle n'a pas été modifiée.
- Flutter/Dart : absents de l'environnement d'exécution.
- Android SDK (aapt, d8, apksigner, build-tools) : absent.
- JDK : installé (Java 21), insuffisant pour compiler Flutter.
- Accès de téléchargement au serveur du SDK : DNS indisponible (`Could not resolve host: dl.google.com`).

## Préparation réalisée

- Vérification de l'archive source et extraction.
- Vérification de l'API : `GET /rdmstore/store/whoami`, `GET /smartdiag/store-codes/<code>/repair-orders` uniquement.
- Suppression de l'affichage trompeur d'un code centre non confirmé avant `whoami`.
- Prise en charge d'une réponse simple `whoami` sous forme de chiffre ou chaîne numérique.
- Ajout d'un script de compilation ARM64 avec `flutter build apk --debug` et d'un workflow GitHub Actions automatisé.
- Vérification statique du contenu, syntaxe shell, configuration XML et absence de POST/PUT/PATCH/DELETE dans l'adaptateur réseau.

## Validation restante

1. Lancer le workflow GitHub Actions pour réellement télécharger Flutter/Android SDK, compiler, signer et tester la validité du paquet.
2. Installer l'APK sur Samsung Galaxy A17 / Android 16.
3. Sur le Wi-Fi atelier avec autorisation d'accès, vérifier le code magasin `whoami` et la récupération des OR.
4. Adapter le parseur si le format JSON réel diffère. N'envoyer aucune écriture aux serveurs.

**Ne pas considérer cette source comme une APK fonctionnelle tant que le workflow n'est pas passé et l'essai réel sur atelier n'a pas eu lieu.**
