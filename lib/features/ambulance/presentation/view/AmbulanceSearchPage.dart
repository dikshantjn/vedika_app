import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/viewmodel/AmbulanceSearchViewModel.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';

class AmbulanceSearchPage extends StatefulWidget {
  @override
  _AmbulanceSearchPageState createState() => _AmbulanceSearchPageState();
}

class _AmbulanceSearchPageState extends State<AmbulanceSearchPage>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
    AnimationController(vsync: this, duration: Duration(seconds: 1))
      ..repeat(reverse: true); // Blinking effect for button
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AmbulanceSearchViewModel(context)..initialize(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Nearby Ambulance Services"),
          backgroundColor: ColorPalette.primaryColor,
          centerTitle: true,
          foregroundColor: Colors.white,
        ),
        drawer: DrawerMenu(),
        body: Consumer<AmbulanceSearchViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                Expanded(
                  flex: 4,
                  child: GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                      viewModel.mapController = controller; // Assign controller to ViewModel
                      viewModel.getUserLocation();
                    },
                    initialCameraPosition: CameraPosition(
                      target: viewModel.currentPosition ?? LatLng(20.5937, 78.9629),
                      zoom: 14,
                    ),
                    markers: viewModel.markers,
                    myLocationEnabled: viewModel.isLocationEnabled,
                    compassEnabled: true,
                    zoomControlsEnabled: true,
                  ),
                ),
                _buildBottomSection(viewModel),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomSection(AmbulanceSearchViewModel viewModel) {
    return Container(
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
            "Need an Ambulance Urgently?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Call an ambulance now for immediate assistance.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          SizedBox(height: 12),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _animationController.value,
                child: child,
              );
            },
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: viewModel.callNearestAmbulance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Call Ambulance", style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
