import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/ClinicAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/tabs/AmbulanceTab.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/tabs/LabTestTab.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/tabs/MedicineDeliveryOrderHistoryTab.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/tabs/BedBookingTab.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/tabs/BloodBankTab.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/tabs/ClinicAppointmentTab.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/tabs/ProductOrdersTab.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/OrderHistoryViewModel.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';

// Simple navigation bridge to pass intents when OrderHistory is embedded in MainScreen
class OrderHistoryNavigation {
  static int? initialTab;
}

class OrderHistoryPage extends StatefulWidget {
  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  String? _userId;
  bool _isDisposed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _loadUserId() async {
    try {
      if (_isDisposed) return;
      final userId = await StorageService.getUserId();
      if (!_isDisposed && mounted) {
        setState(() {
          _userId = userId;
        });
      }
    } catch (e) {
      print('OrderHistoryPage - Error loading user ID: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) {
      print('OrderHistoryPage - didChangeDependencies called on disposed widget, skipping');
      return;
    }
    
    // Get the initialTab from route arguments
    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      print('OrderHistoryPage - Route arguments: $args (type: ${args.runtimeType})');
      // Fallback to static bridge if args are not available due to MainScreen routing
      if (args == null && OrderHistoryNavigation.initialTab != null) {
        _selectedIndex = OrderHistoryNavigation.initialTab!.clamp(0, verticalTitles.length - 1);
        print('OrderHistoryPage - Using bridge initialTab: $_selectedIndex');
        // Clear after use to avoid stale reuse
        OrderHistoryNavigation.initialTab = null;
        return;
      }
      
      if (args != null) {
        // Check if args is a Map<String, dynamic>
        if (args is Map<String, dynamic>) {
          print('OrderHistoryPage - Arguments is Map<String, dynamic>');
          if (args.containsKey('initialTab')) {
            final initialTab = args['initialTab'];
            print('OrderHistoryPage - initialTab value: $initialTab (type: ${initialTab.runtimeType})');
            if (initialTab is int) {
              // Ensure the index is within valid bounds
              if (initialTab >= 0 && initialTab < verticalTitles.length) {
                _selectedIndex = initialTab;
                print('OrderHistoryPage - Set selected index to: $_selectedIndex');
              } else {
                print('Warning: initialTab index out of bounds: $initialTab (max: ${verticalTitles.length - 1})');
                _selectedIndex = 0; // Default to first tab
              }
            } else {
              print('Warning: initialTab is not an int: ${initialTab.runtimeType}');
              _selectedIndex = 0; // Default to first tab
            }
          } else {
            print('OrderHistoryPage - No initialTab found in arguments');
          }
        } else {
          // Log the unexpected argument type for debugging
          print('Warning: OrderHistoryPage received unexpected argument type: ${args.runtimeType}');
          print('Arguments: $args');
          // Try to extract any useful information from the arguments
          if (args.toString().contains('VendorProduct')) {
            print('Warning: VendorProduct object detected in route arguments');
          }
          // Reset to default tab to prevent errors
          _selectedIndex = 0;
        }
      } else {
        print('OrderHistoryPage - No route arguments provided');
      }
    } catch (e, stackTrace) {
      // Log any errors that occur during argument processing
      print('Error processing route arguments in OrderHistoryPage: $e');
      print('Stack trace: $stackTrace');
      // Reset to default tab to prevent errors
      _selectedIndex = 0;
    }
  }

  List<Widget> get _verticals {
    // Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) {
      print('OrderHistoryPage - _verticals getter called on disposed widget, returning empty list');
      return [const Center(child: Text('Widget disposed'))];
    }
    
    try {
      return [
        MedicineDeliveryOrderHistoryTab(),
        AmbulanceTab(),
        _userId != null ? BedBookingTab(userId: _userId!) : const Center(child: CircularProgressIndicator()),
        LabTestTab(),
        BloodBankTab(),
        ClinicAppointmentTab(),
        ProductOrdersTab(),
      ];
    } catch (e) {
      print('Error creating vertical tabs: $e');
      // Return a fallback widget if there's an error
      return [
        const Center(child: Text('Error loading tabs')),
      ];
    }
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

  // Getter to ensure titles are always available
  List<String> get verticalTitles {
    // Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) {
      print('OrderHistoryPage - verticalTitles getter called on disposed widget, returning default titles');
      return ['Orders'];
    }
    
    if (_verticalTitles.isEmpty) {
      print('Warning: _verticalTitles is empty, returning default titles');
      return ['Orders'];
    }
    return _verticalTitles;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    // Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) {
      print('OrderHistoryPage - build called on disposed widget, returning empty container');
      return Container(); // Return empty container if disposed
    }
    
    print('OrderHistoryPage - build method called, selectedIndex: $_selectedIndex');
    
    // Ensure selectedIndex is within bounds
    if (_selectedIndex < 0 || _selectedIndex >= verticalTitles.length) {
      print('Warning: selectedIndex out of bounds, resetting to 0');
      _selectedIndex = 0;
    }
    
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
              // Check if widget is still mounted before accessing context
              if (!mounted || _isDisposed) return;
              
              if (MainScreenNavigator.instance.canGoBack) {
                MainScreenNavigator.instance.goBack();
              } else {
                Navigator.pop(context);
              }
            },
          ),
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
                itemCount: verticalTitles.length,
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: ChoiceChip(
                      label: Text(
                        verticalTitles[index],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      selected: _selectedIndex == index,
                      onSelected: (selected) {
                        // Check if widget is still mounted before calling setState
                        if (!mounted || _isDisposed) return;
                        
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
        body: IndexedStack(
          index: _selectedIndex,
          children: _verticals,
        ),
      ),
    );
  }
}
