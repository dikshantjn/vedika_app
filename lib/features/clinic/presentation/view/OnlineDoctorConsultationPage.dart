import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';
import 'package:vedika_healthcare/features/clinic/presentation/viewmodel/OnlineDoctorConsultationViewModel.dart';

class OnlineDoctorConsultationPage extends StatefulWidget {
  const OnlineDoctorConsultationPage({Key? key}) : super(key: key);

  @override
  State<OnlineDoctorConsultationPage> createState() => _OnlineDoctorConsultationPageState();
}

class _OnlineDoctorConsultationPageState extends State<OnlineDoctorConsultationPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSpecialization = 'All';
  
  // Sample list of specializations
  final List<String> specializations = [
    'All',
    'General Medicine',
    'Cardiology',
    'Dermatology',
    'Pediatrics',
    'Orthopedics',
    'Gynecology',
    'Neurology',
    'Ophthalmology',
    'Psychiatry',
  ];


  
  List<DoctorClinicProfile> get filteredDoctors {
    // This is now obsolete since we're using the view model
    // Return empty list as fallback
    return [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        // Create the view model and initialize it with our dummy data
        final viewModel = OnlineDoctorConsultationViewModel();
        // We'll let the ViewModel fetch its own data from our dummy data setup
        return viewModel;
      },
      child: Scaffold(
        backgroundColor: DoctorConsultationColorPalette.backgroundPrimary,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildSpecializationFilter(),
              const SizedBox(height: 16),
              Expanded(
                child: _buildDoctorsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: ColorPalette.primaryColor),
            onPressed: () {
              final scope = MainScreenScope.maybeOf(context);
              if (scope != null) {
                scope.setIndex(0);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(width: 8),
          const Text(
            'Online Doctor Consultation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DoctorConsultationColorPalette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Consumer<OnlineDoctorConsultationViewModel>(
      builder: (context, viewModel, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: DoctorConsultationColorPalette.borderMedium,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: DoctorConsultationColorPalette.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  color: DoctorConsultationColorPalette.primaryBlue,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: viewModel.searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search doctors, specialties...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: DoctorConsultationColorPalette.textHint,
                        fontSize: 15,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                if (viewModel.searchController.text.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: DoctorConsultationColorPalette.backgroundCard,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.clear),
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      onPressed: () {
                        viewModel.searchController.clear();
                      },
                      color: DoctorConsultationColorPalette.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpecializationFilter() {
    return Consumer<OnlineDoctorConsultationViewModel>(
      builder: (context, viewModel, _) {
        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: specializations.length,
            itemBuilder: (context, index) {
              final specialization = specializations[index];
              final isSelected = specialization == _selectedSpecialization;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(specialization),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSpecialization = specialization;
                    });
                  },
                  backgroundColor: Colors.grey[100],
                  selectedColor: DoctorConsultationColorPalette.secondaryTeal.withOpacity(0.2),
                  checkmarkColor: DoctorConsultationColorPalette.secondaryTeal,
                  labelStyle: TextStyle(
                    color: isSelected 
                        ? DoctorConsultationColorPalette.secondaryTeal
                        : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDoctorsList() {
    return Consumer<OnlineDoctorConsultationViewModel>(
      builder: (context, viewModel, _) {
        // Show loading state if the view model is loading
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: DoctorConsultationColorPalette.primaryBlue,
            ),
          );
        }

        // Show error state if there's an error in the view model
        if (viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: DoctorConsultationColorPalette.errorRed,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading doctors',
                  style: TextStyle(
                    color: DoctorConsultationColorPalette.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(viewModel.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.fetchDoctors(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Use our filtered doctors list if view model's doctors list is empty
        List<DoctorClinicProfile> doctorsToShow = viewModel.doctors.isEmpty ? filteredDoctors : viewModel.doctors;

        // Show empty state if no doctors match the criteria
        if (doctorsToShow.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: DoctorConsultationColorPalette.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No doctors found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: DoctorConsultationColorPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Try changing your search criteria',
                  style: TextStyle(
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedSpecialization = 'All';
                      _searchController.clear();
                    });
                    viewModel.clearFilters();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Clear Filters'),
                ),
              ],
            ),
          );
        }

        // Show the list of doctors
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip(
                    context: context,
                    label: 'Filter',
                    icon: Icons.filter_list,
                    onTap: () => _showFilterBottomSheet(context),
                  ),
                  const SizedBox(width: 12),
                  _buildFilterChip(
                    context: context,
                    label: 'Sort: ${viewModel.sortBy}',
                    icon: Icons.sort,
                    onTap: () => _showSortBottomSheet(context),
                  ),
                  if (viewModel.selectedSpecializations.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ...viewModel.selectedSpecializations.map(
                              (specialization) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Chip(
                                  label: Text(
                                    specialization,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                                  deleteIcon: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  onDeleted: () => viewModel.toggleSpecialization(specialization),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => viewModel.clearFilters(),
                              child: const Text(
                                'Clear All',
                                style: TextStyle(
                                  color: DoctorConsultationColorPalette.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: doctorsToShow.length,
                itemBuilder: (context, index) {
                  return _buildDoctorCard(context, doctorsToShow[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDoctorCard(BuildContext context, DoctorClinicProfile doctor) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.onlineDoctorDetail,
          arguments: doctor,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: DoctorConsultationColorPalette.borderLight,
            width: 1.5,
          ),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'doctor-${doctor.vendorId}',
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: DoctorConsultationColorPalette.backgroundCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: DoctorConsultationColorPalette.borderLight,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: DoctorConsultationColorPalette.shadowLight.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        image: doctor.profilePicture.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(doctor.profilePicture),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: doctor.profilePicture.isEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                color: DoctorConsultationColorPalette.secondaryTealLight,
                                alignment: Alignment.center,
                                child: Text(
                                  doctor.doctorName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    color: DoctorConsultationColorPalette.primaryBlue,
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                doctor.doctorName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: DoctorConsultationColorPalette.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: doctor.consultationTypes.contains('Online')
                                    ? DoctorConsultationColorPalette.successGreen.withOpacity(0.15)
                                    : DoctorConsultationColorPalette.warningYellow.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                doctor.consultationTypes.contains('Online') ? 'Online' : 'Offline',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: doctor.consultationTypes.contains('Online')
                                      ? DoctorConsultationColorPalette.successGreen
                                      : DoctorConsultationColorPalette.warningYellow,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          doctor.specializations.join(' • '),
                          style: const TextStyle(
                            fontSize: 14,
                            color: DoctorConsultationColorPalette.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildInfoChip(
                              icon: Icons.star,
                              iconColor: Colors.amber,
                              text: '4.8 (120)',
                            ),
                            const SizedBox(width: 10),
                            _buildInfoChip(
                              icon: Icons.work_outline,
                              iconColor: DoctorConsultationColorPalette.primaryBlue,
                              text: '${doctor.experienceYears} years',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: DoctorConsultationColorPalette.backgroundCard,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Consultation Fee',
                        style: TextStyle(
                          fontSize: 12,
                          color: DoctorConsultationColorPalette.textSecondary,
                        ),
                      ),
                      Text(
                        '₹${doctor.consultationFeesRange}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: DoctorConsultationColorPalette.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.onlineDoctorDetail,
                        arguments: doctor,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("Book Now"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: DoctorConsultationColorPalette.backgroundCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: DoctorConsultationColorPalette.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: DoctorConsultationColorPalette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer<OnlineDoctorConsultationViewModel>(
        builder: (context, viewModel, _) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
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
                      'Filter Doctors',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: DoctorConsultationColorPalette.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: DoctorConsultationColorPalette.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Specialization',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DoctorConsultationColorPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: viewModel.availableSpecializations.map((specialization) {
                        final isSelected = viewModel.selectedSpecializations.contains(specialization);
                        return GestureDetector(
                          onTap: () => viewModel.toggleSpecialization(specialization),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? DoctorConsultationColorPalette.primaryBlue
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? DoctorConsultationColorPalette.primaryBlue
                                    : DoctorConsultationColorPalette.borderMedium,
                              ),
                            ),
                            child: Text(
                              specialization,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : DoctorConsultationColorPalette.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          viewModel.clearFilters();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(
                            color: DoctorConsultationColorPalette.primaryBlue,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Clear All'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Apply'),
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

  void _showSortBottomSheet(BuildContext context) {
    final sortOptions = [
      'Experience',
      'Fee: Low to High',
      'Fee: High to Low',
      'Name A-Z',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<OnlineDoctorConsultationViewModel>(
        builder: (context, viewModel, _) {
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
                      'Sort By',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: DoctorConsultationColorPalette.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: DoctorConsultationColorPalette.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...sortOptions.map((option) => RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: viewModel.sortBy,
                      activeColor: DoctorConsultationColorPalette.primaryBlue,
                      onChanged: (value) {
                        if (value != null) {
                          viewModel.setSortOption(value);
                          Navigator.pop(context);
                        }
                      },
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: DoctorConsultationColorPalette.borderMedium,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: DoctorConsultationColorPalette.primaryBlue,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: DoctorConsultationColorPalette.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 