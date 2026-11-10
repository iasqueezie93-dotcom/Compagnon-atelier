import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/orders_repository.dart';
import '../../shared/widgets/common.dart';

/// Fiche véhicule (démo : premier véhicule des OR fictifs).
class VehiclePage extends ConsumerWidget {
  const VehiclePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Véhicule'),
        actions: [
          IconButton(
            tooltip: 'Historique',
            icon: const Icon(Icons.history),
            onPressed: () => context.go('/history'),
          ),
        ],
      ),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(icon: Icons.error_outline, message: '$e'),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(icon: Icons.directions_car, message: 'Aucun véhicule');
          }
          final v = list.first.vehicle;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v.label, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 12),
                      _row('Plaque', v.plate),
                      _row('VIN', v.vin ?? '—'),
                      _row('Année', '${v.year ?? "—"}'),
                      _row('Kilométrage', v.mileageKm != null ? '${v.mileageKm} km' : '—'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 120, child: Text(k, style: const TextStyle(color: Colors.grey))),
            Expanded(child: Text(v)),
          ],
        ),
      );
}
