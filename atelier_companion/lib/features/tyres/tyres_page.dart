import 'package:flutter/material.dart';

import '../../data/models/tyre.dart';
import '../../shared/widgets/common.dart';

/// Relevé pneus par position : profondeur + DOT, avec âge calculé localement.
class TyresPage extends StatefulWidget {
  const TyresPage({super.key});
  @override
  State<TyresPage> createState() => _TyresPageState();
}

class _TyresPageState extends State<TyresPage> {
  late final Map<TyrePosition, TyreReading> _readings = {
    for (final p in TyrePosition.values) p: TyreReading(position: p),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pneus / DOT')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const SectionHeader('Schéma véhicule'),
          const _VehicleDiagram(),
          const SectionHeader('Relevés'),
          for (final p in TyrePosition.values) _TyreCard(_readings[p]!, () => setState(() {})),
        ],
      ),
    );
  }
}

/// Schéma simple (original, dessiné en Flutter) — 4 positions.
class _VehicleDiagram extends StatelessWidget {
  const _VehicleDiagram();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget corner(String s) => Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(s, style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.bold)),
        );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [corner('AVG'), corner('AVD')]),
            const SizedBox(height: 8),
            Icon(Icons.directions_car, size: 48, color: cs.outline),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [corner('ARG'), corner('ARD')]),
          ],
        ),
      ),
    );
  }
}

class _TyreCard extends StatelessWidget {
  final TyreReading reading;
  final VoidCallback onChanged;
  const _TyreCard(this.reading, this.onChanged);

  @override
  Widget build(BuildContext context) {
    final age = reading.ageYears();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reading.position.label, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Profondeur (mm)', isDense: true),
                    onChanged: (v) {
                      reading.depthMm = double.tryParse(v.replaceAll(',', '.'));
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: const InputDecoration(
                        labelText: 'DOT (SSAA)', isDense: true, counterText: ''),
                    onChanged: (v) {
                      reading.dot = v;
                      onChanged();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (reading.depthMm != null || reading.dot != null)
              Wrap(
                spacing: 8,
                children: [
                  if (reading.depthMm != null)
                    StatusChip(
                      'Profondeur ${reading.depthMm!.toStringAsFixed(1)} mm',
                      reading.depthMm! < 1.6 ? Colors.red : (reading.depthMm! < 3 ? Colors.orange : Colors.green),
                    ),
                  if (age != null)
                    StatusChip('Âge ${age.toStringAsFixed(1)} ans',
                        age > 6 ? Colors.red : (age > 4 ? Colors.orange : Colors.green)),
                  if (reading.dot != null && age == null)
                    const StatusChip('DOT invalide', Colors.red),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
