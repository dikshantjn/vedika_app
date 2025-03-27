import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineProduct.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Orders/BottomSheetWidgets/MedicineSearchWidget.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Orders/BottomSheetWidgets/OrderDetailsWidget.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Orders/BottomSheetWidgets/SelectedMedicineWidget.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Orders/BottomSheetWidgets/FetchedCartItemsWidget.dart';

class ProcessOrderScreen extends StatefulWidget {
  final String prescriptionUrl;
  final int orderId;
  final String customerName;
  final String orderDate;

  const ProcessOrderScreen({
    Key? key,
    required this.prescriptionUrl,
    required this.orderId,
    required this.customerName,
    required this.orderDate,
  }) : super(key: key);

  @override
  _ProcessOrderScreenState createState() => _ProcessOrderScreenState();
}

class _ProcessOrderScreenState extends State<ProcessOrderScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  MedicineProduct? selectedMedicine;
  final ScrollController _scrollController = ScrollController();
  bool _showOrderDetails = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<MedicineOrderViewModel>(context, listen: false);
      viewModel.fetchCartItems(widget.orderId);
      viewModel.clearSearchResults();
      viewModel.clearCarts();
    });

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  double _previousOffset = 0.0;

  void _scrollListener() {
    double currentOffset = _scrollController.offset;

    if (currentOffset > _previousOffset && _showOrderDetails) {
      // Scrolling Down - Hide the Order Details
      setState(() => _showOrderDetails = false);
    } else if (currentOffset < _previousOffset && !_showOrderDetails) {
      // Scrolling Up - Show the Order Details
      setState(() => _showOrderDetails = true);
    }

    _previousOffset = currentOffset; // Store the last offset value
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MedicalStoreVendorColorPalette.backgroundColor,
      resizeToAvoidBottomInset: false, // Prevent UI shifting due to keyboard
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Process Order"),
        backgroundColor: MedicalStoreVendorColorPalette.primaryColor,
      ),
      body: Consumer<MedicineOrderViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // Medicine Search and Order Details
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    MedicineSearchWidget(
                      orderId: widget.orderId,
                      searchController: _searchController,
                      onMedicineSelected: (medicine) {
                        setState(() {
                          selectedMedicine = medicine;
                          _searchController.text = medicine.name;
                        });
                      },
                    ),

                    // Order Details (Show/Hide based on scroll)
                    if (_showOrderDetails)
                      OrderDetailsWidget(
                        orderId: widget.orderId,
                        customerName: widget.customerName,
                        orderDate: widget.orderDate,
                        prescriptionUrl: widget.prescriptionUrl,
                      )
                    else
                    // Show Button When Order Details Are Hidden
                    // Show Button When Order Details Are Hidden
                      Align(
                        alignment: Alignment.centerRight, // Align to right
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, right: 16), // Add right padding
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _showOrderDetails = true; // Show Order Details Again
                              });
                            },
                            icon: const Icon(Icons.visibility, color: Colors.blue, size: 18), // Small icon
                            label: const Text(
                              "Show Details",
                              style: TextStyle(color: Colors.blue, fontSize: 14), // Smaller text
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.blue, width: 1), // Thin border
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Small padding
                              minimumSize: const Size(10, 10), // Reduce minimum size
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Compact button size
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6), // Small rounded corners
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Expanded Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (viewModel.fetchedCartItems.isEmpty && viewModel.cart.isEmpty)
                        _emptyCartWidget()
                      else ...[
                        if (viewModel.fetchedCartItems.isNotEmpty)
                          FetchedCartItemsWidget(
                            fetchedCartItems: viewModel.fetchedCartItems,
                            onDelete: (cartId) async {
                              bool isDeleted = await viewModel.deleteCartItem(cartId);

                              if (isDeleted) {
                                setState(() {
                                  viewModel.fetchedCartItems.removeWhere((item) => item.cartId == cartId);
                                  viewModel.cart.removeWhere((item) => item.cartId == cartId);
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Cart item deleted successfully!'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to delete cart item.'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        if (viewModel.cart.isNotEmpty)
                          Column(
                            children: viewModel.cart.map((cartItem) {
                              return SelectedMedicineWidget(
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
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 100),
                      ] // Space for the bottom button
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),

      // Keep button fixed at the bottom
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
        ),
        child: Consumer<MedicineOrderViewModel>(
          builder: (context, viewModel, child) {
            return OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                    color: MedicalStoreVendorColorPalette.successColor, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                backgroundColor: Colors.white,
              ),
              onPressed: () async {
                if (viewModel.cart.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("❌ Your cart is empty. Please add medicines."),
                      backgroundColor: MedicalStoreVendorColorPalette.errorColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                final resultMessage = await viewModel.addToCartDB();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(resultMessage),
                    backgroundColor: resultMessage.startsWith("✅")
                        ? MedicalStoreVendorColorPalette.successColor
                        : MedicalStoreVendorColorPalette.errorColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                if (resultMessage.startsWith("✅")) {
                  await viewModel.fetchCartItems(widget.orderId); // 👈 await
                  viewModel.clearCarts(); // optional - clear new items
                }
              },
              child: const Text(
                "Add to User Cart",
                style: TextStyle(
                    fontSize: 16,
                    color: MedicalStoreVendorColorPalette.successColor),
              ),
            );
          },
        ),
      ),
    );
  }

  // 🔹 Widget to show empty cart message
  Widget _emptyCartWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 50, color: Colors.grey),
          const SizedBox(height: 10),
          const Text(
            "Your cart is empty. Search and add medicines!",
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
