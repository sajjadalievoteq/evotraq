import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_route_constants.dart';

/// Centralized application constants: routes, API paths, and assets.
/// Prefer importing this library from `core/consts/app_consts.dart`.
class Constants {
  // app branding
  static const String appName = 'evotraq.io';
  static const String appTagline = 'GS1-compliant track and trace system';

  // layout
  /// Standard max width for primary screen content.
  static const double maxContentWidth = 800;
  static const double spacing = 16;
  static const double cardRadius = 20;
  static const double sectionMaxWidth = 1280;
  static const double dialogMaxWidth = 720;
  static const EdgeInsets sectionPadding = EdgeInsets.all(20);

  // page routes
  // auth routes
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String authResetPasswordRoute = '/reset-password';
  static const String resetPasswordRoute = '/auth/reset-password';
  static const String verifyEmailRoute = '/auth/verify-email';
  static const String verifyEmailAliasRoute = '/verify-email';
  static const String checkEmailRoute = '/check-email';

  // main routes
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';

  // dashboard routes
  static const String journeyDashboardRoute = '/dashboards/journey';

  // admin routes
  static const String adminUsersRoute = '/admin/users';
  static const String adminApprovalsRoute = '/admin/approvals';
  static const String adminSettingsRoute = '/admin/settings';
  static const String adminGs1ValidationRoute = '/admin/gs1-validation';
  static const String adminPerformanceTestsRoute = '/admin/performance-tests';
  static const String adminPerformanceOptimizationRoute =
      '/admin/performance-optimization';
  static const String adminMonitoringRoute = '/admin/monitoring';
  static const String adminIntegrationValidationRoute =
      '/admin/integration-validation';
  static const String adminEventGenerationTestRoute =
      '/admin/event-generation-test';
  static const String adminIndustryTestDataRoute = '/admin/industry-test-data';
  static const String adminValidationRulesRoute = '/admin/validation-rules';
  static const String adminValidationRulesHelpRoute =
      '/admin/validation-rules/help';
  static const String adminValidationRulesNewRoute =
      '/admin/validation-rules/new/:ruleId';
  static const String adminValidationRulesEditRoute =
      '/admin/validation-rules/:ruleId/edit';
  static const String adminDatabasePartitioningRoute =
      '/admin/database-partitioning';
  static const String adminCacheRoute = '/admin/cache';
  static const String adminJobQueueRoute = '/admin/job-queue';
  static const String adminEtlManagementRoute = '/admin/etl-management';
  static const String adminBulkExportRoute = '/admin/bulk-export';
  static const String adminDataConsistencyIntegrityRoute =
      '/admin/data-consistency-integrity';

  // admin api management routes
  static const String adminApiPartnersRoute = '/admin/api-management/partners';
  static const String adminApiPartnerDetailRoute =
      '/admin/api-management/partners/:partnerId';
  static const String adminApiPartnerCredentialsRoute =
      '/admin/api-management/partners/:partnerId/credentials';
  static const String adminApiPartnerAnalyticsRoute =
      '/admin/api-management/partners/:partnerId/analytics';
  static const String adminApiServiceAccountsRoute =
      '/admin/api-management/service-accounts';
  static const String adminApiCollectionsRoute =
      '/admin/api-management/collections';
  static const String adminApiPartnerAccessRoute =
      '/admin/api-management/partners/:partnerId/access';
  static const String adminApiAccessRoute = '/admin/api-management/access';

  // gs1 routes
  static const String gs1GtinsRoute = '/gs1/gtins';
  static const String gs1GtinNewRoute = '/gs1/gtins/new';
  static const String gs1GtinDetailRoute = '/gs1/gtins/:gtinCode';
  static const String gs1GtinEditRoute = '/gs1/gtins/:gtinCode/edit';
  static const String gs1GlnsRoute = GlnRouteConstants.base;
  static const String gs1GlnNewRoute = GlnRouteConstants.newGln;
  static const String gs1GlnDetailRoute = GlnRouteConstants.detail;
  static const String gs1GlnEditRoute = GlnRouteConstants.edit;
  static const String gs1SsccsRoute = '/gs1/ssccs';
  static const String gs1SsccNewRoute = '/gs1/ssccs/new';
  static const String gs1SsccDetailRoute = '/gs1/ssccs/:ssccId';
  static const String gs1SsccEditRoute = '/gs1/ssccs/:ssccId/edit';
  static const String gs1SgtinsRoute = '/gs1/sgtins';
  static const String gs1SgtinNewRoute = '/gs1/sgtins/new';
  static const String gs1SgtinDetailRoute = '/gs1/sgtins/:id';
  static const String gs1SgtinEditRoute = '/gs1/sgtins/:id/edit';
  static const String gs1EpcConversionRoute = '/gs1/epc-conversion';
  static const String gs1ValidationDemoRoute = '/gs1/validation-demo';

