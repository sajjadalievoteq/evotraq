import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_cubit.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_lookup_status.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_state.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/batch/sgtin_batch_master_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/core_groups/sgtin_batch_date_card.dart';

class SgtinCreateBatchSection extends StatefulWidget {
  const SgtinCreateBatchSection({
    required this.borderColor,
    required this.batchLotNumberController,
    required this.expiryDate,
    required this.productionDate,
    required this.bestBeforeDate,
    required this.expiryDateTime,
    required this.onPickExpiry,
    required this.onPickProduction,
    required this.onPickBestBefore,
    required this.setFieldError,
    this.onBatchLotEditingComplete,
    this.onBatchLotFocusLost,
  });

  final Color borderColor;
  final TextEditingController batchLotNumberController;
  final DateTime? expiryDate;
  final DateTime? productionDate;
  final DateTime? bestBeforeDate;
  final DateTime? expiryDateTime;
  final VoidCallback onPickExpiry;
  final VoidCallback onPickProduction;
  final VoidCallback onPickBestBefore;
  final void Function(String, String?) setFieldError;
  final VoidCallback? onBatchLotEditingComplete;
  final VoidCallback? onBatchLotFocusLost;

  @override
  State<SgtinCreateBatchSection> createState() =>
      SgtinCreateBatchSectionState();
}

class SgtinCreateBatchSectionState extends State<SgtinCreateBatchSection> {
  late final TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _register() {
    final qtyText = _quantityController.text.trim();
    context.read<SgtinBatchCubit>().registerBatch(
      batchLot: widget.batchLotNumberController.text,
      manufactureDate: widget.productionDate,
      expiryDate: widget.expiryDate,
      quantityManufactured: qtyText.isEmpty ? null : int.tryParse(qtyText),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.batchLotNumberController,
      builder: (context, _) {
        return BlocBuilder<SgtinBatchCubit, SgtinBatchState>(
          builder: (context, batchState) {
            final lot = widget.batchLotNumberController.text.trim();
            final canRegister = batchState.status.needsRegistration;
            return SgtinBatchDateCard(
              borderColor: widget.borderColor,
              isCreating: true,
              batchLotNumberController: widget.batchLotNumberController,
              expiryDate: widget.expiryDate,
              productionDate: widget.productionDate,
              bestBeforeDate: widget.bestBeforeDate,
              expiryDateTime: widget.expiryDateTime,
              onPickExpiry: widget.onPickExpiry,
              onPickProduction: widget.onPickProduction,
              onPickBestBefore: widget.onPickBestBefore,
              lockDatesFromBatch: batchState.status.isResolved,
              showRegistrationFields: canRegister,
              quantityController: _quantityController,
              onRegister: canRegister ? _register : null,
              isRegistering:
                  batchState.status == SgtinBatchLookupStatus.registering,
              setFieldError: widget.setFieldError,
              onBatchLotEditingComplete: widget.onBatchLotEditingComplete,
              onBatchLotFocusLost: widget.onBatchLotFocusLost,
              batchStatusPanel: lot.isEmpty
                  ? null
                  : SgtinBatchMasterCard(state: batchState, batchLot: lot),
            );
          },
        );
      },
    );
  }
}
