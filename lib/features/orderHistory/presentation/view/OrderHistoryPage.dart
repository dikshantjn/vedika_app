import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/tabs/AmbulanceTab.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/tabs/LabTestTab.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/tabs/MedicineTab.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/tabs/AppointmentTab.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';

class OrderHistoryPage extends StatefulWidget {
  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorPalette.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 5,
        title: Text(
          "Order History",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ColorPalette.primaryColor, ColorPalette.primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 4.0, color: Colors.black), // White underline
              insets: EdgeInsets.symmetric(horizontal: 16.0), // Adjust the width of the underline
            ),
          indicatorWeight: 3.0,
          tabs: [
            Tab(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Text(
                  'Medicine',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Tab(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Text(
                  'Ambulance',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Tab(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Text(
                  'Appointment',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Tab(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Text(
                  'Lab Test',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: DrawerMenu(),
      body: TabBarView(
        controller: _tabController,
        children: [
          MedicineTab(),
          AmbulanceTab(),
          AppointmentTab(),
          LabTestTab(),
        ],
      ),
    );
  }
}