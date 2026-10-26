# Compagnon Atelier — Reboot 0.1

Reconstruction Flutter Android **à partir d'une APK originale**, sans disposer du code source initial.
Cette archive est un **projet source initial, pas une APK compilée**. Les fichiers `Compagnon Atelier-1.zip` et `Compagnon Atelier-1.apk` fournis au départ sont en réalité le même binaire APK.

## Ce qui fonctionne dans le code

- UI Android sombre et compacte, 5 onglets, mode Atelier / Magasin.
- Liaison préférentielle au Wi-Fi atelier par `ConnectivityManager.bindProcessToNetwork`, même lorsque la 4G est activée.
- `GET http://bulbizar.feuvert.fr/rdmstore/store/whoami` pour identifier le magasin **si le service est accessible**.
- `GET http://bulbizar.feuvert.fr/smartdiag/store-codes/<centre>/repair-orders` pour récupérer les OR en **lecture seule**.
- Interface de diagnostic avec points de contrôle, notes, jusqu'à 10 photos par OR. **Brouillons locaux uniquement.**
- Activité main d'œuvre TTC par mois, manuelle, locale et sans fausses valeurs préremplies.
- Accès externe aux portails officiels planning.feuvert.fr/task et vmtorino.feuvert.fr. Pas de formulaire de connexion contourné.
- Récupération des éventuelles listes de pièces déjà incluses dans les réponses OR ; aucune route MCP supplémentaire présumée.

## Prérequis et construction

Il faut Flutter et un SDK Android installés sur un PC, ou une machine Android/Termux configurée avec une chaîne de compilation compatible.
Le conteneur utilisé pour préparer cette archive ne dispose pas de Flutter ni du SDK Android : **aucune APK nouvelle n'a pu être construite ou testée sur appareil**.

### Construction automatisée

Depuis le dossier extrait, sur un PC avec Flutter et Android SDK opérationnels :

```bash
bash build_flutter.sh --debug
```

Le script génère un projet Flutter Android dans `.flutter_build/`, copie le code et les ressources,
lance `flutter pub get`, `flutter analyze`, `flutter test`, puis `flutter build apk --release`.
L'APK final est enregistré à la racine du projet.


## À tester à l'atelier

1. Téléphone connecté au Wi-Fi atelier ; laisser les données mobiles actives.
2. Ouvrir **Réglages** → « Détecter le Wi-Fi et se connecter ».
3. Vérifier la confirmation du centre via `whoami` (historique atelier : **96**, non garanti partout).
4. Actualiser les OR. Le schéma JSON réel peut différer et nécessiter un ajustement du parseur `lib/atelier_api.dart`.
5. Créer un diagnostic et une MO tests : ils restent sur ce téléphone, aucune transmission à Feu Vert.

## Précautions

- Ne pas publier l'APK ni les URL internes, et n'utiliser ces services que si l'accès est autorisé par l'employeur.
- Le serveur de production communiqué par l'APK d'origine est en **HTTP non chiffré** ; la règle Android limite le trafic HTTP à ce domaine. Préférer une variante HTTPS validée côté serveur pour des données sensibles.
- La production d'origine a un champ d'en-tête d'autorisation vide. Aucun secret de l'application d'origine n'a été recopié dans ce projet.
- Les liens planning/MCP ouvrent les outils officiels et respectent leur authentification.
- Ne pas confondre connexion Wi-Fi, succès de `whoami` et récupération effective des OR : trois contrôles distincts.
- Les valeurs de performance / ratio de diagnostic ne sont pas modifiées par ce projet.

## Fichiers de l'APK originale analysés

- `assets/flutter_assets/env/.prod.env` : production et URL serveur.
- `assets/flutter_assets/AssetManifest.json` : icônes et images (sans polices).
- `lib/arm64-v8a/libapp.so` : noms des routes `/rdmstore/store/whoami`, `/smartdiag/store-codes/`, `/repair-orders`.

**État du projet** : refonte V0.1 source, réseau et affichage réels restant à vérifier sur site.

## Compilation automatique GitHub Actions

Consulte `COMPILATION_AUTOMATIQUE.md`. Le workflow est inclus dans `.github/workflows/build-test-apk.yml` pour produire une **APK debug signée** et ciblée ARM64, sans avoir Flutter installé sur ton téléphone.
