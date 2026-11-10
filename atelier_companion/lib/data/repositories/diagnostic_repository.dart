import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/diagnostic.dart';

/// Fournit le modèle de diagnostic (sections + points) depuis une fixture locale.
class DiagnosticRepository {
  Future<List<DiagnosticSection>> loadTemplate() async {
    final raw = await rootBundle.loadString('assets/fixtures/diagnostic_template.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(DiagnosticSection.fromJson).toList();
  }
}

final diagnosticRepositoryProvider =
    Provider<DiagnosticRepository>((_) => DiagnosticRepository());
