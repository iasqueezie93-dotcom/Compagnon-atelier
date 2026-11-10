import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/torch_service.dart';
import '../settings/settings_controller.dart';
import 'menu_catalog.dart';

/// Tableau de bord : menu d'accès (ordre personnalisable), torche globale,
/// bascule de thème et accès aux réglages.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final torch = ref.watch(torchProvider);
    final mode = ref.watch(themeModeProvider);
    final order = ref.watch(menuOrderProvider);
    final entries = [
      for (final id in order)
        if (kMenuCatalog[id] != null) kMenuCatalog[id]!,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atelier Companion'),
        actions: [
          IconButton(
            tooltip: torch.isOn ? 'Éteindre la torche' : 'Allumer la torche',
            icon: Icon(torch.isOn ? Icons.flashlight_on : Icons.flashlight_off),
            onPressed: () => ref.read(torchProvider).toggle(),
          ),
          IconButton(
            tooltip: 'Changer de thème',
            icon: Icon(mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          IconButton(
            tooltip: 'Réglages',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.15,
        children: [for (final e in entries) _MenuCard(e)],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final MenuEntry entry;
  const _MenuCard(this.entry);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go(entry.route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: cs.primaryContainer,
                child: Icon(entry.icon, color: cs.onPrimaryContainer),
              ),
              const SizedBox(height: 12),
              Text(entry.label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
      ),
    );
  }
}
