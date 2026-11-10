import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/repair_order.dart';

/// Source des ordres de réparation. Interface → implémentation branchable
/// (mock aujourd'hui, API officielle autorisée demain).
abstract class OrdersRepository {
  Future<List<RepairOrder>> fetchOrders();
  Future<RepairOrder?> fetchOrder(String id);
}

/// Implémentation mock : lit des fixtures locales. Aucune donnée réelle, aucun réseau.
class MockOrdersRepository implements OrdersRepository {
  List<RepairOrder>? _cache;

  Future<List<RepairOrder>> _load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/fixtures/orders.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return _cache = list.map(RepairOrder.fromJson).toList();
  }

  @override
  Future<List<RepairOrder>> fetchOrders() => _load();

  @override
  Future<RepairOrder?> fetchOrder(String id) async {
    final all = await _load();
    for (final o in all) {
      if (o.id == id) return o;
    }
    return null;
  }
}

final ordersRepositoryProvider =
    Provider<OrdersRepository>((_) => MockOrdersRepository());

final ordersProvider =
    FutureProvider<List<RepairOrder>>((ref) => ref.watch(ordersRepositoryProvider).fetchOrders());

final orderProvider =
    FutureProvider.family<RepairOrder?, String>((ref, id) => ref.watch(ordersRepositoryProvider).fetchOrder(id));
