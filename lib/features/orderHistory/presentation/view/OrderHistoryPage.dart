import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/ClinicAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/tabs/AmbulanceTab.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/tabs/LabTestTab.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/tabs/MedicineTab.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/tabs/BedBookingTab.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/tabs/BloodBankTab.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/tabs/ClinicAppointmentTab.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/tabs/ProductOrdersTab.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/OrderHistoryViewModel.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';

class OrderHistoryPage extends StatefulWidget {
  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  int _selectedIndex = 0;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final userId = await StorageService.getUserId();
    setState(() {
      _userId = userId;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the initialTab from route arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('initialTab')) {
      _selectedIndex = args['initialTab'] as int;
    }
  }

  List<Widget> get _verticals {
    return [
      MedicineTab(),
      AmbulanceTab(),
      _userId != null ? BedBookingTab(userId: _userId!) : const Center(child: CircularProgressIndicator()),
      LabTestTab(),
      BloodBankTab(),
      ClinicAppointmentTab(),
      ProductOrdersTab(),
    ];
  }

  final List<String> _verticalTitles = [
    'Medicine',
    'Ambulance',
    'Bed Booking',
    'Lab Test',
    'Blood Bank',
    'Clinic',
    'Products',
  ];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClinicAppointmentViewModel()),
        ChangeNotifierProvider(create: (_) => OrderHistoryViewModel()),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: ColorPalette.primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 6,
          title: Text(
            "Order History",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 1.2,
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ColorPalette.primaryColor, ColorPalette.primaryColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: Container(
              height: 60,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _verticalTitles.length,
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: ChoiceChip(
                      label: Text(
                        _verticalTitles[index],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      selected: _selectedIndex == index,
                      onSelected: (selected) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      selectedColor: ColorPalette.primaryColor,
                      backgroundColor: Colors.grey.shade200,
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        color: _selectedIndex == index ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: BorderSide(
                          color: _selectedIndex == index ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      elevation: 3,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        drawer: DrawerMenu(),
        body: _verticals[_selectedIndex],
      ),
    );
  }
}
