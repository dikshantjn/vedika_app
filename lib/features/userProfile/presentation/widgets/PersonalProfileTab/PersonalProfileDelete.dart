import 'package:flutter/material.dart';

class PersonalProfileDelete extends StatelessWidget {
  final Function onDelete;

  PersonalProfileDelete({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _showDeleteConfirmationDialog(context);
      },
      child: Text('Delete Profile'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Profile'),
          content: Text('Are you sure you want to delete your profile?'),
          actions: [
            TextButton(
              onPressed: () {
                onDelete();
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }
}
