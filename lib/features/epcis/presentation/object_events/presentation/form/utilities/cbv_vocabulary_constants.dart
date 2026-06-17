/// CBV 2.0 vocabulary constants for the Object Event form.
///
/// Sources:
///   • GS1 CBV 2.0 standard (ISO/IEC 19988:2024)
///   • Internal pharma spec — TABLE 4 (bizStep → action mapping)
///   • Internal pharma spec — TABLE 11 (canonical bizStep × disposition pairings)
///
/// Action semantics for Object Events:
///   ADD    — object enters the supply chain (first life of the EPC)
///   OBSERVE — object is observed / state is tracked (no change of existence)
///   DELETE  — object leaves the supply chain permanently
///
/// NOTE: The following CBV biz steps are intentionally EXCLUDED from this
/// Object Event form because they are used in other EPCIS event types:
///   • encoding        → TransactionEvent context (TABLE 4)
///   • packing         → AggregationEvent ADD     (TABLE 4)
///   • unpacking       → AggregationEvent DELETE   (TABLE 4)
///   • assembling      → TransformationEvent       (TABLE 4)
///   • disassembling   → TransformationEvent       (TABLE 4)
///   • repackaging     → TransformationEvent       (TABLE 4)
abstract final class CbvVocabularyConstants {
  // ─── Action → allowed biz step codes ────────────────────────────────────────
  // Per TABLE 4 of the pharma CBV spec. Only codes listed here appear in the
  // dropdown for that action. Items used in other event types are excluded.

  static const Map<String, List<String>> actionBizStepCodes = {
    // ADD: object comes into existence / enters active tracking
    'ADD': [
      'commissioning',           // serialised pack leaves packaging line
      'creating_class_instance', // new batch/lot declared
      'installing',              // datalogger/sensor attached (ADD per TABLE 4)
      // encoding is EXCLUDED — TransactionEvent context only (TABLE 4)
    ],

    // OBSERVE: object is tracked; no supply-chain entry or exit
    'OBSERVE': [
      // Logistics
      'shipping',
      'receiving',
      'loading',
      'unloading',
      // packing / unpacking EXCLUDED — Aggregation events (TABLE 4)
      'accepting',               // custody/possession change (OBSERVE per TABLE 4)
      'consigning',
      'arriving',
      'departing',
      'staging_outbound',
      'transporting',
      'storing',
      'stocking',
      'picking',
      'entering_exiting',
      'removing',               // extract from location (OBSERVE per TABLE 4)
      'returning',              // sent back (OBSERVE per TABLE 4)
      'collecting',             // reverse-logistics collection (OBSERVE per TABLE 4)
      'reserving',              // set aside for future use (OBSERVE per TABLE 4)
      // Quality & Inspection
      'inspecting',
      'holding',
      'repairing',
      'replacing',
      'cycle_counting',
      'stock_taking',
      'sampling',
      'sensor_reporting',
      // Miscellaneous
      // assembling / disassembling / repackaging EXCLUDED — Transformation events (TABLE 4)
      'killing',                // terminate RFID tag (OBSERVE per TABLE 4)
      'other',
    ],

    // DELETE: object leaves the supply chain permanently
    'DELETE': [
      'decommissioning',        // retire from active use
      'destroying',             // physically destroyed
      'dispensing',             // dispensed to patient (terminal)
      'retail_selling',         // OTC sale at checkout (terminal)
      'void_shipping',          // cancel a previously-declared shipment (TABLE 4)
    ],
  };

  // ─── Default biz step pre-selected when action changes ──────────────────────
  static const Map<String, String> actionDefaultBizStepCode = {
    'ADD': 'commissioning',
    'OBSERVE': 'shipping',
    'DELETE': 'decommissioning',
  };

  // ─── Biz step → canonical disposition codes ──────────────────────────────────
  // Per TABLE 11 and TABLE 4 of the pharma CBV spec.
  // Ordered: most common pharma disposition first.
  // If a biz step has no entry here, the picker falls back to all enabled dispositions.

