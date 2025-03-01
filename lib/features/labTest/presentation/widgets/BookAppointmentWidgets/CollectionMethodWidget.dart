import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabTestAppointmentViewModel.dart';

class CollectionMethodWidget extends StatelessWidget {
  const CollectionMethodWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
        border: Border.all(color: Colors.blue.shade300, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.home_filled, color: Colors.blue.shade600, size: 24),
              SizedBox(width: 8),
              Text(
                "Home Sample Collection",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Consumer<LabTestAppointmentViewModel>(
            builder: (context, viewModel, child) {
              return Switch.adaptive(
                value: viewModel.isHomeSampleCollection,
                onChanged: viewModel.toggleHomeSampleCollection,
                activeColor: Colors.white,
                activeTrackColor: Colors.blue.shade600,
                inactiveTrackColor: Colors.grey.shade300,
                inactiveThumbColor: Colors.grey.shade500,
              );
            },
          ),
        ],
      ),
    );
  }
}
