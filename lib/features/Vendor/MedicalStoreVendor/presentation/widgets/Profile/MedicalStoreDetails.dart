import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicalStoreVendorUpdateProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Profile/CustomSwitch.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Profile/SectionTitle.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Profile/TextFieldWidget.dart';

class MedicalStoreDetails extends StatefulWidget {
  final MedicalStoreVendorUpdateProfileViewModel viewModel;

  const MedicalStoreDetails({Key? key, required this.viewModel}) : super(key: key);

  @override
  _MedicalStoreDetailsState createState() => _MedicalStoreDetailsState();
}

class _MedicalStoreDetailsState extends State<MedicalStoreDetails> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  /// Format time to 12-hour format (AM/PM)
  String formatTime(TimeOfDay? time) {
    if (time == null) return "Select Time";
    final now = DateTime.now();
    final formattedTime = DateFormat.jm().format(DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    ));
    return formattedTime;
  }

  /// Show Time Picker
  Future<void> _pickTime({required bool isStartTime}) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? (_startTime ?? TimeOfDay.now()) : (_endTime ?? TimeOfDay.now()),
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
        widget.viewModel.storeTiming = "${formatTime(_startTime)} - ${formatTime(_endTime)}";
        widget.viewModel.notifyListeners();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: "Store Details"), // Section Title

        TextFieldWidget(
          label: "Address",
          initialValue: widget.viewModel.address,
          onChanged: (value) {
            widget.viewModel.address = value;
          },
        ),
        TextFieldWidget(
          label: "Nearby Landmark",
          initialValue: widget.viewModel.nearbyLandmark,
          onChanged: (value) {
            widget.viewModel.nearbyLandmark = value;
          },
        ),

        // Store Timing (Start & End Time)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickTime(isStartTime: true),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Start Time: ${formatTime(_startTime)}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickTime(isStartTime: false),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "End Time: ${formatTime(_endTime)}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        TextFieldWidget(
          label: "Store Open Days", // New Field
          initialValue: widget.viewModel.storeOpenDays,
          onChanged: (value) {
            widget.viewModel.storeOpenDays = value;
          },
        ),
        TextFieldWidget(
          label: "Floor", // New Field
          initialValue: widget.viewModel.floor,
          onChanged: (value) {
            widget.viewModel.floor = value;
          },
        ),
        CustomSwitch(
          label: "Lift Access",
          value: widget.viewModel.isLiftAccess,
          onChanged: (value) {
            widget.viewModel.isLiftAccess = value;
            widget.viewModel.notifyListeners();
          },
        ),
        CustomSwitch(
          label: "Wheelchair Access",
          value: widget.viewModel.isWheelchairAccess,
          onChanged: (value) {
            widget.viewModel.isWheelchairAccess = value;
            widget.viewModel.notifyListeners();
          },
        ),
      ],
    );
  }
}
