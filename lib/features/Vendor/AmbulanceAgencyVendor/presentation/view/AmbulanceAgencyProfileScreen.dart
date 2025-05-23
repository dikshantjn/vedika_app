import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceAgencyProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/Profile/AgencyBasicInfoSection.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/Profile/AgencyDocumentsSection.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/Profile/AgencyServiceInfoSection.dart';

class AmbulanceAgencyProfileScreen extends StatefulWidget {
  final VoidCallback? onEditPressed;

  const AmbulanceAgencyProfileScreen({Key? key, this.onEditPressed}) : super(key: key);

  @override
  State<AmbulanceAgencyProfileScreen> createState() => _AmbulanceAgencyProfileScreenState();
}

class _AmbulanceAgencyProfileScreenState extends State<AmbulanceAgencyProfileScreen> {
  late AmbulanceAgencyProfileViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = AmbulanceAgencyProfileViewModel();
    viewModel.fetchAgencyProfile();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<AmbulanceAgencyProfileViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (vm.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    "❌ ${vm.error}",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.red[400],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (vm.agency == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "No profile data available.",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return Container(
            color: Colors.grey[50],
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section
                  Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16,
                      bottom: 24,
                      left: 24,
                      right: 24,
                    ),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Agency Profile",
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        if (widget.onEditPressed != null)
                          IconButton(
                            onPressed: widget.onEditPressed,
                            icon: Icon(
                              Icons.edit,
                              color: Colors.blue[700],
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Content Sections
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AgencyBasicInfoSection(viewModel: vm),
                        const SizedBox(height: 32),
                        AgencyServiceInfoSection(viewModel: vm),
                        const SizedBox(height: 32),
                        AgencyDocumentsSection(viewModel: vm),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
