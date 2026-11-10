import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/diagnostic.dart';
import '../../data/repositories/diagnostic_repository.dart';

@immutable
class DiagnosticState {
  final List<DiagnosticSection> sections;
  final bool loading;
  const DiagnosticState({this.sections = const [], this.loading = true});

  int get total => sections.fold(0, (n, s) => n + s.points.length);
  int get done => sections.fold(
        0,
        (n, s) => n + s.points.where((p) => p.verdict != CheckVerdict.nonControle).length,
      );
  double get progress => total == 0 ? 0 : done / total;

  int countOf(CheckVerdict v) =>
      sections.fold(0, (n, s) => n + s.points.where((p) => p.verdict == v).length);
}

/// Contrôleur du diagnostic en cours (brouillon en mémoire + progression).
class DiagnosticController extends StateNotifier<DiagnosticState> {
  DiagnosticController(this._repo) : super(const DiagnosticState()) {
    _init();
  }
  final DiagnosticRepository _repo;

  Future<void> _init() async {
    final sections = await _repo.loadTemplate();
    state = DiagnosticState(sections: sections, loading: false);
  }

  void setVerdict(String pointId, CheckVerdict verdict) {
    for (final s in state.sections) {
      for (final p in s.points) {
        if (p.id == pointId) p.verdict = verdict;
      }
    }
    state = DiagnosticState(sections: state.sections, loading: false);
  }

  void setComment(String pointId, String comment) {
    for (final s in state.sections) {
      for (final p in s.points) {
        if (p.id == pointId) p.comment = comment;
      }
    }
    // Pas de rebuild nécessaire pour le texte ; l'état reste cohérent.
  }
}

final diagnosticControllerProvider =
    StateNotifierProvider<DiagnosticController, DiagnosticState>((ref) {
  return DiagnosticController(ref.watch(diagnosticRepositoryProvider));
});
