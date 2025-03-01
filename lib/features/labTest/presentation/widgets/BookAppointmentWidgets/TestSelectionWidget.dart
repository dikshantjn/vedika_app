import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabTestAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabModel.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabTestModel.dart'; // Ensure LabTestModel is imported

class TestSelectionWidget extends StatelessWidget {
  final LabModel lab;

  const TestSelectionWidget({Key? key, required this.lab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ensures full width
      margin: const EdgeInsets.symmetric(horizontal: 16), // Side margins for better spacing
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 2,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Tests",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          SizedBox(height: 12),
          Consumer<LabTestAppointmentViewModel>(
            builder: (context, viewModel, child) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: lab.tests.map((LabTestModel test) {  // Ensure that `test` is a LabTestModel object
                  final isSelected = viewModel.selectedTests.contains(test);  // Correctly compare with LabTestModel
                  return ChoiceChip(
                    label: Text(
                      test.name,  // Use the name of the test, assuming LabTestModel has a 'name' field
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) => viewModel.toggleTestSelection(test),  // Pass the whole test object
                    selectedColor: Colors.blue.shade600,
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: isSelected ? 4 : 1,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
