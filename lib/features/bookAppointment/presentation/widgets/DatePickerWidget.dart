import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

class DatePickerWidget extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDatePicked;

  const DatePickerWidget(
      {required this.selectedDate, required this.onDatePicked});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 30)),
        );
        if (pickedDate != null) onDatePicked(pickedDate);
      },
      child: Container(
        width: double.infinity,  // Makes the widget take the full width
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
          border: Border.all(
            color: ColorPalette.primaryColor,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate != null
                  ? "${selectedDate!.toLocal()}".split(' ')[0]
                  : "Choose a Date",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: selectedDate != null
                    ? Colors.black
                    : Colors.grey[700],
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: ColorPalette.primaryColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
