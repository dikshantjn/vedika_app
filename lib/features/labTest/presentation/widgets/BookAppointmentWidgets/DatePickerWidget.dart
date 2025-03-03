import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabTestAppointmentViewModel.dart';

class DatePickerWidget extends StatelessWidget {
  const DatePickerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LabTestAppointmentViewModel>(context);
    String formattedDate = viewModel.selectedDate == null
        ? "Select a Date"
        : DateFormat("dd/MM/yyyy").format(viewModel.selectedDate!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => viewModel.selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: Colors.blue.shade300, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: viewModel.selectedDate == null
                        ? Colors.grey.shade600
                        : Colors.black,
                  ),
                ),
                Icon(Icons.calendar_today, color: Colors.blue.shade600),
              ],
            ),
          ),
        ),
        if (viewModel.dateError.value != null) ...[
          const SizedBox(height: 8),
          Text(
            viewModel.dateError.value!,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
        ],
      ],
    );
  }
}
