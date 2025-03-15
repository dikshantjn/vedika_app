import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/ViewModels/VendorLoginViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/ViewModels/vendor_registration_view_model.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/HospitalRegistration/Widgets/login_widget.dart';

class VendorRegistrationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VendorRegistrationViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Consumer<VendorRegistrationViewModel>(
                  builder: (context, viewModel, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Back Button
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),

                        // Display Login or Registration
                        if (viewModel.selectedVendorType == null) ...[
                          // Wrap the LoginWidget with the VendorLoginViewModel
                          ChangeNotifierProvider(
                            create: (_) => VendorLoginViewModel(),
                            child: LoginWidget(
                            ),
                          ),
                          SizedBox(height: 25),
                          Divider(color: Colors.grey[400], thickness: 1.5),
                          SizedBox(height: 25),
                        ],

                        // Registration Section
                        Text(
                          "Vendor Registration",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Select the vendor type and fill in the registration form.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 25),

                        // Vendor Type Dropdown
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: viewModel.selectedVendorType,
                              hint: Text(
                                "Choose Vendor Type",
                                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                              ),
                              items: viewModel.vendorForms.keys.map((String vendor) {
                                return DropdownMenuItem<String>(
                                  value: vendor,
                                  child: Row(
                                    children: [
                                      Icon(Icons.business, color: Colors.teal),
                                      SizedBox(width: 10),
                                      Text(vendor, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                viewModel.setSelectedVendorType(value);
                              },
                              icon: Icon(Icons.arrow_drop_down_circle, color: Colors.teal),
                              dropdownColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 25),

                        // Display Selected Vendor's Registration Form
                        if (viewModel.selectedVendorType != null)
                          viewModel.vendorForms[viewModel.selectedVendorType!]!,
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
