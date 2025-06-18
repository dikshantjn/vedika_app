import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for keyboard handling
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/CartAndPlaceOrderViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/DeliveryPartner/DeliveryPartner.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/DeliveryPartner/DeliveryPartnerViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/cart/OrderPlacedBottomSheet.dart';
import 'package:vedika_healthcare/features/home/data/models/ProductCart.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/VendorProduct.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';

class OrderSummarySheet extends StatefulWidget {
  final CartAndPlaceOrderViewModel cartViewModel;
  final addressId;
  final bool? forceShowDeliveryPartner;

  const OrderSummarySheet({Key? key, required this.cartViewModel, required this.addressId, this.forceShowDeliveryPartner}) : super(key: key);

  @override
  _OrderSummarySheetState createState() => _OrderSummarySheetState();
}

class _OrderSummarySheetState extends State<OrderSummarySheet> {
  bool _showOrderSummary = false;
  bool _loadingSelfDeliveryCheck = true;
  DeliveryPartner? _selectedPartner;
  double _deliveryCharge = 0.0;
  double _discount = 0.0;
  double _platformFee = 10.0;
  String _couponCode = '';
  bool _isCouponApplied = false;
  final TextEditingController _couponController = TextEditingController();
  final FocusNode _couponFocusNode = FocusNode(); // Added focus node for coupon field
  String _couponError = "";
  double _totalSubtotal = 0.0; // Add this field to store the total subtotal
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    widget.cartViewModel.setOnPaymentSuccess(_handlePaymentSuccess);
    widget.cartViewModel.setOnPaymentError(_handlePaymentError);
    
