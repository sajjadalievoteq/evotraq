import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_request_model.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation/utils/decommissioning_disposition.dart';

/// Client-side checks mirroring backend [DecommissioningRequestDTO] constraints.
abstract final class DecommissioningRequestDebug {
  DecommissioningRequestDebug._();

  static List<String> validateRequest(DecommissioningRequest request) {
    final notes = <String>[];

    if (request.epcs.isEmpty) {
      notes.add('FAIL: epcs is empty (backend requires at least one EPC)');
    } else {
      notes.add('OK: ${request.epcs.length} EPC(s) in payload');
      for (var i = 0; i < request.epcs.length; i++) {
        final epc = request.epcs[i];
        if (epc.trim().isEmpty) {
          notes.add('FAIL: epcs[$i] is blank');
        } else if (!epc.startsWith('urn:epc:')) {
          notes.add(
            'WARN: epcs[$i] is not a URN ($epc) — backend may reject or fail processing',
          );
        } else if (!epc.startsWith('urn:epc:id:sgtin:') &&
            !epc.startsWith('urn:epc:id:sscc:')) {
          notes.add(
            'WARN: epcs[$i] type may not be decommissionable ($epc)',
          );
        }
      }
    }

    final gln = request.locationGLN.trim();
    if (gln.isEmpty) {
      notes.add('FAIL: locationGLN is empty');
    } else if (!RegExp(r'^\d{13}$').hasMatch(gln)) {
      notes.add(
        'FAIL: locationGLN must be exactly 13 digits (got "${request.locationGLN}" length ${gln.length})',
      );
    } else {
      notes.add('OK: locationGLN is 13 digits');
    }

    final disposition = request.disposition.trim().toLowerCase();
    if (disposition.isEmpty) {
      notes.add('FAIL: disposition is empty');
    } else if (DecommissioningDisposition.fromCode(disposition) == null) {
      notes.add(
        'FAIL: disposition "$disposition" is not in allowed CBV set',
      );
    } else {
      notes.add('OK: disposition "$disposition"');
    }

    if (request.eventTime == null) {
      notes.add('INFO: eventTime omitted — server will default to now');
    } else {
      notes.add('OK: eventTime ${request.eventTime!.toIso8601String()}');
    }

    if (request.eventTimeZoneOffset != null &&
        request.eventTimeZoneOffset!.isNotEmpty) {
      notes.add('OK: eventTimeZoneOffset ${request.eventTimeZoneOffset}');
    }

    return notes;
  }
}
