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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
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
        ),

        // Show the error message below the time selection field
        ValueListenableBuilder<String?>(
          valueListenable: viewModel.timeError,
          builder: (context, error, child) {
            if (error == null) return SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            );
          },
        ),
      ],
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

  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;
  late FixedExtentScrollController amPmController;

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    final time = widget.viewModel.selectedTime ?? now;

    selectedHour = (time.hourOfPeriod == 0) ? 12 : time.hourOfPeriod;
    selectedMinute = time.minute;
    selectedAmPm = time.period == DayPeriod.am ? 'AM' : 'PM';

    hourController = FixedExtentScrollController(initialItem: selectedHour - 1);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute);
    amPmController = FixedExtentScrollController(initialItem: selectedAmPm == 'AM' ? 0 : 1);
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    amPmController.dispose();
    super.dispose();
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
                  });
                },
                controller: hourController,
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
                controller: minuteController,
              ),
              _timePickerCard(
                title: "AM/PM",
                values: ['AM', 'PM'],
                selectedValue: selectedAmPm,
                onChanged: (value) {
                  setState(() {
                    selectedAmPm = value;
                  });
                },
                controller: amPmController,
              ),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              int hour = selectedHour;
              if (selectedAmPm == 'PM' && hour != 12) {
                hour += 12;
              } else if (selectedAmPm == 'AM' && hour == 12) {
                hour = 0;
              }

              widget.viewModel.selectedTime = TimeOfDay(hour: hour, minute: selectedMinute);
              widget.viewModel.timeError.value = null;
              widget.viewModel.notifyListeners();
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
    required FixedExtentScrollController controller,
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
                controller: controller,
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
