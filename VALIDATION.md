# Validation interne de la refonte 0.1

## Faits vérifiés dans les deux fichiers utilisateur

- L'archive ZIP d'entrée contient seulement `Compagnon Atelier-1.apk`.
- Son contenu APK est **binaire identique** à l'APK envoyé séparément.
- L'APK est un build Flutter release avec bibliothèques Android ARM64, ARMv7 et x86_64.
- L'environnement PRODUCTION désigne `http://bulbizar.feuvert.fr` comme BASE_URL ; le champ HEADER_AUTHORIZATION y est vide.
- Des chaînes de routes sont présentes dans `libapp.so` : `/rdmstore/store/whoami`, `/smartdiag/store-codes/`, `/repair-orders`.
- Les fichiers d'icônes et images d'origine ont été copiés ; aucune police n'a été distribuée.

## Pas encore vérifié

- La disponibilité réseau à partir du Wi-Fi d'un centre Feu Vert.
- Le schéma exact des réponses `whoami` et `/repair-orders` en conditions réelles.
- Le parsing des OR selon le jour et les données de pièces.
- Le bon fonctionnement de la connexion au planning, selon la session officielle.
- La compilation / l'installation APK. Flutter SDK et Android SDK absents du conteneur.

## Politique de mise à jour serveur

Tant qu'un schéma d'écriture authentifié n'a pas été identifié et testé, **aucune écriture vers le serveur Feu Vert** n'est réalisée par cette refonte. La saisie des diagnostics, des photos et de l'activité reste sur l'appareil.
