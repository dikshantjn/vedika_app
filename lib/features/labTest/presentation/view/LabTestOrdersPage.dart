import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

class LabTestOrdersPage extends StatefulWidget {
  const LabTestOrdersPage({Key? key}) : super(key: key);

  @override
  State<LabTestOrdersPage> createState() => _LabTestOrdersPageState();
}

class _LabTestOrdersPageState extends State<LabTestOrdersPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load orders data
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    // TODO: Implement loading lab test orders
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.backgroundColor,
      appBar: AppBar(
        backgroundColor: ColorPalette.primaryColor,
        elevation: 0,
        title: const Text(
          'Lab Test Orders',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: ColorPalette.primaryColor,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.science_outlined,
                      size: 80,
                      color: ColorPalette.primaryColor,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Lab Test Orders',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your lab test orders will appear here.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _loadOrders,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 