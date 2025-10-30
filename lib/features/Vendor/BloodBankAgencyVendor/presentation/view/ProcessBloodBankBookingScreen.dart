import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankBooking.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/viewModel/BloodBankBookingViewModel.dart';
import 'package:flutter/services.dart';
import 'package:vedika_healthcare/core/view/DocumentPreviewScreen.dart';

class ProcessBloodBankBookingScreen extends StatefulWidget {
  final BloodBankBooking booking;

  const ProcessBloodBankBookingScreen({Key? key, required this.booking}) : super(key: key);

  @override
  State<ProcessBloodBankBookingScreen> createState() => _ProcessBloodBankBookingScreenState();
}

class _ProcessBloodBankBookingScreenState extends State<ProcessBloodBankBookingScreen> {
  bool _isProcessing = false;
  int? _selectedPrescriptionIndex;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _unitsController = TextEditingController();
  final TextEditingController _pricePerUnitController = TextEditingController();
  final TextEditingController _deliveryTypeController = TextEditingController();

  String _formatDeliveryType(String? raw) {
    if (raw == null) return '';
    final key = raw.trim().toUpperCase();
    switch (key) {
      case 'HOME_DELIVERY':
        return 'Home Delivery';
      case 'SELF_PICKUP':
        return 'Self Pickup';
      default:
        return raw.trim();
    }
  }

  @override
  void initState() {
    super.initState();
    // Listen to changes in the booking status
    context.read<BloodBankBookingViewModel>().addListener(_onBookingUpdated);
  }

  void _onBookingUpdated() {
    if (mounted) {
      setState(() {
        // Update the local booking with the latest data from ViewModel
        final updatedBooking = context.read<BloodBankBookingViewModel>().getBookingById(widget.booking.bookingId!);
        if (updatedBooking != null) {
          widget.booking.status = updatedBooking.status;
          widget.booking.paymentStatus = updatedBooking.paymentStatus;
          widget.booking.totalAmount = updatedBooking.totalAmount;
        }
      });
    }
  }