  static const Map<String, List<String>> bizStepDispositionCodes = {
    // ── ADD ───────────────────────────────────────────────────────────────────
    // encoding EXCLUDED (TransactionEvent only)
    'commissioning':           ['active'],
    'creating_class_instance': ['active'],
    'installing':              ['active'],

    // ── OBSERVE — Logistics ──────────────────────────────────────────────────
    'shipping':                ['in_transit'],
    'receiving':               ['in_progress', 'completeness_verified', 'completeness_inferred', 'active'],
    'loading':                 ['in_progress'],
    'unloading':               ['in_progress'],
    // packing / unpacking EXCLUDED (AggregationEvent only)
    'accepting':               ['active', 'in_progress'],
    'consigning':              ['in_transit'],
    'arriving':                ['in_progress'],
    'departing':               ['in_transit'],
    'staging_outbound':        ['in_progress'],
    'transporting':            ['in_transit'],
    'storing':                 ['active', 'in_progress', 'sellable_not_accessible'],
    'stocking':                ['active', 'sellable_accessible', 'sellable_not_accessible'],
    'picking':                 ['in_progress'],
    'entering_exiting':        ['retail_sold', 'returned', 'active'],
    'removing':                ['in_progress'],
    'returning':               ['returned', 'non_sellable_other', 'recalled'],
    'collecting':              ['returned', 'non_sellable_other'],
    'reserving':               ['reserved', 'sellable_not_accessible'],

    // ── OBSERVE — Quality & Inspection ───────────────────────────────────────
    'inspecting':              ['conformant', 'non_conformant', 'in_progress', 'active'],
    'holding':                 ['sellable_not_accessible', 'unavailable'],
    'repairing':               ['conformant', 'active'],
    'replacing':               ['active'],
    'cycle_counting':          ['active', 'in_progress'],
    'stock_taking':            ['active', 'in_progress'],
    'sampling':                ['active', 'unavailable'],
    'sensor_reporting':        ['in_transit', 'in_progress'],

    // ── OBSERVE — Miscellaneous ───────────────────────────────────────────────
    // assembling / disassembling / repackaging EXCLUDED (TransformationEvent only)
    'killing':                 ['inactive'],
    'other':                   ['active', 'in_progress'],

    // ── DELETE ────────────────────────────────────────────────────────────────
    'decommissioning':         ['inactive', 'destroyed'],
    'destroying':              ['destroyed'],
    'dispensing':              ['dispensed', 'partially_dispensed'],
    'retail_selling':          ['retail_sold'],
    'void_shipping':           ['in_progress'],
  };

  // ─── Group labels for biz steps (mirrors DB group_name) ─────────────────────
  // Used as fallback when item.group is null.
  // Group names differ from item labels to avoid duplicate text in the dropdown.
  static const Map<String, String> bizStepGroup = {
    // ADD group
    'commissioning':           'Creation & Commissioning',
    'creating_class_instance': 'Creation & Commissioning',
    'installing':              'Creation & Commissioning',
    // DELETE group
    'decommissioning':         'Decommissioning & Disposal',
    'destroying':              'Decommissioning & Disposal',
    'dispensing':              'Sales & Dispensing',
    'retail_selling':          'Sales & Dispensing',
    // Logistics (OBSERVE + void_shipping DELETE)
    'shipping':                'Logistics',
    'receiving':               'Logistics',
    'loading':                 'Logistics',
    'unloading':               'Logistics',
    'accepting':               'Logistics',
    'consigning':              'Logistics',
    'arriving':                'Logistics',
    'departing':               'Logistics',
    'staging_outbound':        'Logistics',
    'transporting':            'Logistics',
    'storing':                 'Logistics',
    'stocking':                'Logistics',
    'picking':                 'Logistics',
    'entering_exiting':        'Logistics',
    'removing':                'Logistics',
    'returning':               'Logistics',
    'collecting':              'Logistics',
    'reserving':               'Logistics',
    'void_shipping':           'Logistics',
    // Quality & Inspection
    'inspecting':              'Quality & Inspection',
    'holding':                 'Quality & Inspection',
    'repairing':               'Quality & Inspection',
    'replacing':               'Quality & Inspection',
    'cycle_counting':          'Quality & Inspection',
    'stock_taking':            'Quality & Inspection',
    'sampling':                'Quality & Inspection',
    'sensor_reporting':        'Quality & Inspection',
    // Miscellaneous
    'killing':                 'Miscellaneous',
    'other':                   'Miscellaneous',
  };

  // ─── Group labels for dispositions (mirrors DB group_name) ──────────────────
  // Full CBV 2.0 disposition list (32 values) per TABLE 5 of the pharma spec.
  static const Map<String, String> dispositionGroup = {
    // Currently Active — object is in good standing, accessible
    'active':                  'Currently Active',
    'sellable_accessible':     'Currently Active',
    'sellable_not_accessible': 'Currently Active',
    'available':               'Currently Active',
    'conformant':              'Currently Active',       // inspection passed; object returns to active flow
    'completeness_verified':   'Currently Active',       // shipment physically verified at receipt
    'completeness_inferred':   'Currently Active',       // shipment verified via upstream aggregation events

    // Pending / In Progress — transient states; object is moving through a process
    'in_progress':             'Pending / In Progress',
    'in_transit':              'Pending / In Progress',
    'encoded':                 'Pending / In Progress',
    'reserved':                'Pending / In Progress',
    'container_open':          'Pending / In Progress',

    // Sold & Dispensed — handed to end consumer or returned from them
    'dispensed':               'Sold & Dispensed',
    'retail_sold':             'Sold & Dispensed',
    'returned':                'Sold & Dispensed',
    'partially_dispensed':     'Sold & Dispensed',

    // Terminal / Problem States — object is unusable, under restriction, or lost
    'inactive':                'Terminal States',
    'destroyed':               'Terminal States',
    'expired':                 'Terminal States',
    'recalled':                'Terminal States',
    'stolen':                  'Terminal States',
    'damaged':                 'Terminal States',
    'non_sellable_other':      'Terminal States',
    'disposed':                'Terminal States',
    'non_conformant':          'Terminal States',       // inspection failed; object blocked
    'needs_replacement':       'Terminal States',
    'container_closed':        'Terminal States',
    'unknown':                 'Terminal States',
    'unavailable':             'Terminal States',
    'mismatch_class':          'Terminal States',
    'mismatch_instance':       'Terminal States',
    'mismatch_quantity':       'Terminal States',
  };
}
