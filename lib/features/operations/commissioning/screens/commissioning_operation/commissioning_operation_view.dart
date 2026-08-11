import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/navigation/pop_or_go.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/utils/barcode_utils.dart';
import 'package:traqtrace_app/data/models/barcode/barcode_details.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_batch.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/services/gs1/gtin/gtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_batch_lookup_status.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_operation_cubit.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_operation_state.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/operations/commissioning/models/commissioning_epc_item.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_epc_resolver.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_field_validators.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_serial_pool_checker.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_serial_pool_status.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_config.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_clear_serials_dialog.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_epc_disambiguation_dialog.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_desktop_layout.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_mobile_layout.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_step1_product_details.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_submit_error_message.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_step2_serial_numbers.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_step3_review.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_partial_success_choice.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_partial_success_result.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_picker_catalog.dart';
import 'widgets/commissioning_partial_success_dialog.dart';

part 'commissioning_identification_actions.dart';
part 'commissioning_workflow_actions.dart';
part 'commissioning_submission_actions.dart';

class CommissioningOperationView extends StatefulWidget {
  const CommissioningOperationView({super.key});

  @override
  State<CommissioningOperationView> createState() =>
      _CommissioningOperationViewState();
}

class _CommissioningOperationViewState
    extends State<CommissioningOperationView> {
  static const _wizardSteps = [
    OperationStepConfig.details,
    OperationStepConfig.items,
    OperationStepConfig.review,
  ];

  final _pageController = PageController();
  int _currentStep = 0;

  final _batchLotController = TextEditingController();
  final _registrationQuantityController = TextEditingController();
  final _referenceController = TextEditingController();
  final _readPointGlnController = TextEditingController();

  final _countryOfOriginController = TextEditingController();
  final _productionOrderController = TextEditingController();
  final _productionLineController = TextEditingController();
  final _regulatoryMarketController = TextEditingController();
  final _regulatoryStatusController = TextEditingController();
  final _operatorIdController = TextEditingController();
  final _notesController = TextEditingController();

  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  late final CommissioningEpcResolver _epcResolver;
  late final CommissioningSerialPoolChecker _poolChecker;
  late final GTINService _gtinService;

  GTIN? _selectedGTIN;
  String? _gtinLoadInFlightFor;
  String? _pharmaGtinIdentifiedFor;
  final Map<String, CommissioningPoolCheckResult> _poolCheckCache = {};

  EPCType? _identifiedType;
  EPCParseResult? _primaryParsed;
  String? _guessabilityWarning;

  bool _isPharmaGtin = false;
  List<GLN> _availableLocations = [];
  GLN? _commissioningLocationGLN;
  String? _locationError;
  DateTime? _expiryDate;
  DateTime? _productionDate;
  DateTime? _bestBeforeDate;
  bool _expiryManuallySet = false;
  bool _productionDateManuallySet = false;

  final List<CommissioningEpcItem> _commissionItems = [];

  bool _isLoading = false;

  bool get _isPharmaSgtin => _identifiedType == EPCType.sgtin && _isPharmaGtin;

  bool get _isDetailsStepValid => _commissioningLocationGLN != null;

  bool get _isStep2Valid =>
      _commissionItems.isNotEmpty &&
      !_commissionItems.any((i) => i.poolStatus.blocksCommissioning) &&
      !_commissionItems.any(
        (i) => i.poolStatus == CommissioningSerialPoolStatus.checking,
      );

  @override
  void initState() {
    super.initState();
    _poolChecker = getIt<CommissioningSerialPoolChecker>();
    _epcResolver = CommissioningEpcResolver(
      sgtinService: getIt<SGTINService>(),
      ssccService: getIt<SSCCService>(),
      poolChecker: _poolChecker,
    );
    _gtinService = getIt<GTINService>();
    _batchLotController.addListener(_onBatchLotTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLocations());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _batchLotController.dispose();
    _registrationQuantityController.dispose();
    _referenceController.dispose();
    _readPointGlnController.dispose();
    _countryOfOriginController.dispose();
    _productionOrderController.dispose();
    _productionLineController.dispose();
    _regulatoryMarketController.dispose();
    _regulatoryStatusController.dispose();
    _operatorIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      CommissioningOperationCubit,
      CommissioningOperationState
    >(
      listenWhen: (previous, current) =>
          previous.resolvedBatch != current.resolvedBatch,
      listener: (context, state) {
        final batch = state.resolvedBatch;
        if (batch != null) _applyBatchDatesFromResolved(batch);
      },
      builder: (context, batchState) {
        final submitLabel = 'Commission ${_commissionItems.length} Items';
        final isBusy = _isLoading || batchState.loading;

        return AppLayoutBuilder(
          builder: (context, layout) {
            final isDesktop = layout.isDesktopUp;
            final step1 = _buildStep1(batchState, embeddedInPanel: isDesktop);
            final step2 = _buildStep2(
              batchState,
              embeddedInPanel: isDesktop,
              fillHeight: !isDesktop,
            );
            final step3 = _buildStep3();

            return isDesktop
                ? OperationDesktopLayout(
                    isLoading: isBusy,
                    appBarTitle: 'New Commissioning Operation',
                    submitLabel: submitLabel,
                    step1Title: 'Details',
                    step2Title: 'Items',
                    step1Complete: _isDetailsStepValid,
                    step2Complete:
                        _isStep2Valid && _isPharmaBatchReady(batchState),
                    detailsStep: step1,
                    itemsStep: step2,
                    reviewStep: step3,
                    onSubmit: _submit,
                  )
                : OperationMobileLayout(
                    isLoading: isBusy,
                    appBarTitle: 'Commissioning',
                    submitLabel: submitLabel,
                    currentStep: _currentStep,
                    steps: _wizardSteps,
                    pageController: _pageController,
                    onPageChanged: (page) =>
                        setState(() => _currentStep = page),
                    onPrevious: _previousStep,
                    onNext: _nextStep,
                    onSubmit: _submit,
                    stepPages: [step1, step2, step3],
                  );
          },
        );
      },
    );
  }
}
