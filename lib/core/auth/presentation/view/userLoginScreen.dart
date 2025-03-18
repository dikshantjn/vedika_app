import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/presentation/view/VerifyOtpWidget.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/userLoginViewModel.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';

class UserLoginScreen extends StatefulWidget {
  @override
  _userLoginScreenState createState() => _userLoginScreenState();
}

class _userLoginScreenState extends State<UserLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.whiteColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),
              SizedBox(height: 20),
              _buildAvatar(),
              SizedBox(height: 20),
              _buildWelcomeText(),
              SizedBox(height: 30),

              /// Consumer to rebuild only this part when state changes
              Consumer<UserLoginViewModel>(
                builder: (context, signupViewModel, child) {
                  return Column(
                    children: [
                      if (!signupViewModel.isOtpSent) ...[
                        _buildPhoneNumberField(),
                        SizedBox(height: 30),
                        if (signupViewModel.isLoading)
                          Center(child: CircularProgressIndicator(color: ColorPalette.primaryColor))
                        else
                          _buildSendOtpButton(signupViewModel),
                      ] else ...[
                        VerifyOtpWidget(),
                      ],
                      if (signupViewModel.errorMessage != null)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            signupViewModel.errorMessage!,
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  );
                },
              ),

              SizedBox(height: 20),
              _buildLoginRedirect(),

              // Go to Home button
              SizedBox(height: 20),
              _buildGoToHomeButton(),

              SizedBox(height: 20),
              _buildLoginAsVendorButton()
            ],
          ),
        ),
      ),
    );
  }

  // Avatar widget
  Widget _buildAvatar() {
    return Center(
      child: CircleAvatar(
        radius: 50,
        backgroundColor: ColorPalette.primaryColor.withOpacity(0.2),
        child: Icon(Icons.person, size: 50, color: ColorPalette.primaryColor),
      ),
    );
  }

  // Welcome text widget
  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          "Welcome!",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ColorPalette.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          "Create an account to get started",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Phone number field
  Widget _buildPhoneNumberField() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: ColorPalette.primaryColor.withOpacity(0.7)),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade200,
          ),
          child: Text(
            "+91",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ColorPalette.primaryColor),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: "Phone Number",
              prefixIcon: Icon(Icons.phone, color: ColorPalette.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ColorPalette.primaryColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ColorPalette.primaryColor.withOpacity(0.7)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ColorPalette.primaryColor),
              ),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) return "Please enter your phone number";
              if (value.length != 10) return "Enter a valid phone number";
              return null;
            },
          ),
        ),
      ],
    );
  }

  // Send OTP button
  Widget _buildSendOtpButton(UserLoginViewModel signupViewModel) {
    return SizedBox(
      width: double.infinity, // Make button take full width
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16), // Keep horizontal padding default
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: ColorPalette.primaryColor,
        ),
        onPressed: signupViewModel.isLoading
            ? null // Disable button when loading
            : () {
          if (_formKey.currentState!.validate()) {
            signupViewModel.sendOtp("+91" + _phoneController.text);
          }
        },
        child: signupViewModel.isLoading
            ? SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : Text(
          "Send OTP",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  // Login redirect widget
  Widget _buildLoginRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(color: Colors.grey.shade600),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            "Login",
            style: TextStyle(
              color: ColorPalette.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Go to Home button
  Widget _buildGoToHomeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: ColorPalette.primaryColor,
        ),
        onPressed: () {
          // Navigate to home screen (replace with actual HomeScreen widget)
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        },
        child: Text(
          "Go to Home",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  /// 🔹 **Login as Vendor Button**
  Widget _buildLoginAsVendorButton() {
    return TextButton(
      onPressed: () {
        // Navigate to Vendor Login Screen (replace with actual route)
        Navigator.pushReplacementNamed(context, AppRoutes.vendor);
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        foregroundColor: ColorPalette.primaryColor,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      child: const Text("Are You a Vendor?"),
    );
  }
}
