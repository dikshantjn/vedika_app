import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/OrderActivity/presentation/viewModal/TrackOrderViewModel.dart';

class TrackOrderScreen extends StatelessWidget {
  final int orderId;

  TrackOrderScreen({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrackOrderViewModel(),
      child: Scaffold(
        appBar: AppBar(title: Text("Track Order")),
        body: Consumer<TrackOrderViewModel>(
          builder: (context, viewModel, _) {
            return FutureBuilder<void>(
              future: viewModel.fetchOrderActivities(orderId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return Column(
                    children: [
                      _buildOrderActivityStepper(viewModel),
                      _buildOrderActivityList(viewModel),
                    ],
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  // Builds the horizontal stepper (stripper) based on the activities
  Widget _buildOrderActivityStepper(TrackOrderViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Stepper(
        currentStep: _getCurrentStep(viewModel),
        onStepTapped: (index) {},
        steps: viewModel.orderActivities.map((activity) {
          return Step(
            title: Text(activity.activity),
            content: Text(activity.timestamp),
            isActive: true,
          );
        }).toList(),
        type: StepperType.horizontal,
      ),
    );
  }

  // Calculate the current step based on the status of the order
  int _getCurrentStep(TrackOrderViewModel viewModel) {
    for (int i = 0; i < viewModel.orderActivities.length; i++) {
      if (viewModel.orderActivities[i].status == "In Progress") {
        return i;
      }
    }
    return viewModel.orderActivities.length - 1; // If completed, return the last step
  }

  // Displays a list of order activities with status and timestamp
  Widget _buildOrderActivityList(TrackOrderViewModel viewModel) {
    return Expanded(
      child: ListView.builder(
        itemCount: viewModel.orderActivities.length,
        itemBuilder: (context, index) {
          final activity = viewModel.orderActivities[index];
          return ListTile(
            title: Text(activity.activity),
            subtitle: Text("Timestamp: ${activity.timestamp}"),
            trailing: Text(activity.status),
          );
        },
      ),
    );
  }
}
