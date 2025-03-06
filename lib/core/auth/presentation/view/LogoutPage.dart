import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/AuthViewModel.dart';

class LogoutPage extends StatefulWidget {
  @override
  _LogoutPageState createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  final AuthViewModel authViewModel = AuthViewModel();

  @override
  void initState() {
    super.initState();
    _logout();
  }

  Future<void> _logout() async {
    await authViewModel.logout(context); // Perform logout
    Navigator.pushReplacementNamed(context, "/login"); // Redirect to login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()), // Show loader while logging out
    );
  }
}
