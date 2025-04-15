import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/viewmodel/BloodBankViewModel.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/widgets/BloodBankDetailsBottomSheet.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankAgency.dart';

class BloodBankMapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BloodBankViewModel(context)..ensureLocationEnabled(),
      child: Consumer<BloodBankViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Blood Banks Nearby"),
              backgroundColor: ColorPalette.primaryColor,
              centerTitle: true,
              foregroundColor: Colors.white,
            ),
            drawer: DrawerMenu(),
            body: Stack(
              children: [
                viewModel.isLoadingLocation
                    ? Center(child: CircularProgressIndicator())
                    : GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    Provider.of<BloodBankViewModel>(context, listen: false).setMapController(controller);
                  },
                  initialCameraPosition: CameraPosition(
                    target: viewModel.currentPosition,
                    zoom: 14,
                  ),
                  markers: viewModel.markers,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  zoomControlsEnabled: true,
                  onTap: (_) {
                    // Close any open bottom sheet when tapping on the map
                    Navigator.pop(context);
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 2),
                      ],
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Are you a blood donor?",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Help save lives by registering as a donor today!",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.donorRegistration);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPalette.bloodBankColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("Register as a Donor", style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
