import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/pharma_groups/pharma_storage_handling_content.dart';

class StorageHandlingGroupWidget extends StatefulWidget {
  const StorageHandlingGroupWidget({
    super.key,
    required this.isEditing,
    required this.initialStorageConditions,
    required this.initialMinStorageTemp,
    required this.initialMaxStorageTemp,
    required this.initialRequiresRefrigeration,
    required this.initialRequiresFreezing,
    required this.initialLightSensitive,
    required this.initialHumiditySensitive,
    required this.initialColdChainRequired,
    required this.onChanged,
    this.showFieldSkeleton = false,
  });

  final bool isEditing;
  final String initialStorageConditions;
  final String initialMinStorageTemp;
  final String initialMaxStorageTemp;
  final bool initialRequiresRefrigeration;
  final bool initialRequiresFreezing;
  final bool initialLightSensitive;
  final bool initialHumiditySensitive;
  final bool initialColdChainRequired;
  final bool showFieldSkeleton;
  final void Function({
    required String storageConditions,
    required String minStorageTemp,
    required String maxStorageTemp,
    required bool requiresRefrigeration,
    required bool requiresFreezing,
    required bool lightSensitive,
    required bool humiditySensitive,
    required bool coldChainRequired,
  })
  onChanged;

  @override
  State<StorageHandlingGroupWidget> createState() =>
      _StorageHandlingGroupWidgetState();
}

class _StorageHandlingGroupWidgetState
    extends State<StorageHandlingGroupWidget> {
  late final TextEditingController _storageConditionsController;
  late final TextEditingController _minStorageTempController;
  late final TextEditingController _maxStorageTempController;
  late bool _requiresRefrigeration;
  late bool _requiresFreezing;
  late bool _lightSensitive;
  late bool _humiditySensitive;

  @override
  void initState() {
    super.initState();
    _storageConditionsController = TextEditingController(
      text: widget.initialStorageConditions,
    );
    _minStorageTempController = TextEditingController(
      text: widget.initialMinStorageTemp,
    );
    _maxStorageTempController = TextEditingController(
      text: widget.initialMaxStorageTemp,
    );
    _requiresRefrigeration = widget.initialRequiresRefrigeration;
    _requiresFreezing = widget.initialRequiresFreezing;
    _lightSensitive = widget.initialLightSensitive;
    _humiditySensitive = widget.initialHumiditySensitive;

    _storageConditionsController.addListener(_emitChange);
    _minStorageTempController.addListener(_emitChange);
    _maxStorageTempController.addListener(_emitChange);
  }

  @override
  void didUpdateWidget(covariant StorageHandlingGroupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialStorageConditions == oldWidget.initialStorageConditions &&
        widget.initialMinStorageTemp == oldWidget.initialMinStorageTemp &&
        widget.initialMaxStorageTemp == oldWidget.initialMaxStorageTemp &&
        widget.initialRequiresRefrigeration ==
            oldWidget.initialRequiresRefrigeration &&
        widget.initialRequiresFreezing == oldWidget.initialRequiresFreezing &&
        widget.initialLightSensitive == oldWidget.initialLightSensitive &&
        widget.initialHumiditySensitive == oldWidget.initialHumiditySensitive) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _requiresRefrigeration = widget.initialRequiresRefrigeration;
        _requiresFreezing = widget.initialRequiresFreezing;
        _lightSensitive = widget.initialLightSensitive;
        _humiditySensitive = widget.initialHumiditySensitive;
      });
      if (widget.initialStorageConditions !=
              oldWidget.initialStorageConditions &&
          widget.initialStorageConditions !=
              _storageConditionsController.text) {
        _storageConditionsController.text = widget.initialStorageConditions;
      }
      if (widget.initialMinStorageTemp != oldWidget.initialMinStorageTemp &&
          widget.initialMinStorageTemp != _minStorageTempController.text) {
        _minStorageTempController.text = widget.initialMinStorageTemp;
      }
      if (widget.initialMaxStorageTemp != oldWidget.initialMaxStorageTemp &&
          widget.initialMaxStorageTemp != _maxStorageTempController.text) {
        _maxStorageTempController.text = widget.initialMaxStorageTemp;
      }
    });
  }

  @override
  void dispose() {
    _storageConditionsController.dispose();
    _minStorageTempController.dispose();
    _maxStorageTempController.dispose();
    super.dispose();
  }

  bool get _coldChainRequired {
    final max = double.tryParse(_maxStorageTempController.text.trim());
    return max != null && max < 8;
  }

  void _emitChange() {
    widget.onChanged(
      storageConditions: _storageConditionsController.text,
      minStorageTemp: _minStorageTempController.text,
      maxStorageTemp: _maxStorageTempController.text,
      requiresRefrigeration: _requiresRefrigeration,
      requiresFreezing: _requiresFreezing,
      lightSensitive: _lightSensitive,
      humiditySensitive: _humiditySensitive,
      coldChainRequired: _coldChainRequired,
    );
  }

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final content = PharmaStorageHandlingContent(
      isEditing: widget.isEditing,
      storageConditionsController: _storageConditionsController,
      minStorageTempController: _minStorageTempController,
      maxStorageTempController: _maxStorageTempController,
      requiresRefrigeration: _requiresRefrigeration,
      requiresFreezing: _requiresFreezing,
      lightSensitive: _lightSensitive,
      humiditySensitive: _humiditySensitive,
      coldChainRequired: _coldChainRequired,
      onRequiresRefrigerationChanged: (value) {
        setState(() => _requiresRefrigeration = value);
        _emitChange();
      },
      onRequiresFreezingChanged: (value) {
        setState(() => _requiresFreezing = value);
        _emitChange();
      },
      onLightSensitiveChanged: (value) {
        setState(() => _lightSensitive = value);
        _emitChange();
      },
      onHumiditySensitiveChanged: (value) {
        setState(() => _humiditySensitive = value);
        _emitChange();
      },
    );
    return Gs1GroupCard(
      title: 'Storage & handling',
      outlineColor: outline,
      showFieldSkeleton: widget.showFieldSkeleton,
      skeletonFieldCount: 2,
      child: content,
    );
  }
}
