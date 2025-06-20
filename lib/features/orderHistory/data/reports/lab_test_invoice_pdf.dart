import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/LabTestBooking.dart';
import 'package:intl/intl.dart';

Future<void> generateAndDownloadLabTestInvoicePDF(LabTestBooking booking) async {
  try {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();
    final indiaFormat = DateFormat('dd MMM yyyy, hh:mm a');
    
    // Get current time in IST
    final now = DateTime.now();
    final generatedDate = now.toLocal();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Container(
            width: double.infinity,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'VEDIKA HEALTHCARE',
                            style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 24,
                              color: PdfColors.blue800,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Row(
                            children: [
                              pw.Text(
                                'Lab Test Invoice',
                                style: pw.TextStyle(
                                  font: font,
                                  fontSize: 14,
                                  color: PdfColors.grey700,
                                ),
                              ),
                              pw.SizedBox(width: 12),
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.blue100,
                                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                                ),
                                child: pw.Text(
                                  'ID: ${booking.bookingId ?? 'N/A'}',
                                  style: pw.TextStyle(
                                    font: boldFont,
                                    fontSize: 12,
                                    color: PdfColors.blue800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                          border: pw.Border.all(color: PdfColors.blue200),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              'Generated Date',
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 10,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              DateFormat('dd MMM yyyy').format(generatedDate),
                              style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 12,
                                color: PdfColors.blue800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Patient and Center Info Section
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Patient Information
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Patient Information',
                              style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 14,
                                color: PdfColors.blue800,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            _buildInfoRow('Name', booking.user?.name ?? 'N/A', font),
                            _buildInfoRow('Phone', booking.user?.phoneNumber ?? 'N/A', font),
                            if (booking.user?.emailId != null)
                              _buildInfoRow('Email', booking.user?.emailId ?? '', font),
                            if (booking.user?.gender != null)
                              _buildInfoRow('Gender', booking.user?.gender ?? '', font),
                            if (booking.user?.bloodGroup != null)
                              _buildInfoRow('Blood Group', booking.user?.bloodGroup ?? '', font),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 16),
                    // Diagnostic Center Information
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Diagnostic Center',
                              style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 14,
                                color: PdfColors.blue800,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            _buildInfoRow('Name', booking.diagnosticCenter?.name ?? 'N/A', font),
                            _buildInfoRow('Address', booking.diagnosticCenter?.address ?? 'N/A', font),
                            _buildInfoRow('City', booking.diagnosticCenter?.city ?? 'N/A', font),
                            _buildInfoRow('State', booking.diagnosticCenter?.state ?? 'N/A', font),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Booking Details Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Booking Details',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 14,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: _buildInfoRow('Booking Date', booking.bookingDate ?? 'N/A', font),
                          ),
                          pw.Expanded(
                            child: _buildInfoRow('Booking Time', booking.bookingTime ?? 'N/A', font),
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: _buildInfoRow('Collection Type', 
                              booking.homeCollectionRequired == true ? 'Home Collection' : 'At Center', 
                              font
                            ),
                          ),
                          pw.Expanded(
                            child: _buildInfoRow('Report Delivery', 
                              booking.reportDeliveryAtHome == true ? 'At Home' : 'At Center', 
                              font
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Tests Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Tests',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 14,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Column(
                        children: [
                          if (booking.selectedTests?.isNotEmpty ?? false)
                            ...(booking.selectedTests ?? []).map((test) => 
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                                child: pw.Row(
                                  children: [
                                    pw.Container(
                                      width: 4,
                                      height: 4,
                                      margin: const pw.EdgeInsets.only(right: 8),
                                      decoration: const pw.BoxDecoration(
                                        color: PdfColors.blue800,
                                        shape: pw.BoxShape.circle,
                                      ),
                                    ),
                                    pw.Text(
                                      test,
                                      style: pw.TextStyle(font: font, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ).toList()
                          else
                            pw.Text(
                              'No tests selected',
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 10,
                                color: PdfColors.grey700,
                                fontStyle: pw.FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Payment Details Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    border: pw.Border.all(color: PdfColors.blue200),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Payment Details',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 14,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      _buildPaymentRow('Test Fees', booking.testFees ?? 0.0, font),
                      if (booking.reportDeliveryFees != null && booking.reportDeliveryFees! > 0)
                        _buildPaymentRow('Delivery Fees', booking.reportDeliveryFees ?? 0.0, font),
                      if (booking.discount != null && booking.discount! > 0)
                        _buildPaymentRow('Discount', -(booking.discount ?? 0.0), font),
                      if (booking.gst != null && booking.gst! > 0)
                        _buildPaymentRow('GST', booking.gst ?? 0.0, font),
                      pw.Divider(color: PdfColors.blue200),
                      pw.SizedBox(height: 4),
                      _buildPaymentRow('Total Amount', booking.totalAmount ?? 0.0, font, isBold: true),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.green100,
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                            ),
                            child: pw.Text(
                              booking.paymentStatus?.toUpperCase() ?? 'PENDING',
                              style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 10,
                                color: PdfColors.green800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Footer
                pw.Spacer(),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 12),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Generated on: ${indiaFormat.format(generatedDate)}',
                        style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600),
                      ),
                      pw.Text(
                        'Thank you for choosing Vedika Healthcare',
                        style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600),
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
    final file = File('${output.path}/lab_test_invoice_${booking.bookingId ?? 'unknown'}.pdf');
    await file.writeAsBytes(await pdf.save());
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'lab_test_invoice_${booking.bookingId ?? 'unknown'}.pdf');
  } catch (e, stackTrace) {
    print('❌ Error generating lab test invoice PDF: $e');
    print('❌ Stack trace: $stackTrace');
    rethrow;
  }
}

pw.Widget _buildInfoRow(String label, String value, pw.Font font) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 80,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.Text(
          ': ',
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: PdfColors.black,
            ),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildPaymentRow(String label, double amount, pw.Font font, {bool isBold = false}) {
  final amountStr = amount >= 0 ? 
    '₹${amount.toStringAsFixed(2)}' : 
    '-₹${amount.abs().toStringAsFixed(2)}';

  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: font,
            fontSize: isBold ? 12 : 10,
            color: PdfColors.grey700,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          amountStr,
          style: pw.TextStyle(
            font: font,
            fontSize: isBold ? 12 : 10,
            color: PdfColors.black,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    ),
  );
} 