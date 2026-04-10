import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/core/network/http_service.dart';
import 'package:traqtrace_app/features/admin/services/admin_service.dart';
import 'package:traqtrace_app/features/auth/services/auth_service.dart';
import 'package:traqtrace_app/features/auth/services/auth_service_impl.dart';
import 'package:traqtrace_app/features/epcis/services/epcis_event_service.dart';
import 'package:traqtrace_app/features/epcis/services/epcis_event_service_impl.dart';
import 'package:traqtrace_app/features/epcis/services/transformation_event_service.dart';
import 'package:traqtrace_app/features/epcis/services/transformation_event_service_impl.dart';
import 'package:traqtrace_app/features/epcis/services/operations/shipping_operation_service.dart';
import 'package:traqtrace_app/features/epcis/services/operations/receiving_operation_service.dart';
import 'package:traqtrace_app/features/epcis/services/operations/packing_operation_service.dart';
import 'package:traqtrace_app/features/epcis/services/operations/commissioning_operation_service.dart';
import 'package:traqtrace_app/features/epcis/services/transaction_document_service.dart';
import 'package:traqtrace_app/features/epcis/services/transaction_document_service_impl.dart';
import 'package:traqtrace_app/features/epcis/services/reference_data_validation_service.dart';
import 'package:traqtrace_app/features/gs1/services/epc_conversion_service.dart';
import 'package:traqtrace_app/features/gs1/services/epc_conversion_service_impl.dart';
import 'package:traqtrace_app/features/gs1/services/gln_service.dart';
import 'package:traqtrace_app/features/gs1/services/gln_service_impl.dart';
import 'package:traqtrace_app/features/gs1/services/gtin_service.dart';
import 'package:traqtrace_app/features/gs1/services/gtin_service_impl.dart';
import 'package:traqtrace_app/features/gs1/services/sgtin_service.dart';
import 'package:traqtrace_app/features/gs1/services/sgtin_service_impl.dart';
import 'package:traqtrace_app/features/gs1/services/sscc_service.dart';
import 'package:traqtrace_app/features/gs1/services/sscc_service_impl.dart';
import 'package:traqtrace_app/features/barcode/services/barcode_generation_service.dart';
import 'package:traqtrace_app/features/user_management/services/user_service.dart';
import 'package:traqtrace_app/features/user_management/services/user_service_impl.dart';
import 'package:traqtrace_app/features/epcis/services/advanced_query_service.dart';
import 'package:traqtrace_app/features/notifications/data/services/notification_api_service.dart';
import 'package:traqtrace_app/features/notifications/data/services/websocket_service.dart';
import 'package:traqtrace_app/features/pharmaceutical/services/pharmaceutical_service.dart';
import 'package:traqtrace_app/features/pharmaceutical/services/gln_pharmaceutical_extension_service.dart';
import 'package:traqtrace_app/features/tobacco/services/gtin_tobacco_extension_service.dart';
import 'package:traqtrace_app/features/tobacco/services/gln_tobacco_extension_service.dart';
import 'package:traqtrace_app/features/tobacco/services/sscc_tobacco_extension_service.dart';
import 'package:traqtrace_app/features/pharmaceutical/services/sscc_pharmaceutical_extension_service.dart';
import 'package:traqtrace_app/core/services/system_settings_service.dart';
import 'package:traqtrace_app/features/dashboards/services/product_journey_service.dart';
import 'package:traqtrace_app/features/api_management/services/service_account_service.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/core/config/app_router.dart';

final getIt = GetIt.instance;

Future<void> initDependencies(AppConfig appConfig) async {
  // Config
  getIt.registerSingleton<AppConfig>(appConfig);

  // Core
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  getIt.registerLazySingleton<TokenManager>(() => TokenManager());
  getIt.registerLazySingleton<HttpService>(() => HttpService());
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
    () => AuthServiceImpl(
      dio: getIt<Dio>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<UserService>(
    () => UserServiceImpl(
      dio: getIt<Dio>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<AdminService>(
    () => AdminService(
      client: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<GTINService>(
    () => GTINServiceImpl(
      httpClient: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<SGTINService>(
    () => SGTINServiceImpl(
      httpClient: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<GLNService>(
    () => GLNServiceImpl(
      client: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<EPCConversionService>(
    () => EPCConversionServiceImpl(
      client: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<BarcodeGenerationService>(
    () => BarcodeGenerationService(
      client: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<SSCCService>(
    () => SSCCServiceImpl(
      httpClient: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<NotificationApiService>(
    () => NotificationApiService(
      client: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<WebSocketService>(() => WebSocketService());

  getIt.registerLazySingleton<ShippingOperationService>(
    () => ShippingOperationServiceImpl(
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<ReceivingOperationService>(
    () => ReceivingOperationServiceImpl(
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<PackingOperationService>(
    () => PackingOperationServiceImpl(
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<CommissioningOperationService>(
    () => CommissioningOperationServiceImpl(
      client: getIt<http.Client>(),
      appConfig: getIt<AppConfig>(),
      tokenManager: getIt<TokenManager>(),
    ),
  );

  getIt.registerLazySingleton<TransactionDocumentService>(
    () => TransactionDocumentServiceImpl(
      httpClient: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<ReferenceDataValidationService>(
    () => ReferenceDataValidationServiceImpl(
      httpClient: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<SystemSettingsService>(
    () => SystemSettingsService(
      dio: getIt<Dio>(),
      baseUrl: getIt<AppConfig>().apiBaseUrl,
      tokenManager: getIt<TokenManager>(),
    ),
  );

  getIt.registerLazySingleton<AdvancedQueryService>(
    () => AdvancedQueryService(getIt<HttpService>()),
  );

  getIt.registerLazySingleton<PharmaceuticalService>(
    () => PharmaceuticalService(
      httpClient: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<GLNPharmaceuticalExtensionService>(
    () => GLNPharmaceuticalExtensionService(
      httpClient: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<GTINTobaccoExtensionService>(
    () => GTINTobaccoExtensionService(
      httpClient: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<GLNTobaccoExtensionService>(
    () => GLNTobaccoExtensionService(
      httpClient: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<SSCCTobaccoExtensionService>(
    () => SSCCTobaccoExtensionService(
      httpClient: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<SSCCPharmaceuticalExtensionService>(
    () => SSCCPharmaceuticalExtensionService(
      httpClient: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<ProductJourneyService>(
    () => ProductJourneyServiceImpl(
      client: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<ServiceAccountService>(
    () => ServiceAccountService(
      httpClient: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<EPCISEventService>(
    () => EPCISEventServiceImpl(
      httpClient: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<TransformationEventService>(
    () => TransformationEventServiceImpl(
      httpClient: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  // Cubits & Routers
  getIt.registerSingleton<AuthCubit>(
    AuthCubit(authService: getIt<AuthService>()),
  );
  getIt.registerSingleton<AppRouter>(AppRouter(authCubit: getIt<AuthCubit>()));
}
