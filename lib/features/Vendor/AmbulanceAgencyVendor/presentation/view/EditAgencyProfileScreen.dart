import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/EditAgencyProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/updateProfile/BasicInfoSection.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/updateProfile/MediaLocationSection.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/updateProfile/OperationalInfoSection.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditAgencyProfileScreen extends StatefulWidget {
  const EditAgencyProfileScreen({super.key});

  @override
  State<EditAgencyProfileScreen> createState() => _EditAgencyProfileScreenState();
}

class _EditAgencyProfileScreenState extends State<EditAgencyProfileScreen> {
  late EditAgencyProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EditAgencyProfileViewModel();
    _viewModel.fetchAgencyProfileData(); // ViewModel handles notifyListeners
  }

  @override
  void dispose() {
    _viewModel.disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditAgencyProfileViewModel>.value(
      value: _viewModel,
      child: Consumer<EditAgencyProfileViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                key: viewModel.formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BasicInfoSection(viewModel: viewModel),
                      const SizedBox(height: 20),
                      OperationalInfoSection(viewModel: viewModel),
                      const SizedBox(height: 20),
                      MediaLocationSection(viewModel: viewModel),
                      const SizedBox(height: 30),
                      OutlinedButton(
                        onPressed: () async {
                          // Show loading indicator
                          viewModel.setLoading(true);
                          try {
                            // Make sure you await the updateAgencyProfile method
                             viewModel.updateAgencyProfile();  // Await the method here

                          } catch (e) {
                            Fluttertoast.showToast(
                              msg: "Failed to update agency profile: ${e.toString()}",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          } finally {
                            // Hide loading indicator
                            viewModel.setLoading(false);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          side: const BorderSide(color: Colors.black, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: Colors.black,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: viewModel.isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        )
                            : const Text("Save Changes"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
