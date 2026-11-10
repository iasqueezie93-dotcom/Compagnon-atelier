/// Véhicule (données fictives).
class Vehicle {
  final String plate;
  final String brand;
  final String model;
  final String? vin;
  final int? year;
  final int? mileageKm;

  const Vehicle({
    required this.plate,
    required this.brand,
    required this.model,
    this.vin,
    this.year,
    this.mileageKm,
  });

  String get label => '$brand $model';

  factory Vehicle.fromJson(Map<String, dynamic> j) => Vehicle(
        plate: j['plate'] as String,
        brand: j['brand'] as String? ?? '',
        model: j['model'] as String? ?? '',
        vin: j['vin'] as String?,
        year: j['year'] as int?,
        mileageKm: j['mileageKm'] as int?,
      );
}
