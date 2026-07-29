import 'dart:convert';

import 'package:flutter/services.dart';

class Gs1AiDefinition {
  const Gs1AiDefinition({
    required this.code,
    required this.title,
    required this.format,
    required this.fnc1,
  });

  final String code;
  final String title;
  final String format;
  final bool fnc1;

  /// Fixed AI+value total length when format is a plain `Nn` (no variable part).
  /// Matches legacy parser semantics (e.g. AI `01` + N14 → 16).
  int? get fixedAiPlusValueLength {
    if (fnc1) return null;
    final m = RegExp(r'^N(\d+)$').firstMatch(format.trim());
    if (m == null) return null;
    return code.length + int.parse(m.group(1)!);
  }

  factory Gs1AiDefinition.fromJson(Map<String, dynamic> json) {
    return Gs1AiDefinition(
      code: '${json['code']}',
      title: '${json['title']}',
      format: '${json['format'] ?? ''}',
      fnc1: json['fnc1'] == true,
    );
  }
}

/// Bundled GS1 Application Identifier reference — single source for the AI
/// cheat-sheet, [GS1BarcodeParser], and [Gs1ElementStringBuilder].
///
/// Prefer [ensureLoaded] (asset). Until then (and in unit tests),
/// [ensureSynced] uses the embedded seed that mirrors `ai-table.json`.
abstract final class Gs1AiTable {
  static List<Gs1AiDefinition>? _all;
  static Future<void>? _loading;

  /// Embedded mirror of `assets/gs1/ai-table.json` for sync / test use.
  /// Keep in sync with the asset — do not invent extra AIs here.
  static const List<Gs1AiDefinition> embeddedSeed = [
    Gs1AiDefinition(code: '00', title: 'SSCC', format: 'N18', fnc1: false),
    Gs1AiDefinition(code: '01', title: 'GTIN', format: 'N14', fnc1: false),
    Gs1AiDefinition(code: '02', title: 'CONTENT', format: 'N14', fnc1: false),
    Gs1AiDefinition(code: '10', title: 'BATCH/LOT', format: 'X..20', fnc1: true),
    Gs1AiDefinition(code: '11', title: 'PROD DATE', format: 'N6', fnc1: false),
    Gs1AiDefinition(code: '13', title: 'PACK DATE', format: 'N6', fnc1: false),
    Gs1AiDefinition(code: '15', title: 'BEST BEFORE', format: 'N6', fnc1: false),
    Gs1AiDefinition(code: '17', title: 'EXPIRY', format: 'N6', fnc1: false),
    Gs1AiDefinition(code: '21', title: 'SERIAL', format: 'X..20', fnc1: true),
    Gs1AiDefinition(code: '30', title: 'VAR COUNT', format: 'N..8', fnc1: true),
    Gs1AiDefinition(code: '37', title: 'COUNT', format: 'N..8', fnc1: true),
    Gs1AiDefinition(
      code: '310',
      title: 'NET WEIGHT (kg)',
      format: 'N6',
      fnc1: false,
    ),
    Gs1AiDefinition(
      code: '400',
      title: 'ORDER NUMBER',
      format: 'X..30',
      fnc1: true,
    ),
    Gs1AiDefinition(
      code: '401',
      title: 'CONSIGNMENT',
      format: 'X..30',
      fnc1: true,
    ),
    Gs1AiDefinition(
      code: '402',
      title: 'SHIPMENT ID',
      format: 'N17',
      fnc1: true,
    ),
    Gs1AiDefinition(code: '410', title: 'SHIP TO LOC', format: 'N13', fnc1: false),
    Gs1AiDefinition(
      code: '414',
      title: 'LOC No (GLN)',
      format: 'N13',
      fnc1: false,
    ),
    Gs1AiDefinition(code: '415', title: 'PAY TO', format: 'N13', fnc1: false),
    Gs1AiDefinition(
      code: '420',
      title: 'SHIP TO POST',
      format: 'X..20',
      fnc1: true,
    ),
    Gs1AiDefinition(
      code: '421',
      title: 'SHIP TO POST+CODE',
      format: 'N3+X..9',
      fnc1: true,
    ),
    Gs1AiDefinition(code: '422', title: 'ORIGIN', format: 'N3', fnc1: true),
    Gs1AiDefinition(
      code: '8003',
      title: 'GRAI',
      format: 'N14+X..16',
      fnc1: true,
    ),
    Gs1AiDefinition(code: '8004', title: 'GIAI', format: 'X..30', fnc1: true),
    Gs1AiDefinition(
      code: '253',
      title: 'GDTI',
      format: 'N13+X..17',
      fnc1: true,
    ),
    Gs1AiDefinition(code: '8018', title: 'GSRN', format: 'N18', fnc1: false),
    Gs1AiDefinition(code: '8010', title: 'CPID', format: 'X..30', fnc1: true),
  ];

  static Future<void> ensureLoaded() {
    return _loading ??= _load();
  }

  /// Ensures [all] is non-empty without awaiting assets (uses [embeddedSeed]).
  static void ensureSynced() {
    _all ??= List<Gs1AiDefinition>.from(embeddedSeed);
  }

  /// Test helper: replace table from a JSON list (or clear with empty).
  static void seedForTest(List<Gs1AiDefinition> defs) {
    _all = List<Gs1AiDefinition>.from(defs);
    _loading = null;
  }

  static Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString('assets/gs1/ai-table.json');
      final list = jsonDecode(raw);
      if (list is! List) {
        ensureSynced();
        return;
      }
      final parsed = <Gs1AiDefinition>[
        for (final e in list)
          if (e is Map<String, dynamic>)
            Gs1AiDefinition.fromJson(e)
          else if (e is Map)
            Gs1AiDefinition.fromJson(Map<String, dynamic>.from(e)),
      ];
      _all = parsed.isEmpty ? List<Gs1AiDefinition>.from(embeddedSeed) : parsed;
    } catch (_) {
      ensureSynced();
    }
  }

  static List<Gs1AiDefinition> get all {
    ensureSynced();
    return _all ?? const [];
  }

  static bool get isEmpty => all.isEmpty;

  static Gs1AiDefinition? definitionFor(String code) {
    final c = code.trim();
    for (final d in all) {
      if (d.code == c) return d;
    }
    return null;
  }

  static String titleFor(String code) =>
      definitionFor(code)?.title ?? '($code)';

  /// Total length of AI digits + value for fixed-length AIs; null if variable.
  static int? fixedAiPlusValueLength(String code) =>
      definitionFor(code)?.fixedAiPlusValueLength;

  static bool isFixedLength(String code) =>
      fixedAiPlusValueLength(code) != null;

  static Set<String> get fixedLengthAiCodes => {
        for (final d in all)
          if (d.fixedAiPlusValueLength != null) d.code,
      };

  static List<Gs1AiDefinition> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where(
          (a) =>
              a.code.contains(q) ||
              a.title.toLowerCase().contains(q) ||
              a.format.toLowerCase().contains(q),
        )
        .toList();
  }
}
