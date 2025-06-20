import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/services/AmbulanceBookingHistoryService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';
import 'package:vedika_healthcare/features/orderHistory/data/reports/ambulance_invoice_pdf.dart';

class AmbulanceBookingHistoryViewModel extends ChangeNotifier {
  List<AmbulanceBooking> bookingHistory = [];
  bool isLoading = false;
  String? errorMessage;
  final VendorLoginService _loginService = VendorLoginService();

  bool _isGeneratingInvoice = false;
  String _generatingInvoiceForBookingId = '';
  
  bool get isGeneratingInvoice => _isGeneratingInvoice;
  bool isGeneratingInvoiceForBooking(String bookingId) => _isGeneratingInvoice && _generatingInvoiceForBookingId == bookingId;

  // ✅ Fetch Completed Booking History by Vendor
  Future<void> fetchBookingHistory() async {
    String? vendorId = await _loginService.getVendorId();

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      bookingHistory =
      await AmbulanceBookingHistoryService.getCompletedRequestsByVendor(vendorId!);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateInvoice(String bookingId) async {
    try {
      _isGeneratingInvoice = true;
      _generatingInvoiceForBookingId = bookingId;
      notifyListeners();

      // Find the booking from the list
      final booking = bookingHistory.firstWhere(
        (booking) => booking.requestId == bookingId,
        orElse: () => throw Exception('Booking not found'),
      );

      // Generate and download the PDF
      await generateAndDownloadAmbulanceInvoicePDF(booking);
      
    } catch (e) {
      debugPrint('Error generating invoice: $e');
      rethrow;
    } finally {
      _isGeneratingInvoice = false;
      _generatingInvoiceForBookingId = '';
      notifyListeners();
    }
  }
}
