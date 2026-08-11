import 'dart:convert';
import 'package:traqtrace_app/features/gs1_tools/utils/epcis_import_content_validator.dart';

import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_date_utils.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/features/gs1_tools/utils/epcis_import_template.dart';

import 'package:traqtrace_app/features/gs1_tools/utils/epcis_import_validation_result.dart';
export 'package:traqtrace_app/features/gs1_tools/utils/epcis_import_validation_result.dart';

/// Three-gate validator: format → schema/structure → content.
/// Rejects on the first failing gate (later gates are not run).
abstract final class EpcisImportValidator {
  static EpcisImportValidationResult validate(
    String rawInput, {
    Set<String>? validBizSteps,
    Set<String>? validDispositions,
  }) {
    final allowedBizSteps = validBizSteps ?? const <String>{};
    final allowedDispositions = validDispositions ?? const <String>{};
    final text = rawInput.trim();
    if (text.isEmpty) {
      return const EpcisImportValidationResult(
        issues: [
          EpcisImportIssue(
            gate: EpcisImportGate.format,
            path: r'$',
            reason:
                'Input does not match the EPCIS import template — download the template.',
          ),
        ],
      );
    }

    // ── Format gate ────────────────────────────────────────────────────────
    if (text.startsWith('<') ||
        !text.startsWith('{') && !text.startsWith('[')) {
      return const EpcisImportValidationResult(
        issues: [
          EpcisImportIssue(
            gate: EpcisImportGate.format,
            path: r'$',
            reason:
                'Input does not match the EPCIS import template — download the template.',
          ),
        ],
      );
    }

    late final Object decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      return const EpcisImportValidationResult(
        issues: [
          EpcisImportIssue(
            gate: EpcisImportGate.format,
            path: r'$',
            reason:
                'Input does not match the EPCIS import template — download the template.',
          ),
        ],
      );
    }

    if (decoded is! Map<String, dynamic>) {
      return const EpcisImportValidationResult(
        issues: [
          EpcisImportIssue(
            gate: EpcisImportGate.format,
            path: r'$',
            reason:
                'Input does not match the EPCIS import template — download the template.',
          ),
        ],
      );
    }

    final doc = Map<String, dynamic>.from(decoded);
    final formatIssues = <EpcisImportIssue>[];

    final context = doc['@context'];
    final contextOk =
        context == EpcisImportTemplate.contextUri ||
        (context is List &&
            context.any((c) => c == EpcisImportTemplate.contextUri));
    if (!contextOk) {
      formatIssues.add(
        const EpcisImportIssue(
          gate: EpcisImportGate.format,
          path: r'$["@context"]',
          reason:
              'Input does not match the EPCIS import template — download the template.',
        ),
      );
    }
    if (doc['type'] != 'EPCISDocument') {
      formatIssues.add(
        const EpcisImportIssue(
          gate: EpcisImportGate.format,
          path: r'$.type',
          reason:
              'Input does not match the EPCIS import template — download the template.',
        ),
      );
    }
    if (doc['epcisBody'] is! Map) {
      formatIssues.add(
        const EpcisImportIssue(
          gate: EpcisImportGate.format,
          path: r'$.epcisBody',
          reason:
              'Input does not match the EPCIS import template — download the template.',
        ),
      );
    }
    if (formatIssues.isNotEmpty) {
      return EpcisImportValidationResult(issues: formatIssues);
    }

    // ── Schema gate ────────────────────────────────────────────────────────
    final schemaIssues = <EpcisImportIssue>[];
    checkUnknownKeys(
      doc.keys.cast<String>(),
      EpcisImportTemplate.documentKeys,
      r'$',
      schemaIssues,
    );

    final schemaVersion = doc['schemaVersion'];
    if (schemaVersion != '2.0') {
      schemaIssues.add(
        EpcisImportIssue(
          gate: EpcisImportGate.schema,
          path: r'$.schemaVersion',
          reason:
              'schemaVersion must be "2.0" (found: ${schemaVersion ?? 'null'})',
        ),
      );
    }
    if (doc['creationDate'] is! String ||
        (doc['creationDate'] as String).trim().isEmpty) {
      schemaIssues.add(
        const EpcisImportIssue(
          gate: EpcisImportGate.schema,
          path: r'$.creationDate',
          reason: 'creationDate is required',
        ),
      );
    }
    if (doc['id'] is! String || (doc['id'] as String).trim().isEmpty) {
      schemaIssues.add(
        const EpcisImportIssue(
          gate: EpcisImportGate.schema,
          path: r'$.id',
          reason: 'id is required',
        ),
      );
    }

    final body = Map<String, dynamic>.from(doc['epcisBody'] as Map);
    checkUnknownKeys(
      body.keys.cast<String>(),
      EpcisImportTemplate.epcisBodyKeys,
      r'$.epcisBody',
      schemaIssues,
    );

    final eventList = body['eventList'];
    if (eventList is! List || eventList.isEmpty) {
      schemaIssues.add(
        const EpcisImportIssue(
          gate: EpcisImportGate.schema,
          path: r'$.epcisBody.eventList',
          reason: 'eventList must be a non-empty array',
        ),
      );
    } else {
      for (var i = 0; i < eventList.length; i++) {
        final path = '\$.epcisBody.eventList[$i]';
        final item = eventList[i];
        if (item is! Map) {
          schemaIssues.add(
            EpcisImportIssue(
              gate: EpcisImportGate.schema,
              path: path,
              reason: 'event must be an object',
            ),
          );
          continue;
        }
        final event = Map<String, dynamic>.from(item);
        _validateEventSchema(event, path, schemaIssues);
      }
    }

