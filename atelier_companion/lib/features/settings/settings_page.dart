import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/common.dart';
import '../home/menu_catalog.dart';
import 'settings_controller.dart';

/// Réglages : thème, personnalisation du menu d'accueil (ordre).
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final order = ref.watch(menuOrderProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('Apparence'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Clair')),
                  ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto), label: Text('Auto')),
                  ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Sombre')),
                ],
                selected: {mode},
                onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).set(s.first),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionHeader('Menu d\'accueil (glisser pour réordonner)'),
              TextButton(
                onPressed: () => ref.read(menuOrderProvider.notifier).reset(),
                child: const Text('Réinit.'),
              ),
            ],
          ),
          Card(
            child: ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (o, n) => ref.read(menuOrderProvider.notifier).reorder(o, n),
              children: [
                for (final id in order)
                  if (kMenuCatalog[id] != null)
                    ListTile(
                      key: ValueKey(id),
                      leading: Icon(kMenuCatalog[id]!.icon),
                      title: Text(kMenuCatalog[id]!.label),
                      trailing: const Icon(Icons.drag_handle),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Application indépendante · données de démonstration fictives.\n'
                'Aucune marque tierce, aucun accès à un système externe.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
