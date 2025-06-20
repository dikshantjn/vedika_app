import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';
import 'package:intl/intl.dart';

Future<void> generateAndDownloadClinicAppointmentInvoicePDF(ClinicAppointment appointment) async {
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
                          'VEDIKA HEALTHCARE',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 24,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Doctor Consultation Invoice',
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
                        border: pw.Border.all(color: PdfColors.blue200),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      ),
                      child: pw.Text(
                        'Doctor\nConsultation',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 12,
                          color: PdfColors.blue800,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),

                // Appointment Information
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
                        'Appointment Details',
                        style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.blue800),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Appointment ID', appointment.clinicAppointmentId, font),
                                _buildInfoRow('Appointment Date', DateFormat('dd MMM yyyy').format(appointment.date), font),
                                _buildInfoRow('Appointment Time', appointment.time, font),
                              ],
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Status', appointment.status, font),
                                _buildInfoRow('Type', appointment.isOnline ? 'Online Consultation' : 'In-clinic Visit', font),
                                _buildInfoRow('Payment Status', appointment.paymentStatus, font),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Doctor Information
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
                        'Doctor Details',
                        style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.blue800),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        appointment.doctor?.doctorName ?? 'N/A',
                        style: pw.TextStyle(font: boldFont, fontSize: 12),
                      ),
                      pw.SizedBox(height: 5),
                      if (appointment.doctor?.specializations.isNotEmpty == true)
                        pw.Text(
                          appointment.doctor!.specializations.first,
                          style: pw.TextStyle(font: font, fontSize: 10),
                        ),
                      if (appointment.doctor?.experienceYears != null) ...[
                        pw.SizedBox(height: 5),
                        pw.Text(
                          '${appointment.doctor?.experienceYears} years of experience',
                          style: pw.TextStyle(font: font, fontSize: 10),
                        ),
                      ],
                      if (appointment.doctor?.address != null) ...[
                        pw.SizedBox(height: 5),
                        pw.Text(
                          appointment.doctor!.address,
                          style: pw.TextStyle(font: font, fontSize: 10),
                        ),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Patient Information
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
                        'Patient Details',
                        style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.blue800),
                      ),
                      pw.SizedBox(height: 10),
                      _buildInfoRow('Name', appointment.user?.name ?? 'N/A', font),
                      _buildInfoRow('Phone', appointment.user?.phoneNumber ?? 'N/A', font),
                      if (appointment.user?.emailId != null)
                        _buildInfoRow('Email', appointment.user?.emailId ?? '', font),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Payment Details
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
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
                        style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.blue800),
                      ),
                      pw.SizedBox(height: 10),
                      _buildCostRow('Consultation Fee', appointment.paidAmount, font),
                      pw.SizedBox(height: 5),
                      pw.Divider(color: PdfColors.blue200),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Total Amount',
                            style: pw.TextStyle(font: boldFont, fontSize: 12, color: PdfColors.blue800),
                          ),
                          pw.Text(
                            '₹${appointment.paidAmount.toStringAsFixed(2)}',
                            style: pw.TextStyle(font: boldFont, fontSize: 12, color: PdfColors.blue800),
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
    final file = File('${output.path}/clinic_appointment_invoice_${appointment.clinicAppointmentId}.pdf');
    await file.writeAsBytes(await pdf.save());
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'clinic_appointment_invoice_${appointment.clinicAppointmentId}.pdf');
  } catch (e, stackTrace) {
    print('❌ Error generating clinic appointment invoice PDF: $e');
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