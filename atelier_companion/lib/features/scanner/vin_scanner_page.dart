import 'package:flutter/material.dart';

import '../../core/vin.dart';
import '../../shared/widgets/common.dart';

/// Saisie/scan VIN ou plaque. En démo : saisie manuelle + validation locale.
/// Production : brancher `google_mlkit_text_recognition` (OCR on-device) sur le
/// bouton « Scanner » — le texte reconnu alimente le même champ. Aucune donnée
/// n'est envoyée au cloud.
class VinScannerPage extends StatefulWidget {
  const VinScannerPage({super.key});
  @override
  State<VinScannerPage> createState() => _VinScannerPageState();
}

class _VinScannerPageState extends State<VinScannerPage> {
  final _controller = TextEditingController();
  String _value = '';

  @override
  Widget build(BuildContext context) {
    final v = _value.trim().toUpperCase();
    final isVin = Vin.isWellFormed(v);
    final isPlate = Plate.isFrenchSiv(v);

    return Scaffold(
      appBar: AppBar(title: const Text('Scanner VIN / plaque')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'VIN (17 car.) ou plaque (AA-123-AA)',
              prefixIcon: Icon(Icons.tag),
            ),
            onChanged: (s) => setState(() => _value = s),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              // TODO(jalon 3): ouvrir la caméra + ML Kit, puis remplir le champ.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('OCR caméra : à brancher (ML Kit) au jalon 3')),
              );
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scanner avec la caméra'),
          ),
          const SizedBox(height: 16),
          if (v.isEmpty)
            const EmptyState(icon: Icons.info_outline, message: 'Saisis ou scanne un VIN / une plaque.')
          else if (isVin) ...[
            const SectionHeader('VIN détecté'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              StatusChip('Format VIN valide', Colors.green),
              StatusChip(
                Vin.checksumValid(v) ? 'Checksum OK' : 'Checksum non conforme (fréquent en Europe)',
                Vin.checksumValid(v) ? Colors.green : Colors.orange,
              ),
              if (Vin.modelYear(v) != null)
                StatusChip('Année modèle ~ ${Vin.modelYear(v)}', Colors.blue),
            ]),
          ] else if (isPlate) ...[
            const SectionHeader('Plaque détectée'),
            StatusChip('Format plaque FR valide', Colors.green),
          ] else
            StatusChip('Format non reconnu', Colors.red),
        ],
      ),
    );
  }
}
