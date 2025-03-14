import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/HospitalRegistration/ViewModal/vendor_registration_view_model.dart';

class LoginWidget extends StatelessWidget {
  final VendorRegistrationViewModel viewModel;

  LoginWidget({required this.viewModel});

  @override
  Widget build(BuildContext context) {
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
                    offset: Offset(0, 4), // Shadow position
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => viewModel.login(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0, // Removing default elevation as the custom shadow is used
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
  }
}
