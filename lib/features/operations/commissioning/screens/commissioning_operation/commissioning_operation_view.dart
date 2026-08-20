import 'package:traqtrace_app/core/layout/app_layout_builder.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/data/services/gs1/gtin/gtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_operation_cubit.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_operation_state.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/commissioning/models/commissioning_epc_item.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_epc_resolver.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_serial_pool_checker.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_serial_pool_status.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_config.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_desktop_layout.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_mobile_layout.dart';

import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/commissioning_identification_actions.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/commissioning_workflow_actions.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/commissioning_submission_actions.dart';

class CommissioningOperationView extends StatefulWidget {
  const CommissioningOperationView({super.key});

  @override
  State<CommissioningOperationView> createState() =>
      CommissioningOperationViewState();
}

class CommissioningOperationViewState
    extends State<CommissioningOperationView> {
  static const _wizardSteps = [
    OperationStepConfig.details,
    OperationStepConfig.items,
    OperationStepConfig.review,
  ];

  final pageController = PageController();
  int currentStep = 0;

  final batchLotController = TextEditingController();
  final referenceController = TextEditingController();
  final readPointGlnController = TextEditingController();

  final countryOfOriginController = TextEditingController();
  final productionOrderController = TextEditingController();
  final productionLineController = TextEditingController();
  final regulatoryMarketController = TextEditingController();
  final regulatoryStatusController = TextEditingController();
  final operatorIdController = TextEditingController();
  final notesController = TextEditingController();

  final step1FormKey = GlobalKey<FormState>();
  final step2FormKey = GlobalKey<FormState>();

  late final CommissioningEpcResolver epcResolver;
  late final CommissioningSerialPoolChecker poolChecker;
  late final GTINService gtinService;

  GTIN? selectedGTIN;
  String? gtinLoadInFlightFor;
  String? pharmaGtinIdentifiedFor;
  final Map<String, CommissioningPoolCheckResult> poolCheckCache = {};

  EPCType? identifiedType;
  EPCParseResult? primaryParsed;
  String? guessabilityWarning;

  bool isPharmaGtin = false;
  List<GLN> availableLocations = [];
  GLN? commissioningLocationGLN;
  String? locationError;
  DateTime? expiryDate;
  DateTime? productionDate;
  DateTime? bestBeforeDate;
  bool expiryManuallySet = false;
  bool productionDateManuallySet = false;

  final List<CommissioningEpcItem> commissionItems = [];

  bool isLoading = false;

  bool get isPharmaSgtin => identifiedType == EPCType.sgtin && isPharmaGtin;

  bool get _isDetailsStepValid => commissioningLocationGLN != null;

  bool get _isStep2Valid =>
      commissionItems.isNotEmpty &&
      !commissionItems.any((i) => i.poolStatus.blocksCommissioning) &&
      !commissionItems.any(
        (i) => i.poolStatus == CommissioningSerialPoolStatus.checking,
      );

  @override
  void initState() {
    super.initState();
    poolChecker = getIt<CommissioningSerialPoolChecker>();
    epcResolver = CommissioningEpcResolver(
      sgtinService: getIt<SGTINService>(),
      ssccService: getIt<SSCCService>(),
      poolChecker: poolChecker,
    );
    gtinService = getIt<GTINService>();
    batchLotController.addListener(onBatchLotTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => loadLocations());
  }

  @override
  void dispose() {
    pageController.dispose();
    batchLotController.dispose();
    referenceController.dispose();
    readPointGlnController.dispose();
    countryOfOriginController.dispose();
    productionOrderController.dispose();
    productionLineController.dispose();
    regulatoryMarketController.dispose();
    regulatoryStatusController.dispose();
    operatorIdController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      CommissioningOperationCubit,
      CommissioningOperationState
    >(
      builder: (context, state) {
        final submitLabel = 'Commission ${commissionItems.length} Items';
        final isBusy = isLoading || state.loading;

        return AppLayoutBuilder(
          builder: (context, layout) {
            final isDesktop = layout.isDesktopUp;
            final step1 = buildStep1(embeddedInPanel: isDesktop);
            final step2 = buildStep2(
              embeddedInPanel: isDesktop,
              fillHeight: !isDesktop,
            );
            final step3 = buildStep3();

            return isDesktop
                ? OperationDesktopLayout(
                    isLoading: isBusy,
                    appBarTitle: 'New Commissioning Operation',
                    submitLabel: submitLabel,
                    step1Title: 'Details',
                    step2Title: 'Items',
                    step1Complete: _isDetailsStepValid,
                    step2Complete: _isStep2Valid,
                    detailsStep: step1,
                    itemsStep: step2,
                    reviewStep: step3,
                    onSubmit: submit,
                  )
                : OperationMobileLayout(
                    isLoading: isBusy,
                    appBarTitle: 'Commissioning',
                    submitLabel: submitLabel,
                    currentStep: currentStep,
                    steps: _wizardSteps,
                    pageController: pageController,
                    onPageChanged: (page) =>
                        setState(() => currentStep = page),
                    onPrevious: previousStep,
                    onNext: nextStep,
                    onSubmit: submit,
                    stepPages: [step1, step2, step3],
                  );
          },
        );
      },
    );
  }
}
