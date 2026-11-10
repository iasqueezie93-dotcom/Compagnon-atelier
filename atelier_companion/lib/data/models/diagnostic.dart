/// Verdict d'un point de contrôle.
enum CheckVerdict { nonControle, conforme, aSurveiller, aReparer }

extension CheckVerdictX on CheckVerdict {
  String get label => switch (this) {
        CheckVerdict.nonControle => 'Non contrôlé',
        CheckVerdict.conforme => 'Conforme',
        CheckVerdict.aSurveiller => 'À surveiller',
        CheckVerdict.aReparer => 'À réparer',
      };
}

/// Un point de contrôle (freinage, pneus, éclairage…).
class CheckPoint {
  final String id;
  final String label;
  CheckVerdict verdict;
  String comment;
  int photoCount;

  CheckPoint({
    required this.id,
    required this.label,
    this.verdict = CheckVerdict.nonControle,
    this.comment = '',
    this.photoCount = 0,
  });

  factory CheckPoint.fromJson(Map<String, dynamic> j) =>
      CheckPoint(id: j['id'] as String, label: j['label'] as String);

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'verdict': verdict.name,
        'comment': comment,
        'photoCount': photoCount,
      };
}

/// Une section de diagnostic regroupant des points de contrôle.
class DiagnosticSection {
  final String title;
  final List<CheckPoint> points;
  const DiagnosticSection({required this.title, required this.points});

  factory DiagnosticSection.fromJson(Map<String, dynamic> j) => DiagnosticSection(
        title: j['title'] as String,
        points: (j['points'] as List)
            .cast<Map<String, dynamic>>()
            .map(CheckPoint.fromJson)
            .toList(),
      );
}
