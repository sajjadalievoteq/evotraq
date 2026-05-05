import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:traqtrace_app/core/web/url_strategy_stub.dart'
    if (dart.library.html) 'package:traqtrace_app/core/web/url_strategy_web.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/config/app_router.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/core/theme/theme_cubit.dart';
import 'package:world_countries/world_countries.dart';

import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/epcis/cubit/aggregation_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/providers/transaction_events_provider.dart';
import 'package:traqtrace_app/features/epcis/providers/transaction_document_provider.dart';
import 'package:traqtrace_app/features/epcis/providers/transformation_events_provider.dart';

import 'package:traqtrace_app/features/epcis/cubit/object_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/epcis_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/shipping_operation_cubit.dart';

import 'package:traqtrace_app/features/gs1/bloc/sgtin/sgtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/bloc/sscc/sscc_cubit.dart';

import 'package:traqtrace_app/features/user_management/cubit/profile_cubit.dart';

import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_rule_provider.dart';
import 'package:traqtrace_app/features/epcis/cubit/advanced_query_cubit.dart';
import 'package:traqtrace_app/features/epcis/providers/traversal_query_provider.dart';
import 'package:traqtrace_app/data/services/advanced_query_service.dart';
// Notification imports
import 'package:traqtrace_app/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:traqtrace_app/data/services/notification_api_service.dart';

import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';
import 'package:traqtrace_app/shared/utils/app_screen_util.dart';
// Dashboard imports

import 'package:traqtrace_app/features/api_management/cubit/api_management_cubit.dart';
import 'package:traqtrace_app/features/api_management/providers/service_account_provider.dart';
import 'package:traqtrace_app/features/api_management/providers/partner_access_provider.dart';
import 'package:traqtrace_app/features/api_management/cubit/api_collection_cubit.dart';

import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/background_container_widget.dart';

import 'package:traqtrace_app/data/services/epcis_event_service.dart';
import 'package:traqtrace_app/data/services/service_account_service.dart';
import 'package:traqtrace_app/data/services/sgtin_service.dart';
import 'package:traqtrace_app/data/services/shipping_operation_service.dart';
import 'package:traqtrace_app/data/services/sscc_service.dart';
import 'package:traqtrace_app/data/services/system_settings_service.dart';
import 'package:traqtrace_app/data/services/user_service.dart';
import 'package:traqtrace_app/data/services/websocket_service.dart';

import 'core/network/dio_service.dart';

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

    debugPrint('Starting TraqTraceApp...');
    runApp(const TraqTraceApp());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('Initializing WebSocket...');
      try {
        getIt<WebSocketService>().initialize(appConfig.apiBaseUrl, '');
      } catch (e) {
        debugPrint('WebSocket initialization failed: $e');
      }
    });
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: getIt<AuthCubit>()),
        BlocProvider<TransactionEventsCubit>(
          create: (context) =>
              TransactionEventsCubit(),
        ),
        BlocProvider<TransformationEventsCubit>(
          create: (context) =>
              TransformationEventsCubit(),
        ),
        BlocProvider<ValidationCubit>(
          create: (context) => ValidationCubit(),
        ),
        BlocProvider<TransactionDocumentCubit>(
          create: (context) =>
              TransactionDocumentCubit(appConfig: getIt<AppConfig>()),
        ),
        BlocProvider<ValidationRuleCubit>(
          create: (context) => ValidationRuleCubit(),
        ),
        BlocProvider<TraversalQueryCubit>(
          create: (context) =>
              TraversalQueryCubit(getIt<AdvancedQueryService>()),
        ),
        BlocProvider<AggregationEventsCubit>(
          create: (context) =>
              AggregationEventsCubit(),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(userService: getIt<UserService>()),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) =>
              ThemeCubit(profileCubit: context.read<ProfileCubit>()),
        ),
        BlocProvider<SSCCCubit>(
          create: (context) => SSCCCubit(ssccService: getIt<SSCCService>()),
        ),
        // Add SGTIN Cubit
        BlocProvider<SGTINCubit>(
          create: (context) => SGTINCubit(sgtinService: getIt<SGTINService>()),
        ),
        BlocProvider<ApiCollectionCubit>(
          create: (context) =>
              ApiCollectionCubit(dioService: getIt<DioService>()),
        ),
        BlocProvider<ApiManagementCubit>(
          create: (context) =>
              ApiManagementCubit(dioService: getIt<DioService>()),
        ),
        BlocProvider<PartnerAccessCubit>(
          create: (context) =>
              PartnerAccessCubit(dioService: getIt<DioService>()),
        ),
        BlocProvider<ServiceAccountCubit>(
          create: (context) =>
              ServiceAccountCubit(service: getIt<ServiceAccountService>()),
        ),
        BlocProvider<ObjectEventsCubit>(
          create: (context) => ObjectEventsCubit(),
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
              localizationsDelegates: const [
                ...GlobalMaterialLocalizations.delegates,
                TypedLocaleDelegate(),
              ],
              builder: (context, child) => AppScreenUtilInit(
                child: AppLayoutBuilder(
                  builder: (context, layout) => Stack(
                    fit: StackFit.expand,
                    children: [
                      const AppBackgroundLayer(),
                      child ?? const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
