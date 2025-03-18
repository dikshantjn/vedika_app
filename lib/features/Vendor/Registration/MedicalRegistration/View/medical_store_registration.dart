import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/ViewModal/medical_store_registration_viewmodel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Widgets/LoadingIndicator.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Widgets/MedicalStoreAddressSection.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Widgets/MedicalStoreDetailsSection.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Widgets/MedicalStoreInfoSection.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Widgets/SuccessDialog.dart';

class MedicalStoreRegistrationForm extends StatefulWidget {
  @override
  _MedicalStoreRegistrationFormState createState() =>
      _MedicalStoreRegistrationFormState();
}

class _MedicalStoreRegistrationFormState
    extends State<MedicalStoreRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool isLoading = false;

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
  Future<void> _registerMedicalStore(
      BuildContext context, MedicalStoreRegistrationViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      // Generate Medical Store ID
      viewModel.generateStoreId();

      try {
        setState(() {
          isLoading = true; // Show loading indicator
        });

        // Call the registerVendor method in the service class
        await viewModel.registerVendor(context);

        // Show a success dialog after registration is successful
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SuccessDialog(
              onLoginPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.vendor);
              },
            );
          },
        );
      } catch (e) {
        // Handle any errors that occurred during registration
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to register vendor: $e"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicalStoreRegistrationViewModel>(
      builder: (context, viewModel, child) {
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Stack(
                children: [
                  // PageView that contains different sections
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

                  // Loading Indicator at the center with a fade background
                  if (isLoading)
                    Center(
                      child: Container(
                        color: Colors.black54, // Semi-transparent overlay background
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
