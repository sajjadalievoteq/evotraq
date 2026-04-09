/// API Management feature for B2B partner integration
/// 
/// This module provides functionality to manage B2B partners, their API credentials,
/// rate limiting, usage analytics, and internal service accounts.

// Models
export 'models/partner.dart';
export 'models/partner_credential.dart';
export 'models/api_audit.dart';
export 'models/service_account.dart';

// Services
export 'services/api_management_service.dart';
export 'services/service_account_service.dart';

// Providers & Cubits
export 'providers/service_account_provider.dart';
export 'cubit/api_management_cubit.dart';
export 'cubit/api_collection_cubit.dart';
export 'cubit/api_collection_state.dart';

// Screens
export 'screens/partner_management_screen.dart';
export 'screens/credential_management_screen.dart';
export 'screens/api_analytics_screen.dart';
export 'screens/service_account_management_screen.dart';

// Widgets
export 'widgets/create_partner_dialog.dart';
