import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/http_service.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';

import 'package:traqtrace_app/data/services/advanced_query_service.dart';
import 'package:traqtrace_app/data/services/auth_service.dart';

import 'package:traqtrace_app/data/services/gln_pharmaceutical_extension_service.dart';
import 'package:traqtrace_app/data/services/gln_service.dart';

import 'package:traqtrace_app/data/services/notification_api_service.dart';

import 'package:traqtrace_app/data/services/pharmaceutical_service.dart';

import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/core/config/app_router.dart';

import '../../data/services/admin_service.dart';
import '../../data/services/barcode_generation_service.dart';
import '../../data/services/commissioning_operation_service.dart';
import '../../data/services/dashboard_service.dart';
import '../../data/services/epc_conversion_service.dart';
import '../../data/services/epcis_event_service.dart';
import '../../data/services/gln_tobacco_extension_service.dart';
import '../../data/services/gtin_service.dart';
import '../../data/services/gtin_tobacco_extension_service.dart';
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
import '../../data/services/user_service.dart';
import '../../data/services/websocket_service.dart';

final getIt = GetIt.instance;

Future<void> initDependencies(AppConfig appConfig) async {
  if (getIt.isRegistered<AppConfig>()) {
    await getIt.reset();
  }

  // Config
  getIt.registerSingleton<AppConfig>(appConfig);

  // Core
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  final httpService = HttpService()..setBaseUrl(appConfig.apiBaseUrl);
  getIt.registerLazySingleton<HttpService>(() => httpService);
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
    () => AuthService(httpService: getIt<HttpService>()),
  );

  getIt.registerLazySingleton<UserService>(
    () => UserService(httpService: getIt<HttpService>()),
  );

  getIt.registerLazySingleton<AdminService>(
    () => AdminService(
      httpService: getIt<HttpService>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<GTINService>(
    () => GTINService(httpService: getIt<HttpService>()),
  );

  getIt.registerLazySingleton<DashboardService>(
    () => DashboardService(httpService: getIt<HttpService>()),
  );

  getIt.registerLazySingleton<SGTINService>(
    () => SGTINService(httpService: getIt<HttpService>()),
  );

  getIt.registerLazySingleton<GLNService>(
    () => GLNService(httpService: getIt<HttpService>()),
  );

  getIt.registerLazySingleton<EPCConversionService>(
    () => EPCConversionService(httpService: getIt<HttpService>()),
  );

  getIt.registerLazySingleton<BarcodeGenerationService>(
    () => BarcodeGenerationService(httpService: getIt<HttpService>()),
  );

  getIt.registerLazySingleton<SSCCService>(
    () => SSCCService(httpService: getIt<HttpService>()),
  );

  getIt.registerLazySingleton<NotificationApiService>(
    () => NotificationApiService(httpService: getIt<HttpService>()),
  );

  getIt.registerLazySingleton<WebSocketService>(() => WebSocketService());

  getIt.registerLazySingleton<ShippingOperationService>(
    () => ShippingOperationService(
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<ReceivingOperationService>(
    () => ReceivingOperationService(
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<PackingOperationService>(
    () => PackingOperationService(
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<CommissioningOperationService>(
    () => CommissioningOperationService(
      client: getIt<http.Client>(),
      appConfig: getIt<AppConfig>(),
      tokenManager: getIt<TokenManager>(),
    ),
  );

  getIt.registerLazySingleton<TransactionDocumentService>(
    () => TransactionDocumentService(
      httpClient: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<ReferenceDataValidationService>(
    () => ReferenceDataValidationService(
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
    () => ProductJourneyService(
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
    () => EPCISEventService(
      httpClient: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: getIt<AppConfig>(),
    ),
  );

  getIt.registerLazySingleton<TransformationEventService>(
    () => TransformationEventService(
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
