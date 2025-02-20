import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package

class DatePickerWidget extends StatelessWidget {
  final String? selectedDate;
  final Function(String) onDatePicked;

  const DatePickerWidget({Key? key, this.selectedDate, required this.onDatePicked}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          // Format the date to dd/MM/yyyy
          String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
          onDatePicked(formattedDate);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.teal.shade50,  // Soft background color
          border: Border.all(color: Colors.teal.shade300),  // Subtle border color
          borderRadius: BorderRadius.circular(12),  // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],  // Soft shadow for depth
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.teal.shade700),
            SizedBox(width: 12),
            Text(
              selectedDate ?? "Select Date",
              style: TextStyle(
                fontSize: 18,
                color: selectedDate != null ? Colors.teal.shade700 : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
