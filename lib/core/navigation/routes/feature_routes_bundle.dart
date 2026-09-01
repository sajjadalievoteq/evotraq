import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/navigation/routes/admin_routes.dart';
import 'package:traqtrace_app/core/navigation/routes/automation_routes.dart';
import 'package:traqtrace_app/core/navigation/routes/epcis_routes.dart';
import 'package:traqtrace_app/core/navigation/routes/fulfillment_operation_routes.dart';
import 'package:traqtrace_app/core/navigation/routes/gs1_routes.dart';
import 'package:traqtrace_app/core/navigation/routes/handling_operation_routes.dart';
import 'package:traqtrace_app/core/navigation/routes/notification_routes.dart';
import 'package:traqtrace_app/core/navigation/routes/route_access.dart';
import 'package:traqtrace_app/core/navigation/routes/tatmeen_routes.dart';
import 'package:traqtrace_app/core/navigation/routes/tool_routes.dart';

/// Feature routes loaded as a separate web chunk after core/auth startup.
List<RouteBase> featureRoutes(RouteAccess access) => [
  ...adminRoutes(access),
  ...automationRoutes(access),
  ...tatmeenRoutes(access),
  ...gs1Routes(),
  ...epcisRoutes(access),
  ...fulfillmentOperationRoutes(access),
  ...handlingOperationRoutes(access),
  ...notificationRoutes(),
  ...toolRoutes(),
];