  // epcis routes
  static const String epcisEventsRoute = '/epcis/events';
  static const String epcisObjectEventsRoute = '/epcis/object-events';
  static const String epcisAggregationEventsRoute = '/epcis/aggregation-events';
  static const String epcisTransactionEventsRoute = '/epcis/transaction-events';
  static const String epcisTransformationEventsRoute =
      '/epcis/transformation-events';
  static const String epcisAdvancedQueryRoute = '/epcis/advanced-query';
  static const String epcisTraversalQueryRoute = '/epcis/traversal-query';
  static const String epcisSerializationRoute = '/epcis/serialization';
  static const String epcisObjectEventNewRoute = '/epcis/object-events/new';
  static const String epcisObjectEventBatchImportRoute =
      '/epcis/object-events/batch-import';
  static const String epcisAggregationEventNewRoute =
      '/epcis/aggregation-events/new';
  static const String epcisTransactionEventNewRoute =
      '/epcis/transaction-events/new';
  static const String epcisTransactionEventHelpRoute =
      '/epcis/transaction-events/help';
  static const String epcisTransformationEventNewRoute =
      '/epcis/transformation-events/new';
  static const String epcisEventDetailRoute = '/epcis/events/:id';
  static const String epcisObjectEventDetailRoute = '/epcis/object-events/:id';
  static const String epcisAggregationEventDetailRoute =
      '/epcis/aggregation-events/:id';
  static const String epcisTransactionEventDetailRoute =
      '/epcis/transaction-events/:id';
  static const String epcisTransactionDocumentsRoute =
      '/epcis/transaction-documents';
  static const String epcisTransactionDocumentHelpRoute =
      '/epcis/transaction-documents/help';
  static const String epcisTransformationEventDetailRoute =
      '/epcis/transformation-events/:id';
  static const String epcisAggregationEventHierarchyRoute =
      '/epcis/aggregation-events/hierarchy/:epc';

  // operations routes
  static const String opShippingRoute = '/operations/shipping';
  static const String opShippingCreateRoute = '/operations/shipping/create';
  static const String opShippingDetailRoute =
      '/operations/shipping/:operationId';
  static const String opReceivingRoute = '/operations/receiving';
  static const String opReceivingCreateRoute = '/operations/receiving/create';
  static const String opReceivingDetailRoute =
      '/operations/receiving/:operationId';
  static const String opPackingRoute = '/operations/packing';
  static const String opPackingCreateRoute = '/operations/packing/create';
  static const String opPackingDetailRoute =
      '/operations/packing/:operationId';
  static const String opCommissioningRoute = '/operations/commissioning';
  static const String opCommissioningNewRoute = '/operations/commissioning/new';
  static const String opCommissioningDetailRoute =
      '/operations/commissioning/:operationId';

  // notification routes
  static const String notificationsRoute = '/notifications';
  static const String notificationSubscriptionsRoute =
      '/notifications/subscriptions';
  static const String notificationDetailRoute =
      '/notifications/:subscriptionId';
  static const String notificationWebhooksRoute = '/notifications/webhooks';

  // barcode routes
  static const String barcodeScanRoute = '/barcode/scan';
  static const String barcodeGenerateRoute = '/barcode/generate';
  static const String barcodeVerifyRoute = '/barcode/verify';

  // demo routes
  static const String demoValidationRulesRoute = '/demo/validation-rules';

  // API endpoints
  static const String authLoginEndpoint = '/auth/login';
  static const String authRegisterEndpoint = '/auth/register';
  static const String authCheckUsernameEndpoint = '/auth/check-username';
  static const String authResendVerificationEmailEndpoint =
      '/auth/resend-verification-email';
  static const String authPasswordResetRequestEndpoint =
      '/auth/password-reset-request';
  static const String authValidateResetTokenEndpoint =
      '/auth/validate-reset-token';
  static const String authResetPasswordEndpoint = '/auth/reset-password';
  static const String verificationVerifyEmailEndpoint =
      '/verification/verify-email';
  static const String usersProfileEndpoint = '/users/profile';
  static const String adminUsersEndpoint = '/admin/users';
  static const String adminApprovalsEndpoint = '/admin/approvals';

  // assets
  // images
  static const String logoImage = 'assets/images/logo.png';
  static const String loginBackground = 'assets/images/background_image.png';

  // Icons
  static const String iconImage = 'assets/icons/icon_app.png';
}
