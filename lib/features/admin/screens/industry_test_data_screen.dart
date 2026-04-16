import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';

import '../../../core/network/dio_service.dart';
import '../../../data/services/industry_test_data_service.dart';

/// Screen for generating industry-specific test data (Tobacco and Pharmaceutical)
/// This creates real product data with accurate specifications for the UAE market
class IndustryTestDataScreen extends StatefulWidget {
  const IndustryTestDataScreen({Key? key}) : super(key: key);

  @override
  State<IndustryTestDataScreen> createState() => _IndustryTestDataScreenState();
}

class _IndustryTestDataScreenState extends State<IndustryTestDataScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  IndustryTestDataService? _testDataService;
  bool _isLoading = false;
  String? _statusMessage;
  bool _isError = false;
  
  // Progress tracking
  int _gtinProgress = 0;
  int _gtinTotal = 0;
  int _glnProgress = 0;
  int _glnTotal = 0;
  int _sgtinProgress = 0;
  int _sgtinTotal = 0;
  int _ssccProgress = 0;
  int _ssccTotal = 0;
  int _eventProgress = 0;
  int _eventTotal = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _testDataService ??= IndustryTestDataService( tokenManager: getIt<TokenManager>(), appConfig: getIt<AppConfig>()
 
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setStatus(String message, {bool isError = false}) {
    setState(() {
      _statusMessage = message;
      _isError = isError;
    });
  }

  Future<void> _generateTobaccoGTINs() async {
    if (_testDataService == null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _gtinProgress = 0;
      _gtinTotal = 50;
      _statusMessage = 'Starting GTIN generation for tobacco products...';
      _isError = false;
    });

    try {
      await _testDataService!.generateTobaccoGTINs(
        onProgress: (current, total, productName) {
          setState(() {
            _gtinProgress = current;
            _gtinTotal = total;
            _statusMessage = 'Creating GTIN $current/$total: $productName';
          });
        },
      );

      _setStatus('Successfully created $_gtinTotal tobacco GTINs with extensions!');
    } catch (e) {
      _setStatus('Error generating tobacco GTINs: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateTobaccoGLNs() async {
    if (_testDataService == null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _glnProgress = 0;
      _glnTotal = 50;
      _statusMessage = 'Starting GLN generation for tobacco locations...';
      _isError = false;
    });

    try {
      await _testDataService!.generateTobaccoGLNs(
        onProgress: (current, total, locationName) {
          setState(() {
            _glnProgress = current;
            _glnTotal = total;
            _statusMessage = 'Creating GLN $current/$total: $locationName';
          });
        },
      );

      _setStatus('Successfully created $_glnTotal tobacco GLNs with extensions!');
    } catch (e) {
      _setStatus('Error generating tobacco GLNs: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateTobaccoSGTINs() async {
    if (_testDataService == null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _sgtinProgress = 0;
      _sgtinTotal = 500; // 50 GTINs × 10 SGTINs each
      _statusMessage = 'Starting SGTIN generation for tobacco products...';
      _isError = false;
    });

    try {
      await _testDataService!.generateTobaccoSGTINs(
        onProgress: (current, total, productInfo) {
          setState(() {
            _sgtinProgress = current;
            _sgtinTotal = total;
            _statusMessage = 'Creating SGTIN $current/$total: $productInfo';
          });
        },
      );

      _setStatus('Successfully created $_sgtinTotal tobacco SGTINs with batch info!');
    } catch (e) {
      _setStatus('Error generating tobacco SGTINs: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateTobaccoSSCCs() async {
    if (_testDataService == null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _ssccProgress = 0;
      _ssccTotal = 50;
      _statusMessage = 'Starting SSCC generation for tobacco containers...';
      _isError = false;
    });

    try {
      await _testDataService!.generateTobaccoSSCCs(
        onProgress: (current, total, containerInfo) {
          setState(() {
            _ssccProgress = current;
            _ssccTotal = total;
            _statusMessage = 'Creating SSCC $current/$total: $containerInfo';
          });
        },
      );

      _setStatus('Successfully created $_ssccTotal tobacco SSCCs with extensions!');
    } catch (e) {
      _setStatus('Error generating tobacco SSCCs: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateTobaccoEvents() async {
    if (_testDataService == null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _eventProgress = 0;
      _eventTotal = 200;
      _statusMessage = 'Starting EPCIS event generation for tobacco supply chain...';
      _isError = false;
    });

    try {
      await _testDataService!.generateTobaccoEvents(
        onProgress: (current, total, eventInfo) {
          setState(() {
            _eventProgress = current;
            _eventTotal = total;
            _statusMessage = 'Creating Event $current/$total: $eventInfo';
          });
        },
      );

      _setStatus('Successfully created $_eventTotal EPCIS events for full supply chain!');
    } catch (e) {
      _setStatus('Error generating tobacco events: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePharmaGTINs() async {
    if (_testDataService == null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _gtinProgress = 0;
      _gtinTotal = 50;
      _statusMessage = 'Starting GTIN generation for pharmaceutical products...';
      _isError = false;
    });

    try {
      await _testDataService!.generatePharmaGTINs(
        onProgress: (current, total, productName) {
          setState(() {
            _gtinProgress = current;
            _gtinTotal = total;
            _statusMessage = 'Creating GTIN $current/$total: $productName';
          });
        },
      );

      _setStatus('Successfully created $_gtinTotal pharmaceutical GTINs with extensions!');
    } catch (e) {
      _setStatus('Error generating pharmaceutical GTINs: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePharmaGLNs() async {
    if (_testDataService == null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _glnProgress = 0;
      _glnTotal = 50;
      _statusMessage = 'Starting GLN generation for pharmaceutical locations...';
      _isError = false;
    });

    try {
      await _testDataService!.generatePharmaGLNs(
        onProgress: (current, total, locationName) {
          setState(() {
            _glnProgress = current;
            _glnTotal = total;
            _statusMessage = 'Creating GLN $current/$total: $locationName';
          });
        },
      );

      _setStatus('Successfully created $_glnTotal pharmaceutical GLNs with extensions!');
    } catch (e) {
      _setStatus('Error generating pharmaceutical GLNs: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePharmaSGTINs() async {
    if (_testDataService == null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _sgtinProgress = 0;
      _sgtinTotal = 100;
      _statusMessage = 'Starting SGTIN generation for pharmaceutical products...';
      _isError = false;
    });

    try {
      await _testDataService!.generatePharmaSGTINs(
        onProgress: (current, total, productInfo) {
          setState(() {
            _sgtinProgress = current;
            _sgtinTotal = total;
            _statusMessage = 'Creating SGTIN $current/$total: $productInfo';
          });
        },
      );

      _setStatus('Successfully created $_sgtinTotal pharmaceutical SGTINs!');
    } catch (e) {
      _setStatus('Error generating pharmaceutical SGTINs: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePharmaSSCCs() async {
    if (_testDataService == null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _ssccProgress = 0;
      _ssccTotal = 50;
      _statusMessage = 'Starting SSCC generation for pharmaceutical containers...';
      _isError = false;
    });

    try {
      await _testDataService!.generatePharmaSSCCs(
        onProgress: (current, total, containerInfo) {
          setState(() {
            _ssccProgress = current;
            _ssccTotal = total;
            _statusMessage = 'Creating SSCC $current/$total: $containerInfo';
          });
        },
      );

      _setStatus('Successfully created $_ssccTotal pharmaceutical SSCCs with extensions!');
    } catch (e) {
      _setStatus('Error generating pharmaceutical SSCCs: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePharmaEvents() async {
    if (_testDataService == null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _eventProgress = 0;
      _eventTotal = 200;
      _statusMessage = 'Starting EPCIS event generation for pharmaceutical supply chain...';
      _isError = false;
    });

    try {
      await _testDataService!.generatePharmaEvents(
        onProgress: (current, total, eventInfo) {
          setState(() {
            _eventProgress = current;
            _eventTotal = total;
            _statusMessage = 'Creating Event $current/$total: $eventInfo';
          });
        },
      );

      _setStatus('Successfully created $_eventTotal EPCIS events for pharmaceutical supply chain!');
    } catch (e) {
      _setStatus('Error generating pharmaceutical events: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Industry Test Data Generation'),
        backgroundColor: isDarkMode ? AppTheme.primaryColorDark : AppTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.local_florist),
              text: 'Tobacco',
            ),
            Tab(
              icon: Icon(Icons.medical_services),
              text: 'Pharmaceutical',
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Status bar
          if (_statusMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: _isError 
                  ? Colors.red.shade100 
                  : Colors.green.shade100,
              child: Row(
                children: [
                  Icon(
                    _isError ? Icons.error : Icons.info,
                    color: _isError ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _statusMessage!,
                      style: TextStyle(
                        color: _isError ? Colors.red.shade900 : Colors.green.shade900,
                      ),
                    ),
                  ),
                  if (_isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
          
          // Progress bar
          if (_isLoading && (_gtinProgress > 0 || _glnProgress > 0 || _sgtinProgress > 0 || _ssccProgress > 0 || _eventProgress > 0))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  if (_gtinProgress > 0)
                    LinearProgressIndicator(
                      value: _gtinTotal > 0 ? _gtinProgress / _gtinTotal : 0,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkMode ? AppTheme.accentColorDark : AppTheme.accentColor,
                      ),
                    ),
                  if (_glnProgress > 0)
                    LinearProgressIndicator(
                      value: _glnTotal > 0 ? _glnProgress / _glnTotal : 0,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkMode ? AppTheme.accentColorDark : AppTheme.accentColor,
                      ),
                    ),
                  if (_sgtinProgress > 0)
                    LinearProgressIndicator(
                      value: _sgtinTotal > 0 ? _sgtinProgress / _sgtinTotal : 0,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkMode ? AppTheme.accentColorDark : AppTheme.accentColor,
                      ),
                    ),
                  if (_ssccProgress > 0)
                    LinearProgressIndicator(
                      value: _ssccTotal > 0 ? _ssccProgress / _ssccTotal : 0,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkMode ? AppTheme.accentColorDark : AppTheme.accentColor,
                      ),
                    ),
                  if (_eventProgress > 0)
                    LinearProgressIndicator(
                      value: _eventTotal > 0 ? _eventProgress / _eventTotal : 0,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkMode ? AppTheme.accentColorDark : AppTheme.accentColor,
                      ),
                    ),
                ],
              ),
            ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTobaccoTab(isDarkMode),
                _buildPharmaTab(isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTobaccoTab(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            elevation: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.brown.shade700, Colors.brown.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_florist, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      const Text(
                        'Tobacco Industry Test Data',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Generate real tobacco product data for the UAE market. '
                    'This includes major brands like Marlboro, Dunhill, Kent, Winston, '
                    'Davidoff, and more with accurate specifications.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Master Data Section
          _buildSectionHeader('Master Data Generation', Icons.dataset),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  title: 'Generate GTINs',
                  description: 'Create 50 tobacco product GTINs with complete '
                      'tobacco extension data (brand, tar, nicotine, etc.)',
                  icon: Icons.qr_code,
                  color: Colors.brown,
                  onPressed: _isLoading ? null : _generateTobaccoGTINs,
                  buttonText: 'Generate 50 GTINs',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  title: 'Generate GLNs',
                  description: 'Create 50 tobacco-related location GLNs '
                      '(factories, warehouses, distributors, retailers)',
                  icon: Icons.location_on,
                  color: Colors.brown,
                  onPressed: _isLoading ? null : _generateTobaccoGLNs,
                  buttonText: 'Generate 50 GLNs',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Serialization Section
          _buildSectionHeader('Serialization', Icons.numbers),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  title: 'Generate SGTINs',
                  description: 'Create 500 serialized tobacco items (10 per GTIN) '
                      'with batch numbers, production dates, and expiry dates',
                  icon: Icons.qr_code_scanner,
                  color: Colors.brown,
                  onPressed: _isLoading ? null : _generateTobaccoSGTINs,
                  buttonText: 'Generate 500 SGTINs',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  title: 'Generate SSCCs',
                  description: 'Create 50 shipping containers (pallets, cases, cartons) '
                      'with tax stamp aggregation and UAE compliance data',
                  icon: Icons.inventory,
                  color: Colors.brown,
                  onPressed: _isLoading ? null : _generateTobaccoSSCCs,
                  buttonText: 'Generate 50 SSCCs',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Events Section
          _buildSectionHeader('EPCIS Events - Full Supply Chain', Icons.event),
          const SizedBox(height: 12),
          
          _buildActionCard(
            title: 'Generate Complete Event Lifecycle',
            description: 'Create EPCIS events for the full tobacco supply chain:\n'
                '• Commissioning: Items created at manufacturer\n'
                '• Packing/Aggregation: Items packed into SSCCs\n'
                '• Shipping: Manufacturer → Distributor → Retailer\n'
                '• Receiving: At each destination location',
            icon: Icons.timeline,
            color: Colors.brown.shade600,
            onPressed: _isLoading ? null : _generateTobaccoEvents,
            buttonText: 'Generate ~200 Events',
          ),
          
          const SizedBox(height: 16),
          
          // Event type info chips
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildEventTypeChip('Object Events', Icons.inventory_2, Colors.blue),
              _buildEventTypeChip('Aggregation Events', Icons.category, Colors.green),
              _buildEventTypeChip('Shipping Events', Icons.local_shipping, Colors.orange),
              _buildEventTypeChip('Receiving Events', Icons.move_to_inbox, Colors.purple),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Product Info
          _buildProductInfoCard(),
        ],
      ),
    );
  }

  Widget _buildPharmaTab(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            elevation: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF121F17), const Color(0xFF2D4A3E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.medical_services, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      const Text(
                        'Pharmaceutical Industry Test Data',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Generate real pharmaceutical product data for the UAE market. '
                    'This includes major medications with accurate specifications.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Master Data Section
          _buildSectionHeader('Master Data Generation', Icons.dataset),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  title: 'Generate GTINs',
                  description: 'Create 50 pharmaceutical product GTINs with complete '
                      'pharma extension data (active ingredient, dosage, etc.)',
                  icon: Icons.qr_code,
                  color: const Color(0xFF2D4A3E),
                  onPressed: _isLoading ? null : _generatePharmaGTINs,
                  buttonText: 'Generate 50 GTINs',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  title: 'Generate GLNs',
                  description: 'Create 50 pharmaceutical-related location GLNs '
                      '(manufacturers, wholesalers, pharmacies, hospitals)',
                  icon: Icons.location_on,
                  color: const Color(0xFF2D4A3E),
                  onPressed: _isLoading ? null : _generatePharmaGLNs,
                  buttonText: 'Generate 50 GLNs',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Serialization Section
          _buildSectionHeader('Serialization', Icons.numbers),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  title: 'Generate SSCCs',
                  description: 'Create shipping containers with pharma extension data '
                      '(temperature control, batch tracking)',
                  icon: Icons.inventory,
                  color: const Color(0xFF2D4A3E),
                  onPressed: _isLoading ? null : _generatePharmaSSCCs,
                  buttonText: 'Generate 50 SSCCs',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  title: 'Generate SGTINs',
                  description: 'Create serialized pharmaceutical products with batch, '
                      'expiry date, and lot number',
                  icon: Icons.qr_code_scanner,
                  color: const Color(0xFF2D4A3E),
                  onPressed: _isLoading ? null : _generatePharmaSGTINs,
                  buttonText: 'Generate SGTINs',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Events Section
          _buildSectionHeader('EPCIS Events', Icons.event),
          const SizedBox(height: 12),
          
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D4A3E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.event, color: Color(0xFF2D4A3E), size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Generate Full Supply Chain',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Create complete pharmaceutical supply chain EPCIS events:\n'
                    '• Commissioning events (manufacturing)\n'
                    '• Aggregation events (packing)\n'
                    '• Shipping events (manufacturer → distributor → pharmacy)\n'
                    '• Receiving events (at each location)\n'
                    'All events include proper pharmaceutical compliance data.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _generatePharmaEvents,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Generate Supply Chain Events'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D4A3E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    required String buttonText,
    bool isDisabled = false,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDisabled ? Colors.grey : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: isDisabled ? Colors.grey : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPressed,
                icon: Icon(isDisabled ? Icons.lock : Icons.play_arrow),
                label: Text(buttonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDisabled ? Colors.grey.shade300 : color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallActionCard({
    required String title,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 160,
      child: Card(
        elevation: 1,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: onPressed != null ? Colors.brown : Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: onPressed != null ? null : Colors.grey,
                  ),
                ),
                if (onPressed == null)
                  const Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfoCard() {
    return Card(
      elevation: 1,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Included Tobacco Brands (UAE Market)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildBrandChip('Marlboro'),
                _buildBrandChip('Dunhill'),
                _buildBrandChip('Kent'),
                _buildBrandChip('Winston'),
                _buildBrandChip('Davidoff'),
                _buildBrandChip('Rothmans'),
                _buildBrandChip('Parliament'),
                _buildBrandChip('L&M'),
                _buildBrandChip('Camel'),
                _buildBrandChip('Lucky Strike'),
                _buildBrandChip('Pall Mall'),
                _buildBrandChip('Benson & Hedges'),
                _buildBrandChip('Vogue'),
                _buildBrandChip('Esse'),
                _buildBrandChip('Mevius'),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Each GTIN includes: Brand family, variant, tar/nicotine/CO content, '
              'pack type, filter type, units per pack, country of origin, intended market (UAE), '
              'max retail price (AED), curing method, and more.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandChip(String brand) {
    return Chip(
      label: Text(
        brand,
        style: const TextStyle(fontSize: 11),
      ),
      backgroundColor: Colors.brown.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildEventTypeChip(String label, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(fontSize: 11, color: color),
      ),
      backgroundColor: color.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
