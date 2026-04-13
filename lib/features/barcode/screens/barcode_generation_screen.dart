import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/loading_indicator.dart';

import '../../../data/services/barcode_generation_service.dart';


class BarcodeGenerationScreen extends StatefulWidget {
  const BarcodeGenerationScreen({Key? key}) : super(key: key);

  @override
  State<BarcodeGenerationScreen> createState() =>
      _BarcodeGenerationScreenState();
}

class _BarcodeGenerationScreenState extends State<BarcodeGenerationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Common state
  bool _isLoading = false;
  String? _errorMessage;
  Uint8List? _barcodeImage;
  double _barcodeWidth = 300;
  double _barcodeHeight = 300;

  // GS1 DataMatrix form controllers
  final _gs1ElementStringController = TextEditingController();

  // SGTIN form controllers
  final _gtinController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _batchLotController = TextEditingController();
  DateTime? _expiryDate;

  // SSCC form controllers
  final _ssccController = TextEditingController();
  String _ssccBarcodeFormat = 'gs1-128';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_resetBarcodeOnTabChange);
  }

  // Access the service provided by the wrapper
  BarcodeGenerationService get _barcodeService =>
      getIt<BarcodeGenerationService>();

  void _resetBarcodeOnTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _barcodeImage = null;
        _errorMessage = null;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _gs1ElementStringController.dispose();
    _gtinController.dispose();
    _serialNumberController.dispose();
    _expiryDateController.dispose();
    _batchLotController.dispose();
    _ssccController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() {
        _expiryDate = picked;
        // Format as YYMMDD for GS1
        _expiryDateController.text = DateFormat('yyMMdd').format(picked);
      });
    }
  }

  Future<void> _generateGS1DataMatrix() async {
    if (_gs1ElementStringController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a GS1 element string';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _barcodeImage = null;
    });

    try {
      final barcodeImage = await _barcodeService.generateDataMatrix(
        gs1ElementString: _gs1ElementStringController.text,
        width: _barcodeWidth.toInt(),
        height: _barcodeHeight.toInt(),
      );

      setState(() {
        _barcodeImage = barcodeImage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _generateSGTINDataMatrix() async {
    if (_gtinController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a GTIN';
      });
      return;
    }

    if (_serialNumberController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a serial number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _barcodeImage = null;
    });

    try {
      final barcodeImage = await _barcodeService.generateSGTINDataMatrix(
        gtin: _gtinController.text,
        serialNumber: _serialNumberController.text,
        expiryDate: _expiryDateController.text.isNotEmpty
            ? _expiryDateController.text
            : null,
        batchLot: _batchLotController.text.isNotEmpty
            ? _batchLotController.text
            : null,
        width: _barcodeWidth.toInt(),
        height: _barcodeHeight.toInt(),
      );

      setState(() {
        _barcodeImage = barcodeImage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _generateSSCCBarcode() async {
    if (_ssccController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an SSCC';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _barcodeImage = null;
    });

    try {
      final barcodeImage = await _barcodeService.generateSSCCBarcode(
        sscc: _ssccController.text,
        format: _ssccBarcodeFormat,
        width: _ssccBarcodeFormat == 'gs1-128' ? 400 : _barcodeWidth.toInt(),
        height: _ssccBarcodeFormat == 'gs1-128' ? 150 : _barcodeHeight.toInt(),
      );

      setState(() {
        _barcodeImage = barcodeImage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Barcode'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'GS1 DataMatrix'),
            Tab(text: 'SGTIN'),
            Tab(text: 'SSCC'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [_buildGS1DataMatrixTab(), _buildSGTINTab(), _buildSSCCTab()],
      ),
    );
  }

  Widget _buildGS1DataMatrixTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GS1 DataMatrix',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Enter a GS1 element string using Application Identifiers in parentheses.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'Example: (01)12345678901231(21)ABC123',
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _gs1ElementStringController,
            decoration: const InputDecoration(
              labelText: 'GS1 Element String',
              border: OutlineInputBorder(),
              hintText: '(01)12345678901231(21)ABC123',
            ),
          ),
          const SizedBox(height: 24),
          _buildSizeSliders(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _generateGS1DataMatrix,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Generate Barcode'),
            ),
          ),
          const SizedBox(height: 24),
          _buildBarcodeDisplay(),
        ],
      ),
    );
  }

  Widget _buildSGTINTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SGTIN DataMatrix',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Generate a Serialized GTIN (SGTIN) DataMatrix barcode.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _gtinController,
            decoration: const InputDecoration(
              labelText: 'GTIN',
              border: OutlineInputBorder(),
              hintText: '12345678901231',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _serialNumberController,
            decoration: const InputDecoration(
              labelText: 'Serial Number',
              border: OutlineInputBorder(),
              hintText: 'ABC123',
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _selectExpiryDate,
            child: AbsorbPointer(
              child: TextField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                  labelText: 'Expiry Date (YYMMDD)',
                  border: OutlineInputBorder(),
                  hintText: '240531',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _batchLotController,
            decoration: const InputDecoration(
              labelText: 'Batch/Lot Number',
              border: OutlineInputBorder(),
              hintText: 'LOT123',
            ),
          ),
          const SizedBox(height: 24),
          _buildSizeSliders(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _generateSGTINDataMatrix,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Generate Barcode'),
            ),
          ),
          const SizedBox(height: 24),
          _buildBarcodeDisplay(),
        ],
      ),
    );
  }

  Widget _buildSSCCTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SSCC',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Generate a Serial Shipping Container Code (SSCC) barcode.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ssccController,
            decoration: const InputDecoration(
              labelText: 'SSCC (18 digits)',
              border: OutlineInputBorder(),
              hintText: '123456789012345678',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          const Text('Barcode Format'),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment<String>(value: 'gs1-128', label: Text('GS1-128')),
              ButtonSegment<String>(
                value: 'datamatrix',
                label: Text('DataMatrix'),
              ),
            ],
            selected: {_ssccBarcodeFormat},
            onSelectionChanged: (Set<String> selection) {
              setState(() {
                _ssccBarcodeFormat = selection.first;
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSizeSliders(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _generateSSCCBarcode,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Generate Barcode'),
            ),
          ),
          const SizedBox(height: 24),
          _buildBarcodeDisplay(),
        ],
      ),
    );
  }

  Widget _buildSizeSliders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Barcode Size'),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Width:'),
            Expanded(
              child: Slider(
                value: _barcodeWidth,
                min: 100,
                max: 500,
                divisions: 8,
                label: _barcodeWidth.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _barcodeWidth = value;
                  });
                },
              ),
            ),
            Text('${_barcodeWidth.round()}px'),
          ],
        ),
        Row(
          children: [
            const Text('Height:'),
            Expanded(
              child: Slider(
                value: _barcodeHeight,
                min: 100,
                max: 500,
                divisions: 8,
                label: _barcodeHeight.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _barcodeHeight = value;
                  });
                },
              ),
            ),
            Text('${_barcodeHeight.round()}px'),
          ],
        ),
      ],
    );
  }

  Widget _buildBarcodeDisplay() {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Error',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(_errorMessage!),
          ],
        ),
      );
    }

    if (_barcodeImage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16),
            child: Image.memory(_barcodeImage!, fit: BoxFit.contain),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Save barcode image to device
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Saving barcode is not implemented yet'),
                    ),
                  );
                },
                icon: const Icon(Icons.save_alt),
                label: const Text('Save'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Print barcode
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Printing is not implemented yet'),
                    ),
                  );
                },
                icon: const Icon(Icons.print),
                label: const Text('Print'),
              ),
            ],
          ),
        ],
      );
    }

    return Container(
      height: 200,
      alignment: Alignment.center,
      child: const Text(
        'Generated barcode will appear here',
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}
