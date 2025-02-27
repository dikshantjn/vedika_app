import 'package:flutter/material.dart';

class PlaceOrderWidget extends StatelessWidget {
  final Function placeOrderAction;
  final bool isPlaceOrderEnabled;
  final bool isPrescriptionUploaded;

  PlaceOrderWidget({
    required this.placeOrderAction,
    required this.isPlaceOrderEnabled,
    required this.isPrescriptionUploaded,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isPlaceOrderEnabled && isPrescriptionUploaded
          ? () async {
        await placeOrderAction();
      }
          : null,
      child: Text(
        "Place Order",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
