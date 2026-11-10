# Atelier Companion

Application atelier Android **indépendante**, écrite from scratch (Flutter + Riverpod + go_router).
Inspirée de l'organisation fonctionnelle d'un compagnon d'atelier, **sans aucun code, asset ou accès**
repris d'une application tierce. Toutes les données métier sont **fictives** (dossier `assets/fixtures/`).

## Fonctionnalités (jalon 1 — livré ici)
- **Accueil** : grille de modules, **ordre personnalisable** (réglages) et persistant.
- **Thème clair / sombre / auto** (persistant).
- **Torche globale** (service, accessible depuis l'accueil et l'écran Photos).
- **Ordres de réparation** : liste + détail (mock).
- **Diagnostic enrichi** : sections → points de contrôle → verdict + commentaire, **barre de progression**,
  **enregistrement dans l'historique local**.
- **Pneus / DOT** : relevé par position, profondeur, **calcul d'âge DOT** et seuils d'alerte.
- **Véhicule** : fiche + **historique local**.
- **Photos** : galerie (capture simulée ; branchement caméra au jalon 3).
- **Scanner VIN / plaque** : saisie + **validation VIN (ISO 3779) et plaque FR** (OCR caméra au jalon 3).
- **Outils mécano** : couple de serrage, pression, usure plaquettes, main-d'œuvre.

## Démarrer
```bash
flutter create . --org com.atelier --project-name atelier_companion   # génère android/ ios/ ...
flutter pub get
flutter test        # tests unitaires (VIN, plaque, DOT)
flutter run
```
> `flutter create .` complète les dossiers de plateforme **sans écraser** `lib/`, `pubspec.yaml`,
> `assets/` ni `test/`. Choisir un **applicationId neuf** et une **nouvelle clé de signature**.

## Structure
```
lib/
  app/        app, theme (clair/sombre), router
  core/       storage (prefs/json), services (torche, notifications), vin
  data/       models + repositories (mock) ; fixtures dans assets/
  features/   home, orders, diagnostic, tyres, photos, vehicle, scanner, tools, settings
  shared/     widgets communs
```

## Jalons suivants (voir aussi PLAN_CUSTOM.md)
2. Caméra réelle + flash matériel (`camera`, `torch_light`), upload vers un stockage autorisé.
3. OCR VIN/plaque (`google_mlkit_text_recognition`), véhicule interactif SVG.
4. Notifications locales (`flutter_local_notifications`), historique SQLite (`drift`), export CSV.
5. (Option) Assistant IA de diagnostic via API officielle (clé fournie par l'utilisateur, jamais en dur).

## Règles
- Pas de marque tierce, pas de secret en dur, pas d'accès non autorisé.
- Fonctions professionnelles = mocks ou **API officielle autorisée** uniquement.
