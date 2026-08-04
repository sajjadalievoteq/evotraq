import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/data/services/admin/industry_test_data_service.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/admin/screens/industry_test_data/widgets/industry_pharma_tab.dart';

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

  final TextEditingController _hierarchyLevelsController =
      TextEditingController(text: '10');
  final TextEditingController _hierarchyChildrenController =
      TextEditingController(text: '100');
  String? _lastHierarchyRunId;
  String? _lastHierarchyRootEpc;
  String? _lastHierarchyRootSscc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _testDataService ??= getIt<IndustryTestDataService>();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hierarchyLevelsController.dispose();
    _hierarchyChildrenController.dispose();
    super.dispose();
  }

  void _setStatus(String message, {bool isError = false}) {
    setState(() {
      _statusMessage = message;
      _isError = isError;
    });
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

  Future<void> _generatePharmaFullSupplyChain() async {
    if (_testDataService == null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _eventProgress = 0;
      _eventTotal = 3;
      _statusMessage =
          'Generating connected pharma supply chain (master data + operations). '
          'This can take several minutes…';
      _isError = false;
    });

    try {
      final result = await _testDataService!.generatePharmaFullConnectedSupplyChain(
        onProgress: (current, total, status) {
          setState(() {
            _eventProgress = current;
            _eventTotal = total;
            _statusMessage = status;
          });
        },
      );
      final shipping = result['shippingOperationsCreated'] ?? 0;
      final receiving = result['receivingOperationsCreated'] ?? 0;
      final inTransit = result['inTransitShipmentsOpen'] ?? 0;
      final commissioning = result['commissioningBatchesCreated'] ?? 0;
      final errCount = (result['errors'] is List)
          ? (result['errors'] as List).length
          : 0;
      _setStatus(
        'Connected supply chain ready: $commissioning commissioning, '
        '$shipping ship, $receiving receive, $inTransit open in-transit. '
        '${errCount > 0 ? "$errCount warning(s) — non-fatal; check server logs. " : ""}'
        'Set operational GLN to seeded distributor/pharmacy for Inbox/Outbox.',
        isError: errCount > 0 && receiving == 0,
      );
    } catch (e) {
      _setStatus(
        'Error generating connected supply chain: ${e.toString()}',
        isError: true,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePackedHierarchy() async {
    if (_testDataService == null || _isLoading) return;

    final levels = int.tryParse(_hierarchyLevelsController.text.trim());
    final children = int.tryParse(_hierarchyChildrenController.text.trim());
    if (levels == null || levels < 1 || levels > 12) {
      _setStatus('Levels must be an integer from 1 to 12.', isError: true);
      return;
    }
    if (children == null || children < 1 || children > 200) {
      _setStatus(
        'Children per level must be an integer from 1 to 200.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _eventProgress = 0;
      _eventTotal = 2;
      _statusMessage =
          'Generating packed hierarchy (depth $levels, $children children/level)…';
      _isError = false;
    });

    try {
      final result = await _testDataService!.generatePackedHierarchy(
        levels: levels,
        childrenPerLevel: children,
        onProgress: (current, total, status) {
          setState(() {
            _eventProgress = current;
            _eventTotal = total;
            _statusMessage = status;
          });
        },
      );

      final runId = result['runId']?.toString();
      final rootEpc = result['rootEpc']?.toString();
      final rootSscc = result['rootSsccCode']?.toString();
      final depth = (result['depth'] as num?)?.toInt() ?? levels;
      final sscc = (result['totalSscc'] as num?)?.toInt() ?? 0;
      final sgtin = (result['totalSgtin'] as num?)?.toInt() ?? 0;
      final ms = (result['processingTimeMs'] as num?)?.toInt() ?? 0;

      setState(() {
        _lastHierarchyRunId = runId;
        _lastHierarchyRootEpc = rootEpc;
        _lastHierarchyRootSscc = rootSscc;
      });

      final searchHint = (rootSscc != null && rootSscc.isNotEmpty)
          ? rootSscc
          : (rootEpc ?? '');
      _setStatus(
        'Hierarchy ready — search this root in Product Hierarchy:\n'
        '$searchHint\n\n'
        'depth $depth · $sscc SSCC / $sgtin SGTIN · ${ms}ms · runId=$runId',
      );
    } catch (e) {
      _setStatus(
        'Error generating packed hierarchy: ${e.toString()}',
        isError: true,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanupPackedHierarchy() async {
    if (_testDataService == null || _isLoading) return;
    final runId = _lastHierarchyRunId;
    if (runId == null || runId.isEmpty) {
      _setStatus(
        'No hierarchy runId yet — generate one first, or paste a known runId.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Cleaning up hierarchy runId=$runId…';
      _isError = false;
    });

    try {
      final result = await _testDataService!.cleanupPackedHierarchy(runId: runId);
      final deleted = (result['deletedRows'] as num?)?.toInt() ?? 0;
      setState(() {
        _lastHierarchyRunId = null;
        _lastHierarchyRootEpc = null;
        _lastHierarchyRootSscc = null;
      });
      _setStatus('Hierarchy cleanup done — ≈$deleted rows removed for runId=$runId.');
    } catch (e) {
      _setStatus(
        'Error cleaning hierarchy: ${e.toString()}',
        isError: true,
      );
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: TraqIcon(AppAssets.iconMedical),
              text: 'Pharmaceutical',
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          if (_statusMessage != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: Material(
                color: _isError
                    ? AppColorMapper.errorColor(context).withValues(alpha: 0.15)
                    : AppColorMapper.successColor(context).withValues(alpha: 0.15),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TraqIcon(
                        _isError ? AppAssets.iconXCircle : AppAssets.iconInfo,
                        color: _isError ? AppColorMapper.errorColor(context) : AppColorMapper.successColor(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SelectableText(
                          _statusMessage!,
                          style: TextStyle(
                            color: _isError
                                ? AppColorMapper.errorColor(context)
                                : AppColorMapper.successColor(context),
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
              ),
            ),
          
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
                        context.colors.textSecondary,
                      ),
                    ),
                  if (_glnProgress > 0)
                    LinearProgressIndicator(
                      value: _glnTotal > 0 ? _glnProgress / _glnTotal : 0,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colors.textSecondary,
                      ),
                    ),
                  if (_sgtinProgress > 0)
                    LinearProgressIndicator(
                      value: _sgtinTotal > 0 ? _sgtinProgress / _sgtinTotal : 0,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colors.textSecondary,
                      ),
                    ),
                  if (_ssccProgress > 0)
                    LinearProgressIndicator(
                      value: _ssccTotal > 0 ? _ssccProgress / _ssccTotal : 0,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colors.textSecondary,
                      ),
                    ),
                  if (_eventProgress > 0)
                    LinearProgressIndicator(
                      value: _eventTotal > 0 ? _eventProgress / _eventTotal : 0,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                IndustryPharmaTab(
                  isDarkMode: isDarkMode,
                  isLoading: _isLoading,
                  hierarchyLevelsController: _hierarchyLevelsController,
                  hierarchyChildrenController: _hierarchyChildrenController,
                  lastHierarchyRunId: _lastHierarchyRunId,
                  lastHierarchyRootEpc: _lastHierarchyRootEpc,
                  lastHierarchyRootSscc: _lastHierarchyRootSscc,
                  onGeneratePharmaGTINs: _generatePharmaGTINs,
                  onGeneratePharmaGLNs: _generatePharmaGLNs,
                  onGeneratePharmaSGTINs: _generatePharmaSGTINs,
                  onGeneratePharmaSSCCs: _generatePharmaSSCCs,
                  onGeneratePharmaFullSupplyChain: _generatePharmaFullSupplyChain,
                  onGeneratePackedHierarchy: _generatePackedHierarchy,
                  onCleanupPackedHierarchy: _cleanupPackedHierarchy,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }





}