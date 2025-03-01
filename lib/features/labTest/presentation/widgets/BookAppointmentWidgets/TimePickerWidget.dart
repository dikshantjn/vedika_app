import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabTestAppointmentViewModel.dart';

class TimePickerWidget extends StatelessWidget {
  const TimePickerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LabTestAppointmentViewModel>(context);
    String formattedTime = viewModel.selectedTime == null
        ? "Select Time"
        : DateFormat("hh:mm a").format(
      DateTime(2000, 1, 1, viewModel.selectedTime!.hour, viewModel.selectedTime!.minute),
    );

    return GestureDetector(
      onTap: () => _selectTime(context, viewModel),
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
              offset: Offset(0, 3),
            ),
          ],
          border: Border.all(color: Colors.blue.shade300, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: viewModel.selectedTime == null
                    ? Colors.grey.shade600
                    : Colors.black,
              ),
            ),
            Icon(Icons.access_time, color: Colors.blue.shade600),
          ],
        ),
      ),
    );
  }

  void _selectTime(BuildContext context, LabTestAppointmentViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return TimePickerSheet(viewModel: viewModel);
      },
    );
  }
}

class TimePickerSheet extends StatefulWidget {
  final LabTestAppointmentViewModel viewModel;

  const TimePickerSheet({Key? key, required this.viewModel}) : super(key: key);

  @override
  _TimePickerSheetState createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<TimePickerSheet> {
  late int selectedHour;
  late int selectedMinute;
  late String selectedAmPm;

  @override
  void initState() {
    super.initState();
    final time = widget.viewModel.selectedTime;
    selectedHour = time?.hour ?? 12;
    selectedMinute = time?.minute ?? 0;
    selectedAmPm = selectedHour >= 12 ? 'PM' : 'AM';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Select Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.close, color: Colors.blue.shade600),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _timePickerCard(
                title: "Hour",
                values: List.generate(12, (index) => index + 1),
                selectedValue: selectedHour,
                onChanged: (value) {
                  setState(() {
                    selectedHour = value;
                    selectedAmPm = selectedHour >= 12 ? 'PM' : 'AM';
                  });
                },
              ),
              _timePickerCard(
                title: "Minute",
                values: List.generate(60, (index) => index),
                selectedValue: selectedMinute,
                onChanged: (value) {
                  setState(() {
                    selectedMinute = value;
                  });
                },
              ),
              _timePickerCard(
                title: "AM/PM",
                values: ['AM', 'PM'],
                selectedValue: selectedAmPm,
                onChanged: (value) {
                  setState(() {
                    selectedAmPm = value;
                    if (selectedAmPm == 'PM' && selectedHour < 12) {
                      selectedHour += 12;
                    } else if (selectedAmPm == 'AM' && selectedHour >= 12) {
                      selectedHour -= 12;
                    }
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              widget.viewModel.selectedTime = TimeOfDay(hour: selectedHour, minute: selectedMinute);
              widget.viewModel.notifyListeners();  // Ensure listeners are notified.
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            ),
            child: Text(
              "Confirm Time",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timePickerCard({
    required String title,
    required List values,
    required selectedValue,
    required Function onChanged,
  }) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Container(
              height: 120,
              width: 80,
              child: ListWheelScrollView.useDelegate(
                itemExtent: 50,
                onSelectedItemChanged: (index) {
                  onChanged(values[index]);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    return Center(
                      child: Text(
                        values[index].toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: selectedValue == values[index]
                              ? Colors.blue.shade600
                              : Colors.black,
                        ),
                      ),
                    );
                  },
                  childCount: values.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
