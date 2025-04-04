import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/Registration/AmbulanceAgencyRegistrationDialog.dart';

class AmbulanceAgencyRegSubmitButton extends StatefulWidget {
  final String buttonText;
  final IconData buttonIcon;
  final Future<void> Function() onPressed; // Callback to trigger registration logic
  final GlobalKey<FormState> formKey;
  final AutovalidateMode autoValidateMode;
  final Function viewModelValidation;

  AmbulanceAgencyRegSubmitButton({
    required this.buttonText,
    required this.buttonIcon,
    required this.onPressed,
    required this.formKey,
    required this.autoValidateMode,
    required this.viewModelValidation,
  });

  @override
  _AmbulanceAgencyRegSubmitButtonState createState() =>
      _AmbulanceAgencyRegSubmitButtonState();
}

class _AmbulanceAgencyRegSubmitButtonState
    extends State<AmbulanceAgencyRegSubmitButton> {
  bool _isLoading = false; // Track the loading state

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () async {
        setState(() {
          _isLoading = true; // Set loading to true when the button is pressed
        });

        // Trigger validation when submitting
        if (widget.formKey.currentState?.validate() ?? false) {
          if (widget.viewModelValidation()) {
            try {
              await widget.onPressed(); // Perform the registration logic
              setState(() {
                _isLoading = false; // Reset loading state after operation
              });
              _showDialog(context, 'Registration Successful', true); // Show success dialog
            } catch (error) {
              setState(() {
                _isLoading = false; // Reset loading state after operation
              });
              _showDialog(context, error.toString(), false); // Show error dialog
            }
          } else {
            setState(() {
              _isLoading = false; // Reset loading state
            });
            _showDialog(context, 'Please fill all required fields', false); // Show validation error dialog
          }
        } else {
          setState(() {
            _isLoading = false; // Reset loading state
          });
          _showDialog(context, 'Please fix the errors', false); // Show form error dialog
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
            // Show CircularProgressIndicator and "Submitting" text when loading
              Row(
                children: [
                  CircularProgressIndicator(
                    color: Colors.teal,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Submitting...',
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else ...[
              // Regular button content when not loading
              Icon(widget.buttonIcon, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                widget.buttonText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
        shadowColor: Colors.teal.shade400,
      ),
    );
  }

  // Show the Registration Dialog
  void _showDialog(BuildContext context, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AmbulanceAgencyRegistrationDialog(
          message: message,
          isSuccess: isSuccess,
        );
      },
    );
  }
}
