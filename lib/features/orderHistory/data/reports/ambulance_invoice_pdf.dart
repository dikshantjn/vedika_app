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

  // Define custom colors
  final primaryColor = PdfColor.fromHex('#1a237e'); // Deep Blue
  final secondaryColor = PdfColor.fromHex('#f5f5f5'); // Light Grey
  final accentColor = PdfColor.fromHex('#4caf50'); // Green
  final textColor = PdfColor.fromHex('#424242'); // Dark Grey
  final lightTextColor = PdfColor.fromHex('#757575'); // Medium Grey
  final primaryColorBorder = PdfColor.fromInt(0x331A237E); // primaryColor with 20% opacity
  final lightTextColorBorder = PdfColor.fromInt(0x33757575); // lightTextColor with 20% opacity

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (pw.Context context) {
        return pw.Container(
          width: double.infinity,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                color: primaryColor,
                padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'VEDIKA',
                          style: pw.TextStyle(
                            fontSize: 32,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        pw.Text(
                          'HEALTHCARE',
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.white,
                            letterSpacing: 5,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'INVOICE',
                            style: pw.TextStyle(
                              color: primaryColor,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '#${booking.requestId}',
                            style: pw.TextStyle(
                              color: lightTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Content
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 32),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Booking Details & Customer Info
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: _buildInfoSection(
                            'BOOKING DETAILS',
                            [
                              _buildInfoRow('Date', indiaFormat.format(booking.timestamp)),
                              _buildInfoRow('Status', booking.status),
                              _buildInfoRow('Booking ID', booking.requestId),
                            ],
                            backgroundColor: secondaryColor,
                          ),
                        ),
                        pw.SizedBox(width: 20),
                        pw.Expanded(
                          child: _buildInfoSection(
                            'CUSTOMER INFORMATION',
                            [
                              _buildInfoRow('Name', booking.user.name ?? '-'),
                              _buildInfoRow('Phone', booking.user.phoneNumber ?? '-'),
                              if (booking.user.emailId != null)
                                _buildInfoRow('Email', booking.user.emailId!),
                            ],
                            backgroundColor: secondaryColor,
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 25),

                    // Journey Details
                    _buildInfoSection(
                      'JOURNEY DETAILS',
                      [
                        _buildInfoRow('Vehicle Type', booking.vehicleType),
                        _buildInfoRow('From', booking.pickupLocation),
                        _buildInfoRow('To', booking.dropLocation),
                        _buildInfoRow('Distance', '${booking.totalDistance.toStringAsFixed(1)} km'),
                      ],
                      backgroundColor: PdfColors.white,
                      borderColor: primaryColorBorder,
                    ),

                    pw.SizedBox(height: 25),

                    // Cost Breakdown
                    pw.Container(
                      padding: const pw.EdgeInsets.all(20),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: primaryColorBorder),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            booking.isPaymentBypassed ? 'PAYMENT STATUS' : 'COST BREAKDOWN',
                            style: pw.TextStyle(
                              color: primaryColor,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 15),
                          if (booking.isPaymentBypassed) ...[
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  'Payment Waived',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 16,
                                    color: primaryColor,
                                  ),
                                ),
                                if (booking.bypassReason != null && booking.bypassReason!.isNotEmpty)
                                  pw.Text(
                                    'Reason: ${booking.bypassReason}',
                                    style: pw.TextStyle(
                                      fontSize: 12,
                                      color: lightTextColor,
                                    ),
                                  ),
                              ],
                            ),
                            if (booking.bypassApprovedBy != null && booking.bypassApprovedBy!.isNotEmpty) ...[
                              pw.SizedBox(height: 10),
                              pw.Text(
                                'Approved By: ${booking.bypassApprovedBy}',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  color: lightTextColor,
                                ),
                              ),
                            ],
                          ] else ...[
                            _buildCostRow('Base Charge', booking.baseCharge),
                            _buildCostRow('Distance Charge (${booking.costPerKm} INR/km)', 
                                      booking.totalDistance * booking.costPerKm),
                            pw.SizedBox(height: 15),
                            pw.Divider(color: lightTextColor),
                            pw.SizedBox(height: 15),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  'TOTAL AMOUNT',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 16,
                                    color: primaryColor,
                                  ),
                                ),
                                pw.Row(
                                  children: [
                                    pw.Text(
                                      '${booking.totalAmount.toStringAsFixed(2)} INR',
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 20,
                                        color: accentColor,
                                      ),
                                    ),
                                    pw.SizedBox(width: 8),
                                    pw.Text(
                                      '(Paid)',
                                      style: pw.TextStyle(
                                        fontSize: 12,
                                        color: accentColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 40),

                    // Footer
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(vertical: 20),
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          top: pw.BorderSide(color: lightTextColorBorder),
                        ),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Thank you for choosing Vedika Healthcare',
                                style: pw.TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'For support: support@vedikahealthcare.com',
                                style: pw.TextStyle(
                                  color: lightTextColor,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(
                                'Generated on',
                                style: pw.TextStyle(
                                  color: lightTextColor,
                                  fontSize: 10,
                                ),
                              ),
                              pw.Text(
                                indiaFormat.format(generatedDate),
                                style: pw.TextStyle(
                                  color: textColor,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  // Save and share PDF
  final output = await getTemporaryDirectory();
  final file = File('${output.path}/ambulance_invoice_${booking.requestId}.pdf');
  await file.writeAsBytes(await pdf.save());
  await Printing.sharePdf(bytes: await pdf.save(), filename: 'ambulance_invoice_${booking.requestId}.pdf');
}

// Helper function to build info sections
pw.Widget _buildInfoSection(String title, List<pw.Widget> content, {
  PdfColor backgroundColor = PdfColors.white,
  PdfColor borderColor = PdfColors.grey200,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(20),
    decoration: pw.BoxDecoration(
      color: backgroundColor,
      borderRadius: pw.BorderRadius.circular(15),
      border: pw.Border.all(color: borderColor),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            color: PdfColor.fromHex('#1a237e'),
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 15),
        ...content,
      ],
    ),
  );
}

// Helper function to build info rows
pw.Widget _buildInfoRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              color: PdfColor.fromHex('#757575'),
              fontSize: 10,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              color: PdfColor.fromHex('#424242'),
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

// Helper function to build cost rows
pw.Widget _buildCostRow(String label, double amount) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            color: PdfColor.fromHex('#757575'),
            fontSize: 12,
          ),
        ),
        pw.Text(
          '${amount.toStringAsFixed(2)} INR',
          style: pw.TextStyle(
            color: PdfColor.fromHex('#424242'),
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),
  );
} 