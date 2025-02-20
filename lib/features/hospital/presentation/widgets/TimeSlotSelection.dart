import 'package:flutter/material.dart';

class TimeSlotSelection extends StatelessWidget {
  final List<String> timeSlots;
  final String? selectedTimeSlot;
  final Function(String) onTimeSlotSelected;

  const TimeSlotSelection({
    required this.timeSlots,
    required this.selectedTimeSlot,
    required this.onTimeSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Time Slot", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 8, // Adjusting the spacing between chips
          children: timeSlots.map((time) {
            return ChoiceChip(
              label: Text(
                time,
                style: TextStyle(fontSize: 13, color: selectedTimeSlot == time ? Colors.white : Colors.black),
              ),
              selected: selectedTimeSlot == time,
              onSelected: (selected) {
                onTimeSlotSelected(selected ? time : "");
              },
              selectedColor: Color(0xFF38A3A5), // Selected color with your specified lighter color
              backgroundColor: Color(0xFFB6DADA), // Default background color for unselected chips
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 4, // Shadow effect
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            );
          }).toList(),
        ),
      ],
    );
  }
}
