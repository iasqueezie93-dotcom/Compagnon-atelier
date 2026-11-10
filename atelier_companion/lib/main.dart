import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/storage/local_store.dart';

/// Point d'entrée. Code 100 % original — aucune dépendance au binaire analysé,
/// aucune connexion à un système tiers. Données de démonstration fictives.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(LocalStore(prefs)),
      ],
      child: const AtelierCompanionApp(),
    ),
  );
}
