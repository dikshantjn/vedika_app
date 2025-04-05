import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        return const Center(child: CircularProgressIndicator());
      }

      if (vm.error != null) {
        return Center(child: Text("❌ ${vm.error}"));
      }

      if (vm.agency == null) {
        return const Center(child: Text("No profile data available."));
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            AgencyBasicInfoSection(viewModel: vm),
        const Divider(height: 30, thickness: 2),
        AgencyServiceInfoSection(viewModel: vm),
        const Divider(height: 30, thickness: 2),
        AgencyDocumentsSection(viewModel: vm),
        const SizedBox(height: 20),
        Center(
        child: OutlinedButton.icon(
        onPressed: widget.onEditPressed, // 🔥 Trigger from parent (like AmbulanceAgencyMainScreen)
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.blue, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          foregroundColor: Colors.blue,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        icon: const Icon(Icons.edit, size: 20, color: Colors.black),
        label: const Text("Edit Profile"),
      ),
        ),
          ],
          ),
          );
        },
        ),
    );
  }
}
