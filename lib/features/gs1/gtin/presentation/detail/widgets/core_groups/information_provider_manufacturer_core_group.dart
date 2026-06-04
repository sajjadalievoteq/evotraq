import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_resolution.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/utilities/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/shared/widgets/gln_selector.dart';

class InformationProviderManufacturerCoreGroup extends StatefulWidget {
  const InformationProviderManufacturerCoreGroup({
    super.key,
    required this.isReadOnly,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final bool showFieldSkeleton;

  @override
  State<InformationProviderManufacturerCoreGroup> createState() =>
      InformationProviderManufacturerCoreGroupState();
}

class InformationProviderManufacturerCoreGroupState
    extends State<InformationProviderManufacturerCoreGroup> {
  GLN? _informationProviderGln;
  GLN? _manufacturerGln;
  late final TextEditingController _informationProviderName;

  @override
  void initState() {
    super.initState();
    _informationProviderName = TextEditingController();
  }

  @override
  void dispose() {
    _informationProviderName.dispose();
    super.dispose();
  }

  String? get informationProviderGln => _glnCodeOrNull(_informationProviderGln);
  String? get informationProviderName =>
      _informationProviderName.text.trim().isEmpty
      ? null
      : _informationProviderName.text.trim();
  String? get manufacturerGln => _glnCodeOrNull(_manufacturerGln);

  String? _glnCodeOrNull(GLN? gln) {
    final code = gln?.glnCode.trim();
    if (code == null || code.isEmpty) return null;
    return code;
  }

  GLN? _glnFromStoredCode(String? code) {
    if (code == null || code.trim().isEmpty) return null;
    return GLN.fromCode(code.trim());
  }

  void setFromGtin({
    required String? informationProviderGln,
    required String? informationProviderName,
    required String? manufacturerGln,
  }) {
    _informationProviderGln = _glnFromStoredCode(informationProviderGln);
    _manufacturerGln = _glnFromStoredCode(manufacturerGln);
    _informationProviderName.text = (informationProviderName ?? '').trim();
    if (mounted) setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveGlnsFromCatalog());
  }

  Future<void> _resolveGlnsFromCatalog() async {
    if (_informationProviderGln == null && _manufacturerGln == null) return;
    try {
      final catalog =
          await getIt<GLNService>().getAllGLNs(page: 0, size: 500);
      if (!mounted) return;
      setState(() {
        _informationProviderGln = resolveGlnForPicker(
          code: _informationProviderGln?.glnCode,
          fallback: _informationProviderGln,
          catalog: catalog,
        );
        _manufacturerGln = resolveGlnForPicker(
          code: _manufacturerGln?.glnCode,
          fallback: _manufacturerGln,
          catalog: catalog,
        );
      });
    } catch (_) {
      // Picker will still resolve when editing.
    }
  }

  void _onInformationProviderGlnChanged(GLN? gln) {
    setState(() {
      _informationProviderGln = gln;
      if (gln != null && _informationProviderName.text.trim().isEmpty) {
        _informationProviderName.text = gln.locationName;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.isReadOnly) ...[
          SgtinInfoRow(
            GtinUiConstants.labelInformationProviderGln,
            _informationProviderGln != null
                ? '${_informationProviderGln!.glnCode} – ${_informationProviderGln!.locationName}'
                : informationProviderGln,
          ),
          const SizedBox(height: 12),
          SgtinInfoRow(
            'Information Provider Name',
            informationProviderName,
          ),
          const SizedBox(height: 12),
          SgtinInfoRow(
            GtinUiConstants.labelManufacturerGlnField,
            _manufacturerGln != null
                ? '${_manufacturerGln!.glnCode} – ${_manufacturerGln!.locationName}'
                : manufacturerGln,
          ),
        ] else ...[
          GLNSelector(
            label: GtinUiConstants.labelInformationProviderGln,
            hintText: 'Search and select information provider location',
            initialValue: _informationProviderGln,
            onChanged: _onInformationProviderGlnChanged,
          ),
          const SizedBox(height: 12),
          Gs1ValidatedField(
            controller: _informationProviderName,
            fieldName: 'information_provider_name',
            label: 'Information Provider Name',
            readOnly: widget.isReadOnly,
            maxLength: 200,
            validator: GtinFieldValidators.validateInformationProviderName,
          ),
          const SizedBox(height: 12),
          GLNSelector(
            label: GtinUiConstants.labelManufacturerGlnField,
            hintText: 'Search and select manufacturer location',
            initialValue: _manufacturerGln,
            onChanged: (gln) => setState(() => _manufacturerGln = gln),
          ),
        ],
      ],
    );

    return Gs1GroupCard(
      title: GtinUiConstants.sectionInformationProviderManufacturer,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      showFieldSkeleton: widget.showFieldSkeleton,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          GtinSkeletonOutlineField(color: c, height: 76),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 76),
        ],
      ),
      child: body,
    );
  }
}
