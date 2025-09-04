import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicTimeslotModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/ViewModels/DoctorClinicTimeslotViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/DoctorClinicCreateTimeslotPage.dart';
import 'package:flutter/services.dart';

class DoctorClinicTimeslotPage extends StatefulWidget {
  const DoctorClinicTimeslotPage({Key? key}) : super(key: key);

  @override
  State<DoctorClinicTimeslotPage> createState() => _DoctorClinicTimeslotPageState();
}

class _DoctorClinicTimeslotPageState extends State<DoctorClinicTimeslotPage> {
  @override
  void initState() {
    super.initState();

    // Load timeslots when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorClinicTimeslotViewModel>().loadTimeslots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorConsultationColorPalette.backgroundPrimary,
      body: _buildTimeslotList(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: DoctorConsultationColorPalette.primaryColor,
      elevation: 0,
      title: const Text(
        'Time Slots',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: DoctorConsultationColorPalette.primaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Widget _buildTimeslotList() {
    return Consumer<DoctorClinicTimeslotViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                DoctorConsultationColorPalette.primaryColor,
              ),
            ),
          );
        }

        if (viewModel.timeslots.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await viewModel.loadTimeslots();
          },
          color: DoctorConsultationColorPalette.primaryColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: viewModel.timeslots.length,
            itemBuilder: (context, index) {
              final timeslot = viewModel.timeslots[index];
              return _buildTimeslotCard(timeslot, viewModel);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DoctorConsultationColorPalette.primaryColor.withOpacity(0.1),
                    DoctorConsultationColorPalette.secondaryTeal.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.schedule,
                size: 64,
                color: DoctorConsultationColorPalette.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Time Slots Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: DoctorConsultationColorPalette.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your consultation schedule to start accepting appointments from patients.',
              style: TextStyle(
                fontSize: 16,
                color: DoctorConsultationColorPalette.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DoctorConsultationColorPalette.primaryColor,
                    DoctorConsultationColorPalette.secondaryTeal,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton.icon(
                onPressed: _navigateToCreateTimeslot,
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Create Your First Time Slot',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: DoctorConsultationColorPalette.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeslotCard(
      timeslot, DoctorClinicTimeslotViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: DoctorConsultationColorPalette.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with day and status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        DoctorConsultationColorPalette.primaryColor.withOpacity(0.1),
                        DoctorConsultationColorPalette.secondaryTeal.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getDayIcon(timeslot.day),
                    color: DoctorConsultationColorPalette.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeslot.day,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: DoctorConsultationColorPalette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: timeslot.isActive
                              ? DoctorConsultationColorPalette.successGreen.withOpacity(0.1)
                              : DoctorConsultationColorPalette.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          timeslot.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: timeslot.isActive
                                ? DoctorConsultationColorPalette.successGreen
                                : DoctorConsultationColorPalette.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: timeslot.isActive,
                  onChanged: (value) async {
                    final success = await viewModel.toggleTimeslotStatus(timeslot.timeSlotID!, value);
                    if (success) {
                      _showSuccessMessage(
                        context,
                        'Timeslot ${value ? 'activated' : 'deactivated'} successfully!',
                      );
                    }
                  },
                  activeColor: DoctorConsultationColorPalette.primaryColor,
                  activeTrackColor: DoctorConsultationColorPalette.primaryColor.withOpacity(0.3),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Time range display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DoctorConsultationColorPalette.backgroundPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: DoctorConsultationColorPalette.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${timeslot.startTime} - ${timeslot.endTime}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DoctorConsultationColorPalette.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: DoctorConsultationColorPalette.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${timeslot.intervalMinutes}min',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: DoctorConsultationColorPalette.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Slot count and preview
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: DoctorConsultationColorPalette.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${timeslot.generatedSlots.length} slots available',
                        style: TextStyle(
                          fontSize: 14,
                          color: DoctorConsultationColorPalette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (timeslot.generatedSlots.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: DoctorConsultationColorPalette.secondaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      timeslot.generatedSlots.first,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: DoctorConsultationColorPalette.secondaryTeal,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showViewSlotsDialog(context, timeslot, viewModel),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View Slots'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: DoctorConsultationColorPalette.secondaryTeal,
                      side: BorderSide(
                        color: DoctorConsultationColorPalette.secondaryTeal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToEditTimeslot(timeslot, viewModel),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: DoctorConsultationColorPalette.primaryColor,
                      side: BorderSide(
                        color: DoctorConsultationColorPalette.primaryColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteDialog(context, timeslot.timeSlotID!, viewModel),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: DoctorConsultationColorPalette.errorRed,
                      side: BorderSide(
                        color: DoctorConsultationColorPalette.errorRed,
                      ),
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
      ),
    );
  }

  IconData _getDayIcon(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return Icons.calendar_view_day;
      case 'tuesday':
        return Icons.calendar_view_day;
      case 'wednesday':
        return Icons.calendar_view_day;
      case 'thursday':
        return Icons.calendar_view_day;
      case 'friday':
        return Icons.calendar_view_day;
      case 'saturday':
        return Icons.calendar_view_week;
      case 'sunday':
        return Icons.calendar_view_week;
      default:
        return Icons.calendar_today;
    }
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _navigateToCreateTimeslot,
      backgroundColor: DoctorConsultationColorPalette.primaryColor,
      foregroundColor: Colors.white,
      elevation: 8,
      child: const Icon(
        Icons.add,
        size: 28,
      ),
    );
  }

  void _navigateToCreateTimeslot() async {
    final viewModel = context.read<DoctorClinicTimeslotViewModel>();
    viewModel.clearSelection();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DoctorClinicCreateTimeslotPage(
          isEditing: false,
        ),
      ),
    );

    // Refresh the list if a timeslot was created
    if (result == true && mounted) {
      viewModel.loadTimeslots();
    }
  }

