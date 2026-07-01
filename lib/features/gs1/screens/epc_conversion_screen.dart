import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/epc_entry_field.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gln_entry_field.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gtin_entry_field.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/serial_entry_field.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/sscc_entry_field.dart';
import 'package:traqtrace_app/features/epcis/validators/epcis_epc_validators.dart';

import 'package:traqtrace_app/data/services/epcis/epc_conversion_service.dart';

class EPCConversionScreen extends StatefulWidget {
  const EPCConversionScreen({super.key});

  @override
  State<EPCConversionScreen> createState() => _EPCConversionScreenState();
}

class _EPCConversionScreenState extends State<EPCConversionScreen> with SingleTickerProviderStateMixin {
  late final EPCConversionService _epcConversionService;
  late TabController _tabController;
  
  final _gtinController = TextEditingController();
  final _serialController = TextEditingController();
  final _sgtinEpcResultController = TextEditingController();

  final _ssccController = TextEditingController();
  final _ssccEpcResultController = TextEditingController();
  
  final _glnController = TextEditingController();
  final _glnExtensionController = TextEditingController();
  final _glnEpcResultController = TextEditingController();
  
  final _epcUriController = TextEditingController();
  final _epcConversionResultController = TextEditingController();
  
  final _gs1ElementStringController = TextEditingController();
  final _gs1ToEpcResultController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String _selectedEpcType = 'SGTIN';
  final List<String> _epcTypes = ['SGTIN', 'SSCC', 'GLN'];

  @override
  void initState() {
    super.initState();
    _epcConversionService = getIt<EPCConversionService>();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    
    _gtinController.dispose();
    _serialController.dispose();
    _sgtinEpcResultController.dispose();
    
    _ssccController.dispose();
    _ssccEpcResultController.dispose();
    
    _glnController.dispose();
    _glnExtensionController.dispose();
    _glnEpcResultController.dispose();
    
    _epcUriController.dispose();
    _epcConversionResultController.dispose();
    
    _gs1ElementStringController.dispose();
    _gs1ToEpcResultController.dispose();
    
    super.dispose();
  }

  Future<void> _convertToEPC(int tabIndex) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      switch (tabIndex) {
        case 0:
          final epcUri = await _epcConversionService.convertSGTINToEPC(
            _gtinController.text,
            _serialController.text,
          );
          _sgtinEpcResultController.text = epcUri;
          break;
        case 1:
          final epcUri = await _epcConversionService.convertSSCCToEPC(
            _ssccController.text,
          );
          _ssccEpcResultController.text = epcUri;
          break;
        case 2:
          final String? extension = _glnExtensionController.text.isEmpty 
              ? null 
              : _glnExtensionController.text;
          final epcUri = await _epcConversionService.convertGLNToEPC(
            _glnController.text,
            extension,
          );
          _glnEpcResultController.text = epcUri;
          break;
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _convertFromEPC() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final epcUri = _epcUriController.text;
      
      switch (_selectedEpcType) {
        case 'SGTIN':
          final result = await _epcConversionService.convertEPCToSGTIN(epcUri);
          _epcConversionResultController.text = 'GTIN: ${result['gtin']}\nSerial: ${result['serial']}';
          break;
        case 'SSCC':
          final sscc = await _epcConversionService.convertEPCToSSCC(epcUri);
          _epcConversionResultController.text = 'SSCC: $sscc';
          break;
        case 'GLN':
          final gln = await _epcConversionService.convertEPCToGLN(epcUri);
          _epcConversionResultController.text = 'GLN: $gln';
          break;
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _convertGS1ElementString() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final epcUri = await _epcConversionService.convertGS1ElementStringToEPC(
        _gs1ElementStringController.text,
      );
      _gs1ToEpcResultController.text = epcUri;
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    context.showInfo('Copied to clipboard', duration: const Duration(seconds: 1));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TraqAppBar(
        context,
        title: const Text('EPC Conversion Tools'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'SGTIN to EPC'),
            Tab(text: 'SSCC to EPC'),
            Tab(text: 'GLN to EPC'),
            Tab(text: 'EPC to GS1'),
            Tab(text: 'GS1 String to EPC'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSGTINToEPCForm(),
          
          _buildSSCCToEPCForm(),
          
          _buildGLNToEPCForm(),
          
          _buildEPCToGS1Form(),
          
          _buildGS1ElementStringToEPCForm(),
        ],
      ),
    );
  }

