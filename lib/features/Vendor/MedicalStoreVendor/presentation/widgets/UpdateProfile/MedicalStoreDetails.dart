import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicalStoreVendorUpdateProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/CustomDropdown.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/CustomSwitch.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/SectionTitle.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/TextFieldWidget.dart';
import 'package:vedika_healthcare/shared/utils/state_city_data.dart';

class MedicalStoreDetails extends StatefulWidget {
  final MedicalStoreVendorUpdateProfileViewModel viewModel;

  const MedicalStoreDetails({Key? key, required this.viewModel}) : super(key: key);

  @override
  _MedicalStoreDetailsState createState() => _MedicalStoreDetailsState();
}

class _MedicalStoreDetailsState extends State<MedicalStoreDetails> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? selectedState;
  String? selectedCity;

  /// Format time to 12-hour format (AM/PM)
  String formatTime(TimeOfDay? time) {
    if (time == null) return "Select Time";
    final now = DateTime.now();
    return DateFormat.jm().format(DateTime(now.year, now.month, now.day, time.hour, time.minute));
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
  void initState() {
    super.initState();

    // If store timing is already fetched, split the time string and set start and end times
    if (widget.viewModel.storeTiming.isNotEmpty) {
      List<String> timeParts = widget.viewModel.storeTiming.split(' - ');
      if (timeParts.length == 2) {
        _startTime = _parseTime(timeParts[0]);
        _endTime = _parseTime(timeParts[1]);
      }
    }

    // If state and city are already fetched, set the selected state and city
    selectedState = widget.viewModel.state;
    selectedCity = widget.viewModel.city;
  }

  // Helper method to parse time string and convert to TimeOfDay
  TimeOfDay _parseTime(String timeString) {
    final timeFormat = DateFormat.jm();
    final time = timeFormat.parse(timeString);
    return TimeOfDay(hour: time.hour, minute: time.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: "Store Details"),
        TextFieldWidget(
          label: "Address",
          initialValue: widget.viewModel.address,
          onChanged: (value) => widget.viewModel.address = value,
        ),
        TextFieldWidget(
          label: "Nearby Landmark",
          initialValue: widget.viewModel.nearbyLandmark,
          onChanged: (value) => widget.viewModel.nearbyLandmark = value,
        ),

        // Store Timing
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
                    child: Text("Start Time: ${formatTime(_startTime)}", style: TextStyle(fontSize: 16)),
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
                    child: Text("End Time: ${formatTime(_endTime)}", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),

        CustomDropdown(
          label: "State",
          items: StateCityDataProvider.states.map((state) => state.name).toList(),
          selectedValue: selectedState,
          onChanged: (newState) {
            setState(() {
              selectedState = newState;
              selectedCity = null; // Reset city selection
              widget.viewModel.state = newState ?? "";
            });
          },
        ),

        CustomDropdown(
          label: "City",
          items: selectedState != null ? StateCityDataProvider.getCities(selectedState!) : [],
          selectedValue: selectedCity,
          onChanged: (newCity) {
            setState(() {
              selectedCity = newCity;
              widget.viewModel.city = newCity ?? "";
            });
          },
        ),

        TextFieldWidget(
          label: "Pincode",
          initialValue: widget.viewModel.pincode,
          keyboardType: TextInputType.number,
          onChanged: (value) => widget.viewModel.pincode = value,
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