  void _navigateToEditTimeslot(timeslot, DoctorClinicTimeslotViewModel viewModel) async {
    viewModel.selectTimeslot(timeslot);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DoctorClinicCreateTimeslotPage(
          isEditing: true,
        ),
      ),
    );

    // Refresh the list if a timeslot was updated
    if (result == true && mounted) {
      viewModel.loadTimeslots();
    }
  }

  void _showDeleteDialog(BuildContext context, String timeSlotID, DoctorClinicTimeslotViewModel viewModel) {
    // Find the timeslot to show its slots
    final timeslot = viewModel.timeslots.firstWhere(
      (t) => t.timeSlotID == timeSlotID,
      orElse: () => DoctorClinicTimeslotModel(
        vendorId: '',
        day: '',
        startTime: '',
        endTime: '',
        intervalMinutes: 30,
        generatedSlots: [],
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return DeleteSlotsDialog(
          timeslot: timeslot,
          viewModel: viewModel,
          onDeleteEntireDay: () async {
            final success = await viewModel.deleteTimeslot(timeSlotID);
            if (success && mounted) {
              _showSuccessMessage(
                context,
                viewModel.successMessage ?? 'Timeslot deleted successfully!',
              );
            }
          },
        );
      },
    );
  }

  void _showViewSlotsDialog(BuildContext context, timeslot, DoctorClinicTimeslotViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            DoctorConsultationColorPalette.primaryColor,
                            DoctorConsultationColorPalette.secondaryTeal,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getDayIcon(timeslot.day),
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${timeslot.day} Time Slots',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${timeslot.startTime} - ${timeslot.endTime} (${timeslot.intervalMinutes}min intervals)',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Active/Inactive Toggle
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: DoctorConsultationColorPalette.backgroundPrimary,
                        border: Border(
                          bottom: BorderSide(
                            color: DoctorConsultationColorPalette.borderLight,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: DoctorConsultationColorPalette.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  timeslot.isActive
                                      ? 'This timeslot is active and visible to patients'
                                      : 'This timeslot is inactive and hidden from patients',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: DoctorConsultationColorPalette.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: timeslot.isActive,
                            onChanged: (value) async {
                              final success = await viewModel.toggleTimeslotStatus(
                                timeslot.timeSlotID!,
                                value,
                              );
                              if (success) {
                                setState(() {
                                  // Update the local state to reflect the change immediately
                                  timeslot.isActive = value;
                                });
                                _showSuccessMessage(
                                  context,
                                  'Timeslot ${value ? 'activated' : 'deactivated'} successfully!',
                                );
                              }
                            },
                            activeColor: DoctorConsultationColorPalette.primaryColor,
                            activeTrackColor: DoctorConsultationColorPalette.primaryColor.withOpacity(0.3),
                          ),
                        ],
                      ),
                    ),

                    // Slots List
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: DoctorConsultationColorPalette.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Available Slots (${timeslot.generatedSlots.length})',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: DoctorConsultationColorPalette.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (timeslot.generatedSlots.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        size: 48,
                                        color: DoctorConsultationColorPalette.textSecondary,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No slots available',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: DoctorConsultationColorPalette.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Flexible(
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 2.5,
                                  ),
                                  itemCount: timeslot.generatedSlots.length,
                                  itemBuilder: (context, index) {
                                    final slot = timeslot.generatedSlots[index];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: DoctorConsultationColorPalette.backgroundPrimary,
                                        border: Border.all(
                                          color: DoctorConsultationColorPalette.borderLight,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          slot,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: DoctorConsultationColorPalette.textPrimary,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Footer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: DoctorConsultationColorPalette.backgroundPrimary,
                        border: Border(
                          top: BorderSide(
                            color: DoctorConsultationColorPalette.borderLight,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Close',
                              style: TextStyle(
                                color: DoctorConsultationColorPalette.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class DeleteSlotsDialog extends StatefulWidget {
  final DoctorClinicTimeslotModel timeslot;
  final DoctorClinicTimeslotViewModel viewModel;
  final VoidCallback onDeleteEntireDay;

  const DeleteSlotsDialog({
    Key? key,
    required this.timeslot,
    required this.viewModel,
    required this.onDeleteEntireDay,
  }) : super(key: key);

  @override
  State<DeleteSlotsDialog> createState() => _DeleteSlotsDialogState();
}

class _DeleteSlotsDialogState extends State<DeleteSlotsDialog> {
  Set<String> selectedSlots = {};
  bool showSpecificSlots = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.95,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: DoctorConsultationColorPalette.shadowLight,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section - Simplified
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DoctorConsultationColorPalette.errorRed.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.delete_forever,
                    color: DoctorConsultationColorPalette.errorRed,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delete Time Slots',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: DoctorConsultationColorPalette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.timeslot.day}: ${widget.timeslot.startTime} - ${widget.timeslot.endTime}',
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
            ),

            // Content Section
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Warning message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: DoctorConsultationColorPalette.errorRed.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: DoctorConsultationColorPalette.errorRed.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: DoctorConsultationColorPalette.errorRed,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Choose what you want to delete. This action cannot be undone.',
                              style: TextStyle(
                                fontSize: 14,
                                color: DoctorConsultationColorPalette.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Deletion Options
                    Text(
                      'Deletion Options',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: DoctorConsultationColorPalette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Option 1: Delete Entire Day
                    InkWell(
                      onTap: () {
                        setState(() {
                          showSpecificSlots = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: showSpecificSlots
                              ? DoctorConsultationColorPalette.backgroundPrimary
                              : DoctorConsultationColorPalette.errorRed.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: showSpecificSlots
                                ? DoctorConsultationColorPalette.borderLight
                                : DoctorConsultationColorPalette.errorRed.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: showSpecificSlots
                                      ? DoctorConsultationColorPalette.textSecondary
                                      : DoctorConsultationColorPalette.errorRed,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Delete Entire Day',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: DoctorConsultationColorPalette.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                if (!showSpecificSlots)
                                  Icon(
                                    Icons.check_circle,
                                    color: DoctorConsultationColorPalette.errorRed,
                                    size: 20,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Remove all time slots for ${widget.timeslot.day} (${widget.timeslot.generatedSlots.length} slots)',
                              style: TextStyle(
                                fontSize: 14,
                                color: DoctorConsultationColorPalette.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Option 2: Delete Specific Slots
                    if (widget.timeslot.generatedSlots.isNotEmpty) ...[
                      InkWell(
                        onTap: () {
                          setState(() {
                            showSpecificSlots = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: showSpecificSlots
                                ? DoctorConsultationColorPalette.errorRed.withOpacity(0.05)
                                : DoctorConsultationColorPalette.backgroundPrimary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: showSpecificSlots
                                  ? DoctorConsultationColorPalette.errorRed.withOpacity(0.3)
                                  : DoctorConsultationColorPalette.borderLight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    color: showSpecificSlots
                                        ? DoctorConsultationColorPalette.errorRed
                                        : DoctorConsultationColorPalette.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Delete Specific Slots',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: DoctorConsultationColorPalette.textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (showSpecificSlots)
                                    Icon(
                                      Icons.check_circle,
                                      color: DoctorConsultationColorPalette.errorRed,
                                      size: 20,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Select individual time slots to delete',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: DoctorConsultationColorPalette.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (showSpecificSlots) ...[
                        const SizedBox(height: 16),

                        // Select All / Clear All buttons
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  selectedSlots = Set.from(widget.timeslot.generatedSlots);
                                });
                              },
                              icon: const Icon(Icons.select_all),
                              label: const Text('Select All'),
                              style: TextButton.styleFrom(
                                foregroundColor: DoctorConsultationColorPalette.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  selectedSlots.clear();
                                });
                              },
                              icon: const Icon(Icons.clear_all),
                              label: const Text('Clear All'),
                              style: TextButton.styleFrom(
                                foregroundColor: DoctorConsultationColorPalette.textSecondary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Slots as Chips
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: 200,
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.timeslot.generatedSlots.map((slot) {
                              final isSelected = selectedSlots.contains(slot);
                              return FilterChip(
                                label: Text(
                                  slot,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : DoctorConsultationColorPalette.textPrimary,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedSlots.add(slot);
                                    } else {
                                      selectedSlots.remove(slot);
                                    }
                                  });
                                },
                                backgroundColor: DoctorConsultationColorPalette.backgroundPrimary,
                                selectedColor: DoctorConsultationColorPalette.errorRed,
                                checkmarkColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: isSelected
                                        ? DoctorConsultationColorPalette.errorRed
                                        : DoctorConsultationColorPalette.borderLight,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              );
                            }).toList(),
                          ),
                        ),

                        if (selectedSlots.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: DoctorConsultationColorPalette.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${selectedSlots.length} slot(s) selected for deletion',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: DoctorConsultationColorPalette.primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ],

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: DoctorConsultationColorPalette.borderLight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: DoctorConsultationColorPalette.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Delete Button
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  DoctorConsultationColorPalette.errorRed,
                                  DoctorConsultationColorPalette.errorRed.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: DoctorConsultationColorPalette.errorRed.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (showSpecificSlots && selectedSlots.isNotEmpty) {
                                  // Delete specific slots
                                  final result = await widget.viewModel.deleteSpecificSlots(
                                    widget.timeslot.timeSlotID!,
                                    selectedSlots.toList(),
                                  );
                                  if (result != null && mounted) {
                                    Navigator.pop(context);
                                    // Show success message using the parent widget method
                                    final pageState = context.findAncestorStateOfType<_DoctorClinicTimeslotPageState>();
                                    pageState?._showSuccessMessage(
                                      context,
                                      widget.viewModel.successMessage ?? 'Selected slots deleted successfully!',
                                    );
                                  }
                                } else if (!showSpecificSlots) {
                                  // Delete entire day
                                  Navigator.pop(context);
                                  widget.onDeleteEntireDay();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                showSpecificSlots && selectedSlots.isNotEmpty
                                    ? 'Delete ${selectedSlots.length} Slots'
                                    : 'Delete Day',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Footer with close button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DoctorConsultationColorPalette.backgroundPrimary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: DoctorConsultationColorPalette.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
