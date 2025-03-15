import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  // Make sure to import provider package
import 'package:vedika_healthcare/features/Vendor/Registration/ViewModels/VendorLoginViewModel.dart';

class LoginWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<VendorLoginViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            Text(
              "Login as a Vendor",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Please enter your credentials to log in and access the vendor dashboard.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 25),

            // Role Dropdown with custom design
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
                  value: viewModel.selectedRole,  // Ensure this value is correctly passed to the dropdown
                  hint: Text(
                    "Select Role",
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                  items: <String>[
                    "Hospital",
                    "Clinic",
                    "Medical Store",
                    "Ambulance Agency",
                    "Blood Bank",
                    "Pathology/Diagnostic Center",
                    "Delivery Partner"
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          Icon(Icons.business, color: Colors.teal),
                          SizedBox(width: 10),
                          Text(
                            value,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      viewModel.updateRole(newValue);  // Update the selected role
                    }
                  },
                  icon: Icon(Icons.arrow_drop_down_circle, color: Colors.teal),
                  dropdownColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 15),
            // Login Fields (Email and Password)
            Column(
              children: [
                // Email Field
                TextField(
                  controller: viewModel.emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // Password Field
                TextField(
                  controller: viewModel.passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // Login Button
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade700, Colors.teal.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (viewModel.emailController.text.isNotEmpty &&
                          viewModel.passwordController.text.isNotEmpty &&
                          viewModel.selectedRole != null) {

                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,  // Prevent dismissal while loading
                          builder: (_) => Center(child: CircularProgressIndicator()),
                        );

                        // Call the login method
                        await viewModel.login(context);  // Simply call the method

                        // Dismiss the loading indicator
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please fill in all fields"))
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),

            // Forgot Password Button
            TextButton(
              onPressed: () {
                // Handle forgot password action
              },
              child: Text(
                "Forgot Password?",
                style: TextStyle(color: Colors.teal),
              ),
            ),
          ],
        );
      },
    );
  }
}
