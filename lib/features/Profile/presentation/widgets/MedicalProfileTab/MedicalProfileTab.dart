import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Profile/presentation/viewmodel/UserProfileViewModel.dart';
import 'EditMedicalProfileScreen.dart';

class MedicalProfileTab extends StatelessWidget {
  final UserProfileViewModel viewModel;

  MedicalProfileTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _buildKeyValueRow('Diabetic', viewModel.medicalProfile.isDiabetic ? 'Yes' : 'No'),
              Divider(),
              _buildKeyValueRow('Allergies', viewModel.medicalProfile.allergies.isNotEmpty
                  ? viewModel.medicalProfile.allergies.join(', ')
                  : 'No allergies listed'),
              Divider(),
              _buildKeyValueRow('Eye Power', '${viewModel.medicalProfile.eyePower}'),
              Divider(),
              _buildKeyValueRow('Current Medication', viewModel.medicalProfile.currentMedication.isNotEmpty
                  ? viewModel.medicalProfile.currentMedication.join(', ')
                  : 'No current medications'),
              Divider(),
              _buildKeyValueRow('Past Medication', viewModel.medicalProfile.pastMedication.isNotEmpty
                  ? viewModel.medicalProfile.pastMedication.join(', ')
                  : 'No past medications'),
              Divider(),
              _buildKeyValueRow('Chronic Conditions', viewModel.medicalProfile.chronicConditions.isNotEmpty
                  ? viewModel.medicalProfile.chronicConditions.join(', ')
                  : 'No chronic conditions'),
              Divider(),
              _buildKeyValueRow('Injuries', viewModel.medicalProfile.injuries.isNotEmpty
                  ? viewModel.medicalProfile.injuries.join(', ')
                  : 'No injuries reported'),
              Divider(),
              _buildKeyValueRow('Surgeries', viewModel.medicalProfile.surgeries.isNotEmpty
                  ? viewModel.medicalProfile.surgeries.join(', ')
                  : 'No surgeries performed'),
              Divider(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditMedicalProfileScreen(viewModel: viewModel),
                ),
              );
            },
            child: Text('Edit Medical Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyValueRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

