import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineProduct.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Orders/BottomSheetWidgets/MedicineSearchWidget.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Orders/BottomSheetWidgets/OrderDetailsWidget.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Orders/BottomSheetWidgets/SelectedMedicineWidget.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Orders/BottomSheetWidgets/FetchedCartItemsWidget.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Orders/PrescriptionPreviewScreen.dart';

class ProcessOrderScreen extends StatefulWidget {
  final String prescriptionUrl;
  final String customerName;
  final String orderDate;
  final String orderId;
  final bool selfDelivery;
  final Map<String, dynamic>? jsonPrescription;

  const ProcessOrderScreen({
    Key? key,
    required this.prescriptionUrl,
    required this.customerName,
    required this.orderDate,
    required this.orderId,
    required this.selfDelivery,
    this.jsonPrescription,
  }) : super(key: key);

  @override
  _ProcessOrderScreenState createState() => _ProcessOrderScreenState();
}

class _ProcessOrderScreenState extends State<ProcessOrderScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  MedicineProduct? selectedMedicine;
  final ScrollController _scrollController = ScrollController();
  bool _showOrderDetails = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<MedicineOrderViewModel>(context, listen: false);
      viewModel.fetchCartItems(widget.orderId);
      viewModel.clearSearchResults();
      viewModel.clearCarts();
      
      // Set up the callback for order updates
      viewModel.onOrderUpdate = (prescriptionId) {
        if (mounted) {
          // Refresh cart items
          viewModel.fetchCartItems(widget.orderId);
          // Show a snackbar to notify the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order updated. Refreshing...'),
              backgroundColor: MedicalStoreVendorColorPalette.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      };
    });
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    // Clear the callback when disposing
    final viewModel = Provider.of<MedicineOrderViewModel>(context, listen: false);
    viewModel.onOrderUpdate = null;
    
    _tabController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  double _previousOffset = 0.0;

  void _scrollListener() {
    double currentOffset = _scrollController.offset;

    if (currentOffset > _previousOffset && _showOrderDetails) {
      setState(() => _showOrderDetails = false);
    } else if (currentOffset < _previousOffset && !_showOrderDetails) {
      setState(() => _showOrderDetails = true);
    }

    _previousOffset = currentOffset;
  }

  void _viewPrescription() async {
    if (widget.prescriptionUrl.isNotEmpty) {
      // Fetch prescription data from API
      final viewModel = Provider.of<MedicineOrderViewModel>(context, listen: false);
      final prescriptionData = await viewModel.fetchPrescriptionData(widget.orderId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrescriptionPreviewScreen(
            prescriptionUrl: widget.prescriptionUrl,
            jsonPrescription: prescriptionData,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No prescription file available"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: false,

      body: Consumer<MedicineOrderViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // Header Section with Medicine Search
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Medicine Search Section
                    Container(
                      padding: EdgeInsets.zero,
                      child: MedicineSearchWidget(
                        orderId: widget.orderId,
                        searchController: _searchController,
                        onMedicineSelected: (medicine) {
                          setState(() {
                            selectedMedicine = medicine;
                            _searchController.text = medicine.name;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16),

                    // Order Details Section
                    if (_showOrderDetails)
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        child: OrderDetailsWidget(
                          orderId: widget.orderId,
                          customerName: widget.customerName,
                          orderDate: widget.orderDate,
                          prescriptionUrl: widget.prescriptionUrl,
                          selfDelivery: widget.selfDelivery,
                          jsonPrescription: widget.jsonPrescription,
                          onOrderConfirmed: () {
                            if (mounted) {
                              final viewModel = Provider.of<MedicineOrderViewModel>(context, listen: false);
                              viewModel.fetchOrders();
                            }
                          },
                        ),
                      )
                    else
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  setState(() {
                                    _showOrderDetails = true;
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.visibility, color: Colors.blue[600], size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        "Show Details",
                                        style: TextStyle(
                                          color: Colors.blue[600],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Modern Tab Bar
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: MedicalStoreVendorColorPalette.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[600],
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_shopping_cart, size: 16),
                          SizedBox(width: 6),
                          Text("New Items"),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 16),
                          SizedBox(width: 6),
                          Text("Past Items"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab View Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // New Cart Items Tab
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: BouncingScrollPhysics(),
                        child: viewModel.cart.isEmpty
                            ? _buildEmptyStateWidget()
                            : Column(
                                children: viewModel.cart.map((cartItem) {
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: SelectedMedicineWidget(
                                      cartItem: cartItem,
                                      onQuantityChanged: (newQuantity) {
                                        setState(() {
                                          int index = viewModel.cart.indexWhere(
                                              (item) => item.productId == cartItem.productId);
                                          if (index != -1) {
                                            viewModel.cart[index] = viewModel.cart[index].copyWith(quantity: newQuantity);
                                          }
                                        });
                                      },
                                      onDelete: () {
                                        setState(() {
                                          viewModel.cart.removeWhere((item) => item.productId == cartItem.productId);
                                        });
                                      },
                                      quantityController: _quantityController,
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ),

                    // Past Cart Items Tab
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: viewModel.fetchedCartItems.isEmpty
                            ? _buildEmptyStateWidget()
                            : Column(
                                children: viewModel.fetchedCartItems.map((cartItem) {
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: FetchedCartItemsWidget(
                                      fetchedCartItems: [cartItem],
                                      onDelete: (cartId) async {
                                        bool isDeleted = await viewModel.deleteCartItem(cartId);

                                        if (isDeleted) {
                                          setState(() {
                                            viewModel.fetchedCartItems.removeWhere((item) => item.cartId == cartId);
                                            viewModel.cart.removeWhere((item) => item.cartId == cartId);
                                          });

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Cart item deleted successfully!'),
                                              backgroundColor: MedicalStoreVendorColorPalette.successColor,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Failed to delete cart item.'),
                                              backgroundColor: Colors.red,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      // Enhanced Bottom Button
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Consumer<MedicineOrderViewModel>(
          builder: (context, viewModel, child) {
            return Container(
              height: 56,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: MedicalStoreVendorColorPalette.successColor,
                    width: 2,
                  ),
                  foregroundColor: MedicalStoreVendorColorPalette.successColor,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () async {
                  if (viewModel.cart.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Your cart is empty. Please add medicines."),
                        backgroundColor: MedicalStoreVendorColorPalette.errorColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                    return;
                  }

                  final resultMessage = await viewModel.addToCartDB(widget.orderId);

                  if (!mounted) return;

                  // Determine success/error based on message content
                  bool isSuccess = resultMessage.toLowerCase().contains('success') || 
                                 resultMessage.toLowerCase().contains('added') ||
                                 resultMessage.toLowerCase().contains('updated');
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(resultMessage),
                      backgroundColor: isSuccess
                          ? MedicalStoreVendorColorPalette.successColor
                          : MedicalStoreVendorColorPalette.errorColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );

                  if (isSuccess) {
                    await viewModel.fetchCartItems(widget.orderId);
                    viewModel.clearCarts();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart, size: 20),
                    SizedBox(width: 8),
                    Text("Add to User Cart"),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Your cart is empty",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Search and add medicines to get started!",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