  Widget _buildSGTINToEPCForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Convert SGTIN to EPC URI',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          GtinEntryField(
            controller: _gtinController,
            label: 'GTIN',
            hintText: 'Enter the GTIN code (e.g., 08712345678906)',
          ),
          const SizedBox(height: 16),
          SerialEntryField(
            controller: _serialController,
            label: 'Serial Number',
            hintText: 'Enter the serial number',
          ),
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: _isLoading ? null : () => _convertToEPC(0),
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Convert to EPC URI'),
          ),
          const SizedBox(height: 24),
          
          if (_sgtinEpcResultController.text.isNotEmpty) ...[
            const Text(
              'EPC URI Result:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _sgtinEpcResultController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[100],
                suffixIcon: IconButton(
                  icon: const TraqIcon(AppAssets.iconCopy),
                  onPressed: () => _copyToClipboard(_sgtinEpcResultController.text),
                ),
              ),
              readOnly: true,
              maxLines: 2,
            ),
          ],
          
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSSCCToEPCForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Convert SSCC to EPC URI',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          SsccEntryField(
            controller: _ssccController,
            label: 'SSCC',
            hintText: 'Enter the 18-digit SSCC code',
            validator: (_) => null,
          ),
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: _isLoading ? null : () => _convertToEPC(1),
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Convert to EPC URI'),
          ),
          const SizedBox(height: 24),
          
          if (_ssccEpcResultController.text.isNotEmpty) ...[
            const Text(
              'EPC URI Result:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ssccEpcResultController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[100],
                suffixIcon: IconButton(
                  icon: const TraqIcon(AppAssets.iconCopy),
                  onPressed: () => _copyToClipboard(_ssccEpcResultController.text),
                ),
              ),
              readOnly: true,
              maxLines: 2,
            ),
          ],
          
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGLNToEPCForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Convert GLN to EPC URI',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          GlnEntryField(
            controller: _glnController,
            label: 'GLN',
            hintText: 'Enter the 13-digit GLN code',
            optional: true,
            validator: (_) => null,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _glnExtensionController,
            decoration: const InputDecoration(
              labelText: 'GLN Extension (Optional)',
              hintText: 'Enter the GLN extension if applicable',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: _isLoading ? null : () => _convertToEPC(2),
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Convert to EPC URI'),
          ),
          const SizedBox(height: 24),
          
          if (_glnEpcResultController.text.isNotEmpty) ...[
            const Text(
              'EPC URI Result:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _glnEpcResultController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[100],
                suffixIcon: IconButton(
                  icon: const TraqIcon(AppAssets.iconCopy),
                  onPressed: () => _copyToClipboard(_glnEpcResultController.text),
                ),
              ),
              readOnly: true,
              maxLines: 2,
            ),
          ],
          
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEPCToGS1Form() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Convert EPC URI to GS1 Identifier',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'EPC Type',
              border: OutlineInputBorder(),
            ),
            value: _selectedEpcType,
            items: _epcTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedEpcType = newValue!;
              });
            },
          ),
          const SizedBox(height: 16),
          
          EpcEntryField(
            controller: _epcUriController,
            label: 'EPC URI',
            hintText: 'Enter the EPC URI (e.g., urn:epc:id:sgtin:...)',
            required: true,
            validator: (value) =>
                EpcisEpcValidators.validateEpcOrBarcode(value),
          ),
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: _isLoading ? null : _convertFromEPC,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Convert from EPC URI'),
          ),
          const SizedBox(height: 24),
          
          if (_epcConversionResultController.text.isNotEmpty) ...[
            const Text(
              'GS1 Identifier Result:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _epcConversionResultController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[100],
                suffixIcon: IconButton(
                  icon: const TraqIcon(AppAssets.iconCopy),
                  onPressed: () => _copyToClipboard(_epcConversionResultController.text),
                ),
              ),
              readOnly: true,
              maxLines: 3,
            ),
          ],
          
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGS1ElementStringToEPCForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Convert GS1 Element String to EPC URI',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _gs1ElementStringController,
            decoration: const InputDecoration(
              labelText: 'GS1 Element String',
              hintText: 'Enter the GS1 Element String (e.g., 01087123456789063421ABCD)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: _isLoading ? null : _convertGS1ElementString,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Convert to EPC URI'),
          ),
          const SizedBox(height: 24),
          
          if (_gs1ToEpcResultController.text.isNotEmpty) ...[
            const Text(
              'EPC URI Result:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _gs1ToEpcResultController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[100],
                suffixIcon: IconButton(
                  icon: const TraqIcon(AppAssets.iconCopy),
                  onPressed: () => _copyToClipboard(_gs1ToEpcResultController.text),
                ),
              ),
              readOnly: true,
              maxLines: 2,
            ),
          ],
          
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }
}
