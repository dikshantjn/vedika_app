import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankBooking.dart';
import 'package:intl/intl.dart';

Future<void> generateAndDownloadBloodBankInvoicePDF(BloodBankBooking booking) async {
  try {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();
    final indiaFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final generatedDate = DateTime.now().toLocal().add(const Duration(hours: 5, minutes: 30));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Container(
            width: double.infinity,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header with Logo and Title
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'VEDIKA HEALTHTECH',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 24,
                            color: PdfColors.red800,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Blood Bank Invoice',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 16,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.red200),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      ),
                      child: pw.Text(
                        'Blood Bank\nServices',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 12,
                          color: PdfColors.red800,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),

                // Booking Information
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Booking Details',
                        style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.red800),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Booking ID', booking.bookingId ?? 'N/A', font),
                                _buildInfoRow('Booking Date', DateFormat('dd MMM yyyy').format(booking.createdAt), font),
                                _buildInfoRow('Status', booking.status ?? 'N/A', font),
                              ],
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Blood Group', booking.bloodType.isNotEmpty ? booking.bloodType[0] : 'N/A', font),
                                _buildInfoRow('Units', '${booking.units} Units', font),
                                _buildInfoRow('Delivery Type', booking.deliveryType ?? 'N/A', font),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Agency Information
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Blood Bank Agency',
                        style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.red800),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        booking.agency?.agencyName ?? 'N/A',
                        style: pw.TextStyle(font: boldFont, fontSize: 12),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        '${booking.agency?.completeAddress ?? ''}, ${booking.agency?.city ?? ''}, ${booking.agency?.state ?? ''}',
                        style: pw.TextStyle(font: font, fontSize: 10),
                      ),
                      if (booking.agency?.phoneNumber != null) ...[
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Contact: ${booking.agency?.phoneNumber}',
                          style: pw.TextStyle(font: font, fontSize: 10),
                        ),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // User Information
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Recipient Details',
                        style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.red800),
                      ),
                      pw.SizedBox(height: 10),
                      _buildInfoRow('Name', booking.user.name ?? 'N/A', font),
                      _buildInfoRow('Phone', booking.user.phoneNumber ?? 'N/A', font),
                      if (booking.user.emailId != null)
                        _buildInfoRow('Email', booking.user.emailId ?? '', font),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Cost Details
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red50,
                    border: pw.Border.all(color: PdfColors.red200),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Cost Details',
                        style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.red800),
                      ),
                      pw.SizedBox(height: 10),
                      _buildCostRow('Price per Unit', booking.totalAmount / (booking.units > 0 ? booking.units : 1), font),
                      _buildCostRow('Number of Units', booking.units.toDouble(), font),
                      if (booking.deliveryFees > 0)
                        _buildCostRow('Delivery Fee', booking.deliveryFees, font),
                      if (booking.gst > 0)
                        _buildCostRow(
                          'GST (${booking.gst}%)',
                          (booking.totalAmount + booking.deliveryFees) * booking.gst / 100,
                          font,
                        ),
                      if (booking.discount > 0)
                        _buildCostRow('Discount', -booking.discount, font),
                      pw.SizedBox(height: 5),
                      pw.Divider(color: PdfColors.red200),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Total Amount',
                            style: pw.TextStyle(font: boldFont, fontSize: 12, color: PdfColors.red800),
                          ),
                          pw.Text(
                            '₹${booking.totalAmount.toStringAsFixed(2)}',
                            style: pw.TextStyle(font: boldFont, fontSize: 12, color: PdfColors.red800),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Payment Status',
                            style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700),
                          ),
                          pw.Text(
                            booking.paymentStatus,
                            style: pw.TextStyle(font: boldFont, fontSize: 10, color: PdfColors.grey700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.Spacer(),
                
                // Footer
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 10),
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
    final file = File('${output.path}/blood_bank_invoice_${booking.bookingId ?? 'unknown'}.pdf');
    await file.writeAsBytes(await pdf.save());
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'blood_bank_invoice_${booking.bookingId ?? 'unknown'}.pdf');
  } catch (e, stackTrace) {
    print('❌ Error generating blood bank invoice PDF: $e');
    print('❌ Stack trace: $stackTrace');
    rethrow;
  }
}

pw.Widget _buildInfoRow(String label, String value, pw.Font font) {
  return pw.Container(
    margin: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 100,
          child: pw.Text(
            label,
            style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700),
          ),
        ),
        pw.Text(
          ': ',
          style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(font: font, fontSize: 10),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildCostRow(String label, double amount, pw.Font font) {
  return pw.Container(
    margin: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700),
        ),
        pw.Text(
          '₹${amount.toStringAsFixed(2)}',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
      ],
    ),
  );
} 