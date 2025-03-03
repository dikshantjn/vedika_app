import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabTestAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabModel.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabTestModel.dart';

class TestSelectionWidget extends StatelessWidget {
  final LabModel lab;

  const TestSelectionWidget({Key? key, required this.lab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LabTestAppointmentViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 6,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Tests",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: lab.tests.map((LabTestModel test) {
                  final isSelected = viewModel.selectedTests.contains(test);
                  return ChoiceChip(
                    label: Text(
                      test.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      viewModel.toggleTestSelection(test);
                    },
                    selectedColor: Colors.blue.shade600,
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: isSelected ? 4 : 1,
                  );
                }).toList(),
              ),
              if (viewModel.testError.value != null) ...[
                const SizedBox(height: 8),
                Text(
                  viewModel.testError.value!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
