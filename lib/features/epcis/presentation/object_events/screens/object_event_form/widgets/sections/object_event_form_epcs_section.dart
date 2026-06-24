import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/barcode/widgets/gs1_barcode_scan_dialog.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_form_add_to_list_section.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';

class ObjectEventFormEpcsSection extends StatefulWidget {
  final List<String> epcList;
  final bool isViewOnly;
  final String? action;
  final String? businessStep;
  final bool quantityListEmpty;
  final ValueChanged<List<String>> onChanged;

  const ObjectEventFormEpcsSection({
    super.key,
    required this.epcList,
    required this.isViewOnly,
    this.action,
    this.businessStep,
    this.quantityListEmpty = false,
    required this.onChanged,
  });

  @override
  State<ObjectEventFormEpcsSection> createState() =>
      _ObjectEventFormEpcsSectionState();
}

class _ObjectEventFormEpcsSectionState extends State<ObjectEventFormEpcsSection> {
  final _controller = TextEditingController();
  String? _inputError;

  static final _gtinAiPattern = RegExp(r'\(0[01]\)');
  static final _bareGtinPattern = RegExp(r'^\d{13,14}$');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addEpc() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;

    if (_gtinAiPattern.hasMatch(value) && !value.contains('(21)')) {
      setState(() {
        _inputError =
            'This barcode contains only a product code — no serial number. '
            'Use the individual item\'s FMD 2D barcode (the one with (21)...).';
      });
      return;
    }

    if (_bareGtinPattern.hasMatch(value)) {
      setState(() {
        _inputError =
            'Product code only — please scan the item\'s individual barcode or '
            'enter the full GS1 string including (21)SERIAL.';
      });
      return;
    }

    final converted = EPCFormatter.formatToEPCUri(value);

    if (converted != null && converted.startsWith('urn:epc:idpat:')) {
      setState(() {
        _inputError =
            'This is a product class identifier, not a serialised item. '
            'Go to the SGTIN list, select an individual item, and copy its EPC URI.';
      });
      return;
    }

    if (converted == null || !converted.startsWith('urn:epc:id:')) {
      setState(() {
        _inputError =
            'Unrecognised format. Accepted inputs:\n'
            '• GS1 barcode: (01)GTIN(21)SERIAL\n'
            '• EPC URI: urn:epc:id:sgtin:...\n'
            '• Or use the scan button to scan a barcode.';
      });
      return;
    }

    if (widget.epcList.contains(converted)) {
      setState(() {
        _inputError = 'This EPC is already in the list.';
      });
      return;
    }

    setState(() => _inputError = null);
    widget.onChanged([...widget.epcList, converted]);
    _controller.clear();
  }

  Future<void> _scanBarcode() async {
    final result = await GS1BarcodeScanDialog.show(
      context,
      title: 'Scan Item Barcode',
      allowedFormats: const ['SGTIN'],
    );
    if (!mounted) return;

    if (result == null) return;

    if (!result.isValid) {
      setState(() {
        _inputError = result.error ?? 'Invalid barcode scan';
      });
      return;
    }

    _controller.text = result.data;
    _addEpc();
  }

  void _remove(int index) {
    final updated = List<String>.from(widget.epcList)..removeAt(index);
    widget.onChanged(updated);
  }

  void _clearAll() => widget.onChanged([]);

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormAddToListSection(
      title: 'EPCs (Serialized Items - at least one object identifier required)',
      requiredFieldNames: ['epcList', 'quantityList'],
      action: widget.action,
      businessStep: widget.businessStep,
      epcListEmpty: widget.epcList.isEmpty,
      quantityListEmpty: widget.quantityListEmpty,
      epcList: widget.epcList,
      listLabel: 'EPCs',
      itemCount: widget.epcList.length,
      isViewOnly: widget.isViewOnly,
      emptyMessage: widget.isViewOnly
          ? 'No EPCs recorded.'
          : 'No EPCs added yet. Enter a value above and press Add.',
      inputArea: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: 'EPC',
          hintText: 'urn:epc:id:sgtin:... or (01)GTIN(21)serial',
          helperText: 'Enter a serialised item EPC or scan a GS1 FMD 2D barcode',
          errorText: _inputError,
          errorMaxLines: 4,
          border: const OutlineInputBorder(),
          suffixIcon: widget.isViewOnly
              ? null
              : IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'Scan barcode',
                  onPressed: _scanBarcode,
                ),
        ),
        onChanged: (_) {
          if (_inputError != null) setState(() => _inputError = null);
        },
        onSubmitted: (_) => _addEpc(),
      ),
      onAdd: _addEpc,
      onClearAll: _clearAll,
      items: List.generate(widget.epcList.length, (index) {
        return ObjectEventFormListItemData(
          title: widget.epcList[index],
          onRemove: widget.isViewOnly ? null : () => _remove(index),
        );
      }),
    );
  }
}
