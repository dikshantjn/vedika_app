import 'dart:typed_data';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/ProductOrder.dart';
import '../../../../features/Vendor/ProductPartner/data/models/product_partner_model.dart';

class ProductOrderInvoicePdf {
  static Future<Uint8List> generate(ProductOrder order) async {
    final pdf = pw.Document();
    final subtotal = _calculateSubtotal(order);
    final deliveryFee = _calculateDeliveryFee(subtotal);
    final gst = _calculateGST(subtotal);
    final total = _calculateTotal(subtotal, deliveryFee, gst);

    // Get the first product's vendor details safely
    final firstProduct = order.items?.firstOrNull?.vendorProduct?.productPartner;

    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader(font, boldFont),
          pw.SizedBox(height: 20),
          _buildOrderInfo(order, font, boldFont),
          pw.SizedBox(height: 20),
          _buildCustomerInfo(order),
          pw.SizedBox(height: 20),
          if (firstProduct != null) _buildVendorInfo(firstProduct),
          if (firstProduct != null) pw.SizedBox(height: 20),
          _buildItemsTable(order, font, boldFont),
          pw.SizedBox(height: 20),
          _buildCostSummary(subtotal, deliveryFee, gst, total, font, boldFont),
          pw.SizedBox(height: 20),
          _buildFooter(font),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(pw.Font font, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'VEDIKA HEALTHCARE',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 24,
              color: PdfColors.teal700,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Order Invoice',
            style: pw.TextStyle(
              font: font,
              fontSize: 16,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildOrderInfo(ProductOrder order, pw.Font font, pw.Font boldFont) {
    return pw.Container(
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
            'Order Details',
            style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.teal700),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Order ID', '#${order.orderId.substring(0, 8)}', font),
                  _buildInfoRow('Order Date', DateFormat('dd MMM yyyy').format(order.placedAt), font),
                  _buildInfoRow('Order Time', DateFormat('hh:mm a').format(order.placedAt), font),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Status', order.status, font),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCustomerInfo(ProductOrder order) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Customer Information',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoText('Name', order.user?.name ?? 'N/A'),
                    _buildInfoText('Phone', order.user?.phoneNumber ?? 'N/A'),
                    if (order.user?.emailId != null)
                      _buildInfoText('Email', order.user?.emailId ?? ''),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (order.user?.location != null)
                      _buildInfoText('Location', order.user?.location ?? ''),
                    if (order.user?.city != null)
                      _buildInfoText('City', order.user?.city ?? ''),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildVendorInfo(ProductPartner vendor) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Vendor Information',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoText('Brand Name', vendor.brandName),
                    _buildInfoText('Company Name', vendor.companyLegalName),
                    _buildInfoText('Phone', vendor.phoneNumber),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoText('Email', vendor.email),
                    _buildInfoText('City', vendor.city),
                    _buildInfoText('State', vendor.state),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(ProductOrder order, pw.Font font, pw.Font boldFont) {
    return pw.Container(
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
            'Order Items',
            style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.teal700),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _buildTableHeader('Product', font),
                  _buildTableHeader('Qty', font),
                  _buildTableHeader('Price', font),
                  _buildTableHeader('Total', font),
                ],
              ),
              ...order.items?.map((item) {
                final product = item.vendorProduct;
                return pw.TableRow(
                  children: [
                    _buildTableCell(product?.name ?? 'N/A', font),
                    _buildTableCell(item.quantity.toString(), font),
                    _buildTableCell('₹${item.priceAtPurchase.toStringAsFixed(2)}', font),
                    _buildTableCell(
                      '₹${(item.quantity * item.priceAtPurchase).toStringAsFixed(2)}',
                      font,
                    ),
                  ],
                );
              }).toList() ?? [],
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCostSummary(double subtotal, double deliveryFee, double gst, double total, pw.Font font, pw.Font boldFont) {
    return pw.Container(
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
            'Cost Details',
            style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.teal700),
          ),
          pw.SizedBox(height: 10),
          _buildCostRow('Items Total', subtotal, font),
          if (deliveryFee > 0)
            _buildCostRow('Delivery Fee', deliveryFee, font),
          _buildCostRow('GST (18%)', gst, font),
          pw.SizedBox(height: 5),
          pw.Divider(color: PdfColors.teal200),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Total Amount',
                style: pw.TextStyle(font: boldFont, fontSize: 12, color: PdfColors.teal700),
              ),
              pw.Text(
                '₹${total.toStringAsFixed(2)}',
                style: pw.TextStyle(font: boldFont, fontSize: 12, color: PdfColors.teal700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Font font) {
    final indiaFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final generatedDate = DateTime.now().toLocal();

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'Generated on: ${indiaFormat.format(generatedDate)}',
            style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600),
          ),
          pw.Text(
            'Thank you for shopping with Vedika Healthcare',
            style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(font: font, color: PdfColors.grey700),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(font: font, color: PdfColors.black),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoText(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label: ',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
            ),
            pw.TextSpan(
              text: value,
              style: const pw.TextStyle(
                color: PdfColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTableHeader(String text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, color: PdfColors.grey700),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font),
      ),
    );
  }

  static pw.Widget _buildCostRow(String label, double amount, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(font: font, color: PdfColors.grey700),
          ),
          pw.Text(
            '₹${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(font: font, color: PdfColors.black),
          ),
        ],
      ),
    );
  }

  static double _calculateSubtotal(ProductOrder order) {
    return order.items?.fold<double>(
      0,
      (sum, item) => sum + (item.quantity * item.priceAtPurchase),
    ) ?? 0;
  }

  static double _calculateDeliveryFee(double subtotal) {
    return subtotal >= 500 ? 0 : 40;
  }

  static double _calculateGST(double subtotal) {
    return subtotal * 0.18;
  }

  static double _calculateTotal(double subtotal, double deliveryFee, double gst) {
    return subtotal + deliveryFee + gst;
  }
}           