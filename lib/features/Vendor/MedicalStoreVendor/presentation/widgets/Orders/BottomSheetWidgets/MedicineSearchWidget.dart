import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineProduct.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';

class MedicineSearchWidget extends StatefulWidget {
  final int orderId;
  final TextEditingController searchController;
  final Function(MedicineProduct) onMedicineSelected;

  const MedicineSearchWidget({
    Key? key,
    required this.orderId,
    required this.searchController,
    required this.onMedicineSelected,
  }) : super(key: key);

  @override
  _MedicineSearchWidgetState createState() => _MedicineSearchWidgetState();
}

class _MedicineSearchWidgetState extends State<MedicineSearchWidget> {
  String? _selectedMedicineName;

  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final currentText = widget.searchController.text;

    // If text is cleared or doesn't match the selected medicine, reset selection
    if (currentText.isEmpty ||
        (_selectedMedicineName != null && currentText != _selectedMedicineName)) {
      setState(() {
        _selectedMedicineName = null;
      });
    }

    // Always search when text changes (unless it exactly matches a selected medicine)
    if (_selectedMedicineName == null || currentText != _selectedMedicineName) {
      Provider.of<MedicineOrderViewModel>(context, listen: false)
          .searchMedicines(currentText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineOrderViewModel>(
      builder: (context, viewModel, child) {
        final showSuggestions =
            _selectedMedicineName == null ||
                widget.searchController.text != _selectedMedicineName;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Box
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.blueAccent, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.searchController,
                      decoration: InputDecoration(
                        hintText: "Search for a medicine...",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (query) {
                        // Search logic is handled in _onTextChanged listener
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Medicine Suggestions List
            if (viewModel.medicineSuggestions.isNotEmpty && showSuggestions)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: viewModel.medicineSuggestions.length,
                  itemBuilder: (context, index) {
                    final medicine = viewModel.medicineSuggestions[index];
                    return ListTile(
                      title: Text(
                        medicine.name,
                        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blueGrey[900]),
                      ),
                      subtitle: Text(
                        "₹${medicine.price.toStringAsFixed(2)}",
                        style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
                        onTap: () {
                          setState(() {
                            _selectedMedicineName = medicine.name; // Update selected medicine name
                          });

                          // Update the search controller with the selected medicine name
                          widget.searchController.text = medicine.name;
                          widget.searchController.selection = TextSelection.fromPosition(
                            TextPosition(offset: widget.searchController.text.length),
                          );

                          // Call onMedicineSelected to notify the parent widget
                          widget.onMedicineSelected(medicine);

                          // Add the selected medicine to the cart
                          // Assuming `MedicineOrderViewModel` has a method like `addToCart`
                          Provider.of<MedicineOrderViewModel>(context, listen: false)
                              .addMedicineToLocalCart(medicine, 1, widget.orderId,context); // You can change the quantity as needed

                          // Clear search results after selection
                          viewModel.clearSearchResults();
                        }
                    );
                  },
                ),
              )
            else if (widget.searchController.text.trim().isNotEmpty &&
                showSuggestions &&
                viewModel.medicineSuggestions.isEmpty)
            // Add New Medicine Option
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "No results found for '${widget.searchController.text.trim()}'",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (widget.searchController.text.trim().isNotEmpty) {
                            final newMedicine = MedicineProduct(
                                productId: DateTime.now().millisecondsSinceEpoch.toString(),
                                name: widget.searchController.text.trim(),
                                price: 0.0,
                                discount: 0.0,
                                manufacturer: "Unknown",
                                type: "General",
                                packSizeLabel: "N/A",
                                shortComposition: "N/A",
                                productURLs: [],
                                quantity: 0
                            );
                            setState(() {
                              _selectedMedicineName = newMedicine.name;
                            });
                            widget.onMedicineSelected(newMedicine);
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline, size: 20, color: Colors.white),
                        label: const Text(
                          "Add As a New Medicine",
                          style: TextStyle(fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}