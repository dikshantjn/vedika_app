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
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Blood Banks"),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: viewModel.selectedCity,
                      dropdownColor: Theme.of(context).colorScheme.primary,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      items: viewModel.cities.map((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          viewModel.setSelectedCity(newValue);
                        }
                      },
                    ),
                  ),
                ],
              ),
              backgroundColor: ColorPalette.primaryColor,
              centerTitle: true,
              foregroundColor: Colors.white,
            ),
            drawer: DrawerMenu(),
            body: Stack(
              children: [
                if (viewModel.isLoadingLocation)
                  const Center(child: CircularProgressIndicator())
                else if (viewModel.currentPosition == null)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Location not available",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => viewModel.ensureLocationEnabled(),
                          child: Text("Retry"),
                        ),
                      ],
                    ),
                  )
                else
                  GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      viewModel.setMapController(controller);
                    },
                    initialCameraPosition: CameraPosition(
                      target: viewModel.currentPosition!,
                      zoom: 14,
                    ),
                    markers: viewModel.markers,
                    myLocationEnabled: true,
                    compassEnabled: true,
                    zoomControlsEnabled: true,
                    onTap: (_) {
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
