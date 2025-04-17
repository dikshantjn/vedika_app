import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/ViewModal/medical_store_registration_viewmodel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Widgets/LoadingIndicator.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Widgets/MedicalStoreAddressSection.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Widgets/MedicalStoreDetailsSection.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Widgets/MedicalStoreInfoSection.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Widgets/SuccessDialog.dart';

class MedicalStoreRegistrationScreen extends StatefulWidget {
  @override
  _MedicalStoreRegistrationScreenState createState() =>
      _MedicalStoreRegistrationScreenState();
}

class _MedicalStoreRegistrationScreenState extends State<MedicalStoreRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool isLoading = false;

  final List<String> _steps = ["Store Details", "Address", "Additional Info"];

  void _nextPage() {
    if (_formKey.currentState!.validate()) {
      setState(() => _currentPage++);
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    setState(() => _currentPage--);
    _pageController.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _registerMedicalStore(
      BuildContext context, MedicalStoreRegistrationViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      viewModel.generateStoreId();
      try {
        setState(() => isLoading = true);
        await viewModel.registerVendor(context);

        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => SuccessDialog(
              email: viewModel.email,
              password: viewModel.password,
              onLoginPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.vendor),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Registration Failed"),
              content: Text("An error occurred: $e"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
          );
        }
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  Widget _buildTimelineStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_steps.length, (index) {
              final isActive = index <= _currentPage;
              final isCompleted = index < _currentPage;
              final isFirst = index == 0;
              final isLast = index == _steps.length - 1;
              final shouldFillRight = index < _currentPage; // Fill right connector if this step is completed

              return Expanded(
                child: Column(
                  children: [
                    // Timeline line and indicator
                    Row(
                      children: [
                        // Left connector (for all except first)
                        if (!isFirst)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: isCompleted ? Colors.teal : Colors.grey[300],
                            ),
                          ),

                        // Circle indicator
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted ? Colors.teal : (isActive ? Colors.teal : Colors.grey[300]),
                            border: Border.all(
                              color: isActive ? Colors.teal : Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isCompleted
                                ? Icon(Icons.check, size: 18, color: Colors.white)
                                : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Right connector (for all except last)
                        if (!isLast)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: shouldFillRight ? Colors.teal : Colors.grey[300],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 8),
          // Step labels aligned correctly below each indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_steps.length, (index) {
              final isActive = index <= _currentPage;
              return Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    _steps[index],
                    style: TextStyle(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? Colors.teal : Colors.grey[600],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context); // Pop back to VendorRegistrationPage
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Medical Store Registration"),
          foregroundColor: Colors.teal,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context), // Ensure back button also pops
          ),
        ),
        body: SafeArea(
          child: Consumer<MedicalStoreRegistrationViewModel>(
            builder: (context, viewModel, child) {
              return isLoading
                  ? Center(child: LoadingIndicator())
                  : Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTimelineStepper(),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: NeverScrollableScrollPhysics(),
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
              );
            },
          ),
        ),
      ),
    );
  }

}