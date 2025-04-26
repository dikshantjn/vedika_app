import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabSearchViewModel.dart';
import 'package:vedika_healthcare/features/labTest/presentation/widgets/LabBottomSheet.dart';

class LabSearchPage extends StatefulWidget {
  @override
  _LabSearchPageState createState() => _LabSearchPageState();
}

class _LabSearchPageState extends State<LabSearchPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final viewModel = Provider.of<LabSearchViewModel>(context, listen: false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.loadUserLocation(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LabSearchViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              // Google Map
              Positioned.fill(
                child: viewModel.isLoading || viewModel.currentPosition == null
                    ? Center(child: CircularProgressIndicator())
                    : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: viewModel.currentPosition ?? LatLng(18.488726, 73.8674683),
                    zoom: 14,
                  ),
                  markers: viewModel.markers,
                  onMapCreated: (controller) {
                    viewModel.setMapController(controller);

                    if (viewModel.currentPosition != null) {
                      controller.animateCamera(
                        CameraUpdate.newLatLngZoom(viewModel.currentPosition!, 14),
                      );
                    }
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                ),
              ),
              // Search Bar
              Positioned(top: 40, left: 15, right: 15, child: _buildSearchBar(viewModel)),
              // Bottom Sheet (Using Separate Widget)
              Align(alignment: Alignment.bottomCenter, child: LabBottomSheet(viewModel: viewModel)),
            ],
          );
        },
      ),
    );
  }

  /// Search Bar Widget
  Widget _buildSearchBar(LabSearchViewModel viewModel) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.black54),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: viewModel.searchController,
              onChanged: (query) => viewModel.filterLabs(query),
              decoration: InputDecoration(
                hintText: "Search labs or tests...",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
