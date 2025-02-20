import 'package:flutter/material.dart';

class TimeSlotSelection extends StatelessWidget {
  final List<String> timeSlots;
  final String? selectedTimeSlot;
  final Function(String) onTimeSlotSelected;

  const TimeSlotSelection({
    Key? key,
    required this.timeSlots,
    this.selectedTimeSlot,
    required this.onTimeSlotSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Time Slot", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        // Wrap widget to arrange the items in multiple rows
        Wrap(
          spacing: 10, // Space between items horizontally
          runSpacing: 10, // Space between rows vertically
          children: timeSlots.map((timeSlot) {
            bool isSelected = selectedTimeSlot == timeSlot;
            return GestureDetector(
              onTap: () => onTimeSlotSelected(timeSlot),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.teal.shade100 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.teal.shade500 : Colors.grey.shade300,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? Colors.teal.withOpacity(0.2) : Colors.transparent,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: isSelected ? Colors.teal.shade700 : Colors.grey.shade500,
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Text(
                      timeSlot,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.teal.shade700 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}