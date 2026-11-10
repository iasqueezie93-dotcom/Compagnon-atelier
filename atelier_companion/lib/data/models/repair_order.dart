import 'vehicle.dart';

/// Statut d'un ordre de réparation.
enum OrderStatus { aFaire, enCours, controle, termine }

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
        OrderStatus.aFaire => 'À faire',
        OrderStatus.enCours => 'En cours',
        OrderStatus.controle => 'À contrôler',
        OrderStatus.termine => 'Terminé',
      };

  static OrderStatus parse(String s) => OrderStatus.values.firstWhere(
        (e) => e.name == s,
        orElse: () => OrderStatus.aFaire,
      );
}

/// Ordre de réparation (données fictives de démonstration).
class RepairOrder {
  final String id;
  final Vehicle vehicle;
  final String customer;
  final OrderStatus status;
  final List<String> operations;

  const RepairOrder({
    required this.id,
    required this.vehicle,
    required this.customer,
    required this.status,
    this.operations = const [],
  });

  factory RepairOrder.fromJson(Map<String, dynamic> j) => RepairOrder(
        id: j['id'] as String,
        vehicle: Vehicle.fromJson(j['vehicle'] as Map<String, dynamic>),
        customer: j['customer'] as String? ?? '',
        status: OrderStatusX.parse(j['status'] as String? ?? 'aFaire'),
        operations:
            (j['operations'] as List?)?.cast<String>() ?? const <String>[],
      );
}
