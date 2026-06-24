import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/utils/object_event_form_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/utils/object_event_form_mandatory_fields.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_form_read_only_field.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_form_required_indicator.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/widgets/object_event_form_section_card.dart';

class ObjectEventFormIlmdSection extends StatefulWidget {
  final Map<String, Object> ilmd;
  final bool isViewOnly;
  final String? action;
  final String? businessStep;
  final List<String> epcList;
  final ValueChanged<Map<String, Object>> onChanged;

  const ObjectEventFormIlmdSection({
    super.key,
    required this.ilmd,
    required this.isViewOnly,
    this.action,
    this.businessStep,
    this.epcList = const [],
    required this.onChanged,
  });

  @override
  State<ObjectEventFormIlmdSection> createState() =>
      _ObjectEventFormIlmdSectionState();
}

class _ObjectEventFormIlmdSectionState extends State<ObjectEventFormIlmdSection> {
  late final TextEditingController _manufacturerController;
  final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _manufacturerController = TextEditingController(
      text: widget.ilmd[ilmdManufacturerOfGoodsKey]?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(ObjectEventFormIlmdSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final manufacturer =
        widget.ilmd[ilmdManufacturerOfGoodsKey]?.toString() ?? '';
    if (_manufacturerController.text != manufacturer) {
      _manufacturerController.text = manufacturer;
    }
  }

  @override
  void dispose() {
    _manufacturerController.dispose();
    super.dispose();
  }

  DateTime? _parseExpirationDate() {
    final raw = widget.ilmd[ilmdItemExpirationDateKey]?.toString();
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      return _dateFormat.parseStrict(raw.trim());
    } catch (_) {
      return null;
    }
  }

  void _updateIlmd(String key, Object? value) {
    final updated = Map<String, Object>.from(widget.ilmd);
    if (value == null || (value is String && value.trim().isEmpty)) {
      updated.remove(key);
    } else {
      updated[key] = value;
    }
    widget.onChanged(updated);
  }

  Future<void> _selectExpirationDate() async {
    final current = _parseExpirationDate() ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    _updateIlmd(ilmdItemExpirationDateKey, _dateFormat.format(picked));
  }

  @override
  Widget build(BuildContext context) {
    final expirationRaw =
        widget.ilmd[ilmdItemExpirationDateKey]?.toString() ?? '';
    final expirationDate = _parseExpirationDate();

    final titleIsRequired = ObjectEventFormMandatoryFields.groupHasRequiredField(
      fieldNames: ObjectEventFormMandatoryFields.ilmdFields,
      action: widget.action,
      businessStep: widget.businessStep,
      epcListEmpty: widget.epcList.isEmpty,
      quantityListEmpty: false,
      epcList: widget.epcList,
    );

    return ObjectEventFormSectionCard(
      title: 'Instance/Lot Master Data (ILMD)',
      showTitleRequiredIndicator: titleIsRequired,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isViewOnly) ...[
            ObjectEventFormReadOnlyText(
              label: 'Item Expiration Date',
              value: expirationRaw.isEmpty ? null : expirationRaw,
            ),
            const SizedBox(height: 8.0),
            ObjectEventFormReadOnlyText(
              label: 'Manufacturer of Goods',
              value: _manufacturerController.text.isEmpty
                  ? null
                  : _manufacturerController.text,
            ),
          ] else ...[
            InkWell(
              onTap: _selectExpirationDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  label: objectEventFormFieldLabel(
                    context,
                    'Item Expiration Date (cbvmda:itemExpirationDate)',
                    true,
                  ),
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  expirationDate != null
                      ? _dateFormat.format(expirationDate)
                      : 'Select date (YYYY-MM-DD)',
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _manufacturerController,
              decoration: InputDecoration(
                label: objectEventFormFieldLabel(
                  context,
                  'Manufacturer of Goods (cbvmda:manufacturerOfGoods)',
                  true,
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) =>
                  _updateIlmd(ilmdManufacturerOfGoodsKey, value.trim()),
            ),
          ],
        ],
      ),
    );
  }
}
