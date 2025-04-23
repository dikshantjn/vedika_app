import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/ViewModels/ClinicAppointmentHistoryViewModel.dart';

class ClinicAppointmentHistoryScreen extends StatefulWidget {
  const ClinicAppointmentHistoryScreen({Key? key}) : super(key: key);

  // Static factory method to create this screen with its provider
  static Widget withProvider() {
    return ChangeNotifierProvider<ClinicAppointmentHistoryViewModel>(
      create: (_) => ClinicAppointmentHistoryViewModel(),
      child: const ClinicAppointmentHistoryScreen(),
    );
  }

  @override
  State<ClinicAppointmentHistoryScreen> createState() => _ClinicAppointmentHistoryScreenState();
}

class _ClinicAppointmentHistoryScreenState extends State<ClinicAppointmentHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ClinicAppointmentHistoryViewModel>(context, listen: false);
      viewModel.initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorConsultationColorPalette.backgroundPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Consumer<ClinicAppointmentHistoryViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.fetchState == HistoryFetchState.loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: DoctorConsultationColorPalette.primaryBlue,
                      ),
                    );
                  }

                  if (viewModel.fetchState == HistoryFetchState.error) {
                    return _buildErrorView(context, viewModel);
                  }

                  if (viewModel.appointments.isEmpty) {
                    return _buildEmptyState(viewModel);
                  }

                  return _buildAppointmentsList(viewModel);
                },
              ),
            ),
            
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.filter_list, color: DoctorConsultationColorPalette.primaryBlue),
                  onPressed: () {
                    _showFilterBottomSheet(context);
                  },
                  tooltip: 'Filter appointments',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, ClinicAppointmentHistoryViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: DoctorConsultationColorPalette.errorRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading appointment history',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DoctorConsultationColorPalette.errorRed,
            ),
          ),
          const SizedBox(height: 8),
          Text(viewModel.errorMessage!),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => viewModel.refreshAppointments(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DoctorConsultationColorPalette.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ClinicAppointmentHistoryViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: DoctorConsultationColorPalette.backgroundCard,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history,
              size: 64,
              color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Completed Appointments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DoctorConsultationColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            viewModel.currentFilter != HistoryFilter.all || 
            viewModel.searchQuery.isNotEmpty || 
            viewModel.startDate != null
                ? 'Try changing your filters to see more results'
                : 'Completed appointments will appear here',
            style: TextStyle(
              fontSize: 16,
              color: DoctorConsultationColorPalette.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (viewModel.currentFilter != HistoryFilter.all || 
              viewModel.searchQuery.isNotEmpty || 
              viewModel.startDate != null)
            OutlinedButton.icon(
              onPressed: () {
                viewModel.resetFilters();
                _searchController.clear();
                setState(() {
                  _isSearchExpanded = false;
                });
              },
              icon: const Icon(Icons.filter_alt_off),
              label: const Text('Reset Filters'),
              style: OutlinedButton.styleFrom(
                foregroundColor: DoctorConsultationColorPalette.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final viewModel = Provider.of<ClinicAppointmentHistoryViewModel>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Appointments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: DoctorConsultationColorPalette.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Appointment Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DoctorConsultationColorPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildFilterChip(
                      label: 'All',
                      isSelected: viewModel.currentFilter == HistoryFilter.all,
                      onTap: () {
                        setState(() {
                          viewModel.setFilter(HistoryFilter.all);
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Online',
                      isSelected: viewModel.currentFilter == HistoryFilter.online,
                      onTap: () {
                        setState(() {
                          viewModel.setFilter(HistoryFilter.online);
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'In-person',
                      isSelected: viewModel.currentFilter == HistoryFilter.inPerson,
                      onTap: () {
                        setState(() {
                          viewModel.setFilter(HistoryFilter.inPerson);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Time Period',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DoctorConsultationColorPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildFilterChip(
                      label: 'Last Week',
                      isSelected: viewModel.currentFilter == HistoryFilter.lastWeek,
                      onTap: () {
                        setState(() {
                          viewModel.setFilter(HistoryFilter.lastWeek);
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Last Month',
                      isSelected: viewModel.currentFilter == HistoryFilter.lastMonth,
                      onTap: () {
                        setState(() {
                          viewModel.setFilter(HistoryFilter.lastMonth);
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Last Year',
                      isSelected: viewModel.currentFilter == HistoryFilter.lastYear,
                      onTap: () {
                        setState(() {
                          viewModel.setFilter(HistoryFilter.lastYear);
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Custom Date',
                      isSelected: viewModel.startDate != null && viewModel.endDate != null,
                      onTap: () async {
                        final DateTimeRange? dateRange = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDateRange: viewModel.startDate != null && viewModel.endDate != null
                              ? DateTimeRange(
                                  start: viewModel.startDate!,
                                  end: viewModel.endDate!,
                                )
                              : null,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: DoctorConsultationColorPalette.primaryBlue,
                                  onPrimary: Colors.white,
                                  onSurface: DoctorConsultationColorPalette.textPrimary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        
                        if (dateRange != null) {
                          setState(() {
                            viewModel.setDateRange(dateRange.start, dateRange.end);
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Sort By',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DoctorConsultationColorPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildFilterChip(
                      label: 'Newest',
                      isSelected: viewModel.sortOrder == HistorySortOrder.newest,
                      onTap: () {
                        setState(() {
                          viewModel.setSortOrder(HistorySortOrder.newest);
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Oldest',
                      isSelected: viewModel.sortOrder == HistorySortOrder.oldest,
                      onTap: () {
                        setState(() {
                          viewModel.setSortOrder(HistorySortOrder.oldest);
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Highest Paid',
                      isSelected: viewModel.sortOrder == HistorySortOrder.highestPaid,
                      onTap: () {
                        setState(() {
                          viewModel.setSortOrder(HistorySortOrder.highestPaid);
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Lowest Paid',
                      isSelected: viewModel.sortOrder == HistorySortOrder.lowestPaid,
                      onTap: () {
                        setState(() {
                          viewModel.setSortOrder(HistorySortOrder.lowestPaid);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          viewModel.resetFilters();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: DoctorConsultationColorPalette.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.check),
                        label: const Text('Apply'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? DoctorConsultationColorPalette.primaryBlue
              : DoctorConsultationColorPalette.backgroundCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? DoctorConsultationColorPalette.primaryBlue
                : DoctorConsultationColorPalette.borderMedium,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? Colors.white
                : DoctorConsultationColorPalette.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppointmentsList(ClinicAppointmentHistoryViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.refreshAppointments(),
      color: DoctorConsultationColorPalette.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: viewModel.appointments.length,
        itemBuilder: (context, index) {
          final appointment = viewModel.appointments[index];
          return _buildHistoryCard(context, appointment);
        },
      ),
    );
  }
  
  Widget _buildHistoryCard(BuildContext context, ClinicAppointment appointment) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final formattedDate = dateFormat.format(appointment.date);
    
    final timeFormat = DateFormat('h:mm a');
    final formattedTime = timeFormat.format(
      DateTime(
        2023, 1, 1,
        int.parse(appointment.time.split(':')[0]),
        int.parse(appointment.time.split(':')[1]),
      ),
    );
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DoctorConsultationColorPalette.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: DoctorConsultationColorPalette.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAppointmentDetails(context, appointment),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: DoctorConsultationColorPalette.borderLight,
                      backgroundImage: appointment.user?.photo != null
                          ? NetworkImage(appointment.user!.photo!)
                          : null,
                      child: appointment.user?.photo == null
                          ? Icon(
                              Icons.person,
                              size: 24,
                              color: appointment.isOnline
                                  ? DoctorConsultationColorPalette.primaryBlue
                                  : DoctorConsultationColorPalette.secondaryTeal,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.user?.name ?? 'Unknown Patient',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: DoctorConsultationColorPalette.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: appointment.isOnline
                                      ? DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1)
                                      : DoctorConsultationColorPalette.secondaryTeal.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      appointment.isOnline ? Icons.videocam : Icons.person,
                                      size: 12,
                                      color: appointment.isOnline
                                          ? DoctorConsultationColorPalette.primaryBlue
                                          : DoctorConsultationColorPalette.secondaryTeal,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      appointment.isOnline ? 'Online' : 'In-person',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: appointment.isOnline
                                            ? DoctorConsultationColorPalette.primaryBlue
                                            : DoctorConsultationColorPalette.secondaryTeal,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: DoctorConsultationColorPalette.successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '₹${appointment.paidAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: DoctorConsultationColorPalette.successGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DoctorConsultationColorPalette.backgroundCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildHistoryInfoItem(
                        icon: Icons.calendar_today,
                        label: 'Date',
                        value: formattedDate,
                      ),
                      const SizedBox(width: 24),
                      _buildHistoryInfoItem(
                        icon: Icons.access_time,
                        label: 'Time',
                        value: formattedTime,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      size: 14,
                      color: DoctorConsultationColorPalette.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tap for details',
                      style: TextStyle(
                        fontSize: 12,
                        color: DoctorConsultationColorPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHistoryInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: DoctorConsultationColorPalette.primaryBlue,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: DoctorConsultationColorPalette.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: DoctorConsultationColorPalette.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  void _showAppointmentDetails(BuildContext context, ClinicAppointment appointment) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final formattedDate = dateFormat.format(appointment.date);
    
    final timeFormat = DateFormat('h:mm a');
    final formattedTime = timeFormat.format(
      DateTime(
        2023, 1, 1,
        int.parse(appointment.time.split(':')[0]),
        int.parse(appointment.time.split(':')[1]),
      ),
    );
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: BoxDecoration(
                color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: DoctorConsultationColorPalette.borderLight,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.history_edu_rounded,
                        color: DoctorConsultationColorPalette.textPrimary,
                        size: 22,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Completed Appointment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: DoctorConsultationColorPalette.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: DoctorConsultationColorPalette.textSecondary),
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Patient info section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: DoctorConsultationColorPalette.borderLight,
                            backgroundImage: appointment.user?.photo != null
                                ? NetworkImage(appointment.user!.photo!)
                                : null,
                            child: appointment.user?.photo == null
                                ? Icon(
                                    Icons.person,
                                    size: 36,
                                    color: appointment.isOnline
                                        ? DoctorConsultationColorPalette.primaryBlue
                                        : DoctorConsultationColorPalette.secondaryTeal,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appointment.user?.name ?? 'Unknown Patient',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: DoctorConsultationColorPalette.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: appointment.isOnline
                                            ? DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1)
                                            : DoctorConsultationColorPalette.secondaryTeal.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            appointment.isOnline ? Icons.videocam : Icons.person,
                                            size: 14,
                                            color: appointment.isOnline
                                                ? DoctorConsultationColorPalette.primaryBlue
                                                : DoctorConsultationColorPalette.secondaryTeal,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            appointment.isOnline ? 'Online' : 'In-person',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: appointment.isOnline
                                                  ? DoctorConsultationColorPalette.primaryBlue
                                                  : DoctorConsultationColorPalette.secondaryTeal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone, 
                                      size: 16, 
                                      color: DoctorConsultationColorPalette.primaryBlue,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      appointment.user?.phoneNumber ?? 'No phone number',
                                      style: TextStyle(
                                        color: DoctorConsultationColorPalette.textSecondary,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                if (appointment.user?.emailId != null) ... [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.email, 
                                        size: 16, 
                                        color: DoctorConsultationColorPalette.primaryBlue,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        appointment.user!.emailId!,
                                        style: TextStyle(
                                          color: DoctorConsultationColorPalette.textSecondary,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Payment card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: DoctorConsultationColorPalette.successGreen.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: DoctorConsultationColorPalette.successGreen.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Payment Received',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: DoctorConsultationColorPalette.textPrimary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: DoctorConsultationColorPalette.successGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    appointment.paymentStatus.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: DoctorConsultationColorPalette.successGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.payments_outlined,
                                  size: 30,
                                  color: DoctorConsultationColorPalette.successGreen,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '₹${appointment.paidAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: DoctorConsultationColorPalette.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Info grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailCard(
                              icon: Icons.calendar_today,
                              title: 'Date',
                              value: formattedDate,
                              color: DoctorConsultationColorPalette.primaryBlueLight,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDetailCard(
                              icon: Icons.access_time_rounded,
                              title: 'Time',
                              value: formattedTime,
                              color: DoctorConsultationColorPalette.secondaryTeal,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildDetailCard(
                        icon: Icons.key,
                        title: 'Appointment ID',
                        value: appointment.clinicAppointmentId,
                        color: DoctorConsultationColorPalette.infoBlue,
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // Generate receipt or report
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Receipt generation coming soon'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.receipt_long),
                            label: const Text('Generate Receipt'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: DoctorConsultationColorPalette.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DoctorConsultationColorPalette.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: DoctorConsultationColorPalette.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: DoctorConsultationColorPalette.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 