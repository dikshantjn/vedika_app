import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:intl/intl.dart';

Future<void> generateAndDownloadInvoicePDF(MedicineOrderModel order) async {
  try {
    final pdf = pw.Document();

    // Format dates in Indian format and IST
    final indiaFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final orderDate = order.createdAt.toLocal().add(const Duration(hours: 5, minutes: 30));
    final generatedDate = DateTime.now().toLocal().add(const Duration(hours: 5, minutes: 30));

    // Define custom colors
    final primaryColor = PdfColor.fromHex('#1a237e'); // Deep Blue
    final secondaryColor = PdfColor.fromHex('#f5f5f5'); // Light Grey
    final accentColor = PdfColor.fromHex('#4caf50'); // Green
    final textColor = PdfColor.fromHex('#424242'); // Dark Grey
    final lightTextColor = PdfColor.fromHex('#757575'); // Medium Grey
    final primaryColorBorder = PdfColor.fromInt(0x331A237E); // primaryColor with 20% opacity

    // Extract cost breakdown
    final subtotal = order.subtotal;
    final deliveryCharge = (order as dynamic).deliveryCharge ?? 0.0;
    final platformFee = (order as dynamic).platformFee ?? 0.0;
    final discountAmount = order.discountAmount;
    final totalAmount = order.totalAmount;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pw.Container(
            width: double.infinity,
            height: double.infinity,
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.max,
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
                              '#${order.orderId}',
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
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 32),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Order Info & Customer Details
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Expanded(
                              child: _buildInfoSection(
                                'ORDER DETAILS',
                                [
                                  _buildInfoRow('Date', indiaFormat.format(orderDate)),
                                  _buildInfoRow('Status', order.orderStatus),
                                  _buildInfoRow('Order ID', order.orderId),
                                ],
                                backgroundColor: secondaryColor,
                              ),
                            ),
                            pw.SizedBox(width: 20),
                            pw.Expanded(
                              child: _buildInfoSection(
                                'CUSTOMER INFORMATION',
                                [
                                  _buildInfoRow('Name', order.user.name ?? '-'),
                                  _buildInfoRow('Email', order.user.emailId ?? '-'),
                                  _buildInfoRow('Phone', order.user.phoneNumber ?? '-'),
                                ],
                                backgroundColor: secondaryColor,
                              ),
                            ),
                          ],
                        ),

                        pw.SizedBox(height: 25),

                        // Items Table
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            borderRadius: pw.BorderRadius.circular(8),
                            border: pw.Border.all(color: primaryColorBorder),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Container(
                                padding: const pw.EdgeInsets.all(15),
                                decoration: pw.BoxDecoration(
                                  color: secondaryColor,
                                  borderRadius: pw.BorderRadius.only(
                                    topLeft: pw.Radius.circular(8),
                                    topRight: pw.Radius.circular(8),
                                  ),
                                ),
                                child: pw.Text(
                                  'ORDER ITEMS',
                                  style: pw.TextStyle(
                                    color: primaryColor,
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                              pw.Table(
                                border: pw.TableBorder(
                                  horizontalInside: pw.BorderSide(color: PdfColor.fromInt(0x66757575)),
                                ),
                                columnWidths: {
                                  0: const pw.FlexColumnWidth(3),
                                  1: const pw.FlexColumnWidth(1),
                                  2: const pw.FlexColumnWidth(1),
                                  3: const pw.FlexColumnWidth(1.2),
                                },
                                children: [
                                  pw.TableRow(
                                    children: [
                                      _buildTableHeader('Medicine'),
                                      _buildTableHeader('Qty'),
                                      _buildTableHeader('Price'),
                                      _buildTableHeader('Total'),
                                    ],
                                  ),
                                  ...order.orderItems.map((item) {
                                    final mp = item.medicineProduct;
                                    return pw.TableRow(
                                      children: [
                                        pw.Padding(
                                          padding: const pw.EdgeInsets.all(12),
                                          child: pw.Column(
                                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.Text(
                                                item.name,
                                                style: pw.TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: pw.FontWeight.bold,
                                                  color: textColor,
                                                ),
                                              ),
                                              pw.SizedBox(height: 4),
                                              if (mp != null && mp.manufacturer.isNotEmpty)
                                                _buildItemDetail('Manufacturer', mp.manufacturer),
                                              if (mp != null && mp.type.isNotEmpty)
                                                _buildItemDetail('Type', mp.type),
                                              if (mp != null && mp.packSizeLabel.isNotEmpty)
                                                _buildItemDetail('Pack Size', mp.packSizeLabel),
                                              if (mp != null && mp.shortComposition.isNotEmpty)
                                                _buildItemDetail('Composition', mp.shortComposition),
                                            ],
                                          ),
                                        ),
                                        _buildTableCell('x${item.quantity}'),
                                        _buildTableCell('${item.price.toStringAsFixed(2)} INR'),
                                        _buildTableCell(
                                          '${(item.price * item.quantity).toStringAsFixed(2)} INR',
                                          isBold: true,
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),
                            ],
                          ),
                        ),

                        pw.SizedBox(height: 25),

                        // Cost Summary
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
                                'COST BREAKDOWN',
                                style: pw.TextStyle(
                                  color: primaryColor,
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 15),
                              _buildCostRow('Subtotal', subtotal),
                              _buildCostRow('Delivery Charge', deliveryCharge),
                              _buildCostRow('Platform Fee', platformFee),
                              _buildCostRow('Discount', -discountAmount),
                              pw.SizedBox(height: 15),
                              pw.Divider(color: PdfColor.fromInt(0x66757575)),
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
                                  pw.Text(
                                    '${totalAmount.toStringAsFixed(2)} INR',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 20,
                                      color: accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        pw.SizedBox(height: 40),

                        // Footer
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(vertical: 20),
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              top: pw.BorderSide(color: PdfColor.fromInt(0x66757575)),
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
                ),
              ],
            ),
          );
        },
      ),
    );

    // Save and share PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/invoice_${order.orderId}.pdf');
    final pdfBytes = await pdf.save();
    
    if (pdfBytes.isEmpty) {
      print('Warning: PDF bytes are empty');
      return;
    }
    
    await file.writeAsBytes(pdfBytes);
    await Printing.sharePdf(bytes: pdfBytes, filename: 'invoice_${order.orderId}.pdf');
    
  } catch (e, stackTrace) {
    print('Error generating PDF: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}

// Helper function to build info sections
pw.Widget _buildInfoSection(String title, List<pw.Widget> content, {
  PdfColor backgroundColor = PdfColors.white,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(20),
    decoration: pw.BoxDecoration(
      color: backgroundColor,
      borderRadius: pw.BorderRadius.circular(8),
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
          width: 80,
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

// Helper function to build table headers
pw.Widget _buildTableHeader(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(12),
    child: pw.Text(
      text.toUpperCase(),
      style: pw.TextStyle(
        fontSize: 10,
        color: PdfColor.fromHex('#1a237e'),
        fontWeight: pw.FontWeight.bold,
      ),
    ),
  );
}

// Helper function to build table cells
pw.Widget _buildTableCell(String text, {bool isBold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(12),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 11,
        fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: PdfColor.fromHex('#424242'),
      ),
    ),
  );
}

// Helper function to build item details
pw.Widget _buildItemDetail(String label, String value) {
  return pw.Text(
    '$label: $value',
    style: pw.TextStyle(
      fontSize: 10,
      color: PdfColor.fromHex('#757575'),
    ),
  );
}

// Helper function to build cost rows
pw.Widget _buildCostRow(String label, double value) {
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
          '${value >= 0 ? value.toStringAsFixed(2) : '-${value.abs().toStringAsFixed(2)}'} INR',
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