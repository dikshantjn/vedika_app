import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/OrderActivity/presentation/view/TrackOrderScreen.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/MedicineOrderViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/ChooseFileWidget.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/EnableLocationWidget.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';

class MedicineOrderScreen extends StatefulWidget {
  @override
  _MedicineOrderScreenState createState() => _MedicineOrderScreenState();
}

class _MedicineOrderScreenState extends State<MedicineOrderScreen> {
  bool isLocationEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  // Function to check if the location service is enabled
  Future<void> _checkLocationStatus() async {
    bool locationStatus = await Provider.of<LocationProvider>(context, listen: false).isLocationServiceEnabled();
    setState(() {
      isLocationEnabled = locationStatus;
    });
  }

  // Callback when location is enabled
  void _onLocationEnabled() {
    setState(() {
      isLocationEnabled = true; // Update state to show ChooseFileWidget
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MedicineOrderViewModel(context),
      child: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: ColorPalette.primaryColor,
              foregroundColor: Colors.white,
              title: Text(
                "Order Medicine",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {
                    // Navigate to notifications screen
                  },
                ),
              ],
            ),
            drawer: DrawerMenu(),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorPalette.primaryColor.withOpacity(0.1),
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Consumer<MedicineOrderViewModel>(
                builder: (context, viewModel, child) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Check if location is enabled
                        Expanded(
                          child: Center(
                            child: isLocationEnabled
                                ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ChooseFileWidget(
                                  pickPrescription: viewModel.pickPrescription,
                                ),
                                SizedBox(height: 20),
                                // Track Order Button
                                OutlinedButton(
                                  onPressed: () {
                                    // Navigate to the TrackOrderScreen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TrackOrderScreen(orderId: 123), // Pass the actual orderId here
                                      ),
                                    );
                                  },
                                  child: Text("Track Order"),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: ColorPalette.primaryColor,
                                    foregroundColor: Colors.white,
                                    side: BorderSide(color: ColorPalette.primaryColor),
                                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ],
                            )
                                : EnableLocationWidget(
                              enableLocation: viewModel.enableLocation,
                              onLocationEnabled: _onLocationEnabled, // Pass the callback
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