  @override
  void dispose() {
    context.read<BloodBankBookingViewModel>().removeListener(_onBookingUpdated);
    _notesController.dispose();
    _totalAmountController.dispose();
    _discountController.dispose();
    _unitsController.dispose();
    _pricePerUnitController.dispose();
    _deliveryTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Process Blood Booking',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.blue.shade700,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Booking Status: ${widget.booking.status.toUpperCase()}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Request details card
                Expanded(
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.medical_services,
                                  color: theme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Booking Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  _buildInfoRow(
                                    icon: Icons.person,
                                    label: 'Patient Name',
                                    value: widget.booking.user?.name ?? 'Anonymous',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    icon: Icons.bloodtype,
                                    label: 'Blood Type',
                                    value: widget.booking.bloodType.join(", "),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    icon: Icons.bloodtype,
                                    label: 'Units Required',
                                    value: '${widget.booking.bloodRequest?.units ?? 1}',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    icon: Icons.calendar_today,
                                    label: 'Request Date',
                                    value: dateFormat.format(widget.booking.createdAt),
                                  ),
                                  const SizedBox(height: 16),
                                  // Payment Details Section
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.08),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.receipt_long, size: 18, color: Colors.red),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Payment Details',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                            ),
                                            const Spacer(),
                                            OutlinedButton.icon(
                                              onPressed: _isProcessing ? null : _showNotifyPaymentDialog,
                                              icon: const Icon(Icons.edit, size: 16),
                                              label: const Text('Edit'),
                                              style: OutlinedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        _buildKeyValue('Notes', widget.booking.notes?.toString().trim().isNotEmpty == true ? widget.booking.notes! : '-'),
                                        const SizedBox(height: 8),
                                        _buildKeyValue('Total Amount', widget.booking.totalAmount != null ? '₹${widget.booking.totalAmount!.toStringAsFixed(2)}' : '-'),
                                        const SizedBox(height: 8),
                                        _buildKeyValue('Discount', (widget.booking.discount is num) ? '₹${(widget.booking.discount as num).toStringAsFixed(2)}' : (widget.booking.discount?.toString() ?? '-')),
                                        const SizedBox(height: 8),
                                        _buildKeyValue('Units', (widget.booking.units != null) ? widget.booking.units.toString() : (widget.booking.bloodRequest?.units?.toString() ?? '-')),
                                        const SizedBox(height: 8),
                                        _buildKeyValue('Price Per Unit', (widget.booking.pricePerUnit is num) ? '₹${(widget.booking.pricePerUnit as num).toStringAsFixed(2)}' : (widget.booking.pricePerUnit?.toString() ?? '-')),
                                        const SizedBox(height: 8),
                                        _buildKeyValue('Delivery Type', _formatDeliveryType(widget.booking.deliveryType).isNotEmpty ? _formatDeliveryType(widget.booking.deliveryType) : '-'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Prescription Section
                                  if (widget.booking.bloodRequest?.prescriptionUrls.isNotEmpty ?? false) ...[
                                    Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: Colors.purple.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.description,
                                            color: Colors.purple,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Prescription',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        for (int i = 0; i < widget.booking.bloodRequest!.prescriptionUrls.length; i++) ...[
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: OutlinedButton.icon(
                                              onPressed: () {
                                                final url = widget.booking.bloodRequest!.prescriptionUrls[i];
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) => DocumentPreviewScreen(
                                                      url: url,
                                                      title: 'Prescription ${i + 1}',
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.visibility_outlined, size: 18),
                                              label: Text('View Prescription ${i + 1}'),
                                              style: OutlinedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Action buttons based on status
                if (widget.booking.status.toLowerCase() == 'confirmed')
                  _buildNotifyPaymentButton()
                else if (widget.booking.status.toLowerCase() == 'paymentcompleted')
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _markAsWaitingForPickup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: _isProcessing
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.local_shipping),
                      label: _isProcessing
                          ? const Text(
                              'Processing...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : const Text(
                              'Mark as Waiting for Pickup',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  )
                else if (widget.booking.status.toLowerCase() == 'waitingforpickup')
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _markAsCompleted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: _isProcessing
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.check_circle),
                      label: _isProcessing
                          ? const Text(
                              'Processing...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : const Text(
                              'Mark as Completed',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Prescription Photo Viewer
          if (_selectedPrescriptionIndex != null && 
              widget.booking.bloodRequest != null && 
              widget.booking.bloodRequest!.prescriptionUrls.isNotEmpty)
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPrescriptionIndex = null;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.9),
                child: Stack(
                  children: [
                    Center(
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Image.network(
                          widget.booking.bloodRequest!.prescriptionUrls[_selectedPrescriptionIndex!],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 20,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedPrescriptionIndex = null;
                          });
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyValue(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _markAsWaitingForPickup() async {
    if (widget.booking.bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error!',
            message: 'Booking ID is missing',
            contentType: ContentType.failure,
          ),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await context.read<BloodBankBookingViewModel>().updateBookingStatus(
        widget.booking.bookingId!,
        'waitingforpickup',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Success!',
              message: 'Booking marked as waiting for pickup',
              contentType: ContentType.success,
            ),
          ),
        );
        // Update local state instead of navigating back
        setState(() {
          widget.booking.status = 'waitingforpickup';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Error!',
              message: 'Error updating status: $e',
              contentType: ContentType.failure,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _markAsCompleted() async {
    if (widget.booking.bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error!',
            message: 'Booking ID is missing',
            contentType: ContentType.failure,
          ),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await context.read<BloodBankBookingViewModel>().updateBookingStatus(
        widget.booking.bookingId!,
        'completed',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Success!',
              message: 'Booking marked as completed',
              contentType: ContentType.success,
            ),
          ),
        );
        // Update local state instead of navigating back
        setState(() {
          widget.booking.status = 'completed';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Error!',
              message: 'Error updating status: $e',
              contentType: ContentType.failure,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _showNotifyPaymentDialog() async {
    // Prefill with existing values
    _notesController.text = widget.booking.notes ?? '';
    _totalAmountController.text = widget.booking.totalAmount != null
        ? widget.booking.totalAmount!.toStringAsFixed(2)
        : '';
    _discountController.text = (widget.booking.discount is num)
        ? (widget.booking.discount as num).toStringAsFixed(2)
        : (widget.booking.discount?.toString() ?? '');
    _unitsController.text = (widget.booking.units ?? widget.booking.bloodRequest?.units)?.toString() ?? '';
    _pricePerUnitController.text = (widget.booking.pricePerUnit is num)
        ? (widget.booking.pricePerUnit as num).toStringAsFixed(2)
        : (widget.booking.pricePerUnit?.toString() ?? '');
    _deliveryTypeController.text = widget.booking.deliveryType ?? '';

    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.payment,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Update Payment Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Enter any additional notes',
                      prefixIcon: const Icon(Icons.note),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _totalAmountController,
                    decoration: InputDecoration(
                      labelText: 'Total Amount',
                      hintText: 'Enter total amount',
                      prefixIcon: const Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _discountController,
                    decoration: InputDecoration(
                      labelText: 'Discount',
                      hintText: 'Enter discount amount',
                      prefixIcon: const Icon(Icons.discount),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _unitsController,
                    decoration: InputDecoration(
                      labelText: 'Units',
                      hintText: 'Enter number of units',
                      prefixIcon: const Icon(Icons.bloodtype),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _pricePerUnitController,
                    decoration: InputDecoration(
                      labelText: 'Price per Unit',
                      hintText: 'Enter price per unit',
                      prefixIcon: const Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _deliveryTypeController.text.isEmpty ? null : _deliveryTypeController.text,
                    decoration: InputDecoration(
                      labelText: 'Delivery Type',
                      hintText: 'Select delivery type',
                      prefixIcon: const Icon(Icons.delivery_dining),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'SELF_PICKUP',
                        child: Text('Pickup'),
                      ),
                      DropdownMenuItem(
                        value: 'HOME_DELIVERY',
                        child: Text('Delivery'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        _deliveryTypeController.text = value;
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : () async {
                                if (widget.booking.bookingId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      elevation: 0,
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.transparent,
                                      content: AwesomeSnackbarContent(
                                        title: 'Error!',
                                        message: 'Booking ID is missing',
                                        contentType: ContentType.failure,
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  _isProcessing = true;
                                });

                                try {
                                  await context.read<BloodBankBookingViewModel>().notifyUser(
                                    widget.booking.bookingId!,
                                    notes: _notesController.text.isNotEmpty
                                        ? _notesController.text
                                        : null,
                                    totalAmount: _totalAmountController.text.isNotEmpty
                                        ? double.parse(_totalAmountController.text)
                                        : null,
                                    discount: _discountController.text.isNotEmpty
                                        ? double.parse(_discountController.text)
                                        : null,
                                    units: _unitsController.text.isNotEmpty
                                        ? int.parse(_unitsController.text)
                                        : null,
                                    pricePerUnit: _pricePerUnitController.text.isNotEmpty
                                        ? double.parse(_pricePerUnitController.text)
                                        : null,
                                    deliveryType: _deliveryTypeController.text.isNotEmpty
                                        ? _deliveryTypeController.text
                                        : null,
                                  );

                                  if (mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        elevation: 0,
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.transparent,
                                        content: AwesomeSnackbarContent(
                                          title: 'Success!',
                                          message: 'Payment details notified to user',
                                          contentType: ContentType.success,
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        elevation: 0,
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.transparent,
                                        content: AwesomeSnackbarContent(
                                          title: 'Error!',
                                          message: 'Error notifying user: $e',
                                          contentType: ContentType.failure,
                                        ),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isProcessing = false;
                                    });
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: _isProcessing
                            ? const Text('Processing...')
                            : const Text('Update and Notify'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotifyPaymentButton() {
    // Don't show the button if payment is completed
    if (widget.booking.status.toLowerCase() == 'paymentcompleted' ||
        widget.booking.paymentStatus?.toLowerCase() == 'paid') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'Payment Completed',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: ₹${widget.booking.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _showNotifyPaymentDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: _isProcessing
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.notifications),
        label: _isProcessing
            ? const Text(
                'Processing...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              )
            : const Text(
                'Notify Payment to User',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
} 