import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/AuthViewModel.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

class VerifyOtpWidget extends StatefulWidget {
  @override
  _VerifyOtpWidgetState createState() => _VerifyOtpWidgetState();
}

class _VerifyOtpWidgetState extends State<VerifyOtpWidget> with CodeAutoFill {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    // Auto-focus the first box after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes.first.requestFocus();
      }
    });
    listenForCode();
  }

  @override
  void dispose() {
    cancel(); // stop listening for code
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  void codeUpdated() {
    final receivedCode = code ?? '';
    if (receivedCode.isEmpty) return;
    final digits = receivedCode.replaceAll(RegExp(r'\D'), '');
    for (int i = 0; i < 6; i++) {
      _controllers[i].text = i < digits.length ? digits[i] : '';
    }
    setState(() {});
    if (digits.length == 6 && mounted) {
      final vm = Provider.of<AuthViewModel>(context, listen: false);
      vm.verifyOtp(digits, context);
    }
  }

  String _currentOtp() => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    // Handle paste of multiple digits
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      int writeIndex = index;
      for (int i = 0; i < digits.length && writeIndex < 6; i++, writeIndex++) {
        _controllers[writeIndex].text = digits[i];
      }
      final nextIndex = (index + digits.length - 1).clamp(0, 5);
      _focusNodes[nextIndex].requestFocus();
      setState(() {});
      return;
    }

    // Navigate back when cleared
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      setState(() {});
      return;
    }

    // Move forward on single digit
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.96),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primaryColor.withOpacity(0.08),
            blurRadius: 14,
            offset: Offset(0, 8),
            spreadRadius: -6,
          ),
        ],
        border: Border.all(
          color: _controllers[index].text.isNotEmpty
              ? ColorPalette.primaryColor.withOpacity(0.6)
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Center(
        child: Focus(
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
              if (_controllers[index].text.isNotEmpty) {
                _controllers[index].clear();
                setState(() {});
                return KeyEventResult.handled;
              }
              if (index > 0) {
                _controllers[index - 1].text = '';
                _focusNodes[index - 1].requestFocus();
                setState(() {});
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            autofocus: index == 0,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            keyboardType: TextInputType.number,
            textInputAction: index < 5 ? TextInputAction.next : TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
            ),
            onTap: () {
              // Select text for quick overwrite when tapping a box
              _controllers[index].selection = TextSelection(baseOffset: 0, extentOffset: _controllers[index].text.length);
            },
            onChanged: (v) => _onDigitChanged(index, v),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signupViewModel = Provider.of<AuthViewModel>(context);

    final String otp = _currentOtp();
    final bool isComplete = otp.length == 6 && !otp.contains('');

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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => _buildOtpBox(i)),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: ColorPalette.primaryColor,
          ),
          onPressed: signupViewModel.isVerifying
              ? null
              : () async {
                  final value = _currentOtp();
                  if (value.length == 6) {
                    await signupViewModel.verifyOtp(value, context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter a valid 6-digit OTP")),
                    );
                  }
                },
          child: signupViewModel.isVerifying
              ? SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
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
        if (signupViewModel.errorMessage != null) ...[
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    signupViewModel.errorMessage!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
