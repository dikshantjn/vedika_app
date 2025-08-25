import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart' show MainScreenNavigator;
import 'package:vedika_healthcare/features/clinic/presentation/viewmodel/ClinicSearchViewModel.dart';
import 'package:vedika_healthcare/features/clinic/presentation/widgets/DraggableClinicList.dart';

class ClinicSearchPage extends StatefulWidget {
  @override
  _ClinicSearchPageState createState() => _ClinicSearchPageState();
}

class _ClinicSearchPageState extends State<ClinicSearchPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ClinicSearchViewModel>(context, listen: false);
      viewModel.ensureLocationEnabled(context).then((_) {
        viewModel.loadUserLocation(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          Consumer<ClinicSearchViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading || viewModel.currentPosition == null) {
                return Center(
                  child: CircularProgressIndicator(
                    color: DoctorConsultationColorPalette.primaryBlue,
                  ),
                );
              }
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: viewModel.currentPosition!,
                  zoom: 14,
                ),
                markers: viewModel.markers,
                onMapCreated: viewModel.onMapCreated,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
              );
            },
          ),

          // Search Bar
          Positioned(
            top: 40,
            left: 15,
            right: 15,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: DoctorConsultationColorPalette.shadowLight,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Provider.of<ClinicSearchViewModel>(context, listen: false)
                          .filterClinics(
                        Provider.of<ClinicSearchViewModel>(context, listen: false)
                            .searchController
                            .text,
                      );
                    },
                    child: Icon(
                      Icons.search,
                      color: DoctorConsultationColorPalette.primaryBlue,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Consumer<ClinicSearchViewModel>(
                      builder: (context, viewModel, child) {
                        return TextField(
                          controller: viewModel.searchController,
                          onChanged: viewModel.filterClinics,
                          decoration: InputDecoration(
                            hintText: "Search clinics...",
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: DoctorConsultationColorPalette.textHint,
                            ),
                          ),
                          style: TextStyle(
                            color: DoctorConsultationColorPalette.textPrimary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 15,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DoctorConsultationColorPalette.shadowLight,
                    blurRadius: 3,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: ColorPalette.primaryColor),
                onPressed: () {
                  if (MainScreenNavigator.instance.canGoBack) {
                    MainScreenNavigator.instance.goBack();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ),

          // Clinic List
          Consumer<ClinicSearchViewModel>(
            builder: (context, viewModel, child) {
              return DraggableClinicList(
                clinics: viewModel.filteredClinics.isNotEmpty
                    ? viewModel.filteredClinics
                    : viewModel.clinics,
                expandedItems: viewModel.expandedItems,
                onClinicTap: (index, lat, lng) {
                  viewModel.toggleClinicExpansion(index);
                  viewModel.mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
