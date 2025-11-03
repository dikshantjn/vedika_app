import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Order.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/OrderMedicine.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/NewOrders/NewOrdersViewModel.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/NewOrders/PrescriptionPreviewScreen.dart';

class NewProcessOrderScreen extends StatefulWidget {
  final Order order;

  const NewProcessOrderScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<NewProcessOrderScreen> createState() => _NewProcessOrderScreenState();
}

class MedicineItem {
  final String id;
  String name;
  int quantity;
  double price;

  MedicineItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });
}

class _NewProcessOrderScreenState extends State<NewProcessOrderScreen> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _deliveryChargeController = TextEditingController();
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _medicineQtyController = TextEditingController();
  final TextEditingController _medicinePriceController = TextEditingController();
  
  String _selectedStatus = 'waiting for payment';
  bool _isLoading = false;
  bool _isFetchingDetails = false;
  bool _isDeleting = false; // Track delete operation state
  String _currentStatus = ''; // Track current status for immediate UI updates
  List<MedicineItem> _medicineItems = [];
  Order? _orderDetails; // Full order details with medicines
  String? _deletingMedicineId; // Track which medicine is being deleted

  @override
  void initState() {
    super.initState();
    // Initialize current status
    _currentStatus = widget.order.status;
    // Map any existing status to a valid dropdown value
    _selectedStatus = _mapStatusToValidValue(_currentStatus);
    if (widget.order.note != null) {
      _noteController.text = widget.order.note!;
    }
    // Initialize discount and delivery charge if needed
    _deliveryChargeController.text = '0.0';
    _discountController.text = '0.0';
    
    // Fetch order details on init
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isFetchingDetails = true;
    });

    try {
      final viewModel = context.read<NewOrdersViewModel>();
      final orderDetails = await viewModel.getOrderDetails(widget.order.orderId);
      
      if (mounted && orderDetails != null) {
        setState(() {
          _orderDetails = orderDetails;
          _currentStatus = orderDetails.status;
          _selectedStatus = _mapStatusToValidValue(_currentStatus);
          
          // Update note if available
          if (orderDetails.note != null && orderDetails.note!.isNotEmpty) {
            _noteController.text = orderDetails.note!;
          }
          
          // Don't populate _medicineItems with existing medicines
          // _medicineItems should only contain newly added medicines (not yet saved)
          _medicineItems = [];
          
          // Populate billing details
          if (orderDetails.subtotal > 0) {
            // Discount from backend is already a percentage (e.g., "10.00" = 10%)
            if (orderDetails.discount > 0) {
              _discountController.text = orderDetails.discount.toStringAsFixed(1);
            }
            
            // Set delivery charge if it exists
            if (orderDetails.deliveryCharges > 0) {
              _deliveryChargeController.text = orderDetails.deliveryCharges.toStringAsFixed(2);
            }
            // Note: GST is fixed at 18% by backend, no need to set controller
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching order details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load order details'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingDetails = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _discountController.dispose();
    _deliveryChargeController.dispose();
    _medicineNameController.dispose();
    _medicineQtyController.dispose();
    _medicinePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Process Order',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: _buildStatusChip(_orderDetails?.status ?? _currentStatus),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrderDetails,
        color: ColorPalette.primaryColor,
        child: _isFetchingDetails
            ? _buildShimmerLoading()
            : SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderHeader(),
                    SizedBox(height: 20),
                    _buildBillingAndStatusSection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and order ID
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorPalette.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.shopping_cart_rounded,
                  color: ColorPalette.primaryColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Order #${widget.order.orderId}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          
          // Customer details section
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.blue[600],
                        size: 14,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Details',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            widget.order.user?.name ?? 'Unknown Customer',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            widget.order.user?.phoneNumber ?? 'No Contact number',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _shareCustomerDetails(),
                      icon: Icon(
                        Icons.share,
                        color: Colors.blue[600],
                        size: 18,
                      ),
                      padding: EdgeInsets.all(4),
                      constraints: BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      tooltip: 'Share Customer Details',
                    ),
                  ],
                ),
                // Delivery Address section
                if (widget.order.deliveryAddress != null) ...[
                  SizedBox(height: 10),
                  Divider(color: Colors.blue[200], height: 1),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Colors.green[600],
                          size: 14,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Address',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.order.deliveryAddress!.houseStreet,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              widget.order.deliveryAddress!.addressLine1,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (widget.order.deliveryAddress!.addressLine2 != null &&
                                widget.order.deliveryAddress!.addressLine2!.isNotEmpty) ...[
                              SizedBox(height: 2),
                              Text(
                                widget.order.deliveryAddress!.addressLine2!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            SizedBox(height: 2),
                            Text(
                              '${widget.order.deliveryAddress!.city}, ${widget.order.deliveryAddress!.state} ${widget.order.deliveryAddress!.zipCode}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              widget.order.deliveryAddress!.country,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (widget.order.deliveryAddress!.addressType.isNotEmpty) ...[
                              SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.order.deliveryAddress!.addressType,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 10),

          // General product (if exists)
          if (widget.order.prescription?.generalProduct != null && widget.order.prescription!.generalProduct!.trim().isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shopping_bag, color: Colors.orange[700], size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'General Products',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          widget.order.prescription!.generalProduct!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
          ],
          
          // Prescription files (if exist)
          if (widget.order.prescription?.prescriptionFiles != null && widget.order.prescription!.prescriptionFiles.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_file, color: Colors.grey[700], size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Prescription Files',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ...widget.order.prescription!.prescriptionFiles.map((url) {
                    final String name = Uri.tryParse(url)?.pathSegments.isNotEmpty == true
                        ? Uri.parse(url).pathSegments.last
                        : url.split('/').last;
                    final bool isPdf = name.toLowerCase().endsWith('.pdf');
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PrescriptionPreviewScreen(fileUrl: url, fileName: name),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 6),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
                                color: isPdf ? Colors.red[600] : Colors.blue[600], size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.chevron_right, size: 18, color: Colors.grey[600]),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            SizedBox(height: 10),
          ],

          // Order details in a compact grid layout
          Row(
            children: [
              Expanded(
                child: _buildDetailCard(
                  'Total Amount',
                  _orderDetails?.totalAmount != null && _orderDetails!.totalAmount > 0
                      ? '₹${_orderDetails!.totalAmount.toStringAsFixed(2)}'
                      : (_calculateSubtotal() > 0 ? '₹${_calculateTotalAmount().toStringAsFixed(2)}' : 'Not Set'),
                  Icons.payments_rounded,
                  Colors.green,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildDetailCard(
                  'Created',
                  _formatDateTime(widget.order.createdAt),
                  Icons.access_time_rounded,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingAndStatusSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medicines and Billing Section
          Row(
            children: [
              Icon(Icons.medication, color: ColorPalette.primaryColor, size: 20),
              SizedBox(width: 10),
              Text(
                'Medicines and Billing Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Medicine Entry Fields
          // Medicine Name - Full Row
          TextField(
            controller: _medicineNameController,
            decoration: InputDecoration(
              labelText: 'Medicine Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ColorPalette.primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ColorPalette.primaryColor, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ColorPalette.primaryColor),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: (_) => setState(() {}), // Auto-update breakdown
          ),
          SizedBox(height: 12),
          
          // Quantity, Price and Add Button Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _medicineQtyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ColorPalette.primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ColorPalette.primaryColor, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ColorPalette.primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (_) => setState(() {}), // Auto-update breakdown
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _medicinePriceController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Price',
                    prefixText: '₹',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ColorPalette.primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ColorPalette.primaryColor, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ColorPalette.primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (_) => setState(() {}), // Auto-update breakdown
                ),
              ),
              SizedBox(width: 8),
              Container(
                height: 48,
                width: 48,
                child: ElevatedButton(
                  onPressed: _addMedicine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Icon(Icons.add, size: 24),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Medicine Items List (only show newly added temporary medicines here)
          if (_medicineItems.isNotEmpty) ...[
            Text(
              'Newly Added Medicines',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            ..._medicineItems.map((item) => _buildMedicineItemRow(item)),
            SizedBox(height: 12),
          ],
          
          // Divider to separate medicine entry from billing details
          Divider(thickness: 1, color: Colors.grey[300]),
          SizedBox(height: 16),
          
          // Discount and Delivery Charge Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _discountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Discount %',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ColorPalette.primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ColorPalette.primaryColor, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ColorPalette.primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (_) => setState(() {}), // Auto-update breakdown
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _deliveryChargeController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Delivery Charge',
                    prefixText: '₹',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ColorPalette.primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ColorPalette.primaryColor, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ColorPalette.primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (_) => setState(() {}), // Auto-update breakdown
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Show existing medicines from DB above cost breakdown
          if (_orderDetails?.medicines != null && _orderDetails!.medicines!.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.medication, size: 16, color: Colors.blue[700]),
                      SizedBox(width: 6),
                      Text(
                        'Existing Medicines',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ..._orderDetails!.medicines!.map((med) {
                    final itemTotal = med.quantity * med.price;
                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  med.medicineName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[900],
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Qty: ${med.quantity} × ₹${med.price.toStringAsFixed(2)} = ₹${itemTotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _isDeleting && _deletingMedicineId == med.orderMedicineId
                              ? Container(
                                  width: 32,
                                  height: 32,
                                  padding: EdgeInsets.all(6),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red[600]!),
                                  ),
                                )
                              : IconButton(
                                  onPressed: _isDeleting ? null : () => _deleteExistingMedicine(med.orderMedicineId),
                                  icon: Icon(Icons.delete_outline, color: Colors.red[600], size: 20),
                                  padding: EdgeInsets.all(4),
                                  constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                  tooltip: 'Delete Medicine',
                                ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 12),
          ],
          
          // Total Amount with Breakdown (always show if there are medicines)
          if (_calculateSubtotal() > 0 || (_orderDetails != null && _orderDetails!.totalAmount > 0)) ...[
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cost Breakdown
                  Text(
                    'Cost Breakdown',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.green[900],
                    ),
                  ),
                  SizedBox(height: 8),
                  // Show newly added medicines in breakdown
                  if (_medicineItems.isNotEmpty) ...[
                    Text(
                      'New Medicines',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    ..._medicineItems.map((item) {
                      final itemTotal = item.quantity * item.price;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.name} (Qty: ${item.quantity})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[800],
                                ),
                              ),
                            ),
                            Text(
                              '₹${itemTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[800],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    SizedBox(height: 8),
                    Divider(color: Colors.green[300], height: 1),
                    SizedBox(height: 8),
                  ],
                  
                  // Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[800],
                        ),
                      ),
                      Text(
                        _orderDetails?.subtotal != null && _orderDetails!.subtotal > 0
                            ? '₹${_orderDetails!.subtotal.toStringAsFixed(2)}'
                            : '₹${_calculateSubtotal().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  
                  // Discount (always show in rupees)
                  if (_calculateDiscountAmount() > 0 || (double.tryParse(_discountController.text.trim()) ?? 0.0) > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          double.tryParse(_discountController.text.trim()) != null && 
                          double.tryParse(_discountController.text.trim())! > 0
                              ? 'Discount (${_discountController.text.trim()}%)'
                              : 'Discount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          '-₹${_calculateDiscountAmount().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                  ],
                  
                  // GST (always show in rupees - 18% default or from backend)
                  if (_calculateGSTAmount() > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GST (18%)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          '₹${_calculateGSTAmount().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                  ],
                  
                  // Platform Fee (if available from order details)
                  if (_orderDetails?.platformFee != null && _orderDetails!.platformFee > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Platform Fee',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          '₹${_orderDetails!.platformFee.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                  ],
                  
                  // Delivery Charge
                  if ((_orderDetails?.deliveryCharges != null && _orderDetails!.deliveryCharges > 0) || 
                      (double.tryParse(_deliveryChargeController.text.trim()) ?? 0.0) > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivery Charge',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          '₹${(double.tryParse(_deliveryChargeController.text.trim()) ?? _orderDetails?.deliveryCharges ?? 0.0).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Divider(color: Colors.green[300], height: 1),
                    SizedBox(height: 8),
                  ],
                  
                  // Total Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.green[900],
                        ),
                      ),
                      Text(
                        '₹${_calculateTotalAmount().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.green[900],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            
            // Save Button for Billing Details (only show if new medicines are added)
            if (_medicineItems.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveBillingDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.save, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Save Billing Details',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ],
          
          Divider(),
          SizedBox(height: 16),
          
          // Order Notes Section
          Row(
            children: [
              Icon(Icons.note, color: Colors.orange[600], size: 20),
              SizedBox(width: 10),
              Text(
                'Order Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: () => _showNoteDialog(),
                icon: Icon(
                  _noteController.text.isNotEmpty ? Icons.edit : Icons.add,
                  color: Colors.orange[600],
                  size: 18,
                ),
                padding: EdgeInsets.all(4),
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (_noteController.text.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Text(
                _noteController.text,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
          
          Divider(),
          SizedBox(height: 16),
          
          // Status Update Section
          Row(
            children: [
              Icon(Icons.update_rounded, color: ColorPalette.primaryColor, size: 20),
              SizedBox(width: 10),
              Text(
                'Update Order Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatus,
                isExpanded: true,
                hint: Text('Choose status'),
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: ColorPalette.primaryColor),
                items: [
                  'ready_to_pickup',
                  'out_for_delivery',
                  'delivered',
                ].map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(
                      _getStatusDisplayText(status),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedStatus = newValue;
                    });
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 20),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey[400]!),
                    foregroundColor: Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.update_rounded, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Update Status',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineItemRow(MedicineItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity} × ₹${item.price.toStringAsFixed(2)} = ₹${(item.quantity * item.price).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeMedicine(item.id),
            icon: Icon(Icons.delete_outline, color: Colors.red[600], size: 18),
            padding: EdgeInsets.all(4),
            constraints: BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  void _addMedicine() {
    final name = _medicineNameController.text.trim();
    final qty = int.tryParse(_medicineQtyController.text.trim()) ?? 0;
    final price = double.tryParse(_medicinePriceController.text.trim()) ?? 0.0;

    if (name.isEmpty || qty <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter valid medicine details'),
          backgroundColor: Colors.red[600],
        ),
      );
      return;
    }

    setState(() {
      _medicineItems.add(
        MedicineItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          quantity: qty,
          price: price,
        ),
      );
      _medicineNameController.clear();
      _medicineQtyController.clear();
      _medicinePriceController.clear();
    });
  }

  void _removeMedicine(String id) {
    setState(() {
      _medicineItems.removeWhere((item) => item.id == id);
    });
  }

  Future<void> _deleteExistingMedicine(String orderMedicineId) async {
    // Find the medicine name for better dialog display
    String medicineName = 'this medicine';
    if (_orderDetails?.medicines != null && _orderDetails!.medicines!.isNotEmpty) {
      try {
        final medicine = _orderDetails!.medicines!.firstWhere(
          (med) => med.orderMedicineId == orderMedicineId,
        );
        medicineName = medicine.medicineName;
      } catch (e) {
        // If medicine not found, use default name
        medicineName = 'this medicine';
      }
    }
    
    // Show improved confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          constraints: BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 40,
                  color: Colors.red[600],
                ),
              ),
              SizedBox(height: 24),
              // Title
              Text(
                'Delete Medicine?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              // Content
              Text(
                'Are you sure you want to delete "$medicineName" from this order?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 28),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldDelete != true) return;

    setState(() {
      _isDeleting = true;
      _deletingMedicineId = orderMedicineId;
    });

    try {
      final viewModel = context.read<NewOrdersViewModel>();
      final response = await viewModel.deleteOrderMedicine(widget.order.orderId, orderMedicineId);
      
      if (mounted) {
        if (response != null && response['success'] == true) {
          // Refresh order details to get updated data
          await _fetchOrderDetails();
          
          // Show success snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      response['message'] ?? 'Medicine deleted successfully',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: EdgeInsets.all(16),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      response?['message'] ?? 'Failed to delete medicine. Please try again.',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: EdgeInsets.all(16),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error deleting medicine: ${e.toString()}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.all(16),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
          _deletingMedicineId = null;
        });
      }
    }
  }

  double _calculateSubtotal() {
    double existingTotal = 0.0;
    if (_orderDetails?.medicines != null && _orderDetails!.medicines!.isNotEmpty) {
      existingTotal = _orderDetails!.medicines!.fold(0.0, (sum, med) => sum + (med.quantity * med.price));
    }
    double newTotal = _medicineItems.fold(0.0, (sum, item) => sum + (item.quantity * item.price));
    return existingTotal + newTotal;
  }

  // Get discount percentage from input or calculate from backend discount amount
  double _getDiscountPercentage() {
    // If discount percentage is entered in input field, use it
    double discountPercent = double.tryParse(_discountController.text.trim()) ?? 0.0;
    if (discountPercent > 0) {
      return discountPercent;
    }
    
    // If discount exists from backend, it's already a percentage (not amount)
    if (_orderDetails?.discount != null && _orderDetails!.discount > 0) {
      return _orderDetails!.discount;
    }
    
    return 0.0;
  }

  // Calculate discount amount in rupees (for UI display)
  double _calculateDiscountAmount() {
    double subtotal = _calculateSubtotal();
    if (subtotal <= 0) return 0.0;
    
    // Get discount percentage (from input or backend)
    double discountPercent = _getDiscountPercentage();
    if (discountPercent > 0) {
      // Calculate discount amount from percentage
      return subtotal * (discountPercent / 100);
    }
    
    return 0.0;
  }

  // Get GST percentage (default 18% from backend)
  double _getGSTPercentage() {
    // If GST exists from backend, it's already a percentage (not amount)
    if (_orderDetails?.gst != null && _orderDetails!.gst > 0) {
      return _orderDetails!.gst;
    }
    
    // Default to 18% GST (as set in backend)
    return 18.0;
  }

  // Calculate GST amount in rupees (for UI display)
  // Uses 18% by default or backend GST percentage
  double _calculateGSTAmount() {
    double subtotal = _calculateSubtotal();
    if (subtotal <= 0) return 0.0;
    
    // Calculate discount amount first
    double discountAmount = _calculateDiscountAmount();
    double amountAfterDiscount = subtotal - discountAmount;
    
    // Get GST percentage (from backend or default 18%)
    double gstPercent = _getGSTPercentage();
    
    // Calculate GST on amount after discount
    return amountAfterDiscount * (gstPercent / 100);
  }

  double _calculateTotalAmount() {
    double subtotal = _calculateSubtotal();
    if (subtotal <= 0) return 0.0;
    
    // Always calculate from current state
    double discountAmount = _calculateDiscountAmount();
    double deliveryCharge = double.tryParse(_deliveryChargeController.text.trim()) ?? 0.0;
    double gst = _calculateGSTAmount(); // Calculate GST from percentage
    double platformFee = _orderDetails?.platformFee ?? widget.order.platformFee;
    double total = subtotal - discountAmount + deliveryCharge + gst + platformFee;
    
    // Return total (can be positive even if subtotal is greater than discount)
    return total > 0 ? total : 0.0;
  }

  Future<void> _saveBillingDetails() async {
    // Check if there are any medicines (existing or newly added)
    bool hasExistingMedicines = _orderDetails?.medicines != null && _orderDetails!.medicines!.isNotEmpty;
    bool hasNewMedicines = _medicineItems.isNotEmpty;
    
    if (!hasExistingMedicines && !hasNewMedicines) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please add at least one medicine before saving billing details',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final totalAmount = _calculateTotalAmount();
    if (totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please check medicine details and billing information',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final viewModel = context.read<NewOrdersViewModel>();
      
      // Calculate values based on BOTH existing + newly added medicines
      final subtotal = _calculateSubtotal(); // Already includes existing + new medicines
      
      // Get discount percentage (from input or calculate from backend)
      final discountPercent = _getDiscountPercentage();
      
      // Get GST percentage (from input or calculate from backend)
      final gstPercent = _getGSTPercentage();
      
      final deliveryCharges = double.tryParse(_deliveryChargeController.text.trim()) ?? 0.0;
      final platformFee = _orderDetails?.platformFee ?? widget.order.platformFee;
      
      // Calculate GST amount from percentage
      final gstAmount = subtotal > 0 ? (subtotal * (gstPercent / 100)) : 0.0;
      
      // Calculate discount amount from percentage
      final discountAmount = subtotal > 0 ? (subtotal * (discountPercent / 100)) : 0.0;
      
      // Calculate total amount including all components
      final calculatedTotal = subtotal - discountAmount + deliveryCharges + gstAmount + platformFee;
      
      // Only send newly added medicines (not existing ones)
      // Existing medicines are already in DB, we just add new ones
      final response = await viewModel.addOrderMedicines(
        widget.order.orderId,
        _medicineItems, // Only send newly added medicines
        subtotal, // Total subtotal (existing + new medicines)
        discountPercent, // Send discount as percentage
        gstPercent, // Send GST as percentage
        deliveryCharges,
        platformFee,
        calculatedTotal, // Total amount calculated from all medicines
      );

      if (mounted) {
        if (response != null && response['success'] == true) {
          // Clear newly added medicines list as they're now saved to DB
          setState(() {
            _medicineItems = [];
            _medicineNameController.clear();
            _medicineQtyController.clear();
            _medicinePriceController.clear();
          });
          
          // Refresh order details to get updated data
          await _fetchOrderDetails();
          
          // Show success snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Success!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          response['message'] ?? 'Medicine and billing details added successfully!',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: EdgeInsets.all(16),
              duration: Duration(seconds: 2),
            ),
          );
          
          // Don't pop - stay on screen and refresh data
        } else {
          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Error',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          response?['message'] ?? 'Failed to save billing details. Please try again.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: EdgeInsets.all(16),
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Error',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Error saving billing details: ${e.toString()}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.all(16),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  void _showNoteDialog() {
    final TextEditingController noteController = TextEditingController(
      text: _noteController.text,
    );
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            widget.order.note != null ? 'Edit Note' : 'Add Note',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add or update the note for this order:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter your note here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange[500]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final note = noteController.text.trim();
                Navigator.of(context).pop();
                
                // Show loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Updating note...'),
                      ],
                    ),
                    backgroundColor: Colors.blue[600],
                    duration: Duration(seconds: 2),
                  ),
                );
                
                                  try {
                    final viewModel = context.read<NewOrdersViewModel>();
                    final response = await viewModel.updateOrderNote(widget.order.orderId, note);
                    
                    // Check if widget is still mounted before updating UI
                    if (!mounted) return;
                    
                    if (response != null && response['success'] == true) {
                      setState(() {
                        // Update local state immediately
                        _noteController.text = note;
                      });
                      
                      _showSnackBar(note.isNotEmpty ? 'Note updated successfully!' : 'Note removed', backgroundColor: Colors.green[600]);
                    } else {
                      _showSnackBar('Failed to update note', backgroundColor: Colors.red[600]);
                    }
                  } catch (e) {
                    _showSnackBar('Error: $e', backgroundColor: Colors.red[600]);
                  }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }



  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
        statusText = 'Pending';
        break;
      case 'verified':
        chipColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        statusText = 'Verified';
        break;
      case 'confirmed':
        chipColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        statusText = 'Confirmed';
        break;
      case 'waiting_for_payment':
        chipColor = Colors.purple[100]!;
        textColor = Colors.purple[700]!;
        statusText = 'Waiting for Payment';
        break;
      case 'payment_completed':
        chipColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        statusText = 'Payment Completed';
        break;
      case 'ready_to_pickup':
        chipColor = Colors.indigo[100]!;
        textColor = Colors.indigo[700]!;
        statusText = 'Ready for Pickup';
        break;
      case 'out_for_delivery':
        chipColor = Colors.teal[100]!;
        textColor = Colors.teal[700]!;
        statusText = 'Out for Delivery';
        break;
      case 'delivered':
        chipColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        statusText = 'Delivered';
        break;
      default:
        chipColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
        statusText = 'Unknown';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'verified':
        return 'Verified';
      case 'confirmed':
        return 'Confirmed';
      case 'waiting_for_payment':
      case 'waiting for payment':
        return 'Waiting for Payment';
      case 'payment_completed':
      case 'payment completed':
        return 'Payment Completed';
      case 'ready_to_pickup':
      case 'ready for pickup':
        return 'Ready for Pickup';
      case 'out_for_delivery':
      case 'out for delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      default:
        return status.replaceAll('_', ' ').split(' ').map((word) => 
          word.isNotEmpty ? (word[0].toUpperCase() + (word.length > 1 ? word.substring(1).toLowerCase() : '')) : word
        ).join(' ');
    }
  }

  Future<void> _updateStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final viewModel = context.read<NewOrdersViewModel>();
      final response = await viewModel.updateOrderStatus(widget.order.orderId, _selectedStatus);
      
      if (mounted) {
        if (response != null && response['success'] == true) {
          setState(() {
            // Update local state immediately
            _currentStatus = _selectedStatus;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Order status updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?['message'] ?? 'Failed to update order status'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _mapStatusToValidValue(String currentStatus) {
    // Map any existing status to a valid dropdown value
    switch (currentStatus.toLowerCase()) {
      case 'pending':
      case 'verified':
      case 'confirmed':
      case 'waiting_for_payment':
      case 'payment_completed':
        return 'ready_to_pickup'; // Default to ready for pickup for old statuses
      case 'ready_to_pickup':
        return 'ready_to_pickup';
      case 'out_for_delivery':
        return 'out_for_delivery';
      case 'delivered':
        return 'delivered';
      default:
        // If status is unknown, default to ready for pickup
        return 'ready_to_pickup';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Helper method to safely show snackbars
  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor ?? Colors.green[600],
        ),
      );
    }
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: Duration(milliseconds: 1500),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header Shimmer
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 16,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            // Billing Section Shimmer
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Share customer details and address
  void _shareCustomerDetails() {
    final StringBuffer shareText = StringBuffer();
    
    // Order header
    shareText.writeln('📦 Order Details');
    shareText.writeln('Order ID: ${widget.order.orderId}');
    shareText.writeln('');
    
    // Customer details
    shareText.writeln('👤 Customer Information:');
    shareText.writeln('Name: ${widget.order.user?.name ?? 'Unknown Customer'}');
    shareText.writeln('Phone: ${widget.order.user?.phoneNumber ?? 'No Contact number'}');
    shareText.writeln('');
    
    // Delivery address
    if (widget.order.deliveryAddress != null) {
      shareText.writeln('📍 Delivery Address:');
      final address = widget.order.deliveryAddress!;
      shareText.writeln('${address.houseStreet}');
      shareText.writeln('${address.addressLine1}');
      if (address.addressLine2 != null && address.addressLine2!.isNotEmpty) {
        shareText.writeln('${address.addressLine2}');
      }
      shareText.writeln('${address.city}, ${address.state} ${address.zipCode}');
      shareText.writeln('${address.country}');
      if (address.addressType.isNotEmpty) {
        shareText.writeln('Type: ${address.addressType}');
      }
      shareText.writeln('');
    }
    
    // Order amount
    if (widget.order.totalAmount > 0) {
      shareText.writeln('💰 Order Amount: ₹${widget.order.totalAmount.toStringAsFixed(2)}');
      shareText.writeln('');
    }
    
    // Order status
    shareText.writeln('📊 Status: ${_getStatusDisplayText(widget.order.status)}');
    
    Share.share(shareText.toString(), subject: 'Order ${widget.order.orderId} - Customer Details');
  }
}
