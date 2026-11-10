import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/orders_repository.dart';
import '../../shared/widgets/common.dart';

/// Détail d'un ordre de réparation + accès rapide aux modules liés.
class OrderDetailPage extends ConsumerWidget {
  final String orderId;
  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderProvider(orderId));
    return Scaffold(
      appBar: AppBar(title: Text('OR $orderId')),
      body: order.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(icon: Icons.error_outline, message: 'Erreur : $e'),
        data: (o) {
          if (o == null) {
            return const EmptyState(icon: Icons.search_off, message: 'OR introuvable');
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(o.vehicle.label,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text('${o.vehicle.plate}  ·  ${o.vehicle.year ?? "?"}  ·  '
                          '${o.vehicle.mileageKm ?? "?"} km'),
                      Text('Client : ${o.customer}'),
                    ],
                  ),
                ),
              ),
              const SectionHeader('Opérations'),
              for (final op in o.operations)
                Card(child: ListTile(leading: const Icon(Icons.check_circle_outline), title: Text(op))),
              const SectionHeader('Actions'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => context.go('/diagnostic'),
                    icon: const Icon(Icons.build_circle_outlined),
                    label: const Text('Diagnostic'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => context.go('/tyres'),
                    icon: const Icon(Icons.tire_repair_outlined),
                    label: const Text('Pneus'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => context.go('/photos'),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Photos'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
