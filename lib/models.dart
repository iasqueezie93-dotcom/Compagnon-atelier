import 'dart:convert';

String _asText(dynamic v) => v == null ? '' : v.toString().trim();

Map<String, dynamic> asMap(dynamic raw) => raw is Map
    ? raw.map((k, v) => MapEntry(k.toString(), v))
    : <String, dynamic>{};

String pick(Map<String, dynamic> row, List<String> names, [String fallback = '']) {
  for (final name in names) {
    for (final entry in row.entries) {
      if (entry.key.toLowerCase() == name.toLowerCase() && _asText(entry.value).isNotEmpty) {
        return _asText(entry.value);
      }
    }
  }
  return fallback;
}

class RepairOrder {
  final String id;
  final String label;
  final String plate;
  final String vehicle;
  final String status;
  final String date;
  final Map<String, dynamic> raw;

  RepairOrder({required this.id, required this.label, required this.plate,
    required this.vehicle, required this.status, required this.date, required this.raw});

  factory RepairOrder.fromJson(dynamic value, int index) {
    final map = asMap(value);
    final id = pick(map, ['id','repairOrderId','repair_order_id','idOr','orderId','numOr','number','code'], 'ligne-$index');
    final nestedVehicle = asMap(map['vehicle'] ?? map['car'] ?? map['vehicule']);
    final plate = pick(map, ['licensePlate','registration','immat','plate','immatriculation'],
        pick(nestedVehicle, ['registration','licensePlate','plate','immat']));
    final make = pick(nestedVehicle, ['brand','make','marque']);
    final model = pick(nestedVehicle, ['model','modele']);
    return RepairOrder(
      id: id,
      label: pick(map, ['repairOrderNumber','repairOrderCode','repairOrder','number','numOr','code'],id),
      plate: plate,
      vehicle: pick(map, ['vehicleLabel','vehicleName','carName','vehicule'], '$make $model').trim(),
      status: pick(map, ['statusLabel','status','state','statut'], 'À consulter'),
      date: pick(map, ['date','appointmentDate','dateRdv','createdAt','scheduledAt']),
      raw: map,
    );
  }
}

class ActivityEntry {
  final String id;
  final String label;
  final String orderId;
  final String technician;
  final DateTime date;
  final double amount;
  ActivityEntry({required this.id, required this.label, required this.orderId,
    required this.technician, required this.date, required this.amount});
  Map<String, dynamic> toJson() => {
    'id': id, 'label':label, 'orderId':orderId, 'technician':technician,
    'date':date.toIso8601String(), 'amount':amount
  };
  factory ActivityEntry.fromJson(dynamic data) {
    final v = asMap(data);
    return ActivityEntry(id: _asText(v['id']), label:_asText(v['label']),
      orderId:_asText(v['orderId']),technician:_asText(v['technician']),
      date:DateTime.tryParse(_asText(v['date'])) ?? DateTime.now(),
      amount: (v['amount'] is num) ? (v['amount'] as num).toDouble() : double.tryParse(_asText(v['amount'])) ?? 0);
  }
}

class InspectionDraft {
  Map<String, String> points;
  String note;
  List<String> photos;
  DateTime updatedAt;
  InspectionDraft({Map<String, String>? points,String? note,List<String>? photos,DateTime? updatedAt})
      : points=points ?? {}, note=note ?? '', photos=photos ?? [],updatedAt=updatedAt ?? DateTime.now();
  Map<String, dynamic> toJson() => {'points':points,'note':note,'photos':photos,'updatedAt':updatedAt.toIso8601String()};
  factory InspectionDraft.fromJson(dynamic data) {
    final v=asMap(data);
    return InspectionDraft(points: asMap(v['points']).map((k, val) => MapEntry(k,_asText(val))),
      note: _asText(v['note']),photos:(v['photos'] is List) ? (v['photos'] as List).map((x)=>x.toString()).toList():[],
      updatedAt:DateTime.tryParse(_asText(v['updatedAt'])));
  }
}

String toJsonString(dynamic value) => jsonEncode(value);
