import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserMedicalProfileViewModel.dart';
import 'EditMedicalProfileScreen.dart';

class MedicalProfileTab extends StatefulWidget {
  final UserMedicalProfileViewModel viewModel;

  const MedicalProfileTab({Key? key, required this.viewModel}) : super(key: key);

  @override
  _MedicalProfileTabState createState() => _MedicalProfileTabState();
}

class _MedicalProfileTabState extends State<MedicalProfileTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.fetchMedicalProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isLoading) {
          return Center(child: CircularProgressIndicator()); // Show loader
        }

        if (widget.viewModel.errorMessage?.isNotEmpty == true) {
          return Center(child: Text("Error: ${widget.viewModel.errorMessage}"));
        }

        final medicalProfile = widget.viewModel.medicalProfile;

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildKeyValueRow('Diabetic', medicalProfile?.isDiabetic == true ? 'Yes' : 'No'),
                  Divider(),
                  _buildKeyValueRow(
                      'Allergies',
                      (medicalProfile?.allergies?.isNotEmpty == true)
                          ? medicalProfile!.allergies.join(', ')
                          : 'NA'),
                  Divider(),
                  _buildKeyValueRow('Eye Power', medicalProfile?.eyePower?.toString() ?? 'NA'),
                  Divider(),
                  _buildKeyValueRow(
                      'Current Medication',
                      (medicalProfile?.currentMedication?.isNotEmpty == true)
                          ? medicalProfile!.currentMedication.join(', ')
                          : 'NA'),
                  Divider(),
                  _buildKeyValueRow(
                      'Past Medication',
                      (medicalProfile?.pastMedication?.isNotEmpty == true)
                          ? medicalProfile!.pastMedication.join(', ')
                          : 'NA'),
                  Divider(),
                  _buildKeyValueRow(
                      'Chronic Conditions',
                      (medicalProfile?.chronicConditions?.isNotEmpty == true)
                          ? medicalProfile!.chronicConditions.join(', ')
                          : 'NA'),
                  Divider(),
                  _buildKeyValueRow(
                      'Injuries',
                      (medicalProfile?.injuries?.isNotEmpty == true)
                          ? medicalProfile!.injuries.join(', ')
                          : 'NA'),
                  Divider(),
                  _buildKeyValueRow(
                      'Surgeries',
                      (medicalProfile?.surgeries?.isNotEmpty == true)
                          ? medicalProfile!.surgeries.join(', ')
                          : 'NA'),
                  Divider(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
              child: ElevatedButton(
                onPressed: () async {
                  // Navigate to EditMedicalProfileScreen and wait for a result
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditMedicalProfileScreen(viewModel: widget.viewModel),
                    ),
                  );

                  // Reload data if the result is true
                  if (result == true) {
                    widget.viewModel.fetchMedicalProfile();
                  }
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
      },
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
