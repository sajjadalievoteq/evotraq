import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/epcis/cubit/epcis_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/services/epcis_event_service_impl.dart';

/// Factory for creating EPCIS-related providers
class EPCISProviders {
  
  /// Create all EPCIS providers
  static List<SingleChildWidget> providers() {
    return [
      BlocProvider<EPCISEventsCubit>(
        create: (context) => EPCISEventsCubit(
          EPCISEventServiceImpl(
            httpClient: http.Client(),
            tokenManager: Provider.of<TokenManager>(context, listen: false),
            appConfig: Provider.of<AppConfig>(context, listen: false),
          ),
        ),
      ),
    ];
  }
}
