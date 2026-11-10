import 'package:flutter/material.dart';

/// Définition d'une entrée de menu.
class MenuEntry {
  final String id;
  final String label;
  final IconData icon;
  final String route;
  const MenuEntry(this.id, this.label, this.icon, this.route);
}

/// Catalogue central des modules accessibles depuis l'accueil.
const Map<String, MenuEntry> kMenuCatalog = {
  'orders': MenuEntry('orders', 'Ordres de réparation', Icons.assignment_outlined, '/orders'),
  'diagnostic': MenuEntry('diagnostic', 'Diagnostic', Icons.build_circle_outlined, '/diagnostic'),
  'tyres': MenuEntry('tyres', 'Pneus / DOT', Icons.tire_repair_outlined, '/tyres'),
  'photos': MenuEntry('photos', 'Photos', Icons.photo_camera_outlined, '/photos'),
  'vehicle': MenuEntry('vehicle', 'Véhicule', Icons.directions_car_outlined, '/vehicle'),
  'scanner': MenuEntry('scanner', 'Scanner VIN', Icons.qr_code_scanner_outlined, '/scanner'),
  'tools': MenuEntry('tools', 'Outils mécano', Icons.calculate_outlined, '/tools'),
};
