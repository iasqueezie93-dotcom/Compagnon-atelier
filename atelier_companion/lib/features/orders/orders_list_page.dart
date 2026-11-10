import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/repair_order.dart';
import '../../data/repositories/orders_repository.dart';
import '../../shared/widgets/common.dart';

/// Liste des ordres de réparation (données fictives).
class OrdersListPage extends ConsumerWidget {
  const OrdersListPage({super.key});

  Color _statusColor(OrderStatus s, ColorScheme cs) => switch (s) {
        OrderStatus.aFaire => cs.outline,
        OrderStatus.enCours => Colors.orange,
        OrderStatus.controle => Colors.blue,
        OrderStatus.termine => Colors.green,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Ordres de réparation')),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(icon: Icons.error_outline, message: 'Erreur : $e'),
        data: (list) => list.isEmpty
            ? const EmptyState(icon: Icons.inbox_outlined, message: 'Aucun OR')
            : ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  for (final o in list)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.assignment_outlined),
                        title: Text('${o.vehicle.label} · ${o.vehicle.plate}'),
                        subtitle: Text('OR ${o.id} — ${o.customer}'),
                        trailing: StatusChip(o.status.label, _statusColor(o.status, cs)),
                        onTap: () => context.go('/orders/${o.id}'),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
