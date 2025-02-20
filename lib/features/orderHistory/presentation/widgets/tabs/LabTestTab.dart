import 'package:flutter/material.dart';

class LabTestTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text('Lab Test Order 1'),
          subtitle: Text('Order details here'),
        ),
        ListTile(
          title: Text('Lab Test Order 2'),
          subtitle: Text('Order details here'),
        ),
        // Add more list items here to show the order history
      ],
    );
  }
}