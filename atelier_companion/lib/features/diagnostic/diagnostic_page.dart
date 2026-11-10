import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/diagnostic.dart';
import '../../data/repositories/history_repository.dart';
import 'diagnostic_controller.dart';

/// Diagnostic enrichi : sections → points → verdict + commentaire, progression,
/// enregistrement dans l'historique local.
class DiagnosticPage extends ConsumerWidget {
  const DiagnosticPage({super.key});

  Color _verdictColor(CheckVerdict v, ColorScheme cs) => switch (v) {
        CheckVerdict.nonControle => cs.outline,
        CheckVerdict.conforme => Colors.green,
        CheckVerdict.aSurveiller => Colors.orange,
        CheckVerdict.aReparer => Colors.red,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(diagnosticControllerProvider);
    final ctrl = ref.read(diagnosticControllerProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    if (state.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostic'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(value: state.progress),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '${state.done}/${state.total} points — '
              '${(state.progress * 100).round()} %   '
              '(✓ ${state.countOf(CheckVerdict.conforme)}  '
              '△ ${state.countOf(CheckVerdict.aSurveiller)}  '
              '✗ ${state.countOf(CheckVerdict.aReparer)})',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          for (final section in state.sections)
            Card(
              child: ExpansionTile(
                title: Text(section.title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                childrenPadding: const EdgeInsets.only(bottom: 8),
                children: [
                  for (final p in section.points)
                    _PointTile(
                      point: p,
                      color: _verdictColor(p.verdict, cs),
                      onVerdict: (v) => ctrl.setVerdict(p.id, v),
                      onComment: (c) => ctrl.setComment(p.id, c),
                    ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await ref.read(historyRepositoryProvider).add(
                HistoryEntry(
                  id: 'DIAG-${DateTime.now().millisecondsSinceEpoch}',
                  title: 'Diagnostic enregistré',
                  subtitle: '${state.done}/${state.total} points · '
                      '${state.countOf(CheckVerdict.aReparer)} à réparer',
                  date: DateTime.now(),
                ),
              );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Diagnostic enregistré (historique local)')),
            );
          }
        },
        icon: const Icon(Icons.save_outlined),
        label: const Text('Enregistrer'),
      ),
    );
  }
}

class _PointTile extends StatelessWidget {
  final CheckPoint point;
  final Color color;
  final ValueChanged<CheckVerdict> onVerdict;
  final ValueChanged<String> onComment;
  const _PointTile({
    required this.point,
    required this.color,
    required this.onVerdict,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(point.label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: [
              for (final v in CheckVerdict.values)
                if (v != CheckVerdict.nonControle)
                  ChoiceChip(
                    label: Text(v.label),
                    selected: point.verdict == v,
                    onSelected: (_) => onVerdict(v),
                  ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: point.comment,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              isDense: true,
              labelText: 'Commentaire',
              prefixIcon: Icon(Icons.edit_note),
            ),
            onChanged: onComment,
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }
}
