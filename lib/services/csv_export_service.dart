import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';

import '../models/rabbit.dart';

/// Exportacion de datos a CSV.
///
/// El archivo se guarda con el nombre de la app en el equipo: en Web lo
/// descarga el navegador, en Android/iOS queda en el directorio de la
/// aplicacion y en escritorio en la carpeta de Descargas.
class CsvExportService {
  const CsvExportService._();

  /// Columnas del CSV de conejos.
  static const List<String> _columnas = [
    'Chapeta',
    'Raza',
    'Genero',
    'Estado',
    'Peso (kg)',
    'Fecha de nacimiento',
    'Edad (meses)',
    'Jaula',
    'Estado reproductivo',
  ];

  /// Genera el CSV de la lista de conejos y lo guarda en el equipo.
  ///
  /// Devuelve el numero de conejos exportados, o `null` si no habia nada
  /// que exportar.
  static Future<int?> exportarConejos(List<Rabbit> rabbits) async {
    if (rabbits.isEmpty) return null;

    final bytes = Uint8List.fromList(utf8.encode(construirCsv(rabbits)));

    final marca = DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now());
    await FileSaver.instance.saveFile(
      name: 'conejos_cunitech_$marca',
      bytes: bytes,
      fileExtension: 'csv',
      // Excel en espanol espera punto y coma y necesita el charset en el
      // tipo MIME para abrir los acentos correctamente.
      mimeType: MimeType.custom,
      customMimeType: 'text/csv;charset=utf-8',
    );

    return rabbits.length;
  }

  /// Construye el contenido CSV.
  ///
  /// - `;` como separador de columnas: en Excel en espanol la coma es el
  ///   separador decimal, asi que con comas todas las columnas se amontonan
  ///   en una sola.
  /// - `\r\n` como salto de linea (el que espera Excel).
  /// - BOM UTF-8 al principio para que reconozca los acentos y la enye.
  static String construirCsv(List<Rabbit> rabbits) {
    final filas = <List<dynamic>>[
      _columnas,
      for (final conejo in rabbits) _filaConejo(conejo),
    ];
    return const CsvEncoder(
      addBom: true,
      fieldDelimiter: ';',
      lineDelimiter: '\r\n',
    ).convert(filas);
  }

  static List<dynamic> _filaConejo(Rabbit conejo) {
    final fechaNacimiento = DateFormat('dd/MM/yyyy').format(conejo.birthDate);
    return [
      conejo.displayId,
      conejo.breed,
      conejo.gender,
      conejo.healthStatus,
      conejo.weightKg > 0 ? conejo.weightKg.toStringAsFixed(2) : '',
      fechaNacimiento,
      conejo.ageMonths,
      conejo.cageNumber ?? '',
      conejo.reproductiveStatus,
    ];
  }
}
