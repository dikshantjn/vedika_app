import 'package:flutter/material.dart';

class StepperWidget extends StatelessWidget {
  final int currentStep;

  StepperWidget({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    List<String> steps = [
      "Request Sent",
      "Request Accepted",
      "Prescription Verified",
      "Select Medicine"
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Centers everything
          children: List.generate(steps.length, (index) {
            bool isCompleted = index <= currentStep;

            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // Aligns circles properly
                    children: [
                      // Step Circle
                      Container(
                        width: 36, // Fixed width
                        height: 36, // Fixed height
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? Colors.blue : Colors.grey.shade300,
                        ),
                        child: Center(
                          child: Icon(Icons.check, size: 18, color: Colors.white),
                        ),
                      ),

                      // Connecting Line (Only between steps)
                      if (index < steps.length - 1)
                        Expanded(
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            height: 4,
                            margin: EdgeInsets.symmetric(horizontal: 4), // More spacing
                            decoration: BoxDecoration(
                              color: (index < currentStep) ? Colors.blue : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 10), // More spacing below circles
                  SizedBox(
                    width: 80, // Ensures all text is aligned
                    child: Text(
                      steps[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