    // Use addPostFrameCallback to set address ID after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.cartViewModel.setAddressId(widget.addressId);
      if (widget.forceShowDeliveryPartner != null) {
        if (widget.forceShowDeliveryPartner!) {
          _fetchNearbyDeliveryPartners();
        } else {
          setState(() {
            _showOrderSummary = true;
          });
        }
        setState(() {
          _loadingSelfDeliveryCheck = false;
        });
        return;
      }
      // Check selfDelivery for all orders in cart using the correct user orders
      final orderIds = widget.cartViewModel.cartItems.map((item) => item.orderId).toSet();
      final orders = widget.cartViewModel.orders;
      print('Order IDs in cart: $orderIds');
      for (var order in orders) {
        print('Order: \'${order.orderId}\', selfDelivery: ${order.selfDelivery}');
      }
      final hasAnyOrderWithSelfDeliveryFalse = orderIds.any((orderId) {
        final order = orders.firstWhere(
          (o) => o.orderId == orderId,
          orElse: () => MedicineOrderModel(
            orderId: '',
            prescriptionId: '',
            userId: '',
            vendorId: '',
            discountAmount: 0.0,
            subtotal: 0.0,
            totalAmount: 0.0,
            orderStatus: '',
            paymentStatus: '',
            deliveryStatus: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            user: UserModel.empty(),
            orderItems: [],
            platformFee: 0,
            deliveryCharge: 0
          ),
        );
        print('Checking orderId: $orderId, found orderId: ${order.orderId}, selfDelivery: ${order.selfDelivery}');
        return order.orderId.isNotEmpty && order.selfDelivery == false;
      });
      print("hasAnyOrderWithSelfDeliveryFalse $hasAnyOrderWithSelfDeliveryFalse");
      if (hasAnyOrderWithSelfDeliveryFalse) {
        _fetchNearbyDeliveryPartners();
      } else {
        // All orders are self delivery, skip finding delivery partner
        setState(() {
          _showOrderSummary = true;
        });
      }
      setState(() {
        _loadingSelfDeliveryCheck = false;
      });
    });
    _setupKeyboardListeners();
  }

  @override
  void dispose() {
    widget.cartViewModel.setOnPaymentSuccess(null);
    widget.cartViewModel.setOnPaymentError(null);
    _couponFocusNode.dispose(); // Clean up focus node
    super.dispose();
  }

  void _handlePaymentSuccess(String paymentId) {
    if (!mounted) return;
    
    setState(() {
      _isProcessingPayment = false;
    });

    // Close the current bottom sheet
    Navigator.of(context).pop();

    // Show the success bottom sheet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OrderPlacedBottomSheet.showOrderPlacedBottomSheet(context, paymentId);
    });
  }

  void _handlePaymentError(String error) {
    if (!mounted) return;
    
    setState(() {
      _isProcessingPayment = false;
    });

    // Show error bottom sheet
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true, // Add this to allow full height
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            top: 32,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 300,
                child: Lottie.asset(
                  'assets/animations/paymentfailed.json',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Payment Failed",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 12),
              Text(
                error,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red,
                      Colors.red.withOpacity(0.8),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Center(
                      child: Text(
                        "Try Again",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _setupKeyboardListeners() {
    // Listen to keyboard visibility changes
    _couponFocusNode.addListener(() {
      if (_couponFocusNode.hasFocus) {
        // Scroll the sheet up when keyboard appears
        Future.delayed(const Duration(milliseconds: 300), () {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    });
  }

  void _fetchNearbyDeliveryPartners() {
    final deliveryPartnerViewModel = Provider.of<DeliveryPartnerViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      deliveryPartnerViewModel.fetchNearbyPartners(context);

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            if (deliveryPartnerViewModel.partners.isNotEmpty) {
              _selectedPartner = deliveryPartnerViewModel.partners.first;
              _deliveryCharge = deliveryPartnerViewModel.calculateDeliveryCharges(context, _selectedPartner!);
              widget.cartViewModel.setDeliveryCharge(_deliveryCharge);
            }
            _showOrderSummary = true;
          });
        }
      });
    });
  }

  void _applyCoupon() {
    if (_couponController.text.isEmpty) {
      setState(() {
        _couponError = "Please enter a coupon code.";
      });
      return;
    }

    // Call ViewModel method
    widget.cartViewModel.applyCoupon(_couponController.text);

    // Check if coupon is applied before proceeding
    if (!widget.cartViewModel.isCouponApplied) {
      setState(() {
        _couponError = "Invalid coupon code. Please try again.";
      });
      return;
    }

    setState(() {
      _isCouponApplied = widget.cartViewModel.isCouponApplied;
      _discount = widget.cartViewModel.discount;
      _couponError = ""; // Clear any previous error
    });

    // Dismiss keyboard before showing animation
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Center(
          child: Lottie.asset(
            'assets/animations/cheers.json',
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.width * 0.9,
            repeat: false,
            fit: BoxFit.contain,
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingSelfDeliveryCheck) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_showOrderSummary) _loadingAnimation() else _buildOrderSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loadingAnimation() {
    return SizedBox(
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/findingDeliveryPartner.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 16),
          Text(
            'Finding Delivery Partner...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildOrderSummary() {
    final cartViewModel = widget.cartViewModel;
    final List<CartModel> cartItems = cartViewModel.cartItems;
    final List<ProductCart> productCartItems = cartViewModel.productCartItems;
    final Map<String, List<CartModel>> ordersGrouped = {};

    // Calculate subtotal for medicine orders
    double medicineSubtotal = cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

    // Calculate subtotal for product items
    double productSubtotal = productCartItems.fold(0.0, (sum, item) {
      final productDetails = cartViewModel.productDetails.firstWhere(
        (product) => product.productId == item.productId,
        orElse: () => VendorProduct(
          productId: '',
          vendorId: '',
          name: '',
          category: '',
          description: '',
          images: [],
          price: 0.0,
          rating: 0.0,
          howItWorks: '',
          usp: [],
          isActive: false,
          highlights: [],
          comingSoon: false,
          stock: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          reviewCount: 0,
        ),
      );
      final price = productDetails.price > 0 ? productDetails.price : (item.price ?? 0.0);
      final quantity = item.quantity ?? 0;
      return sum + (price * quantity);
    });

    // Update the class field with total subtotal
    _totalSubtotal = medicineSubtotal + productSubtotal;

    // If both cart and product cart are empty, show message
    if (cartItems.isEmpty && productCartItems.isEmpty) {
      return Center(
        child: Text(
          "No orders found.",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    // Grouping cart items by order ID
    for (var item in cartItems) {
      ordersGrouped.putIfAbsent(item.orderId!, () => []).add(item);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Order Summary',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ColorPalette.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${cartItems.length + productCartItems.length} Items',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorPalette.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              // Show medicine orders if any
              if (cartItems.isNotEmpty) ...[
                ...ordersGrouped.entries.map((entry) {
                  String orderId = entry.key;
                  List<CartModel> items = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.medication_outlined, color: ColorPalette.primaryColor, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Medicine Order #${orderId.length > 12 ? '${orderId.substring(0, 8)}...' : orderId}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'x${item.quantity}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      if (entry.key != ordersGrouped.keys.last)
                        Divider(height: 1, color: Colors.grey[200]),
                    ],
                  );
                }).toList(),
              ],

              // Show product orders if any
              if (productCartItems.isNotEmpty) ...[
                if (cartItems.isNotEmpty) Divider(height: 1, color: Colors.grey[200]),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.shopping_bag_outlined, color: ColorPalette.primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Product Items',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...productCartItems.map((item) {
                        // Find the corresponding product details
                        final productDetails = cartViewModel.productDetails.firstWhere(
                          (product) => product.productId == item.productId,
                          orElse: () => VendorProduct(
                            productId: '',
                            vendorId: '',
                            name: '',
                            category: '',
                            description: '',
                            images: [],
                            price: 0.0,
                            rating: 0.0,
                            howItWorks: '',
                            usp: [],
                            isActive: false,
                            highlights: [],
                            comingSoon: false,
                            stock: 0,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                            reviewCount: 0,
                          ),
                        );

                        final price = productDetails.price > 0 ? productDetails.price : (item.price ?? 0.0);
                        final quantity = item.quantity ?? 0;
                        final name = productDetails.name.isNotEmpty ? productDetails.name : (item.productName ?? 'Product');
                        final imageUrl = productDetails.images.isNotEmpty 
                            ? productDetails.images.first 
                            : item.imageUrl;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: imageUrl != null
                                    ? Image.network(
                                        imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey[200],
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                    : null,
                                                valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                          );
                                        },
                                      )
                                    : Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (productDetails.category.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          productDetails.category,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Quantity and Price
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'x$quantity',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${(price * quantity).toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildCouponSection(),
        if (cartViewModel.isCouponApplied) _discountBox(),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _priceRow('Subtotal', _totalSubtotal),
              const SizedBox(height: 8),
              _priceRow('Delivery Charge', cartViewModel.deliveryCharge),
              const SizedBox(height: 8),
              _priceRow('Platform Fee', 10.0),
              const Divider(height: 24),
              _priceRow('Total Amount', _totalSubtotal + cartViewModel.deliveryCharge + 10.0 - cartViewModel.discount, isBold: true),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildPayNowButton(),
      ],
    );
  }

  Widget _priceRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: isBold ? Colors.black87 : Colors.grey[600],
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: isBold ? ColorPalette.primaryColor : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCouponSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer_outlined, color: ColorPalette.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Apply Coupon',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  focusNode: _couponFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ColorPalette.primaryColor),
                    ),
                    errorText: _couponError.isNotEmpty ? _couponError : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorPalette.primaryColor,
                      ColorPalette.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _isCouponApplied ? null : _applyCoupon,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        'Apply',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _discountBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: Colors.green[700], size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Discount Applied!',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          Text(
            '- ₹${_discount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayNowButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorPalette.primaryColor,
            ColorPalette.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isProcessingPayment ? null : _payNow,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isProcessingPayment)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else ...[
                Text(
                  'Pay Now',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _payNow() {
    FocusScope.of(context).unfocus();

    setState(() {
      _isProcessingPayment = true;
    });

    // Calculate the final total amount
    final totalAmount = _totalSubtotal + widget.cartViewModel.deliveryCharge + 10.0 - widget.cartViewModel.discount;

    // Ensure latest calculations before payment
    widget.cartViewModel.setDeliveryCharge(widget.cartViewModel.deliveryCharge);
    widget.cartViewModel.setDiscount(widget.cartViewModel.discount);
    widget.cartViewModel.setPlatformFee(10.0);

    // Ensuring total is positive
    if (totalAmount <= 0) {
      _handlePaymentError("Invalid amount. Please try again.");
      return;
    }

    try {
      double amount = totalAmount.roundToDouble();
      widget.cartViewModel.handlePayment(amount);
    } catch (e) {
      _handlePaymentError("An unexpected error occurred. Please try again.");
    }
  }
}