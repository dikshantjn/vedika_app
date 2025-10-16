import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter; 
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/presentation/view/VerifyOtpWidget.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/userLoginViewModel.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/home/presentation/view/HomePage.dart';

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
      body: Stack(
        children: [
          Container(
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
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        if (signupViewModel.infoMessage != null) ...[
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.green.withOpacity(0.25)),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    signupViewModel.infoMessage!,
                                                    style: TextStyle(color: Colors.green.shade700, fontSize: 13),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                        ],
                                        VerifyOtpWidget(),
                                      ],
                                    ),
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
          // Full-screen loading overlay while logging in and preparing home
          Consumer<UserLoginViewModel>(
            builder: (context, vm, _) {
              if (!vm.isVerifying) return SizedBox.shrink();
              return Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.88),
                                Colors.white.withOpacity(0.78),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ColorPalette.primaryColor.withOpacity(0.20),
                                blurRadius: 30,
                                spreadRadius: -8,
                                offset: Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 62,
                                width: 62,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      ColorPalette.primaryColor,
                                      ColorPalette.primaryColor.withOpacity(0.8),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ColorPalette.primaryColor.withOpacity(0.35),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Signing you in...",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: ColorPalette.primaryColor,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Preparing your home experience",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primaryColor.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          child: Image.asset(
            'assets/logo/Logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          "Welcome to Vedika Healthtech",
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
              "Enter your Contact number to continue",
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
                hintText: "Enter Contact number",
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return "Please enter your Contact number";
                if (value.length != 10) return "Enter a valid 10-digit Contact number";
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
    return Column(
      children: [
        // Go to Home Page button
        Container(
          width: double.infinity,
          height: 50,
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.green.shade600,
                Colors.green.shade500,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.25),
                blurRadius: 15,
                offset: Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "Go to Home Page",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Login as Vendor button
        Row(
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
        ),
      ],
    );
  }
}
