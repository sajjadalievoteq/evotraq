import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart' as gtin_model;
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/bloc/sgtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/sgtin_detail_form_body.dart';

class SgtinDetailFormBlocBody extends StatelessWidget {
  const SgtinDetailFormBlocBody({
    super.key,
    required this.sgtinId,
    required this.formFieldsHydrated,
    required this.formKey,
    required this.onRefresh,
    required this.isCreating,
    required this.isEditing,
    required this.isLocalLoading,
    required this.loadedSgtin,
    required this.gtinController,
    required this.serialNumberController,
    required this.batchLotNumberController,
    required this.regulatoryMarketController,
    required this.regulatoryStatusController,
    required this.selectedGtin,
    required this.selectedStatus,
    required this.expiryDate,
    required this.productionDate,
    required this.bestBeforeDate,
    required this.onGtinChanged,
    required this.onStatusChanged,
    required this.onTransitionError,
    required this.onPickExpiry,
    required this.onPickProduction,
    required this.onPickBestBefore,
    required this.setFieldError,
    required this.onDecommission,
    required this.onSubmit,
  });

  final String? sgtinId;
  final bool formFieldsHydrated;
  final GlobalKey<FormState> formKey;
  final Future<void> Function() onRefresh;
  final bool isCreating;
  final bool isEditing;
  final bool isLocalLoading;
  final SGTIN? loadedSgtin;

  final TextEditingController gtinController;
  final TextEditingController serialNumberController;
  final TextEditingController batchLotNumberController;
  final TextEditingController regulatoryMarketController;
  final TextEditingController regulatoryStatusController;

  final gtin_model.GTIN? selectedGtin;
  final ItemStatus? selectedStatus;
  final DateTime? expiryDate;
  final DateTime? productionDate;
  final DateTime? bestBeforeDate;

  final ValueChanged<gtin_model.GTIN?> onGtinChanged;
  final ValueChanged<ItemStatus> onStatusChanged;
  final ValueChanged<String> onTransitionError;
  final VoidCallback onPickExpiry;
  final VoidCallback onPickProduction;
  final VoidCallback onPickBestBefore;
  final void Function(String fieldName, String? error) setFieldError;
  final VoidCallback onDecommission;
  final VoidCallback onSubmit;

  bool _fieldSkeletonsActive(SGTINState state) {
    if (state.status == SGTINStatus.error) return false;
    return !formFieldsHydrated;
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.outlineVariant;

    return BlocBuilder<SGTINCubit, SGTINState>(
      builder: (context, state) {
        final sk = sgtinId != null && _fieldSkeletonsActive(state);

        return SgtinDetailFormBody(
          formKey: formKey,
          onRefresh: onRefresh,
          showSkeleton: sk,
          isCreating: isCreating,
          isEditing: isEditing,
          isLocalLoading: isLocalLoading,
          loadedSgtin: loadedSgtin,
          borderColor: borderColor,
          gtinController: gtinController,
          serialNumberController: serialNumberController,
          batchLotNumberController: batchLotNumberController,
          regulatoryMarketController: regulatoryMarketController,
          regulatoryStatusController: regulatoryStatusController,
          selectedGtin: selectedGtin,
          selectedStatus: selectedStatus,
          expiryDate: expiryDate,
          productionDate: productionDate,
          bestBeforeDate: bestBeforeDate,
          onGtinChanged: onGtinChanged,
          onStatusChanged: onStatusChanged,
          onTransitionError: onTransitionError,
          onPickExpiry: onPickExpiry,
          onPickProduction: onPickProduction,
          onPickBestBefore: onPickBestBefore,
          setFieldError: setFieldError,
          onDecommission: onDecommission,
          onSubmit: onSubmit,
        );
      },
    );
  }
}
