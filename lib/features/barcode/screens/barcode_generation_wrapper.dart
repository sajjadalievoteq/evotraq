import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/barcode/screens/barcode_generation_screen.dart';
import 'package:traqtrace_app/features/barcode/services/barcode_generation_service.dart';

/// A wrapper widget that provides the necessary services for barcode generation
class BarcodeGenerationWrapper extends StatelessWidget {
  const BarcodeGenerationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get global providers
    final appConfig = Provider.of<AppConfig>(context, listen: false);
    final tokenManager = Provider.of<TokenManager>(context, listen: false);
    
    // Create the barcode service
    final barcodeService = BarcodeGenerationService(
      client: http.Client(),
      tokenManager: tokenManager,
      appConfig: appConfig,
    );
    
    // Provide the service to the screen
    return Provider<BarcodeGenerationService>.value(
      value: barcodeService,
      child: const BarcodeGenerationScreen(),
    );
  }
}
