class ObjectEventFormValidationResponseParser {
  ObjectEventFormValidationResponseParser._();

  static List<String> extractErrorMessages(Map<String, dynamic>? response) {
    if (response == null) return [];

    final raw = <String>[];

    if (response.containsKey('errors')) {
      final errors = response['errors'] as Map<String, dynamic>?;
      if (errors != null) {
        for (final category in ['schema', 'businessRule', 'referenceData', 'other']) {
          final list = errors[category] as List<dynamic>? ?? [];
          for (final error in list) {
            raw.add(error.toString());
          }
        }
      }
    } else if (response.containsKey('validationErrors')) {
      final list = response['validationErrors'] as List<dynamic>? ?? [];
      for (final e in list) raw.add(e.toString());
    } else if (response.containsKey('error')) {
      raw.add(response['error'].toString());
    } else if (response.containsKey('message')) {
      raw.add(response['message'].toString());
    }

    if (raw.isEmpty) {
      response.forEach((key, value) {
        if (key.toLowerCase().contains('error') || key.toLowerCase().contains('message')) {
          raw.add(value.toString());
        }
      });
    }

    return raw.map(_humanise).toList();
  }

  // ---------------------------------------------------------------------------
  // Translation table — raw pattern → friendly message
  // ---------------------------------------------------------------------------
  static String _humanise(String raw) {
    // EPC list item format
    final epcListMatch = RegExp(r'\$\.epcList\[(\d+)\].*does not match the regex').firstMatch(raw);
    if (epcListMatch != null) {
      final n = int.parse(epcListMatch.group(1)!) + 1;
      return 'EPC #$n is not a valid GS1 instance-level identifier.\n'
          'Copy the EPC URI from the SGTIN list (e.g. urn:epc:id:sgtin:062920.0001000.ABC123), '
          'or enter a GS1 barcode like (01)00629200010003(21)ABC123.';
    }

    // idpat / class-level EPC in epcList
    if (raw.contains('idpat') || raw.contains('epc:idpat')) {
      return 'The EPC entered is a product class identifier (no serial number). '
          'Object events require a serialised item — go to the SGTIN list, '
          'open a specific item, and copy its EPC URI.';
    }

    // XE-018 duplicate commission
    if (raw.contains('XE-018') || raw.contains('already has a prior ObjectEvent')) {
      final epc = _extractEpc(raw);
      return 'This item${epc != null ? ' ($epc)' : ''} has already been commissioned. '
          'Use OBSERVE to record further events on it, or DELETE first to decommission.';
    }

    // XE-024 delete without prior add
    if (raw.contains('XE-024') || raw.contains('no prior commissioning event')) {
      final epc = _extractEpc(raw);
      return 'Cannot delete${epc != null ? ' $epc' : ' this item'} — '
          'it has never been commissioned. Commission it with ADD first.';
    }

    // XE-016 inactive / unknown GLN
    if (raw.contains('XE-016') || raw.contains('Read point GLN not found') ||
        raw.contains('GLN not found or inactive')) {
      return 'The Read Point or Business Location GLN does not exist in the system or is inactive. '
          'Check the GLN master data screen and ensure the location is active.';
    }

    // DSCSA-T3 shipping without destination
    if (raw.contains('DSCSA-T3') || raw.contains('shipping event requires destinationList')) {
      return 'DSCSA §582 requires a destination party for all shipping events. '
          'Add at least one entry under Destination List before saving.';
    }

    // ILMD missing entirely
    if (raw.contains('ILMD is required for commissioning')) {
      return 'Pharmaceutical commissioning events require item-level data (ILMD). '
          'Fill in the Expiration Date and Manufacturer of Goods fields.';
    }

    // ILMD missing expiry
    if (raw.contains('itemExpirationDate') && (raw.contains('required') || raw.contains('missing'))) {
      return 'Item Expiration Date (cbvmda:itemExpirationDate) is required for '
          'commissioning a pharmaceutical item. Enter the date in YYYY-MM-DD format.';
    }

    // ILMD missing manufacturer
    if (raw.contains('manufacturerOfGoods') && (raw.contains('required') || raw.contains('missing'))) {
      return 'Manufacturer of Goods (cbvmda:manufacturerOfGoods) is required for '
          'commissioning a pharmaceutical item.';
    }

    // Certification info incomplete
    if (raw.contains('certificationAgency') || raw.contains('certification_agency')) {
      return 'Certification Agency is required when adding certification information. '
          'Enter the certifying body (e.g. regulator or inspection agency name).';
    }
    if (raw.contains('certificationStandard') || raw.contains('certification_standard')) {
      return 'Certification Standard or Certification Type is required when adding certification information.';
    }
    if (raw.contains('certificationInfo[')) {
      return raw.replaceFirst(RegExp(r'^certificationInfo\[\d+\]:\s*'), 'Certification: ');
    }

    // Database integrity — missing required field
    if (raw.contains('Required field missing') || raw.contains('DATA_INTEGRITY_VIOLATION')) {
      return raw.replaceFirst('Required field missing: ', 'Missing required field: ');
    }
    if (raw.contains('A required field is missing')) {
      return 'A required field is missing. Check certification info (agency and standard), '
          'event time zone, business step, disposition, and location fields.';
    }

    // CBV pairing violation
    if (raw.contains('CBV') && (raw.contains('pair') || raw.contains('disposition') || raw.contains('bizStep'))) {
      return 'The selected Business Step and Disposition are not a valid GS1 CBV combination. '
          'Change the Disposition to match the Business Step, or use the auto-fill.';
    }

    // Invalid EPC URI format (generic)
    if (raw.contains('Invalid EPC URI format')) {
      final epc = _extractEpc(raw);
      return 'The EPC "${epc ?? 'entered'}" is not a valid GS1 EPC URI. '
          'Expected format: urn:epc:id:sgtin:<prefix>.<itemRef>.<serial>.';
    }

    // Duplicate EPC in list
    if (raw.contains('Duplicate EPC')) {
      final epc = _extractEpc(raw);
      return 'The same EPC${epc != null ? ' ($epc)' : ''} appears more than once in the list. Remove the duplicate.';
    }

    // EPC/quantity list empty
    if (raw.contains('Either EPC list or quantity list must be provided')) {
      return 'You must add at least one item to the EPC List (or Quantity List) before saving.';
    }

    // Invalid bizStep format
    if (raw.contains('Business Step') && raw.contains('GS1 CBV format')) {
      return 'Business Step must follow GS1 CBV format: urn:epcglobal:cbv:bizstep:<step>.';
    }

    // Invalid timezone
    if (raw.contains('eventTimeZoneOffset') || raw.contains('timezone') || raw.contains('TimeZone')) {
      return 'Time zone offset is invalid. Use ±HH:MM format (e.g. +04:00).';
    }

    // SGTIN serial not found in master data
    if (raw.contains('SGTIN serial number not found')) {
      return 'The serial number in this EPC does not exist in the SGTIN master data. '
          'Generate or register the SGTIN first, then create the event.';
    }

    // HTTP 409 conflict
    if (raw.contains('409') || raw.contains('Conflict')) {
      return 'The event conflicts with existing data (HTTP 409). '
          'This usually means a duplicate event ID or a business rule violation.';
    }

    // Generic schema validation fallback — strip the raw JSON path noise
    if (raw.contains('Schema validation error') || raw.contains('does not match the regex')) {
      final cleaned = raw
          .replaceAll(RegExp(r'Schema validation error:\s*'), '')
          .replaceAll(RegExp(r'\$\.[a-zA-Z\[\]0-9.]+:\s*'), '')
          .replaceAll(RegExp(r'does not match the regex pattern.*'), 'has an invalid format.');
      return 'Format error: $cleaned';
    }

    // Business rule prefix — strip the code prefix for cleaner display
    if (raw.contains('Object Event validation failed:')) {
      return raw.replaceFirst('Object Event validation failed: ', '');
    }

    return raw;
  }

  static String? _extractEpc(String message) {
    final match = RegExp(r'(urn:epc:[^\s,]+)').firstMatch(message);
    return match?.group(1);
  }
}
