import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/HospitalRegistration/ViewModal/hospital_registration_viewmodel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/HospitalRegistration/Widgets/hospital_address_section.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/HospitalRegistration/Widgets/hospital_details_section.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/HospitalRegistration/Widgets/hospital_documents_section.dart';

class HospitalRegistrationForm extends StatefulWidget {
  @override
  _HospitalRegistrationFormState createState() => _HospitalRegistrationFormState();
}

class _HospitalRegistrationFormState extends State<HospitalRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 2) {
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

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HospitalRegistrationViewModel>(context);

    return Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView( // Make the content scrollable
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(), // Prevent swiping manually
                    children: [
                      HospitalDetailsSection(viewModel: viewModel, onNext: _nextPage),
                      HospitalAddressSection(viewModel: viewModel, onNext: _nextPage, onPrevious: _previousPage),
                      HospitalDocumentsSection(viewModel: viewModel, onPrevious: _previousPage, onRegister: () {
                        if (_formKey.currentState!.validate()) {
                          viewModel.generateHospitalId();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Hospital Registered Successfully! ID: ${viewModel.generatedHospitalId}")),
                          );
                        }
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
