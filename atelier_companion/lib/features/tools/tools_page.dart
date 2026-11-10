import 'package:flutter/material.dart';

import '../../shared/widgets/common.dart';

/// Boîte à outils mécanicien — calculs locaux originaux.
class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Outils mécano')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          _TorqueTool(),
          _PressureTool(),
          _PadWearTool(),
          _LaborCostTool(),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _ToolCard({required this.title, required this.icon, required this.child});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [Icon(icon), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w700))]),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

Widget _num(String label, ValueChanged<double?> onChanged) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, isDense: true),
        onChanged: (s) => onChanged(double.tryParse(s.replaceAll(',', '.'))),
      ),
    );

Widget _result(BuildContext c, String text) => Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(text, style: Theme.of(c).textTheme.titleMedium),
    );

/// Couple N·m ↔ lb·ft
class _TorqueTool extends StatefulWidget {
  const _TorqueTool();
  @override
  State<_TorqueTool> createState() => _TorqueToolState();
}

class _TorqueToolState extends State<_TorqueTool> {
  double? _nm;
  @override
  Widget build(BuildContext context) {
    const k = 1.3558179483;
    return _ToolCard(
      title: 'Couple de serrage',
      icon: Icons.settings_suggest_outlined,
      child: Column(children: [
        _num('Couple (N·m)', (v) => setState(() => _nm = v)),
        if (_nm != null) _result(context, '${_nm!.toStringAsFixed(1)} N·m = ${(_nm! / k).toStringAsFixed(1)} lb·ft'),
      ]),
    );
  }
}

/// Pression bar ↔ psi
class _PressureTool extends StatefulWidget {
  const _PressureTool();
  @override
  State<_PressureTool> createState() => _PressureToolState();
}

class _PressureToolState extends State<_PressureTool> {
  double? _bar;
  @override
  Widget build(BuildContext context) {
    return _ToolCard(
      title: 'Pression pneu',
      icon: Icons.compress,
      child: Column(children: [
        _num('Pression (bar)', (v) => setState(() => _bar = v)),
        if (_bar != null) _result(context, '${_bar!.toStringAsFixed(2)} bar = ${(_bar! * 14.5038).toStringAsFixed(1)} psi'),
      ]),
    );
  }
}

/// Usure plaquettes : % restant entre épaisseur neuve et mini.
class _PadWearTool extends StatefulWidget {
  const _PadWearTool();
  @override
  State<_PadWearTool> createState() => _PadWearToolState();
}

class _PadWearToolState extends State<_PadWearTool> {
  double? _new, _min, _cur;
  @override
  Widget build(BuildContext context) {
    double? pct;
    if (_new != null && _min != null && _cur != null && _new! > _min!) {
      pct = ((_cur! - _min!) / (_new! - _min!) * 100).clamp(0, 100);
    }
    return _ToolCard(
      title: 'Usure plaquettes',
      icon: Icons.disc_full_outlined,
      child: Column(children: [
        _num('Épaisseur neuve (mm)', (v) => setState(() => _new = v)),
        _num('Épaisseur mini (mm)', (v) => setState(() => _min = v)),
        _num('Épaisseur actuelle (mm)', (v) => setState(() => _cur = v)),
        if (pct != null)
          _result(context, 'Restant : ${pct.toStringAsFixed(0)} %'
              '${pct < 20 ? "  ⚠️ à remplacer bientôt" : ""}'),
      ]),
    );
  }
}

/// Coût main-d'œuvre = temps (h) × taux horaire.
class _LaborCostTool extends StatefulWidget {
  const _LaborCostTool();
  @override
  State<_LaborCostTool> createState() => _LaborCostToolState();
}

class _LaborCostToolState extends State<_LaborCostTool> {
  double? _h, _rate;
  @override
  Widget build(BuildContext context) {
    final total = (_h != null && _rate != null) ? _h! * _rate! : null;
    return _ToolCard(
      title: 'Main-d\'œuvre',
      icon: Icons.schedule,
      child: Column(children: [
        _num('Temps (h)', (v) => setState(() => _h = v)),
        _num('Taux horaire (€)', (v) => setState(() => _rate = v)),
        if (total != null) _result(context, 'Total : ${total.toStringAsFixed(2)} €'),
      ]),
    );
  }
}
