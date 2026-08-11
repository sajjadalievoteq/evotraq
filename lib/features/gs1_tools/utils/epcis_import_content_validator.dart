import 'dart:convert';
import 'package:traqtrace_app/features/gs1_tools/utils/epcis_import_validator.dart';

import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_date_utils.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/features/gs1_tools/utils/epcis_import_template.dart';

import 'package:traqtrace_app/features/gs1_tools/utils/epcis_import_validation_result.dart';
export 'package:traqtrace_app/features/gs1_tools/utils/epcis_import_validation_result.dart';

/// Three-gate validator: format → schema/structure → content.
/// Rejects on the first failing gate (later gates are not run).

class EpcisImportContentValidator {
  static void validateEventContent(
    Map<String, dynamic> event,
    String path,
    List<EpcisImportIssue> issues, {
    required Set<String> allowedBizSteps,
    required Set<String> allowedDispositions,
  }) {
    EpcisImportValidator.validateIsoInstant(
      event['eventTime'] as String?,
      '$path.eventTime',
      issues,
    );

    final tz = event['eventTimeZoneOffset'] as String?;
    if (tz == null || !RegExp(r'^([+-]\d{2}:\d{2}|Z)$').hasMatch(tz)) {
      issues.add(
        EpcisImportIssue(
          gate: EpcisImportGate.content,
          path: '$path.eventTimeZoneOffset',
          reason: 'eventTimeZoneOffset must be [+/-]HH:MM or Z',
        ),
      );
    }

    final bizStep = event['bizStep'];
    if (bizStep is String && bizStep.trim().isNotEmpty) {
      final short = CbvVocabularyFormatter.shortName(bizStep);
      if (allowedBizSteps.isNotEmpty && !allowedBizSteps.contains(short)) {
        issues.add(
          EpcisImportIssue(
            gate: EpcisImportGate.content,
            path: '$path.bizStep',
            reason: 'Unrecognized CBV bizStep: $bizStep',
          ),
        );
      }
    }

    final disposition = event['disposition'];
    if (disposition is String && disposition.trim().isNotEmpty) {
      final short = CbvVocabularyFormatter.shortName(disposition);
      if (allowedDispositions.isNotEmpty &&
          !allowedDispositions.contains(short)) {
        issues.add(
          EpcisImportIssue(
            gate: EpcisImportGate.content,
            path: '$path.disposition',
            reason: 'Unrecognized CBV disposition: $disposition',
          ),
        );
      }
    }

    void checkEpc(String? epc, String epcPath) {
      if (epc == null || epc.trim().isEmpty) {
        issues.add(
          EpcisImportIssue(
            gate: EpcisImportGate.content,
            path: epcPath,
            reason: 'EPC is required',
          ),
        );
        return;
      }
      final trimmed = epc.trim();
      if (!Gs1CanonicalIdentifier.isValid(trimmed) &&
          Gs1CanonicalIdentifier.classify(trimmed) ==
              Gs1CanonicalKind.unknown) {
        issues.add(
          EpcisImportIssue(
            gate: EpcisImportGate.content,
            path: epcPath,
            reason: 'Invalid GS1 identifier: $trimmed',
          ),
        );
        return;
      }
      final gtin = Gs1CanonicalIdentifier.extractGtin(trimmed);
      if (gtin != null) {
        final err = CheckDigitUtils.validateGtin(gtin);
        if (err != null) {
          issues.add(
            EpcisImportIssue(
              gate: EpcisImportGate.content,
              path: epcPath,
              reason: 'Invalid GTIN check digit: $err',
            ),
          );
        }
      }
      final sscc = Gs1CanonicalIdentifier.extractSscc18(trimmed);
      if (sscc != null) {
        final err = CheckDigitUtils.validateSscc(sscc);
        if (err != null) {
          issues.add(
            EpcisImportIssue(
              gate: EpcisImportGate.content,
              path: epcPath,
              reason: 'Invalid SSCC check digit: $err',
            ),
          );
        }
      }
    }

    final epcList = event['epcList'];
    if (epcList is List) {
      for (var i = 0; i < epcList.length; i++) {
        checkEpc(epcList[i]?.toString(), '$path.epcList[$i]');
      }
    }
    final parentId = event['parentID'];
    if (parentId is String) {
      checkEpc(parentId, '$path.parentID');
    }
    final childEpcs = event['childEPCs'];
    if (childEpcs is List) {
      for (var i = 0; i < childEpcs.length; i++) {
        checkEpc(childEpcs[i]?.toString(), '$path.childEPCs[$i]');
      }
    }

    final ilmd = event['ilmd'];
    if (ilmd is Map && ilmd['cbvmda:itemExpirationDate'] != null) {
      final exp = ilmd['cbvmda:itemExpirationDate'].toString();
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(exp)) {
        issues.add(
          EpcisImportIssue(
            gate: EpcisImportGate.content,
            path: '$path.ilmd["cbvmda:itemExpirationDate"]',
            reason: 'Must be YYYY-MM-DD',
          ),
        );
      } else {
        // Reuse Gs1DateUtils for calendar validity via YYMMDD conversion.
        final yymmdd =
            '${exp.substring(2, 4)}${exp.substring(5, 7)}${exp.substring(8, 10)}';
        final err = Gs1DateUtils.validateYymmdd(
          yymmdd,
          label: 'itemExpirationDate',
        );
        if (err != null) {
          issues.add(
            EpcisImportIssue(
              gate: EpcisImportGate.content,
              path: '$path.ilmd["cbvmda:itemExpirationDate"]',
              reason: err,
            ),
          );
        }
      }
    }
  }
}
