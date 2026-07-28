import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/data/services/epcis/epcis_serialization_service.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_query_parameters_dto.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class EPCISSerializationScreen extends StatefulWidget {
  const EPCISSerializationScreen({super.key});

  @override
  State<EPCISSerializationScreen> createState() => _EPCISSerializationScreenState();
}

class _EPCISSerializationScreenState extends State<EPCISSerializationScreen>
    with SingleTickerProviderStateMixin {
  
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final TextEditingController _validationInputController = TextEditingController();
  final TextEditingController _importInputController = TextEditingController();
  
  late TabController _tabController;
  late EPCISSerializationService _serializationService;
  bool _isLoading = false;
  String? _errorMessage;
  String? _validationErrorMessage;
  String? _importErrorMessage;
  String _selectedInputFormat = 'XML';
  String _selectedOutputFormat = 'JSON-LD';
  
  final List<String> _formats = ['XML', 'JSON-LD', 'CSV', 'PDF', 'HTML'];
  
  String _startDateFilter = '';
  String _endDateFilter = '';
  String _epcFilter = '';
  String _businessStepFilter = '';
  String _locationFilter = '';
  String _limitFilter = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    _serializationService = getIt<EPCISSerializationService>();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _validationInputController.dispose();
    _importInputController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TraqAppBar(
        context,
        title: const Text('EPCIS Serialization & Format Conversion'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: context.horizontalPadding.add(
              const EdgeInsets.only(top: TraqSpacing.lg, bottom: TraqSpacing.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EPCIS Serialization & Format Conversion',
                  style: context.text.h2,
                ),
                const SizedBox(height: TraqSpacing.sm),
                Text(
                  'Convert, validate, import and export EPCIS XML and JSON-LD documents.',
                  style: context.text.body.copyWith(color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          Expanded(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    color: context.colors.background,
                    borderColor: context.colors.border,
                    tabBar: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabs: const [
                        Tab(text: 'Format Conversion'),
                        Tab(text: 'Validation'),
                        Tab(text: 'Export'),
                        Tab(text: 'Import'),
                      ],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildFormatConversionTab(),
                  _buildValidationTab(),
                  _buildExportTab(),
                  _buildImportTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatConversionTab() {
    final editorHeight = context.isMobile ? 240.0 : 420.0;
    return SingleChildScrollView(
      padding: context.horizontalPadding.add(
        const EdgeInsets.only(top: TraqSpacing.lg, bottom: TraqSpacing.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: TraqSpacing.surfacePad,
              child: context.isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _formatDropdown(
                          label: 'Input Format',
                          value: _selectedInputFormat,
                          onChanged: (value) =>
                              setState(() => _selectedInputFormat = value!),
                        ),
                        const SizedBox(height: TraqSpacing.md),
                        Center(
                          child: IconButton(
                            tooltip: 'Swap formats',
                            onPressed: () => setState(() {
                              final oldInput = _selectedInputFormat;
                              _selectedInputFormat = _selectedOutputFormat;
                              _selectedOutputFormat = oldInput;
                            }),
                            icon: TraqIcon(AppAssets.iconTransform),
                          ),
                        ),
                        const SizedBox(height: TraqSpacing.md),
                        _formatDropdown(
                          label: 'Output Format',
                          value: _selectedOutputFormat,
                          onChanged: (value) =>
                              setState(() => _selectedOutputFormat = value!),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _formatDropdown(
                            label: 'Input Format',
                            value: _selectedInputFormat,
                            onChanged: (value) =>
                                setState(() => _selectedInputFormat = value!),
                          ),
                        ),
                        const SizedBox(width: TraqSpacing.lg),
                        IconButton(
                          tooltip: 'Swap formats',
                          onPressed: () => setState(() {
                            final oldInput = _selectedInputFormat;
                            _selectedInputFormat = _selectedOutputFormat;
                            _selectedOutputFormat = oldInput;
                          }),
                          icon: TraqIcon(AppAssets.iconTransform),
                        ),
                        const SizedBox(width: TraqSpacing.lg),
                        Expanded(
                          child: _formatDropdown(
                            label: 'Output Format',
                            value: _selectedOutputFormat,
                            onChanged: (value) =>
                                setState(() => _selectedOutputFormat = value!),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: TraqSpacing.lg),
          context.isMobile
              ? Column(
                  children: [
                    _editorPanel(
                      title: 'Input ($_selectedInputFormat)',
                      height: editorHeight,
                      controller: _inputController,
                      hintText: 'Paste your EPCIS data here...',
                      trailing: TextButton.icon(
                        onPressed: _loadSampleData,
                        icon: const TraqIcon(AppAssets.iconBraces),
                        label: const Text('Load Sample'),
                      ),
                    ),
                    const SizedBox(height: TraqSpacing.lg),
                    _editorPanel(
                      title: 'Output ($_selectedOutputFormat)',
                      height: editorHeight,
                      controller: _outputController,
                      readOnly: true,
                      hintText: 'Converted data will appear here...',
                      trailing: TextButton.icon(
                        onPressed: _outputController.text.isNotEmpty
                            ? () => _copyToClipboard(_outputController.text)
                            : null,
                        icon: const TraqIcon(AppAssets.iconCopy),
                        label: const Text('Copy'),
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _editorPanel(
                        title: 'Input ($_selectedInputFormat)',
                        height: editorHeight,
                        controller: _inputController,
                        hintText: 'Paste your EPCIS data here...',
                        trailing: TextButton.icon(
                          onPressed: _loadSampleData,
                          icon: const TraqIcon(AppAssets.iconBraces),
                          label: const Text('Load Sample'),
                        ),
                      ),
                    ),
                    const SizedBox(width: TraqSpacing.lg),
                    Expanded(
                      child: _editorPanel(
                        title: 'Output ($_selectedOutputFormat)',
                        height: editorHeight,
                        controller: _outputController,
                        readOnly: true,
                        hintText: 'Converted data will appear here...',
                        trailing: TextButton.icon(
                          onPressed: _outputController.text.isNotEmpty
                              ? () => _copyToClipboard(_outputController.text)
                              : null,
                          icon: const TraqIcon(AppAssets.iconCopy),
                          label: const Text('Copy'),
                        ),
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: TraqSpacing.lg),
          Card(
            child: Padding(
              padding: TraqSpacing.surfacePad,
              child: Wrap(
                spacing: TraqSpacing.sm,
                runSpacing: TraqSpacing.sm,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _convertFormat,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : TraqIcon(AppAssets.iconTransform),
                    label: const Text('Convert'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _clearAll,
                    icon: TraqIcon(AppAssets.iconX),
                    label: const Text('Clear'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _loadSampleData,
                    icon: const TraqIcon(AppAssets.iconBraces),
                    label: const Text('Load Sample'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _outputController.text.isNotEmpty
                        ? () => _copyToClipboard(_outputController.text)
                        : null,
                    icon: const TraqIcon(AppAssets.iconCopy),
                    label: const Text('Copy Output'),
                  ),
                ],
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: TraqSpacing.lg),
            _errorCard(_errorMessage!, onDismiss: () => setState(() => _errorMessage = null)),
          ],
        ],
      ),
    );
  }

  Widget _buildValidationTab() {
    return SingleChildScrollView(
      padding: context.horizontalPadding.add(
        const EdgeInsets.only(top: TraqSpacing.lg, bottom: TraqSpacing.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: TraqSpacing.surfacePad,
              child: Wrap(
                spacing: TraqSpacing.sm,
                runSpacing: TraqSpacing.sm,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _validateSchema('XML'),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : TraqIcon(AppAssets.iconCheck),
                    label: const Text('Validate XML (EPCIS 1.3)'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _validateSchema('JSON'),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : TraqIcon(AppAssets.iconCheck),
                    label: const Text('Validate JSON (EPCIS 2.0)'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: TraqSpacing.lg),
          _editorPanel(
            title: 'EPCIS Document to Validate',
            height: context.isMobile ? 260 : 380,
            controller: _validationInputController,
            hintText: 'Paste your EPCIS document here...',
          ),
          const SizedBox(height: TraqSpacing.lg),
          _editorPanel(
            title: 'Validation Result',
            height: context.isMobile ? 220 : 300,
            controller: _outputController,
            readOnly: true,
            hintText: 'Validation output will appear here...',
          ),
          if (_validationErrorMessage != null) ...[
            const SizedBox(height: TraqSpacing.lg),
            _errorCard(
              _validationErrorMessage!,
              onDismiss: () => setState(() => _validationErrorMessage = null),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExportTab() {
    return SingleChildScrollView(
      padding: context.horizontalPadding.add(
        const EdgeInsets.only(top: TraqSpacing.lg, bottom: TraqSpacing.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: TraqSpacing.surfacePad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Events - Query Filters',
                    style: context.text.h3,
                  ),
                  const SizedBox(height: TraqSpacing.sm),
                  Text(
                    'Configure filters to select which EPCIS events to export.',
                    style: context.text.body.copyWith(color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: TraqSpacing.lg),
                  context.isMobile
                      ? Column(
                          children: [
                            _exportFilterField(
                              labelText: 'Start Date (Optional)',
                              hintText: '2025-01-01T00:00:00Z',
                              onChanged: (value) => _startDateFilter = value,
                            ),
                            const SizedBox(height: TraqSpacing.md),
                            _exportFilterField(
                              labelText: 'End Date (Optional)',
                              hintText: '2025-12-31T23:59:59Z',
                              onChanged: (value) => _endDateFilter = value,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _exportFilterField(
                                labelText: 'Start Date (Optional)',
                                hintText: '2025-01-01T00:00:00Z',
                                onChanged: (value) => _startDateFilter = value,
                              ),
                            ),
                            const SizedBox(width: TraqSpacing.md),
                            Expanded(
                              child: _exportFilterField(
                                labelText: 'End Date (Optional)',
                                hintText: '2025-12-31T23:59:59Z',
                                onChanged: (value) => _endDateFilter = value,
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: TraqSpacing.md),
                  _exportFilterField(
                    labelText: 'EPCs (Optional)',
                    hintText: 'Comma-separated EPCs (e.g., https://id.gs1.org/01/10614148123456/21/400)',
                    onChanged: (value) => _epcFilter = value,
                  ),
                  const SizedBox(height: TraqSpacing.md),
                  _exportFilterField(
                    labelText: 'Business Steps (Optional)',
                    hintText: 'Comma-separated business steps (e.g., receiving, shipping)',
                    onChanged: (value) => _businessStepFilter = value,
                  ),
                  const SizedBox(height: TraqSpacing.md),
                  _exportFilterField(
                    labelText: 'Business Locations (Optional)',
                    hintText: 'Comma-separated GLNs (e.g., 1234567890123)',
                    onChanged: (value) => _locationFilter = value,
                  ),
                  const SizedBox(height: TraqSpacing.md),
                  _exportFilterField(
                    labelText: 'Max Results (Optional)',
                    hintText: 'Maximum number of events (e.g., 1000)',
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _limitFilter = value,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: TraqSpacing.lg),
          Card(
            child: Padding(
              padding: TraqSpacing.surfacePad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Export to Format', style: context.text.h3),
                  const SizedBox(height: TraqSpacing.sm),
                  Text(
                    'Select a format to export events that match the current filters.',
                    style: context.text.body.copyWith(color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: TraqSpacing.md),
                  Wrap(
                    spacing: TraqSpacing.sm,
                    runSpacing: TraqSpacing.sm,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _exportEvents('CSV'),
                        icon: const TraqIcon(AppAssets.iconTable),
                        label: const Text('Export CSV'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _exportEvents('PDF'),
                        icon: const TraqIcon(AppAssets.iconPdf),
                        label: const Text('Export PDF'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _exportEvents('HTML'),
                        icon: const TraqIcon(AppAssets.iconGlobe),
                        label: const Text('Export HTML'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _exportEvents('EXCEL'),
                        icon: const TraqIcon(AppAssets.iconGrid),
                        label: const Text('Export Excel'),
                      ),
                    ],
                  ),
                  if (_isLoading) ...[
                    const SizedBox(height: TraqSpacing.md),
                    const LinearProgressIndicator(),
                    const SizedBox(height: TraqSpacing.sm),
                    Text(
                      'Exporting events...',
                      style: context.text.body.copyWith(color: context.colors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: TraqSpacing.lg),
          _editorPanel(
            title: 'Export Output',
            height: context.isMobile ? 220 : 280,
            controller: _outputController,
            readOnly: true,
            hintText: 'Export response will appear here...',
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: TraqSpacing.lg),
            _errorCard(
              _errorMessage!,
              onDismiss: () => setState(() => _errorMessage = null),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImportTab() {
    final editorHeight = context.isMobile ? 240.0 : 360.0;
    return SingleChildScrollView(
      padding: context.horizontalPadding.add(
        const EdgeInsets.only(top: TraqSpacing.lg, bottom: TraqSpacing.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: TraqSpacing.surfacePad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Import EPCIS Events', style: context.text.h3),
                  const SizedBox(height: TraqSpacing.sm),
                  Text(
                    'Paste XML or JSON-LD EPCIS documents containing events to store in the system.',
                    style: context.text.body.copyWith(color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: TraqSpacing.md),
                  Wrap(
                    spacing: TraqSpacing.sm,
                    runSpacing: TraqSpacing.sm,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _importEvents('XML'),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const TraqIcon(AppAssets.iconCloudUpload),
                        label: const Text('Import XML Events'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _importEvents('JSON-LD'),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const TraqIcon(AppAssets.iconCloudUpload),
                        label: const Text('Import JSON-LD Events'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _loadImportSampleData,
                        icon: const TraqIcon(AppAssets.iconBraces),
                        label: const Text('Load Sample'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: TraqSpacing.lg),
          context.isMobile
              ? Column(
                  children: [
                    _editorPanel(
                      title: 'EPCIS Document to Import',
                      height: editorHeight,
                      controller: _importInputController,
                      hintText:
                          'Paste your EPCIS document here...\n\nThis imports all events contained in the document.',
                    ),
                    const SizedBox(height: TraqSpacing.lg),
                    _editorPanel(
                      title: 'Import Results',
                      height: editorHeight,
                      controller: _outputController,
                      readOnly: true,
                      hintText: 'Import results and statistics will appear here...',
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _editorPanel(
                        title: 'EPCIS Document to Import',
                        height: editorHeight,
                        controller: _importInputController,
                        hintText:
                            'Paste your EPCIS document here...\n\nThis imports all events contained in the document.',
                      ),
                    ),
                    const SizedBox(width: TraqSpacing.lg),
                    Expanded(
                      child: _editorPanel(
                        title: 'Import Results',
                        height: editorHeight,
                        controller: _outputController,
                        readOnly: true,
                        hintText: 'Import results and statistics will appear here...',
                      ),
                    ),
                  ],
                ),
          if (_importErrorMessage != null) ...[
            const SizedBox(height: TraqSpacing.lg),
            _errorCard(
              _importErrorMessage!,
              onDismiss: () => setState(() => _importErrorMessage = null),
            ),
          ],
        ],
      ),
    );
  }

  Widget _exportFilterField({
    required String labelText,
    required String hintText,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
  }) {
    return TextField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }

  Widget _formatDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: _formats
          .map((format) => DropdownMenuItem(value: format, child: Text(format)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _editorPanel({
    required String title,
    required double height,
    required TextEditingController controller,
    required String hintText,
    Widget? trailing,
    bool readOnly = false,
  }) {
    return Card(
      child: Padding(
        padding: TraqSpacing.surfacePad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: TraqSpacing.sm),
            SizedBox(
              height: height,
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                readOnly: readOnly,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: hintText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorCard(String message, {required VoidCallback onDismiss}) {
    return Builder(
      builder: (context) {
        final color = AppColorMapper.errorColor(context);
        return Card(
          color: color.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(TraqSpacing.md),
            child: Row(
              children: [
                TraqIcon(AppAssets.iconAlert, color: color),
                const SizedBox(width: TraqSpacing.sm),
                Expanded(
                  child: Text(message, style: TextStyle(color: color)),
                ),
                IconButton(
                  onPressed: onDismiss,
                  icon: TraqIcon(AppAssets.iconX),
                  color: color,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _convertFormat() async {
    if (_inputController.text.isEmpty) {
      _showError('Please enter input data to convert');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String result;
      
      if (_selectedInputFormat == 'XML' && _selectedOutputFormat == 'JSON-LD') {
        final jsonLdResult = await _serializationService.convertXmlToJsonLd(_inputController.text);
        result = const JsonEncoder.withIndent('  ').convert(jsonLdResult);
      } else if (_selectedInputFormat == 'JSON-LD' && _selectedOutputFormat == 'XML') {
        try {
          final jsonInput = jsonDecode(_inputController.text) as Map<String, dynamic>;
          result = await _serializationService.convertJsonLdToXml(jsonInput);
        } catch (e) {
          throw Exception('Invalid JSON format in input');
        }
      } else {
        throw Exception('Conversion from $_selectedInputFormat to $_selectedOutputFormat is not supported yet');
      }

      _outputController.text = result;

    } catch (e) {
      _showError('Conversion failed: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _validateSchema(String format) async {
    if (_validationInputController.text.isEmpty) {
      _showValidationError('Please enter data to validate');
      return;
    }

    setState(() {
      _isLoading = true;
      _validationErrorMessage = null;
    });

    try {
      Map<String, dynamic> response;

      if (format == 'XML') {
        response = await _serializationService.validateXmlSchema(_validationInputController.text);
      } else {
        try {
          final jsonInput = jsonDecode(_validationInputController.text) as Map<String, dynamic>;
          response = await _serializationService.validateJsonSchema(jsonInput);
        } catch (e) {
          throw Exception('Invalid JSON format in input');
        }
      }
      
      _outputController.text = const JsonEncoder.withIndent('  ').convert(response);
      
      if (response['valid'] == true) {
        context.showSuccess('Document is valid according to EPCIS $format schema');
      } else {
        _showValidationError('Document validation failed: ${response['errors'].join(', ')}');
      }

    } catch (e) {
      _showValidationError('Validation failed: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportEvents(String format) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      DateTime? startTime;
      DateTime? endTime;
      List<String> epcs = [];
      List<String> businessSteps = [];
      List<String> businessLocations = [];
      int? limit;

      if (_startDateFilter.isNotEmpty) {
        try {
          startTime = DateTime.parse(_startDateFilter);
        } catch (e) {
          throw Exception('Invalid start date format. Use ISO 8601 format (e.g., 2025-01-01T00:00:00Z)');
        }
      }

      if (_endDateFilter.isNotEmpty) {
        try {
          endTime = DateTime.parse(_endDateFilter);
        } catch (e) {
          throw Exception('Invalid end date format. Use ISO 8601 format (e.g., 2025-12-31T23:59:59Z)');
        }
      }

      if (_epcFilter.isNotEmpty) {
        epcs = _epcFilter.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }

      if (_businessStepFilter.isNotEmpty) {
        businessSteps = _businessStepFilter.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }

      if (_locationFilter.isNotEmpty) {
        businessLocations = _locationFilter.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }

      if (_limitFilter.isNotEmpty) {
        try {
          limit = int.parse(_limitFilter);
          if (limit <= 0) {
            throw Exception('Limit must be a positive number');
          }
        } catch (e) {
          throw Exception('Invalid limit format. Enter a positive number');
        }
      }

      final queryParams = EPCISQueryParametersDTO(
        startTime: startTime,
        endTime: endTime,
        epcs: epcs.isNotEmpty ? epcs : null,
        businessSteps: businessSteps.isNotEmpty ? businessSteps : null,
        businessLocations: businessLocations.isNotEmpty ? businessLocations : null,
        dispositions: [],
        readPoints: [],
        limit: limit,
      );

      String result;
      List<int>? binaryResult;
      
      switch (format.toLowerCase()) {
        case 'csv':
          result = await _serializationService.exportToCsv(queryParams);
          _outputController.text = result;
          context.showSuccess('Events exported to CSV format successfully. ${result.split('\n').length - 1} events exported.');
          break;
        case 'html':
          result = await _serializationService.exportToHtml(queryParams);
          _outputController.text = result;
          context.showSuccess('Events exported to HTML format successfully');
          break;
        case 'pdf':
          binaryResult = await _serializationService.exportToPdf(queryParams);
          _outputController.text = 'PDF exported successfully (${binaryResult.length} bytes). Binary data cannot be displayed in text format.';
          context.showSuccess('Events exported to PDF format successfully. ${binaryResult.length} bytes generated.');
          break;
        case 'excel':
          binaryResult = await _serializationService.exportToExcel(queryParams);
          _outputController.text = 'Excel exported successfully (${binaryResult.length} bytes). Binary data cannot be displayed in text format.';
          context.showSuccess('Events exported to Excel format successfully. ${binaryResult.length} bytes generated.');
          break;
        default:
          throw Exception('Export format $format is not supported');
      }

    } catch (e) {
      _showError('Export failed: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _importEvents(String format) async {
    if (_importInputController.text.isEmpty) {
      _showImportError('Please enter EPCIS document to import');
      return;
    }

    setState(() {
      _isLoading = true;
      _importErrorMessage = null;
    });

    try {
      Map<String, dynamic> result;

      if (format == 'XML') {
        result = await _serializationService.importEventsFromXml(_importInputController.text);
      } else {
        try {
          final jsonInput = jsonDecode(_importInputController.text) as Map<String, dynamic>;
          result = await _serializationService.importEventsFromJsonLd(jsonInput);
        } catch (e) {
          throw Exception('Invalid JSON format in input');
        }
      }
      
      _outputController.text = const JsonEncoder.withIndent('  ').convert(result);
      
      final eventsImported = result['eventsImported'] ?? result['totalEvents'] ?? 0;
      final eventsSkipped = result['eventsSkipped'] ?? result['duplicates'] ?? 0;
      final errors = result['errors'] ?? [];
      
      if (errors.isNotEmpty) {
        _showImportError('Import completed with errors: ${errors.join(', ')}');
      } else {
        context.showSuccess('Successfully imported $eventsImported events into the database${eventsSkipped > 0 ? ' ($eventsSkipped duplicates skipped)' : ''}');
      }

    } catch (e) {
      _showImportError('Import failed: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadImportSampleData() {
    _importInputController.text = '''{
  "@context": "https://gs1.github.io/EPCIS/epcis-context.jsonld",
  "type": "EPCISDocument",
  "schemaVersion": "2.0",
  "creationDate": "2025-07-19T12:00:00Z",
  "epcisBody": {
    "eventList": [
      {
        "type": "ObjectEvent",
        "eventTime": "2025-07-19T10:30:00Z",
        "epcList": ["https://id.gs1.org/01/10614141073464/21/2025"],
        "action": "OBSERVE",
        "bizStep": "urn:epcglobal:cbv:bizstep:receiving",
        "disposition": "urn:epcglobal:cbv:disp:in_progress",
        "readPoint": {
          "id": "https://id.gs1.org/414/0614141073467"
        },
        "bizLocation": {
          "id": "https://id.gs1.org/414/0614141073467"
        }
      },
      {
        "type": "ObjectEvent",
        "eventTime": "2025-07-19T11:15:00Z",
        "epcList": ["https://id.gs1.org/01/10614141073464/21/2026"],
        "action": "OBSERVE",
        "bizStep": "urn:epcglobal:cbv:bizstep:shipping",
        "disposition": "urn:epcglobal:cbv:disp:in_transit",
        "readPoint": {
          "id": "https://id.gs1.org/414/0614141073467"
        },
        "bizLocation": {
          "id": "https://id.gs1.org/414/0614141073467"
        }
      }
    ]
  }
}''';
  }

  void _loadSampleData() {
    if (_selectedInputFormat == 'XML') {
      _inputController.text = '''<?xml version="1.0" encoding="UTF-8"?>
<epcis:EPCISDocument xmlns:epcis="urn:epcglobal:epcis:xsd:1" schemaVersion="1.3">
  <EPCISBody>
    <EventList>
      <ObjectEvent>
        <eventTime>2023-01-01T12:00:00Z</eventTime>
        <epcList>
          <epc>https://id.gs1.org/01/10614141073464/21/2017</epc>
        </epcList>
        <action>OBSERVE</action>
        <bizStep>urn:epcglobal:cbv:bizstep:receiving</bizStep>
        <disposition>urn:epcglobal:cbv:disp:in_progress</disposition>
        <readPoint>
          <id>https://id.gs1.org/414/0614141073467</id>
        </readPoint>
      </ObjectEvent>
    </EventList>
  </EPCISBody>
</epcis:EPCISDocument>''';
    } else {
      _inputController.text = '''{
  "@context": "https://gs1.github.io/EPCIS/epcis-context.jsonld",
  "type": "EPCISDocument",
  "schemaVersion": "2.0",
  "creationDate": "2023-01-01T12:00:00Z",
  "epcisBody": {
    "eventList": [
      {
        "type": "ObjectEvent",
        "eventTime": "2023-01-01T12:00:00Z",
        "epcList": ["https://id.gs1.org/01/10614141073464/21/2017"],
        "action": "OBSERVE",
        "bizStep": "urn:epcglobal:cbv:bizstep:receiving",
        "disposition": "urn:epcglobal:cbv:disp:in_progress",
        "readPoint": {
          "id": "https://id.gs1.org/414/0614141073467"
        }
      }
    ]
  }
}''';
    }
  }

  void _clearAll() {
    setState(() {
      _inputController.clear();
      _outputController.clear();
      _validationInputController.clear();
      _importInputController.clear();
      _errorMessage = null;
      _validationErrorMessage = null;
      _importErrorMessage = null;
    });
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    context.showSuccess('Copied to clipboard');
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    context.showError(message);
  }

  void _showValidationError(String message) {
    setState(() => _validationErrorMessage = message);
    context.showError(message);
  }

  void _showImportError(String message) {
    setState(() => _importErrorMessage = message);
    context.showError(message);
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  _StickyTabBarDelegate({
    required this.tabBar,
    required this.color,
    required this.borderColor,
  });

  final TabBar tabBar;
  final Color color;
  final Color borderColor;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: color,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: borderColor),
            bottom: BorderSide(color: borderColor),
          ),
        ),
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar ||
        oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor;
  }
}