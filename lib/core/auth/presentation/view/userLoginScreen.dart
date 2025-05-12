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
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity, // 👈 This makes it stretch to full height
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ColorPalette.primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.03,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: size.height * 0.05),
                    _buildLogo(),
                    SizedBox(height: size.height * 0.04),
                    _buildWelcomeText(),
                    SizedBox(height: size.height * 0.05),
                    
                    Consumer<UserLoginViewModel>(
                      builder: (context, signupViewModel, child) {
                        return AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: !signupViewModel.isOtpSent
                              ? _buildLoginForm(signupViewModel)
                              : VerifyOtpWidget(),
                        );
                      },
                    ),
                    
                    SizedBox(height: size.height * 0.03),
                    _buildDivider(),
                    SizedBox(height: size.height * 0.02),
                    _buildBottomActions(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            ColorPalette.primaryColor,
            ColorPalette.primaryColor.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        Icons.medical_services_rounded,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          "Welcome to Vedika Healthcare",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: ColorPalette.primaryColor,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12),
        Text(
          "Your trusted healthcare companion",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(UserLoginViewModel signupViewModel) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Login with Phone",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorPalette.primaryColor,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Enter your mobile number to continue",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 25),
            _buildPhoneNumberField(),
            SizedBox(height: 25),
            _buildLoginButton(signupViewModel),
            if (signupViewModel.errorMessage != null) ...[
              SizedBox(height: 15),
              Text(
                signupViewModel.errorMessage!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade200)),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(
                  "+91",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.primaryColor,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  color: ColorPalette.primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: "Enter mobile number",
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return "Please enter your phone number";
                if (value.length != 10) return "Enter a valid 10-digit phone number";
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(UserLoginViewModel signupViewModel) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            ColorPalette.primaryColor,
            ColorPalette.primaryColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primaryColor.withOpacity(0.25),
            blurRadius: 15,
            offset: Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: signupViewModel.isLoading
            ? null
            : () {
                if (_formKey.currentState!.validate()) {
                  signupViewModel.sendOtp("+91" + _phoneController.text);
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(vertical: 14),
        ),
        child: signupViewModel.isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                "Continue",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "or continue with",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.vendor),
          child: Text(
            "Login as Vendor",
            style: TextStyle(
              color: ColorPalette.primaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
