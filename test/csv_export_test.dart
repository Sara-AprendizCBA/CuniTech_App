import 'package:flutter_test/flutter_test.dart';

import 'package:cunitech/models/rabbit.dart';
import 'package:cunitech/services/csv_export_service.dart';

Rabbit _conejo({
  String chapeta = 'NZ-001',
  String raza = 'Netherland',
  String genero = 'Hembra',
  String estado = 'Saludable',
  double peso = 2.5,
  DateTime? nacimiento,
  String? jaula,
}) {
  return Rabbit(
    id: chapeta,
    breed: raza,
    gender: genero,
    birthDate: nacimiento ?? DateTime(2024, 3, 15),
    weightKg: peso,
    healthStatus: estado,
    farmId: 1,
    registrationDate: DateTime(2024, 4, 1),
    chapeta: chapeta,
    cageNumber: jaula,
  );
}

void main() {
  test('el CSV tiene cabecera, BOM y una fila por conejo', () {
    final csv = CsvExportService.construirCsv([
      _conejo(),
      _conejo(
        chapeta: 'RE-002',
        raza: 'Rex, Gigante',
        genero: 'Macho',
        estado: 'Enfermo',
        peso: 3.15,
        jaula: 'J-12',
      ),
    ]);

    // BOM para Excel
    expect(csv.startsWith('\ufeff'), isTrue);

    // Excel en espanol: separador de columnas punto y coma.
    final lineas = csv.replaceAll('\ufeff', '').trim().split('\r\n');
    expect(lineas.length, 3, reason: 'cabecera + 2 conejos');
    expect(lineas.first, contains('Chapeta'));
    expect(lineas.first, contains('Raza'));
    expect(lineas.first, contains('Peso (kg)'));
    expect(lineas.first.split(';').length, 9, reason: '9 columnas separadas por ;');

    // Ninguna coma como separador de columnas.
    expect(lineas.first.contains(','), isFalse);

    expect(lineas[1], contains('NZ-001'));
    expect(lineas[1], contains('Netherland'));
    expect(lineas[1], contains('Hembra'));
    expect(lineas[1], contains('Saludable'));
    expect(lineas[1], contains('2.50'));
    expect(lineas[1], contains('15/03/2024'));

    // Con ';' como separador, la coma del valor NO necesita comillas.
    expect(lineas[2], contains('Rex, Gigante'));
    expect(lineas[2], isNot(contains('"Rex, Gigante"')));
    expect(lineas[2], contains('RE-002'));
    expect(lineas[2], contains('Enfermo'));
    expect(lineas[2], contains('J-12'));
  });

  test('un valor con punto y coma si va entre comillas', () {
    final csv = CsvExportService.construirCsv([
      _conejo(raza: 'Rex; Gigante'),
    ]);
    final linea = csv.replaceAll('\ufeff', '').trim().split('\r\n')[1];
    expect(linea, contains('"Rex; Gigante"'));
    expect(linea.split(';').length, greaterThan(9),
        reason: 'el separador dentro del valor no cuenta como columna');
  });

  test('un conejo sin peso exporta el campo vacio', () {
    final csv = CsvExportService.construirCsv([_conejo(peso: 0)]);
    final linea = csv.replaceAll('\ufeff', '').trim().split('\r\n')[1];
    expect(linea, contains(';;'), reason: 'peso vacio entre punto y comas');
  });
}
