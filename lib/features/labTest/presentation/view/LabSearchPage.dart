import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabSearchViewModel.dart';
import 'package:vedika_healthcare/features/labTest/presentation/widgets/LabBottomSheet.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart';

class LabSearchPage extends StatefulWidget {
  @override
  _LabSearchPageState createState() => _LabSearchPageState();
}

class _LabSearchPageState extends State<LabSearchPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      key: _scaffoldKey,
      body: Consumer<LabSearchViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              // Google Map
              Positioned.fill(
                child: viewModel.isLoading || viewModel.currentPosition == null
                    ? _buildLoadingState()
                    : _buildMap(viewModel),
              ),
              // Top Bar with Search
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildTopBar(viewModel),
              ),
              // Bottom Sheet
              if (viewModel.isMapReady)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: LabBottomSheet(viewModel: viewModel),
                ),
              // Side Panel
              if (viewModel.isSidePanelOpen)
                _buildSidePanel(viewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidePanel(LabSearchViewModel viewModel) {
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
                    "Locations",
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
                viewModel.loadUserLocation(context);
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
                  ...viewModel.cityLabCounts.entries.take(10).map((entry) {
                    final isSelected = viewModel.selectedCity == entry.key;
                    return _buildCityOption(
                      city: entry.key,
                      labCount: entry.value,
                      isSelected: isSelected,
                      onTap: () {
                        viewModel.selectCity(entry.key);
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
    required int labCount,
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorPalette.primaryColor
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "$labCount labs",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
            ),
            SizedBox(height: 16),
            Text(
              "Loading your location...",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(LabSearchViewModel viewModel) {
    return GoogleMap(
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
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
    );
  }

  Widget _buildTopBar(LabSearchViewModel viewModel) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 8,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () {
              final scope = MainScreenScope.maybeOf(context);
              if (scope != null) {
                scope.setIndex(0);
              } else {
                Navigator.pop(context);
              }
            },
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildSearchBar(viewModel),
          ),
          SizedBox(width: 12),
          IconButton(
            icon: Icon(Icons.location_city, color: ColorPalette.primaryColor),
            onPressed: () {
              viewModel.toggleSidePanel();
              if (!viewModel.isSidePanelOpen) {
                // If closing panel, try to get location again
                viewModel.loadUserLocation(context);
              }
            },
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(LabSearchViewModel viewModel) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 12),
          Icon(
            Icons.search,
            color: Colors.grey[600],
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: viewModel.searchController,
              onChanged: (query) => viewModel.filterLabs(query),
              decoration: InputDecoration(
                hintText: "Search labs or tests...",
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          if (viewModel.searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.grey[600],
                size: 20,
              ),
              onPressed: () {
                viewModel.searchController.clear();
                viewModel.filterLabs('');
              },
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          SizedBox(width: 8),
        ],
      ),
    );
  }
}
