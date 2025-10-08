import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/orderHistory/data/services/MedicineDeliveryOrderService.dart';
import 'package:vedika_healthcare/features/orderHistory/data/services/AmbulanceOrderService.dart';
import 'package:vedika_healthcare/features/orderHistory/data/services/BedBookingOrderService.dart';
import 'package:vedika_healthcare/features/orderHistory/data/services/LabTestOrderService.dart';
import 'package:vedika_healthcare/features/orderHistory/data/services/BloodBankOrderService.dart';
import 'package:vedika_healthcare/features/orderHistory/data/services/ClinicAppointmentOrderService.dart';
import 'package:vedika_healthcare/features/orderHistory/data/services/ProductOrderService.dart';

class InvoiceViewerScreen extends StatefulWidget {
  final String orderId;
  final String categoryLabel; // e.g., "Medicine Delivery"

  const InvoiceViewerScreen({Key? key, required this.orderId, required this.categoryLabel}) : super(key: key);

  @override
  State<InvoiceViewerScreen> createState() => _InvoiceViewerScreenState();
}

class _InvoiceViewerScreenState extends State<InvoiceViewerScreen> {
  final MedicineDeliveryOrderService _medicineService = MedicineDeliveryOrderService();
  final AmbulanceOrderService _ambulanceService = AmbulanceOrderService();
  final BedBookingOrderService _hospitalService = BedBookingOrderService();
  final LabTestOrderService _labTestService = LabTestOrderService();
  final BloodBankOrderService _bloodBankService = BloodBankOrderService();
  final ClinicAppointmentOrderService _clinicService = ClinicAppointmentOrderService();
  final ProductOrderService _productOrderService = ProductOrderService();
  final PdfViewerController _pdfController = PdfViewerController();

  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _error;
  bool _isSharing = false;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      Uint8List bytes;
      if (widget.categoryLabel.toLowerCase().contains('ambulance')) {
        bytes = await _ambulanceService.fetchAmbulanceInvoiceBytes(widget.orderId);
      } else if (widget.categoryLabel.toLowerCase().contains('hospital')) {
        bytes = await _hospitalService.fetchHospitalInvoiceBytes(widget.orderId);
      } else if (widget.categoryLabel.toLowerCase().contains('lab')) {
        bytes = await _labTestService.fetchLabTestInvoiceBytes(widget.orderId);
      } else if (widget.categoryLabel.toLowerCase().contains('blood')) {
        bytes = await _bloodBankService.fetchBloodBankInvoiceBytes(widget.orderId);
      } else if (widget.categoryLabel.toLowerCase().contains('clinic')) {
        bytes = await _clinicService.fetchClinicInvoiceBytes(widget.orderId);
      } else if (widget.categoryLabel.toLowerCase().contains('product')) {
        bytes = await _productOrderService.fetchProductOrderInvoiceBytes(widget.orderId);
      } else {
        bytes = await _medicineService.fetchMedicineDeliveryInvoiceBytes(widget.orderId);
      }
      if (!mounted) return;
      setState(() {
        _pdfBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load invoice: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<File> _writeTempInvoice(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final categoryPrefix = widget.categoryLabel.toLowerCase().replaceAll(' ', '_');
    final path = '${dir.path}/${categoryPrefix}_invoice_${widget.orderId}.pdf';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> _shareInvoice() async {
    if (_pdfBytes == null) return;
    setState(() => _isSharing = true);
    try {
      final file = await _writeTempInvoice(_pdfBytes!);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.categoryLabel} Invoice - Order #${widget.orderId}',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share invoice: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isSharing = false);
    }
  }

  Future<void> _downloadInvoice() async {
    if (_pdfBytes == null) return;
    setState(() => _isDownloading = true);
    try {
      // Save to app documents so user can keep it
      final dir = await getApplicationDocumentsDirectory();
      final categoryPrefix = widget.categoryLabel.toLowerCase().replaceAll(' ', '_');
      final file = File('${dir.path}/${categoryPrefix}_invoice_${widget.orderId}.pdf');
      await file.writeAsBytes(_pdfBytes!, flush: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to ${file.path}'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Invoice', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            Text(
              widget.categoryLabel,
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85)),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: ColorPalette.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Share',
            onPressed: _pdfBytes == null || _isSharing ? null : _shareInvoice,
            icon: _isSharing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                : const Icon(Icons.share, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Download',
            onPressed: _pdfBytes == null || _isDownloading ? null : _downloadInvoice,
            icon: _isDownloading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                : const Icon(Icons.download, color: Colors.white),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadInvoice,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(backgroundColor: ColorPalette.primaryColor, foregroundColor: Colors.white),
              )
            ],
          ),
        ),
      );
    }
    if (_pdfBytes == null) {
      return const Center(child: Text('No invoice data'));
    }
    return SfPdfViewer.memory(
      _pdfBytes!,
      controller: _pdfController,
      canShowScrollStatus: false,
      canShowPaginationDialog: false,
      enableTextSelection: true,
      enableDoubleTapZooming: true,
    );
  }
}


