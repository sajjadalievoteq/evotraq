import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:traqtrace_app/core/web/url_strategy_stub.dart'
    if (dart.library.html) 'package:traqtrace_app/core/web/url_strategy_web.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/config/app_router.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/core/theme/theme_provider.dart';
import 'package:traqtrace_app/features/admin/cubit/admin_cubit.dart';
import 'package:traqtrace_app/features/admin/services/admin_service.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/epcis/cubit/aggregation_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/providers/transaction_events_provider.dart';
import 'package:traqtrace_app/features/epcis/providers/transaction_document_provider.dart';
import 'package:traqtrace_app/features/epcis/providers/transformation_events_provider.dart';
import 'package:traqtrace_app/features/epcis/services/epcis_event_service.dart';
import 'package:traqtrace_app/features/epcis/cubit/object_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/epcis_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/shipping_operation_cubit.dart';
import 'package:traqtrace_app/features/epcis/services/transformation_event_service.dart';
import 'package:traqtrace_app/features/epcis/services/operations/shipping_operation_service.dart';
import 'package:traqtrace_app/features/epcis/services/operations/receiving_operation_service.dart';
import 'package:traqtrace_app/features/epcis/services/operations/packing_operation_service.dart';
import 'package:traqtrace_app/features/epcis/services/operations/commissioning_operation_service.dart';
import 'package:traqtrace_app/features/epcis/services/transaction_document_service.dart';
import 'package:traqtrace_app/features/epcis/services/reference_data_validation_service.dart';
import 'package:traqtrace_app/features/gs1/bloc/gln/gln_cubit.dart';
import 'package:traqtrace_app/features/gs1/bloc/gtin/gtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/bloc/sgtin/sgtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/bloc/sscc/sscc_cubit.dart';
import 'package:traqtrace_app/features/gs1/services/epc_conversion_service.dart';
import 'package:traqtrace_app/features/gs1/services/gln_service.dart';
import 'package:traqtrace_app/features/gs1/services/gtin_service.dart';
import 'package:traqtrace_app/features/gs1/services/sgtin_service.dart';
import 'package:traqtrace_app/features/gs1/services/sscc_service.dart';
import 'package:traqtrace_app/features/user_management/cubit/profile_cubit.dart';
import 'package:traqtrace_app/features/user_management/services/user_service.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_rule_provider.dart';
import 'package:traqtrace_app/features/epcis/cubit/advanced_query_cubit.dart';
import 'package:traqtrace_app/features/epcis/providers/traversal_query_provider.dart';
import 'package:traqtrace_app/features/epcis/services/advanced_query_service.dart';
// Notification imports
import 'package:traqtrace_app/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/notifications/data/services/notification_api_service.dart';
import 'package:traqtrace_app/features/notifications/data/services/websocket_service.dart';
// Pharmaceutical imports
import 'package:traqtrace_app/features/pharmaceutical/services/pharmaceutical_service.dart';
import 'package:traqtrace_app/features/pharmaceutical/services/gln_pharmaceutical_extension_service.dart';
// Tobacco Extension imports
import 'package:traqtrace_app/features/tobacco/services/gtin_tobacco_extension_service.dart';
import 'package:traqtrace_app/features/tobacco/services/gln_tobacco_extension_service.dart';
import 'package:traqtrace_app/features/tobacco/services/sscc_tobacco_extension_service.dart';
// Pharmaceutical Extension imports
import 'package:traqtrace_app/features/pharmaceutical/services/sscc_pharmaceutical_extension_service.dart';
// System Settings imports
import 'package:traqtrace_app/core/services/system_settings_service.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
// Dashboard imports
import 'package:traqtrace_app/features/dashboards/services/product_journey_service.dart';
// API Management imports
import 'package:traqtrace_app/features/api_management/cubit/api_management_cubit.dart';
import 'package:traqtrace_app/features/api_management/providers/service_account_provider.dart';
import 'package:traqtrace_app/features/api_management/providers/partner_access_provider.dart';
import 'package:traqtrace_app/features/api_management/cubit/api_collection_cubit.dart';
import 'package:traqtrace_app/features/api_management/services/service_account_service.dart';

import 'package:traqtrace_app/core/di/injection.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Use path URL strategy for better web navigation
    configureUrlStrategy();

    // Create app config for proper environment
    final appConfig = AppConfig(
      apiBaseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:8080/api',
      ),
      appName: 'evotraq.io',
      appVersion: '1.0.0',
    );

    debugPrint('Initializing dependencies...');
    // Initialize dependency injection
    await initDependencies(appConfig);
    debugPrint('Dependencies initialized.');

    // Check auth status immediately
    debugPrint('Checking auth status...');
    try {
      getIt<AuthCubit>().checkAuth();
    } catch (e) {
      debugPrint('Auth check failed: $e');
    }

    // Initialize WebSocket with the base URL
    debugPrint('Initializing WebSocket...');
    try {
      getIt<WebSocketService>().initialize(appConfig.apiBaseUrl, '');
    } catch (e) {
      debugPrint('WebSocket initialization failed: $e');
    }

    debugPrint('Starting TraqTraceApp...');
    runApp(const TraqTraceApp());
  } catch (e, stackTrace) {
    debugPrint('FATAL ERROR DURING APP START: $e');
    debugPrint(stackTrace.toString());

    // Fallback UI so the screen isn't just blank
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SelectableText(
              'Failed to start application.\n\nError: $e\n\nCheck browser console for more details.',
            ),
          ),
        ),
      ),
    );
  }
}

