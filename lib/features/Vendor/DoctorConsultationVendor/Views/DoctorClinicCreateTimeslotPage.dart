import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/ViewModels/DoctorClinicTimeslotViewModel.dart';

class DoctorClinicCreateTimeslotPage extends StatefulWidget {
  final bool isEditing;

  const DoctorClinicCreateTimeslotPage({
    Key? key,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<DoctorClinicCreateTimeslotPage> createState() => _DoctorClinicCreateTimeslotPageState();
}

class _DoctorClinicCreateTimeslotPageState extends State<DoctorClinicCreateTimeslotPage> {
  @override
  void initState() {
    super.initState();

    // If editing, ensure form is populated and slots are generated
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final viewModel = Provider.of<DoctorClinicTimeslotViewModel>(context, listen: false);
        developer.log('🔍 Edit mode initialization - Selected timeslot: ${viewModel.selectedTimeslot?.day ?? 'null'}, ID: ${viewModel.selectedTimeslot?.timeSlotID ?? 'null'}');
        developer.log('🔍 Edit mode - Form values: Day=${viewModel.dayController.text}, Start=${viewModel.startTimeController.text}, End=${viewModel.endTimeController.text}');

        // Generate slots preview to show existing slots in the preview
        viewModel.generateSlotsPreview();
        // Force a rebuild to ensure form fields show populated values
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorConsultationColorPalette.backgroundPrimary,
      appBar: _buildAppBar(),
      body: _buildCreateTimeslotForm(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: DoctorConsultationColorPalette.primaryColor,
      elevation: 0,
      title: Text(
        widget.isEditing ? 'Edit Time Slot' : 'Create Time Slot',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: DoctorConsultationColorPalette.primaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Widget _buildCreateTimeslotForm() {
    return Consumer<DoctorClinicTimeslotViewModel>(
      builder: (context, viewModel, child) {
        // Debug logging for form values
        if (widget.isEditing) {
          developer.log('🔍 Form values - Day: ${viewModel.dayController.text}, Start: ${viewModel.startTimeController.text}, End: ${viewModel.endTimeController.text}, Interval: ${viewModel.intervalController.text}');
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      DoctorConsultationColorPalette.primaryColor.withOpacity(0.1),
                      DoctorConsultationColorPalette.secondaryTeal.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: DoctorConsultationColorPalette.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: DoctorConsultationColorPalette.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.schedule,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.isEditing ? 'Update Time Slot' : 'New Time Slot',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: DoctorConsultationColorPalette.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Configure your consultation schedule',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: DoctorConsultationColorPalette.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Day Selection Card
              _buildDaySelectionCard(viewModel),

              const SizedBox(height: 24),

              // Time Configuration Card
              _buildTimeConfigurationCard(viewModel),

              const SizedBox(height: 24),

              // Preview Section (only show if slots are generated or editing existing timeslot)
              if (viewModel.generatedSlots.isNotEmpty || (widget.isEditing && viewModel.selectedTimeslot != null))
                _buildPreviewCard(viewModel),

              const SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDaySelectionCard(DoctorClinicTimeslotViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: DoctorConsultationColorPalette.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: DoctorConsultationColorPalette.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Day Selection',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DoctorConsultationColorPalette.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: widget.isEditing ? ValueKey('edit_day_${viewModel.dayController.text}') : null,
            value: viewModel.dayController.text.isNotEmpty && viewModel.weekDays.contains(viewModel.dayController.text)
                ? viewModel.dayController.text
                : null,
            items: viewModel.weekDays.map((day) {
              return DropdownMenuItem(
                value: day,
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_view_day,
                      color: DoctorConsultationColorPalette.primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      day,
                      style: TextStyle(
                        color: DoctorConsultationColorPalette.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                viewModel.dayController.text = value;
                viewModel.clearValidationErrors();
                viewModel.generateSlotsPreview();
              }
            },
            decoration: InputDecoration(
              hintText: 'Select consultation day',
              hintStyle: TextStyle(
                color: DoctorConsultationColorPalette.textHint,
              ),
              filled: true,
              fillColor: DoctorConsultationColorPalette.backgroundPrimary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: DoctorConsultationColorPalette.borderLight,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: DoctorConsultationColorPalette.borderLight,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: DoctorConsultationColorPalette.primaryColor,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(
                Icons.today,
                color: DoctorConsultationColorPalette.primaryColor,
              ),
            ),
          ),
          if (viewModel.validationErrors['day'] != null) ...[
            const SizedBox(height: 8),
            Text(
              viewModel.validationErrors['day']!,
              style: TextStyle(
                fontSize: 12,
                color: DoctorConsultationColorPalette.errorRed,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeConfigurationCard(DoctorClinicTimeslotViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: DoctorConsultationColorPalette.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: DoctorConsultationColorPalette.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Time Configuration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DoctorConsultationColorPalette.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Time Range
          Row(
            children: [
              Expanded(
                child: _buildTimeField(
                  key: widget.isEditing ? ValueKey('edit_start_${viewModel.startTimeController.text}') : null,
                  label: 'Start Time',
                  controller: viewModel.startTimeController,
                  hint: '09:00',
                  icon: Icons.play_arrow,
                  error: viewModel.validationErrors['startTime'],
                  onChanged: (value) {
                    viewModel.clearValidationErrors();
                    viewModel.generateSlotsPreview();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.arrow_forward,
                color: DoctorConsultationColorPalette.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeField(
                  key: widget.isEditing ? ValueKey('edit_end_${viewModel.endTimeController.text}') : null,
                  label: 'End Time',
                  controller: viewModel.endTimeController,
                  hint: '17:00',
                  icon: Icons.stop,
                  error: viewModel.validationErrors['endTime'],
                  onChanged: (value) {
                    viewModel.clearValidationErrors();
                    viewModel.generateSlotsPreview();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Interval Selection
          Text(
            'Consultation Duration',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DoctorConsultationColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DoctorConsultationColorPalette.backgroundPrimary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DoctorConsultationColorPalette.borderLight,
              ),
            ),
            child: DropdownButtonFormField<int>(
              key: widget.isEditing ? ValueKey('edit_interval_${viewModel.intervalController.text}') : null,
              value: viewModel.intervalController.text.isNotEmpty
                  ? int.tryParse(viewModel.intervalController.text)
                  : 30,
              items: viewModel.timeIntervals.map((interval) {
                return DropdownMenuItem(
                  value: interval,
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: DoctorConsultationColorPalette.primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$interval minutes',
                        style: TextStyle(
                          color: DoctorConsultationColorPalette.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  viewModel.intervalController.text = value.toString();
                  viewModel.clearValidationErrors();
                  viewModel.generateSlotsPreview();
                }
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (viewModel.validationErrors['intervalMinutes'] != null) ...[
            const SizedBox(height: 8),
            Text(
              viewModel.validationErrors['intervalMinutes']!,
              style: TextStyle(
                fontSize: 12,
                color: DoctorConsultationColorPalette.errorRed,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeField({
    Key? key,
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
    String? error,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: DoctorConsultationColorPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: _parseTimeString(controller.text) ?? TimeOfDay.now(),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: DoctorConsultationColorPalette.primaryColor,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: DoctorConsultationColorPalette.textPrimary,
                    ),
                    dialogBackgroundColor: Colors.white,
                  ),
                  child: child!,
                );
              },
            );

            if (picked != null) {
              final formattedTime = _formatTimeOfDay(picked);
              controller.text = formattedTime;
              onChanged(formattedTime);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: DoctorConsultationColorPalette.backgroundPrimary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: error != null
                    ? DoctorConsultationColorPalette.errorRed
                    : DoctorConsultationColorPalette.borderLight,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: DoctorConsultationColorPalette.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? hint : controller.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: controller.text.isEmpty
                          ? DoctorConsultationColorPalette.textHint
                          : DoctorConsultationColorPalette.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.access_time,
                  color: DoctorConsultationColorPalette.primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(
            error,
            style: TextStyle(
              fontSize: 12,
              color: DoctorConsultationColorPalette.errorRed,
            ),
          ),
        ],
      ],
    );
  }

  // Helper method to parse time string to TimeOfDay
  TimeOfDay? _parseTimeString(String timeString) {
    if (timeString.isEmpty) return null;

    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }

  // Helper method to format TimeOfDay to HH:MM string
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Helper method to build time slot ranges from individual slots
  List<Widget> _buildTimeSlotRanges(List<String> slots) {
    List<Widget> slotWidgets = [];

    for (int i = 0; i < slots.length - 1; i++) {
      final currentSlot = slots[i];
      final nextSlot = slots[i + 1];
      final rangeText = '$currentSlot to $nextSlot';

      slotWidgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: DoctorConsultationColorPalette.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: DoctorConsultationColorPalette.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Text(
            rangeText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: DoctorConsultationColorPalette.primaryColor,
            ),
          ),
        ),
      );
    }

    // If there's only one slot, show it as is
    if (slots.length == 1) {
      slotWidgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: DoctorConsultationColorPalette.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: DoctorConsultationColorPalette.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Text(
            slots[0],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: DoctorConsultationColorPalette.primaryColor,
            ),
          ),
        ),
      );
    }

    return slotWidgets;
  }

  Widget _buildPreviewCard(DoctorClinicTimeslotViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DoctorConsultationColorPalette.successGreen.withOpacity(0.1),
            DoctorConsultationColorPalette.secondaryTeal.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DoctorConsultationColorPalette.successGreen.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: DoctorConsultationColorPalette.successGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Generated Time Slots',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DoctorConsultationColorPalette.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: DoctorConsultationColorPalette.primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isEditing && viewModel.selectedTimeslot != null
                          ? '${viewModel.selectedTimeslot!.generatedSlots.length} existing slots'
                          : '${viewModel.generatedSlots.length} slots will be created',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DoctorConsultationColorPalette.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _buildTimeSlotRanges(
                    widget.isEditing && viewModel.selectedTimeslot != null
                        ? viewModel.selectedTimeslot!.generatedSlots.take(12).toList()
                        : viewModel.generatedSlots.take(12).toList(),
                  ),
                ),
                if ((widget.isEditing && viewModel.selectedTimeslot != null
                        ? viewModel.selectedTimeslot!.generatedSlots.length
                        : viewModel.generatedSlots.length) > 12)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '... and ${(widget.isEditing && viewModel.selectedTimeslot != null
                          ? viewModel.selectedTimeslot!.generatedSlots.length
                          : viewModel.generatedSlots.length) - 12} more slots',
                      style: TextStyle(
                        fontSize: 12,
                        color: DoctorConsultationColorPalette.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(DoctorClinicTimeslotViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: DoctorConsultationColorPalette.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (widget.isEditing) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: DoctorConsultationColorPalette.textSecondary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: viewModel.isFormValid && !viewModel.isSaving
                      ? () async {
                          // Debug: Check selected timeslot before update
                          if (widget.isEditing) {
                            developer.log('🔍 Before update - Selected timeslot: ${viewModel.selectedTimeslot?.day ?? 'null'}, ID: ${viewModel.selectedTimeslot?.timeSlotID ?? 'null'}');
                          }

                          final success = widget.isEditing
                              ? await viewModel.updateTimeslot()
                              : await viewModel.createTimeslot();

                          if (success && mounted) {
                            _showSuccessMessage(context, viewModel.successMessage ?? 'Updated Successfully!');
                            Navigator.pop(context, true); // Return success
                          }
                        }
                      : null,
                  icon: viewModel.isSaving
                      ? Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(right: 8),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(widget.isEditing ? Icons.save : Icons.add),
                  label: Text(
                    viewModel.isSaving
                        ? 'Saving...'
                        : (widget.isEditing ? 'Update Slot' : 'Create Slot'),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: DoctorConsultationColorPalette.primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: DoctorConsultationColorPalette.buttonDisabled,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: DoctorConsultationColorPalette.successGreen,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: DoctorConsultationColorPalette.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
