import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';

class TextFieldWidget extends StatelessWidget {
  final String label;
  final String initialValue;
  final Function(String) onChanged;
  final TextInputType keyboardType;
  final bool isObscure;

  const TextFieldWidget({
    Key? key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.isObscure = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        keyboardType: keyboardType,
        obscureText: isObscure,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: MedicalStoreVendorColorPalette.textPrimary, fontSize: 16),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: MedicalStoreVendorColorPalette.secondaryColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: MedicalStoreVendorColorPalette.primaryColor, width: 2),
          ),
        ),
      ),
    );
  }
}
