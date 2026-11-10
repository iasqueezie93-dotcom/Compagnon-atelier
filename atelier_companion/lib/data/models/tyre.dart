/// Position d'un pneu sur le véhicule.
enum TyrePosition { avantGauche, avantDroit, arriereGauche, arriereDroit }

extension TyrePositionX on TyrePosition {
  String get label => switch (this) {
        TyrePosition.avantGauche => 'Avant gauche',
        TyrePosition.avantDroit => 'Avant droit',
        TyrePosition.arriereGauche => 'Arrière gauche',
        TyrePosition.arriereDroit => 'Arrière droit',
      };
  String get short => switch (this) {
        TyrePosition.avantGauche => 'AVG',
        TyrePosition.avantDroit => 'AVD',
        TyrePosition.arriereGauche => 'ARG',
        TyrePosition.arriereDroit => 'ARD',
      };
}

/// Relevé d'un pneu : profondeur (mm) et code DOT (semaine/année).
class TyreReading {
  final TyrePosition position;
  double? depthMm;
  String? dot; // ex: "3623" => 36e semaine 2023

  TyreReading({required this.position, this.depthMm, this.dot});

  /// Âge en années depuis le DOT (null si invalide). Calcul local, sans réseau.
  double? ageYears({DateTime? now}) {
    final d = dot;
    if (d == null || d.length != 4) return null;
    final week = int.tryParse(d.substring(0, 2));
    final yy = int.tryParse(d.substring(2, 4));
    if (week == null || yy == null || week < 1 || week > 53) return null;
    final year = 2000 + yy;
    final manufactured = DateTime(year).add(Duration(days: (week - 1) * 7));
    final ref = now ?? DateTime.now();
    return ref.difference(manufactured).inDays / 365.25;
  }

  bool get isValidDot => ageYears() != null;
}
