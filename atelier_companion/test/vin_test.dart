import 'package:flutter_test/flutter_test.dart';
import 'package:atelier_companion/core/vin.dart';
import 'package:atelier_companion/data/models/tyre.dart';

void main() {
  group('VIN', () {
    test('format 17 caractères sans I/O/Q', () {
      expect(Vin.isWellFormed('1HGBH41JXMN109186'), isTrue);
      expect(Vin.isWellFormed('TROPCOURT'), isFalse);
      expect(Vin.isWellFormed('1HGBH41JXMN1O9186'), isFalse); // O interdit
    });
    test('checksum de référence', () {
      expect(Vin.checksumValid('1HGBH41JXMN109186'), isTrue);
    });
  });

  group('Plaque', () {
    test('format SIV FR', () {
      expect(Plate.isFrenchSiv('AB-123-CD'), isTrue);
      expect(Plate.isFrenchSiv('AB123CD'), isTrue);
      expect(Plate.isFrenchSiv('1234'), isFalse);
    });
  });

  group('DOT', () {
    test('âge calculé depuis un code DOT', () {
      final r = TyreReading(position: TyrePosition.avantGauche, dot: '0120');
      final age = r.ageYears(now: DateTime(2025, 1, 1));
      expect(age, isNotNull);
      expect(age! > 4 && age < 6, isTrue);
    });
    test('DOT invalide → null', () {
      final r = TyreReading(position: TyrePosition.avantDroit, dot: '99');
      expect(r.ageYears(), isNull);
    });
  });
}
