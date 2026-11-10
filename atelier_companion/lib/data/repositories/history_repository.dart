import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/local_store.dart';

/// Une entrée d'historique local (intervention/diagnostic enregistré).
class HistoryEntry {
  final String id;
  final String title;
  final String subtitle;
  final DateTime date;

  const HistoryEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'date': date.toIso8601String(),
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> j) => HistoryEntry(
        id: j['id'] as String,
        title: j['title'] as String,
        subtitle: j['subtitle'] as String? ?? '',
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
      );
}

/// Historique local persistant (préférences JSON).
class HistoryRepository {
  HistoryRepository(this._store);
  final LocalStore _store;
  static const _key = 'history_entries';

  List<HistoryEntry> all() => _store
      .getJsonList(_key)
      .map(HistoryEntry.fromJson)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  Future<void> add(HistoryEntry e) async {
    final list = _store.getJsonList(_key)..add(e.toJson());
    await _store.setJsonList(_key, list);
  }

  Future<void> clear() => _store.setJsonList(_key, []);
}

final historyRepositoryProvider =
    Provider<HistoryRepository>((ref) => HistoryRepository(ref.watch(localStoreProvider)));
