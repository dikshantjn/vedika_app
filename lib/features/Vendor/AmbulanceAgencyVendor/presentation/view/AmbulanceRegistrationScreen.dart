import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceAgencyViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/Registration/AgencyInfoSection.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/Registration/AmbulanceAgencyRegSubmitButton.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/Registration/AmbulanceDetailsSection.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/Registration/PaymentLocationSection.dart';

class AmbulanceRegistrationScreen extends StatefulWidget {
  @override
  _AmbulanceRegistrationScreenState createState() =>
      _AmbulanceRegistrationScreenState();
}

class _AmbulanceRegistrationScreenState extends State<AmbulanceRegistrationScreen> {
  int _currentIndex = 0; // Track the current section index
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Key to manage form validation
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled; // Control when to show validation errors

  final List<Widget> _sections = [
    AgencyInfoSection(),
    AmbulanceDetailsSection(),
    PaymentLocationSection(),
  ];

  final List<String> _steps = ['Agency Info', 'Ambulance Details', 'Location Details'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Ambulance Agency Registration',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ChangeNotifierProvider(
        create: (_) => AmbulanceAgencyViewModel(),
        child: Consumer<AmbulanceAgencyViewModel>(
          builder: (context, viewModel, _) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autoValidateMode, // Set autovalidate mode here
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTimeline(_steps, _currentIndex),
                      _sections[_currentIndex],
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentIndex > 0)
                            IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                setState(() {
                                  if (_currentIndex > 0) {
                                    _currentIndex--;
                                  }
                                });
                              },
                            ),
                          if (_currentIndex == _steps.length - 1)
                            if (_currentIndex == _steps.length - 1)
                              AmbulanceAgencyRegSubmitButton(
                                buttonText: 'Submit Request',
                                buttonIcon: Icons.check_circle_outline,
                                onPressed: () async {
                                  // Submit the registration logic here
                                  await viewModel.submitRegistration();
                                },
                                formKey: _formKey,
                                autoValidateMode: _autoValidateMode,
                                viewModelValidation: viewModel.validateForm,
                              ),
                          Spacer(),
                          if (_currentIndex < _steps.length - 1)
                            IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: () {
                                // Trigger validation when moving to the next step
                                setState(() {
                                  _autoValidateMode = AutovalidateMode.always;
                                });

                                if (_formKey.currentState?.validate() ?? false) {
                                  setState(() {
                                    if (_currentIndex < _steps.length - 1) {
                                      _currentIndex++;
                                    }
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fix the errors')));
                                }
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Horizontal Timeline Builder
  Widget _buildTimeline(List<String> steps, int currentStepIndex) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final isCompleted = index <= currentStepIndex - 1;
          final isCurrent = index == currentStepIndex;

          Color lineColor = isCompleted ? Colors.green : Colors.grey.shade300;
          Color indicatorColor = isCompleted ? Colors.green : (isCurrent ? Colors.blue : Colors.white);
          Color textColor = isCompleted ? Colors.green : (isCurrent ? Colors.blue : Colors.grey);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            width: 120,
            child: TimelineTile(
              axis: TimelineAxis.horizontal,
              alignment: TimelineAlign.start,
              isFirst: index == 0,
              isLast: index == steps.length - 1,
              beforeLineStyle: LineStyle(color: lineColor, thickness: 2),
              indicatorStyle: IndicatorStyle(
                width: 30,
                height: 30,
                indicator: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted ? Colors.green : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(Icons.check, size: 18, color: Colors.white)  // Show check icon if completed
                        : Text(
                      (index + 1).toString(), // Display step number
                      style: TextStyle(
                        color: isCompleted ? Colors.white : (isCurrent ? Colors.white : Colors.grey),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              afterLineStyle: LineStyle(color: lineColor, thickness: 2),
              endChild: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  steps[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textColor),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