    if (schemaIssues.isNotEmpty) {
      return EpcisImportValidationResult(issues: schemaIssues);
    }

    // ── Content gate ───────────────────────────────────────────────────────
    final contentIssues = <EpcisImportIssue>[];
    final serialized = jsonEncode(doc);
    for (final placeholder in EpcisImportTemplate.placeholders) {
      if (serialized.contains(placeholder)) {
        contentIssues.add(
          EpcisImportIssue(
            gate: EpcisImportGate.content,
            path: r'$',
            reason:
                'Replace placeholder $placeholder with a real value before import',
          ),
        );
      }
    }
    if (contentIssues.isNotEmpty) {
      return EpcisImportValidationResult(issues: contentIssues);
    }

    validateIsoInstant(
      doc['creationDate'] as String,
      r'$.creationDate',
      contentIssues,
    );

    final events = (body['eventList'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    for (var i = 0; i < events.length; i++) {
      EpcisImportContentValidator.validateEventContent(
        events[i],
        '\$.epcisBody.eventList[$i]',
        contentIssues,
        allowedBizSteps: allowedBizSteps,
        allowedDispositions: allowedDispositions,
      );
    }

    if (contentIssues.isNotEmpty) {
      return EpcisImportValidationResult(issues: contentIssues);
    }

    return EpcisImportValidationResult(issues: const [], document: doc);
  }

  static void _validateEventSchema(
    Map<String, dynamic> event,
    String path,
    List<EpcisImportIssue> issues,
  ) {
    final type = event['type'];
    if (type is! String ||
        !EpcisImportTemplate.allowedEventTypes.contains(type)) {
      issues.add(
        EpcisImportIssue(
          gate: EpcisImportGate.schema,
          path: '$path.type',
          reason:
              'type must be one of ${EpcisImportTemplate.allowedEventTypes.join(", ")}',
        ),
      );
      return;
    }

    final allowed = type == 'ObjectEvent'
        ? EpcisImportTemplate.objectEventKeys
        : EpcisImportTemplate.aggregationEventKeys;
    checkUnknownKeys(event.keys.cast<String>(), allowed, path, issues);

    void require(String key) {
      final value = event[key];
      if (value == null || (value is String && value.trim().isEmpty)) {
        issues.add(
          EpcisImportIssue(
            gate: EpcisImportGate.schema,
            path: '$path.$key',
            reason: '$key is required',
          ),
        );
      }
    }

    require('eventTime');
    require('eventTimeZoneOffset');
    require('action');

    final action = event['action'];
    if (action is String &&
        !const {'ADD', 'OBSERVE', 'DELETE'}.contains(action)) {
      issues.add(
        EpcisImportIssue(
          gate: EpcisImportGate.schema,
          path: '$path.action',
          reason: 'action must be ADD, OBSERVE, or DELETE',
        ),
      );
    }

    if (type == 'ObjectEvent') {
      final epcList = event['epcList'];
      final qty = event['quantityList'];
      final hasEpc = epcList is List && epcList.isNotEmpty;
      final hasQty = qty is List && qty.isNotEmpty;
      if (!hasEpc && !hasQty) {
        issues.add(
          EpcisImportIssue(
            gate: EpcisImportGate.schema,
            path: '$path.epcList',
            reason: 'ObjectEvent requires epcList or quantityList',
          ),
        );
      }
    } else {
      require('parentID');
      final children = event['childEPCs'];
      final childQty = event['childQuantityList'];
      final hasChildren = children is List && children.isNotEmpty;
      final hasChildQty = childQty is List && childQty.isNotEmpty;
      if (!hasChildren && !hasChildQty) {
        issues.add(
          EpcisImportIssue(
            gate: EpcisImportGate.schema,
            path: '$path.childEPCs',
            reason: 'AggregationEvent requires childEPCs or childQuantityList',
          ),
        );
      }
    }
  }

  static void validateIsoInstant(
    String? value,
    String path,
    List<EpcisImportIssue> issues,
  ) {
    if (value == null || value.trim().isEmpty) {
      issues.add(
        EpcisImportIssue(
          gate: EpcisImportGate.content,
          path: path,
          reason: 'ISO-8601 date-time is required',
        ),
      );
      return;
    }
    try {
      DateTime.parse(value);
    } on FormatException {
      issues.add(
        EpcisImportIssue(
          gate: EpcisImportGate.content,
          path: path,
          reason: 'Invalid ISO-8601 date-time: $value',
        ),
      );
    }
  }

  static void checkUnknownKeys(
    Iterable<String> keys,
    Set<String> allowed,
    String path,
    List<EpcisImportIssue> issues,
  ) {
    for (final key in keys) {
      if (!allowed.contains(key)) {
        issues.add(
          EpcisImportIssue(
            gate: EpcisImportGate.schema,
            path: '$path.$key',
            reason:
                'Unknown field "$key" is not allowed — use only the import template fields',
          ),
        );
      }
    }
  }
}
