import 'package:flutter/material.dart';

class ReadOnlyTextFieldWidget extends StatelessWidget {
  final String label;
  final String initialValue;

  const ReadOnlyTextFieldWidget({
    Key? key,
    required this.label,
    required this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        TextFormField(
          initialValue: initialValue,
          enabled: false, // Disables input
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}
