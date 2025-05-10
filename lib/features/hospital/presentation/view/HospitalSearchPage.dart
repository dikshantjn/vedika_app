import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/hospital/presentation/viewModal/HospitalSearchViewModel.dart';
import 'package:vedika_healthcare/features/hospital/presentation/widgets/DraggableHospitalList.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';

class HospitalSearchPage extends StatefulWidget {
  @override
  _HospitalSearchPageState createState() => _HospitalSearchPageState();
}

class _HospitalSearchPageState extends State<HospitalSearchPage> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = Provider.of<HospitalSearchViewModel>(context, listen: false);
      await viewModel.ensureLocationEnabled(context);
      await viewModel.loadInitialBookings(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HospitalSearchViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Google Map
              Positioned.fill(
                child: viewModel.isLoading || viewModel.currentPosition == null
                    ? Center(child: CircularProgressIndicator())
                    : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: viewModel.currentPosition!,
                    zoom: 14,
                  ),
                  markers: viewModel.markers,
                  onMapCreated: viewModel.onMapCreated,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                ),
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
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => viewModel.filterHospitals(viewModel.searchController.text),
                        child: Icon(Icons.search, color: Colors.black54),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: viewModel.searchController,
                          onChanged: (value) => viewModel.filterHospitals(value),
                          decoration: InputDecoration(
                            hintText: "Search hospitals...",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.black54),
                          ),
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Draggable Hospital List
              DraggableHospitalList(
                hospitals: viewModel.filteredHospitals,
                expandedItems: viewModel.expandedItems,
                onHospitalTap: (index, lat, lng) {
                  viewModel.onHospitalTap(index, lat, lng);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

