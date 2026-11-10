/// Validation et vérification de VIN (ISO 3779). Calcul 100 % local.
class Vin {
  /// VIN valide : 17 caractères, sans I, O, Q.
  static bool isWellFormed(String vin) {
    final v = vin.toUpperCase();
    if (v.length != 17) return false;
    return RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(v);
  }

  static const _translit = {
    'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5, 'F': 6, 'G': 7, 'H': 8,
    'J': 1, 'K': 2, 'L': 3, 'M': 4, 'N': 5, 'P': 7, 'R': 9,
    'S': 2, 'T': 3, 'U': 4, 'V': 5, 'W': 6, 'X': 7, 'Y': 8, 'Z': 9,
  };
  static const _weights = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2];

  /// Vérifie le 9e caractère de contrôle (convention nord-américaine).
  /// Beaucoup de VIN européens ne respectent pas ce checksum : informatif.
  static bool checksumValid(String vin) {
    final v = vin.toUpperCase();
    if (!isWellFormed(v)) return false;
    var sum = 0;
    for (var i = 0; i < 17; i++) {
      final c = v[i];
      final val = _translit[c] ?? int.tryParse(c);
      if (val == null) return false;
      sum += val * _weights[i];
    }
    final r = sum % 11;
    final expected = r == 10 ? 'X' : '$r';
    return v[8] == expected;
  }

  /// Année modèle approximative depuis le 10e caractère (codes 2010-2039).
  static int? modelYear(String vin) {
    if (!isWellFormed(vin)) return null;
    const codes = 'ABCDEFGHJKLMNPRSTVWXY123456789';
    final idx = codes.indexOf(vin.toUpperCase()[9]);
    if (idx < 0) return null;
    return 2010 + idx; // plage courante ; ambiguïté 30 ans ignorée en démo
  }
}

/// Plaque française SIV (AA-123-AA). Validation de format simple.
class Plate {
  static bool isFrenchSiv(String plate) =>
      RegExp(r'^[A-Z]{2}-?\d{3}-?[A-Z]{2}$').hasMatch(plate.toUpperCase().trim());
}
