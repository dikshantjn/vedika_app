import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/EmergencyService/data/services/EmergencyService.dart';
import 'package:vedika_healthcare/features/EmergencyService/presentation/viewmodel/EmergencyViewModel.dart';

class EmergencyDialog extends StatefulWidget {
  final String doctorNumber;
  final String ambulanceNumber;
  final String bloodBankNumber;

  const EmergencyDialog({
    Key? key,
    required this.doctorNumber,
    required this.ambulanceNumber,
    required this.bloodBankNumber,
  }) : super(key: key);

  @override
  State<EmergencyDialog> createState() => _EmergencyDialogState();
}

class _EmergencyDialogState extends State<EmergencyDialog> {
  late EmergencyViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EmergencyViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<EmergencyViewModel>(
        builder: (context, viewModel, _) {
          return WillPopScope(
            onWillPop: () async {
              // Ensure the dialog can be closed even if location check is in progress
              return true;
            },
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 20,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with more space
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 80,
                    ),
                    const SizedBox(height: 20),

                    // Title with a modern font
                    const Text(
                      "Emergency Call",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Descriptive text
                    const Text(
                      "Do you want to call emergency services?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Show loading or options
                    if (!viewModel.showOptions) ...[
                      viewModel.isLoading
                          ? Column(
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text("Checking location..."),
                        ],
                      )
                          : ElevatedButton(
                        onPressed: () {
                          viewModel.checkLocationEnabled(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          "Yes, Call Emergency",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],

                    // Show options after clicking "Yes, Call Emergency"
                    if (viewModel.showOptions) ...[
                      _buildOptionButton(
                        context,
                        "Call to Doctor",
                        Colors.blueAccent,
                        Icons.call,
                            () => context.read<EmergencyService>().triggerDoctorEmergency(widget.doctorNumber),
                      ),
                      const SizedBox(height: 15),

                      _buildOptionButton(
                        context,
                        "Call Ambulance",
                        Colors.greenAccent,
                        Icons.local_hospital,
                            () => context.read<EmergencyService>().triggerAmbulanceEmergency(widget.ambulanceNumber),
                      ),
                      const SizedBox(height: 15),

                      _buildOptionButton(
                        context,
                        "Call Blood Bank",
                        Colors.pinkAccent,
                        Icons.bloodtype,
                            () => context.read<EmergencyService>().triggerBloodBankEmergency(widget.bloodBankNumber),
                      ),
                      const SizedBox(height: 25),
                    ],

                    // Cancel Button with softer design
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "No, Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to create option buttons with icons
  Widget _buildOptionButton(
      BuildContext context,
      String text,
      Color color,
      IconData icon,
      VoidCallback onPressed,
      ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
