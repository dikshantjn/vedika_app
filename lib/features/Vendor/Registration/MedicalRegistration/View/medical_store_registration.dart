import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/ViewModal/medical_store_registration_viewmodel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Widgets/MedicalStoreAddressSection.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Widgets/MedicalStoreDetailsSection.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Widgets/MedicalStoreInfoSection.dart';

class MedicalStoreRegistrationForm extends StatefulWidget {
  @override
  _MedicalStoreRegistrationFormState createState() => _MedicalStoreRegistrationFormState();
}

class _MedicalStoreRegistrationFormState extends State<MedicalStoreRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// **Move to Next Page**
  void _nextPage() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _currentPage++;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// **Move to Previous Page**
  void _previousPage() {
    setState(() {
      _currentPage--;
    });
    _pageController.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// **Handle Registration**
  void _registerMedicalStore(BuildContext context, MedicalStoreRegistrationViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      // Generate Medical Store ID
      viewModel.generateStoreId();

      // Show loading indicator or a Snackbar message before making the request
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Submitting your request..."),
          backgroundColor: Colors.blue,
        ),
      );

      try {
        // Call the registerVendor method in the service class
        await viewModel.registerVendor(); // Assuming this is an async function from the ViewModel

        // If registration is successful, show a success message with the generated ID
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Vendor registered successfully! ID: ${viewModel.generatedStoreId}"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Handle any errors that occurred during registration
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to register vendor: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicalStoreRegistrationViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: NeverScrollableScrollPhysics(), // Prevent swiping manually
                        children: [
                          MedicalStoreDetailsSection(
                            viewModel: viewModel,
                            onNext: _nextPage,
                          ),
                          MedicalStoreAddressSection(
                            viewModel: viewModel,
                            onPrevious: _previousPage,
                            onNext: _nextPage,
                          ),
                          MedicalStoreInfoSection(
                            viewModel: viewModel,
                            onPrevious: _previousPage,
                            onRegister: () => _registerMedicalStore(context, viewModel),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
