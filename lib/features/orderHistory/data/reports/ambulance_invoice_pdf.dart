import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';
import 'package:intl/intl.dart';

Future<void> generateAndDownloadAmbulanceInvoicePDF(AmbulanceBooking booking) async {
  final pdf = pw.Document();
  final indiaFormat = DateFormat('dd MMM yyyy, hh:mm a');
  final generatedDate = DateTime.now();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (pw.Context context) {
        return pw.Container(
          color: PdfColors.grey50,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                color: PdfColors.blue800,
                padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 22),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('VEDIKA HEALTHCARE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.white, letterSpacing: 1.2)),
                        pw.SizedBox(height: 4),
                        pw.Text('AMBULANCE INVOICE', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(10),
                        border: pw.Border.all(color: PdfColors.blue100, width: 1.2),
                      ),
                      child: pw.Text('Booking #${booking.requestId}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue800, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 18),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 32),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Booking & User Info
                    pw.Container(
                      padding: const pw.EdgeInsets.all(16),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(12),
                        boxShadow: [
                          pw.BoxShadow(
                            color: PdfColors.blue50,
                            blurRadius: 2,
                            spreadRadius: 1,
                          ),
                        ],
                        border: pw.Border.all(color: PdfColors.blue100),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Booking Date:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.blueGrey800)),
                              pw.Text(indiaFormat.format(booking.timestamp), style: pw.TextStyle(fontSize: 11)),
                              pw.SizedBox(height: 6),
                              pw.Text('Status:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.blueGrey800)),
                              pw.Text(booking.status, style: pw.TextStyle(fontSize: 11)),
                            ],
                          ),
                          pw.SizedBox(width: 24),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text('Customer', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.blue800)),
                              pw.SizedBox(height: 4),
                              pw.Text(booking.user.name ?? '-', style: pw.TextStyle(fontSize: 12)),
                              if (booking.user.emailId != null && booking.user.emailId!.isNotEmpty)
                                pw.Text(booking.user.emailId!, style: pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 18),
                    // Agency Info
                    pw.Text('Agency', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15, color: PdfColors.blue800, letterSpacing: 0.5)),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(14),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(10),
                        border: pw.Border.all(color: PdfColors.blue100),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(booking.agency?.agencyName ?? 'Unknown Agency', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                          if (booking.agency?.contactNumber != null)
                            pw.Text('Contact: ${booking.agency!.contactNumber}', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                          if (booking.agency?.address != null)
                            pw.Text('Address: ${booking.agency!.address}', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 18),
                    // Vehicle Info
                    pw.Text('Vehicle', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15, color: PdfColors.blue800, letterSpacing: 0.5)),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(14),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(10),
                        border: pw.Border.all(color: PdfColors.blue100),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Type: ${booking.vehicleType}', style: pw.TextStyle(fontSize: 13)),
                              pw.Text('Distance: ${booking.totalDistance.toStringAsFixed(2)} km', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text('Cost per km: ${booking.costPerKm.toStringAsFixed(2)} INR', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                              pw.Text('Base Charge: ${booking.baseCharge.toStringAsFixed(2)} INR', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 18),
                    // Route Info
                    pw.Text('Route', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15, color: PdfColors.blue800, letterSpacing: 0.5)),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(14),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(10),
                        border: pw.Border.all(color: PdfColors.blue100),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Pickup: ${booking.pickupLocation}', style: pw.TextStyle(fontSize: 13)),
                          pw.Text('Drop: ${booking.dropLocation}', style: pw.TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 18),
                    // Cost Breakdown
                    pw.Text('Cost Breakdown', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15, color: PdfColors.blue800, letterSpacing: 0.5)),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(18),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(12),
                        border: pw.Border.all(color: PdfColors.blue100),
                        boxShadow: [
                          pw.BoxShadow(
                            color: PdfColors.blue50,
                            blurRadius: 2,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _receiptRow('Base Charge', booking.baseCharge),
                          pw.SizedBox(height: 8),
                          _receiptRow('Distance Charge', booking.totalDistance * booking.costPerKm),
                          pw.Divider(height: 24, color: PdfColors.blueGrey),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16, color: PdfColors.blue800)),
                              pw.Text('${booking.totalAmount.toStringAsFixed(2)} INR', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, color: PdfColors.blue800)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 28),
                    pw.Divider(),
                    // Footer
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Thank you for choosing Vedika Healthcare!', style: pw.TextStyle(fontSize: 13, color: PdfColors.blueGrey)),
                            pw.Text('For support, contact us at support@vedikahealthcare.com', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text('Invoice Generated:', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                            pw.Text(indiaFormat.format(generatedDate), style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  // Save PDF to file and trigger download/print
  final output = await getTemporaryDirectory();
  final file = File('${output.path}/ambulance_invoice_${booking.requestId}.pdf');
  await file.writeAsBytes(await pdf.save());
  await Printing.sharePdf(bytes: await pdf.save(), filename: 'ambulance_invoice_${booking.requestId}.pdf');
}

pw.Widget _receiptRow(String label, double value) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(label, style: pw.TextStyle(fontSize: 12, color: PdfColors.blueGrey, fontWeight: pw.FontWeight.normal)),
      pw.Text('${value.toStringAsFixed(2)} INR', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey)),
    ],
  );
} 