import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/history_repository.dart';
import '../../shared/widgets/common.dart';

/// Historique local des interventions/diagnostics enregistrés.
class VehicleHistoryPage extends ConsumerStatefulWidget {
  const VehicleHistoryPage({super.key});
  @override
  ConsumerState<VehicleHistoryPage> createState() => _VehicleHistoryPageState();
}

class _VehicleHistoryPageState extends ConsumerState<VehicleHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(historyRepositoryProvider);
    final entries = repo.all();
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        actions: [
          if (entries.isNotEmpty)
            IconButton(
              tooltip: 'Vider',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () async {
                await repo.clear();
                if (mounted) setState(() {});
              },
            ),
        ],
      ),
      body: entries.isEmpty
          ? const EmptyState(icon: Icons.history, message: 'Aucune entrée.\nEnregistre un diagnostic pour le voir ici.')
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final e in entries)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: Text(e.title),
                      subtitle: Text('${e.subtitle}\n${fmt.format(e.date)}'),
                      isThreeLine: true,
                    ),
                  ),
              ],
            ),
    );
  }
}
