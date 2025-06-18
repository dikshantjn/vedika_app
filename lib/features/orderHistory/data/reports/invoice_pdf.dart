import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:intl/intl.dart';

Future<void> generateAndDownloadInvoicePDF(MedicineOrderModel order) async {
  final pdf = pw.Document();

  // Format dates in Indian format and IST
  final indiaFormat = DateFormat('dd MMM yyyy, hh:mm a');
  final orderDate = order.createdAt.toLocal().add(const Duration(hours: 5, minutes: 30));
  final generatedDate = DateTime.now().toLocal().add(const Duration(hours: 5, minutes: 30));

  // Extract cost breakdown (with fallback to 0.0 if null)
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
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Colored Header Bar
            pw.Container(
              width: double.infinity,
              color: PdfColors.blue800,
              padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('VEDIKA HEALTHCARE', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                      pw.Text('INVOICE', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text('Order #${order.orderId}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
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
                  // Order Info
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Order Date: ${indiaFormat.format(orderDate)}', style: pw.TextStyle(fontSize: 12)),
                          pw.Text('Order Status: ${order.orderStatus}', style: pw.TextStyle(fontSize: 12)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Customer:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                          pw.Text(order.user.name ?? '-', style: pw.TextStyle(fontSize: 12)),
                          pw.Text(order.user.emailId ?? '-', style: pw.TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 18),
                  // Items Table Header
                  pw.Text('Order Items', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15, color: PdfColors.blue800)),
                  pw.SizedBox(height: 8),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(1),
                      3: const pw.FlexColumnWidth(1),
                    },
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.blue50),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Medicine', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Price (INR)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Total (INR)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                      ...order.orderItems.map((item) {
                        final mp = item.medicineProduct;
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(item.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                                  if (mp != null && mp.manufacturer.isNotEmpty)
                                    pw.Text('Manufacturer: ${mp.manufacturer}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                                  if (mp != null && mp.type.isNotEmpty)
                                    pw.Text('Type: ${mp.type}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                                  if (mp != null && mp.packSizeLabel.isNotEmpty)
                                    pw.Text('Pack Size: ${mp.packSizeLabel}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                                  if (mp != null && mp.shortComposition.isNotEmpty)
                                    pw.Text('Composition: ${mp.shortComposition}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                                ],
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text('x${item.quantity}', style: pw.TextStyle(fontSize: 12)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text('${item.price.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text('${(item.price * item.quantity).toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                  pw.SizedBox(height: 18),
                  // Cost Breakdown & Summary
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: PdfColors.blue200, width: 1),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          _summaryRow('Subtotal', subtotal),
                          _summaryRow('Delivery Charge', deliveryCharge),
                          _summaryRow('Platform Fee', platformFee),
                          _summaryRow('Discount', -discountAmount),
                          pw.Divider(),
                          pw.Row(
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Text('Total: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                              pw.Text('${totalAmount.toStringAsFixed(2)} INR', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16, color: PdfColors.blue800)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 24),
                  pw.Divider(),
                  // Footer
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Thank you for your purchase!', style: pw.TextStyle(fontSize: 13, color: PdfColors.blueGrey)),
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
        );
      },
    ),
  );

  // Save PDF to file and trigger download/print
  final output = await getTemporaryDirectory();
  final file = File('${output.path}/invoice_${order.orderId}.pdf');
  await file.writeAsBytes(await pdf.save());
  await Printing.sharePdf(bytes: await pdf.save(), filename: 'invoice_${order.orderId}.pdf');
}

// Helper for summary rows
pw.Widget _summaryRow(String label, double value) {
  return pw.Row(
    mainAxisSize: pw.MainAxisSize.min,
    children: [
      pw.Text('$label: ', style: pw.TextStyle(fontSize: 12)),
      pw.Text('${value >= 0 ? value.toStringAsFixed(2) : '-${value.abs().toStringAsFixed(2)}'} INR', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
    ],
  );
} 