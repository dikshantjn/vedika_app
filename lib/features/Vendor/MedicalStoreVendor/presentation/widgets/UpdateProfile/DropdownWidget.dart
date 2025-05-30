import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';

class DropdownWidget extends StatelessWidget {
  final String label;
  final List<String> items;
  final String selectedValue;
  final Function(String?) onChanged;

  const DropdownWidget({
    Key? key,
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If selectedValue is not in items, set it to null to avoid issues.
    String? valueToDisplay = items.contains(selectedValue) ? selectedValue : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: valueToDisplay,  // Use the safe value for display
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: MedicalStoreVendorColorPalette.textPrimary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: MedicalStoreVendorColorPalette.secondaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: MedicalStoreVendorColorPalette.primaryColor),
          ),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          // Safely update the value if valid, otherwise leave unchanged
          if (value != null && items.contains(value)) {
            onChanged(value);
          }
        },
      ),
    );
  }
}
