import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/viewmodel/BloodBankViewModel.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/widgets/BloodBankDetailsBottomSheet.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankAgency.dart';

class BloodBankMapScreen extends StatefulWidget {
  @override
  _BloodBankMapScreenState createState() => _BloodBankMapScreenState();
}

class _BloodBankMapScreenState extends State<BloodBankMapScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BloodBankViewModel(context)..ensureLocationEnabled(),
      child: Consumer<BloodBankViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              backgroundColor: ColorPalette.primaryColor,
              title: const Text(
                "Blood Banks",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.bloodtype),
                  onPressed: () => viewModel.showBloodTypeDialog(),
                ),
                IconButton(
                  icon: const Icon(Icons.location_city),
                  onPressed: () => viewModel.toggleSidePanel(),
                ),
              ],
            ),
            drawer: DrawerMenu(),
            body: Stack(
              children: [
                // Google Map
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
                      _mapController = controller;
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
                    mapToolbarEnabled: false,
                    myLocationButtonEnabled: false,
                    onTap: (_) {
                      if (viewModel.isSidePanelOpen) {
                        viewModel.toggleSidePanel();
                      }
                    },
                  ),

                // Side Panel
                if (viewModel.isSidePanelOpen)
                  _buildSidePanel(viewModel),

                // Bottom Sheet
                if (viewModel.isMapReady)
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

  Widget _buildSidePanel(BloodBankViewModel viewModel) {
    return Positioned(
      top: 0,
      right: 0,
      bottom: 0,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    "Select City",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.black87),
                    onPressed: () => viewModel.toggleSidePanel(),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
            // My Location Option
            _buildLocationOption(
              icon: Icons.my_location,
              title: "My Location",
              subtitle: "Use current location",
              onTap: () {
                viewModel.ensureLocationEnabled();
                viewModel.toggleSidePanel();
              },
            ),
            Divider(height: 1),
            // Cities List
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "Popular Cities",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  ...viewModel.cities.map((city) {
                    final isSelected = viewModel.selectedCity == city;
                    return _buildCityOption(
                      city: city,
                      isSelected: isSelected,
                      onTap: () {
                        viewModel.setSelectedCity(city);
                        viewModel.toggleSidePanel();
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColorPalette.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: ColorPalette.primaryColor,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityOption({
    required String city,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? ColorPalette.primaryColor.withOpacity(0.1) : null,
        child: Row(
          children: [
            Expanded(
              child: Text(
                city,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? ColorPalette.primaryColor : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: ColorPalette.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
