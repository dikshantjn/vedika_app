import 'package:flutter/material.dart';
class MedicineTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text('Medicine Order 1'),
          subtitle: Text('Order details here'),
        ),
        ListTile(
          title: Text('Medicine Order 2'),
          subtitle: Text('Order details here'),
        ),
        // Add more list items here to show the order history
      ],
    );
  }
}

