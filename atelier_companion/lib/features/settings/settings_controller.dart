import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/local_store.dart';

/// Mode de thème persistant (clair / sombre / système).
class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._store) : super(_read(_store));
  final LocalStore _store;
  static const _key = 'theme_mode';

  static ThemeMode _read(LocalStore s) {
    switch (s.getString(_key)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void set(ThemeMode mode) {
    state = mode;
    _store.setString(_key, mode.name);
  }

  void toggle() => set(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController(ref.watch(localStoreProvider));
});

/// Ordre des entrées du menu d'accueil, personnalisable et persistant.
class MenuOrderController extends StateNotifier<List<String>> {
  MenuOrderController(this._store) : super(_read(_store));
  final LocalStore _store;
  static const _key = 'menu_order';

  static const defaultOrder = <String>[
    'orders', 'diagnostic', 'tyres', 'photos', 'vehicle', 'scanner', 'tools',
  ];

  static List<String> _read(LocalStore s) {
    final saved = s.getStringList(_key);
    if (saved.isEmpty) return List.of(defaultOrder);
    // Complète avec d'éventuelles nouvelles entrées non encore ordonnées.
    final result = saved.where(defaultOrder.contains).toList();
    for (final id in defaultOrder) {
      if (!result.contains(id)) result.add(id);
    }
    return result;
  }

  void reorder(int oldIndex, int newIndex) {
    final list = List.of(state);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
    _store.setStringList(_key, list);
  }

  void reset() {
    state = List.of(defaultOrder);
    _store.setStringList(_key, state);
  }
}

final menuOrderProvider =
    StateNotifierProvider<MenuOrderController, List<String>>((ref) {
  return MenuOrderController(ref.watch(localStoreProvider));
});
