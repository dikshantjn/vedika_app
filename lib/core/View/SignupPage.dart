import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/ViewModel/SignupViewModel.dart';

class SignupPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final signupViewModel = Provider.of<SignupViewModel>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.blue.shade300],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          prefixIcon: Icon(Icons.person, color: Colors.blue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value!.isEmpty ? "Enter your name" : null,
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          prefixIcon: Icon(Icons.phone, color: Colors.blue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.length == 10 ? null : "Enter a valid phone number",
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: Icon(Icons.lock, color: Colors.blue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        obscureText: true,
                        validator: (value) => value!.length >= 6 ? null : "Password must be 6+ chars",
                      ),
                      SizedBox(height: 20),
                      signupViewModel.isLoading
                          ? Center(child: CircularProgressIndicator())
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.blue.shade800,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              signupViewModel.signUp(
                                name: _nameController.text,
                                phone: _phoneController.text,
                                password: _passwordController.text,
                              );
                            }
                          },
                          child: Text("Sign Up", style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                      if (signupViewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            signupViewModel.errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Go back to login
                        },
                        child: Text("Already have an account? Login",
                            style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
