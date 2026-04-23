import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';

import 'package:traqtrace_app/data/services/advanced_query_service.dart';
import 'package:traqtrace_app/data/services/auth_service/auth_service.dart';

import 'package:traqtrace_app/data/services/gln_pharmaceutical_extension_service.dart';
import 'package:traqtrace_app/data/services/gln_service.dart';

import 'package:traqtrace_app/data/services/notification_api_service.dart';

import 'package:traqtrace_app/data/services/pharmaceutical_service.dart';

import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/admin/user_management/cubit/user_management_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/core/config/app_router.dart';
import 'package:traqtrace_app/data/services/user_management/user_management_service.dart';

import '../../data/services/advanced_performance_service.dart';
import '../../data/services/aggregation_event_service.dart';
import '../../data/services/barcode_generation_service.dart';
import '../../data/services/commissioning_operation_service.dart';
import '../../data/services/dashboard_service.dart';
import '../../data/services/database_partitioning_service.dart';
import '../../data/services/epc_conversion_service.dart';
import '../../data/services/epcis_event_service.dart';
import '../../data/services/gln_tobacco_extension_service.dart';
import '../../data/services/gs1/gtin/gtin_service.dart';
import '../../data/services/gtin_tobacco_extension_service.dart';
import '../../data/services/industry_test_data_service.dart';
import '../../data/services/packing_operation_service.dart';
import '../../data/services/product_journey_service.dart';
import '../../data/services/receiving_operation_service.dart';
import '../../data/services/reference_data_validation_service.dart';
import '../../data/services/service_account_service.dart';
import '../../data/services/sgtin_service.dart';
import '../../data/services/shipping_operation_service.dart';
import '../../data/services/sscc_pharmaceutical_extension_service.dart';
import '../../data/services/sscc_service.dart';
import '../../data/services/sscc_tobacco_extension_service.dart';
import '../../data/services/system_settings_service.dart';
import '../../data/services/transaction_document_service.dart';
import '../../data/services/transformation_event_service.dart';
import '../../data/services/transaction_event_service.dart';
import '../../data/services/sensor_element_service.dart';
import '../../data/services/certification_info_service.dart';
import '../../data/services/data_consistency_service.dart';
import '../../data/services/epcis_serialization_service.dart';
import '../../data/services/error_correction_service.dart';
import '../../data/services/gs1_barcode_api_service.dart';
import '../../data/services/bulk_export_service.dart';
import '../../data/services/cache_service.dart';
import '../../data/services/etl_service.dart';
import '../../data/services/performance_optimization_service.dart';
import '../../data/services/user_service.dart';
import '../../data/services/validation_service.dart';
import '../../data/services/websocket_service.dart';


final getIt = GetIt.instance;

Future<void> initDependencies(AppConfig appConfig) async {
  if (getIt.isRegistered<AppConfig>()) {
    await getIt.reset();
  }

  // Config
  getIt.registerSingleton<AppConfig>(appConfig);

  // Core
  final dioService = DioService()..setBaseUrl(appConfig.apiBaseUrl);
  getIt.registerLazySingleton<DioService>(() => dioService);
  getIt.registerLazySingleton<TokenManager>(() => TokenManager());
  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: getIt<AppConfig>().apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
        contentType: 'application/json',
      ),
    ),
  );

  // Services
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<UserService>(
    () => UserService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<UserManagementService>(
    () => UserManagementService(),
  );

  getIt.registerLazySingleton<GTINService>(
    () => GTINService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<DashboardService>(
    () => DashboardService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<SGTINService>(
    () => SGTINService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<GLNService>(
    () => GLNService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<EPCConversionService>(
    () => EPCConversionService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<BarcodeGenerationService>(
    () => BarcodeGenerationService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<SSCCService>(
    () => SSCCService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<NotificationApiService>(
    () => NotificationApiService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<WebSocketService>(() => WebSocketService());

  getIt.registerLazySingleton<ShippingOperationService>(
    () => ShippingOperationService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<ReceivingOperationService>(
    () => ReceivingOperationService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<PackingOperationService>(
    () => PackingOperationService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<CommissioningOperationService>(
    () => CommissioningOperationService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<TransactionDocumentService>(
    () => TransactionDocumentService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<ReferenceDataValidationService>(
    () => ReferenceDataValidationService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<SystemSettingsService>(
    () => SystemSettingsService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<DatabasePartitioningService>(
    () => DatabasePartitioningService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<AdvancedQueryService>(
    () => AdvancedQueryService(getIt<DioService>()),
  );

  getIt.registerLazySingleton<PharmaceuticalService>(
    () => PharmaceuticalService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<GLNPharmaceuticalExtensionService>(
    () => GLNPharmaceuticalExtensionService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<GTINTobaccoExtensionService>(
    () => GTINTobaccoExtensionService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<GLNTobaccoExtensionService>(
    () => GLNTobaccoExtensionService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<SSCCTobaccoExtensionService>(
    () => SSCCTobaccoExtensionService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<SSCCPharmaceuticalExtensionService>(
    () => SSCCPharmaceuticalExtensionService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<ProductJourneyService>(
    () => ProductJourneyService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<ServiceAccountService>(
    () => ServiceAccountService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<EPCISEventService>(
    () => EPCISEventService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<TransformationEventService>(
    () => TransformationEventService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<TransactionEventService>(
    () => TransactionEventService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<SensorElementService>(
    () => SensorElementService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<CertificationInfoService>(
    () => CertificationInfoService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<AdvancedPerformanceService>(
    () => AdvancedPerformanceService(
      dioService: getIt<DioService>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<IndustryTestDataService>(
    () => IndustryTestDataService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<AggregationEventService>(
    () => AggregationEventService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<EPCISSerializationService>(
    () => EPCISSerializationService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<ValidationService>(
    () => ValidationService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<DataConsistencyService>(
    () => DataConsistencyService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<ErrorCorrectionService>(
    () => ErrorCorrectionService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<GS1BarcodeApiService>(
    () => GS1BarcodeApiService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<BulkExportService>(
    () => BulkExportService(getIt<DioService>()),
  );

  getIt.registerLazySingleton<ETLService>(
    () => ETLService(getIt<DioService>()),
  );

  getIt.registerLazySingleton<CacheService>(
    () => CacheService(dioService: getIt<DioService>()),
  );

  getIt.registerLazySingleton<PerformanceOptimizationService>(
    () => PerformanceOptimizationService(dioService: getIt<DioService>()),
  );

  // Cubits & Routers
  getIt.registerSingleton<AuthCubit>(
    AuthCubit(authService: getIt<AuthService>()),
  );
  getIt.registerFactory<UserManagementCubit>(
    () => UserManagementCubit(
      userManagementService: getIt<UserManagementService>(),
    ),
  );
  getIt.registerFactory<GTINCubit>(
    () => GTINCubit(
      gtinService: getIt<GTINService>(),
      pharmaceuticalService: getIt<PharmaceuticalService>(),
      tobaccoExtensionService: getIt<GTINTobaccoExtensionService>(),
    ),
  );
  getIt.registerSingleton<AppRouter>(AppRouter(authCubit: getIt<AuthCubit>()));
}
