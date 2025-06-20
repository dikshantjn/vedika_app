import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vedika_healthcare/features/hospital/presentation/models/BedBooking.dart';
import 'package:intl/intl.dart';

Future<void> generateAndDownloadBedBookingInvoicePDF(BedBooking booking) async {
  final pdf = pw.Document();

  // Format dates in Indian format and IST
  final indiaFormat = DateFormat('dd MMM yyyy, hh:mm a');
  final bookingDate = booking.bookingDate.toLocal().add(const Duration(hours: 5, minutes: 30));
  final generatedDate = DateTime.now().toLocal().add(const Duration(hours: 5, minutes: 30));

  // Define custom colors
  final primaryBlue = PdfColor.fromHex('#1A237E');
  final secondaryBlue = PdfColor.fromHex('#3949AB');
  final lightBlue = PdfColor.fromHex('#E8EAF6');
  final borderColor = PdfColor.fromHex('#C5CAE9');
  final primaryBlueLight = PdfColor.fromInt(0x1A1A237E); // 10% opacity of primary blue

  // Define styles
  final headerStyle = pw.TextStyle(
    color: PdfColors.white,
    fontSize: 24,
    fontWeight: pw.FontWeight.bold,
  );
  final subHeaderStyle = pw.TextStyle(
    color: PdfColors.white,
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
  );
  final sectionTitleStyle = pw.TextStyle(
    color: primaryBlue,
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
  );
  final labelStyle = pw.TextStyle(
    color: PdfColors.grey800,
    fontSize: 10,
    fontWeight: pw.FontWeight.bold,
  );
  final valueStyle = pw.TextStyle(
    color: PdfColors.grey800,
    fontSize: 10,
  );

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: primaryBlue,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('VEDIKA HEALTHCARE', style: headerStyle),
                  pw.SizedBox(height: 4),
                  pw.Container(
                    width: 120,
                    height: 2,
                    margin: const pw.EdgeInsets.symmetric(vertical: 8),
                    color: PdfColors.white,
                  ),
                  pw.Text('BED BOOKING INVOICE', style: subHeaderStyle),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Invoice Info (Full Width)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: lightBlue,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: borderColor),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: primaryBlue,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          'INVOICE',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Text(
                        '#${booking.bedBookingId?.substring(0, 8) ?? 'N/A'}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: primaryBlue,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Booking Date', indiaFormat.format(bookingDate), labelStyle, valueStyle),
                            _buildInfoRow('Time Slot', booking.timeSlot, labelStyle, valueStyle),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 20),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Invoice Date', indiaFormat.format(generatedDate), labelStyle, valueStyle),
                            _buildInfoRow('Payment Status', booking.paymentStatus.toUpperCase(), labelStyle, valueStyle),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Hospital and Patient Details (Side by Side)
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Hospital Details
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: lightBlue,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: borderColor),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Hospital Details Header
                        pw.Row(
                          children: [
                            pw.Text('HOSPITAL DETAILS', style: sectionTitleStyle),
                          ],
                        ),
                        pw.SizedBox(height: 12),
                        pw.Text(
                          booking.hospital.name,
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          '${booking.hospital.address}, ${booking.hospital.city},\n${booking.hospital.state}',
                          style: valueStyle,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Contact: ${booking.hospital.contactNumber}', style: valueStyle),
                        pw.Text('Email: ${booking.hospital.email}', style: valueStyle),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),
                // Patient Details
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: lightBlue,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: borderColor),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Text('PATIENT DETAILS', style: sectionTitleStyle),
                          ],
                        ),
                        pw.SizedBox(height: 12),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            borderRadius: pw.BorderRadius.circular(6),
                            border: pw.Border.all(color: borderColor),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow('Name', booking.user.name ?? 'N/A', labelStyle, valueStyle),
                              _buildInfoRow('Phone', booking.user.phoneNumber ?? 'N/A', labelStyle, valueStyle),
                              if (booking.user.emailId != null && booking.user.emailId!.isNotEmpty)
                                _buildInfoRow('Email', booking.user.emailId!, labelStyle, valueStyle),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),

            // Booking Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: lightBlue,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: borderColor),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Booking Summary Header
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('BOOKING SUMMARY', style: sectionTitleStyle),
                      if (booking.paymentStatus.toLowerCase() == 'paid')
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('#E8F5E9'),
                            borderRadius: pw.BorderRadius.circular(4),
                            border: pw.Border.all(color: PdfColor.fromHex('#81C784')),
                          ),
                          child: pw.Text(
                            'PAID',
                            style: pw.TextStyle(
                              color: PdfColor.fromHex('#2E7D32'),
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  // Summary Table
                  pw.Table(
                    border: pw.TableBorder.all(color: borderColor),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(2),
                    },
                    children: [
                      // Table Header
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: secondaryBlue),
                        children: [
                          _buildTableCell('Description', isHeader: true),
                          _buildTableCell('Duration', isHeader: true),
                          _buildTableCell('Amount', isHeader: true),
                        ],
                      ),
                      // Table Data
                      pw.TableRow(
                        children: [
                          _buildTableCell('${booking.bedType} Bed Charges'),
                          _buildTableCell('1 Day'),
                          _buildTableCell('${booking.price.toStringAsFixed(2)} INR'),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  // Total Amount
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: secondaryBlue,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'TOTAL AMOUNT',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        pw.Text(
                          '${booking.price.toStringAsFixed(2)} INR',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Footer
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 12),
              decoration: pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: borderColor)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Thank you for choosing Vedika Healthcare!',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: secondaryBlue,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'For support, contact us at support@vedikahealthcare.com',
                        style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Generated on:',
                        style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                      ),
                      pw.Text(
                        indiaFormat.format(generatedDate),
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey800,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  // Save PDF to file and trigger download/print
  final output = await getTemporaryDirectory();
  final file = File('${output.path}/bed_booking_invoice_${booking.bedBookingId ?? 'unknown'}.pdf');
  await file.writeAsBytes(await pdf.save());
  await Printing.sharePdf(bytes: await pdf.save(), filename: 'bed_booking_invoice_${booking.bedBookingId ?? 'unknown'}.pdf');
}

pw.Widget _buildInfoRow(String label, String value, pw.TextStyle labelStyle, pw.TextStyle valueStyle) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 80,
          child: pw.Text(label, style: labelStyle),
        ),
        pw.Text(': ', style: labelStyle),
        pw.Expanded(
          child: pw.Text(value, style: valueStyle),
        ),
      ],
    ),
  );
}

pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        color: isHeader ? PdfColors.white : PdfColors.grey800,
        fontSize: 10,
        fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );
} 