class TraqTraceApp extends StatelessWidget {
  const TraqTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TransactionEventsProvider>(
          create: (context) =>
              TransactionEventsProvider(appConfig: getIt<AppConfig>()),
        ),
        ChangeNotifierProvider<TransformationEventsProvider>(
          create: (context) => TransformationEventsProvider(
            getIt<TransformationEventService>(),
            getIt<http.Client>(),
            getIt<TokenManager>(),
            getIt<AppConfig>(),
          ),
        ),
        ChangeNotifierProvider<ValidationServiceProvider>(
          create: (context) =>
              ValidationServiceProvider(appConfig: getIt<AppConfig>()),
        ),
        ChangeNotifierProvider<TransactionDocumentProvider>(
          create: (context) => TransactionDocumentProvider(
            service: getIt<TransactionDocumentService>(),
            appConfig: getIt<AppConfig>(),
          ),
        ),
        ChangeNotifierProvider<ValidationRuleProvider>(
          create: (context) =>
              ValidationRuleProvider(appConfig: getIt<AppConfig>()),
        ),
        ChangeNotifierProvider<TraversalQueryProvider>(
          create: (context) =>
              TraversalQueryProvider(getIt<AdvancedQueryService>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: getIt<AuthCubit>()),
          BlocProvider<AggregationEventsCubit>(
            create: (context) =>
                AggregationEventsCubit(appConfig: getIt<AppConfig>()),
          ),
          BlocProvider<ProfileCubit>(
            create: (context) =>
                ProfileCubit(userService: getIt<UserService>()),
          ),
          BlocProvider<ThemeCubit>(
            create: (context) =>
                ThemeCubit(profileCubit: context.read<ProfileCubit>()),
          ),
          BlocProvider<AdminCubit>(
            create: (context) =>
                AdminCubit(adminService: getIt<AdminService>()),
          ),
          // Add GTIN Cubit
          BlocProvider<GTINCubit>(
            create: (context) => GTINCubit(gtinService: getIt<GTINService>()),
          ),
          // Add GLN Cubit
          BlocProvider<GLNCubit>(
            create: (context) => GLNCubit(glnService: getIt<GLNService>()),
          ),
          BlocProvider<SSCCCubit>(
            create: (context) => SSCCCubit(ssccService: getIt<SSCCService>()),
          ),
          // Add SGTIN Cubit
          BlocProvider<SGTINCubit>(
            create: (context) =>
                SGTINCubit(sgtinService: getIt<SGTINService>()),
          ),
          BlocProvider<ApiCollectionCubit>(
            create: (context) => ApiCollectionCubit(
              httpClient: getIt<http.Client>(),
              tokenManager: getIt<TokenManager>(),
              appConfig: getIt<AppConfig>(),
            ),
          ),
          BlocProvider<ApiManagementCubit>(
            create: (context) => ApiManagementCubit(
              httpClient: getIt<http.Client>(),
              tokenManager: getIt<TokenManager>(),
              appConfig: getIt<AppConfig>(),
            ),
          ),
          BlocProvider<PartnerAccessCubit>(
            create: (context) => PartnerAccessCubit(
              httpClient: getIt<http.Client>(),
              tokenManager: getIt<TokenManager>(),
              appConfig: getIt<AppConfig>(),
            ),
          ),
          BlocProvider<ServiceAccountCubit>(
            create: (context) =>
                ServiceAccountCubit(service: getIt<ServiceAccountService>()),
          ),
          BlocProvider<ObjectEventsCubit>(
            create: (context) => ObjectEventsCubit(
              httpClient: getIt<http.Client>(),
              tokenManager: getIt<TokenManager>(),
              appConfig: getIt<AppConfig>(),
            ),
          ),
          BlocProvider<EPCISEventsCubit>(
            create: (context) => EPCISEventsCubit(getIt<EPCISEventService>()),
          ),
          BlocProvider<AdvancedQueryCubit>(
            create: (context) =>
                AdvancedQueryCubit(getIt<AdvancedQueryService>()),
          ),
          BlocProvider<ShippingOperationCubit>(
            create: (context) =>
                ShippingOperationCubit(getIt<ShippingOperationService>()),
          ),
          BlocProvider<SystemSettingsCubit>(
            create: (context) =>
                SystemSettingsCubit(getIt<SystemSettingsService>()),
          ),
          // Add Notification Cubit
          BlocProvider<NotificationCubit>(
            create: (context) => NotificationCubit(
              apiService: getIt<NotificationApiService>(),
              webSocketService: getIt<WebSocketService>(),
            ),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          buildWhen: (previous, current) =>
              previous.isDarkMode != current.isDarkMode,
          builder: (context, themeState) {
            return BlocListener<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state.isAuthenticated && state.user != null) {
                  context.read<SystemSettingsCubit>().initialize();
                } else if (!state.isAuthenticated) {
                  context.read<SystemSettingsCubit>().reset();
                }
              },
              child: MaterialApp.router(
                title: getIt<AppConfig>().appName,
                theme: AppTheme.lightTheme(),
                debugShowCheckedModeBanner: false,
                darkTheme: AppTheme.darkTheme(),
                themeMode: themeState.themeMode,
                routerConfig: getIt<AppRouter>().router,
              ),
            );
          },
        ),
      ),
    );
  }
}
