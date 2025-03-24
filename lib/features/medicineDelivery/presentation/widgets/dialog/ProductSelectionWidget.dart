import 'package:flutter/material.dart';

class ProductSelectionWidget extends StatelessWidget {
  final List<String> availableProducts;
  final VoidCallback onProceed;

  ProductSelectionWidget({required this.availableProducts, required this.onProceed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Select Medicines to Order", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Column(
          children: availableProducts.map((product) {
            return ListTile(
              leading: Icon(Icons.medical_services, color: Colors.blue),
              title: Text(product),
              trailing: ElevatedButton(onPressed: () => print("Added $product"), child: Text("Add")),
            );
          }).toList(),
        ),
        SizedBox(height: 10),
        ElevatedButton(onPressed: onProceed, child: Text("Proceed to Cart")),
      ],
    );
  }
}
