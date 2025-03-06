import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/userLoginViewModel.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

class VerifyOtpWidget extends StatefulWidget {
  @override
  _VerifyOtpWidgetState createState() => _VerifyOtpWidgetState();
}

class _VerifyOtpWidgetState extends State<VerifyOtpWidget> {
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final signupViewModel = Provider.of<UserLoginViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Enter OTP",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ColorPalette.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          "We have sent a 6-digit OTP to your phone",
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "OTP",
            prefixIcon: Icon(Icons.lock_outline, color: ColorPalette.primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorPalette.primaryColor),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty || value.length != 6) {
              return "Enter a valid 6-digit OTP";
            }
            return null;
          },
        ),
        SizedBox(height: 20),
        signupViewModel.isLoading
            ? Center(child: CircularProgressIndicator(color: ColorPalette.primaryColor))
            : ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: ColorPalette.primaryColor,
          ),
          onPressed: () async {
            // Pass OTP directly to verifyOtp
            if (_otpController.text.length == 6) {
              await signupViewModel.verifyOtp(_otpController.text);
            } else {
              // Show some validation message if OTP is invalid
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please enter a valid 6-digit OTP")),
              );
            }
          },
          child: Text(
            "Verify OTP",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        SizedBox(height: 10),
        TextButton(
          onPressed: () {
            // Implement Resend OTP functionality
            signupViewModel.sendOtp(signupViewModel.phoneNumber);
          },
          child: Text(
            "Resend OTP",
            style: TextStyle(color: ColorPalette.primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
