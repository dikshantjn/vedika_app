import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/PrescriptionUploadViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/ChooseFileWidget.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/EnableLocationWidget.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';

class MedicineOrderScreen extends StatefulWidget {
  const MedicineOrderScreen({Key? key}) : super(key: key);

  @override
  State<MedicineOrderScreen> createState() => _MedicineOrderScreenState();
}

class _MedicineOrderScreenState extends State<MedicineOrderScreen> {
  bool isLocationEnabled = false;

  @override
  void initState() {
    super.initState();
    // Defer to after first frame to use Provider context and avoid blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final lp = Provider.of<LocationProvider>(context, listen: false);
      if (!lp.isInitialized) {
        // Fire-and-forget init; Splash usually initializes this already
        unawaited(lp.initializeLocation());
      }
      if (lp.isLocationLoaded && mounted) {
        setState(() {
          isLocationEnabled = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // No heavy checks here; rely on global LocationProvider state
  Future<void> _checkLocationStatus() async {}

  // Callback when location is enabled
  void _onLocationEnabled() {
    setState(() {
      isLocationEnabled = true; // Update state to show ChooseFileWidget
    });
  }

  Widget _promoCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _promoCard(
          icon: Icons.local_offer_rounded,
          title: 'FLAT 15% OFF on first order',
          subtitle: 'Use code WELCOME15 at checkout',
          color: Colors.teal,
        ),
        const SizedBox(height: 12),
        _promoCard(
          icon: Icons.card_giftcard_rounded,
          title: 'Buy 2 Get 1 Free',
          subtitle: 'On selected vitamins and supplements',
          color: Colors.deepPurple,
        ),
        const SizedBox(height: 12),
        _promoCard(
          icon: Icons.local_shipping_outlined,
          title: 'Free delivery',
          subtitle: 'For orders above ₹499',
          color: Colors.indigo,
        ),
      ],
    );
  }

  Widget _promoCard({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PrescriptionUploadViewModel>(
      create: (_) => PrescriptionUploadViewModel(context),
      child: Consumer<PrescriptionUploadViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              foregroundColor: Colors.white,
              backgroundColor: ColorPalette.primaryColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () {
                  final scope = MainScreenScope.maybeOf(context);
                  if (scope != null) {
                    scope.setIndex(0);
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              title: const Text(
                "Order Medicine",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // Navigate to notifications screen
                  },
                ),
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ColorPalette.primaryColor.withOpacity(0.1),
                    Colors.white,
                  ],
                ),
              ),
              child: Consumer<LocationProvider>(
                builder: (context, locationProvider, child) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: ColorPalette.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.medication_outlined,
                                      color: ColorPalette.primaryColor,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Upload Prescription",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Upload your prescription to order medicines",
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Main Content
                        Expanded(
                          child: Center(
                            child: (isLocationEnabled || locationProvider.isLocationLoaded)
                                ? SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ChooseFileWidget(
                                            pickPrescription: viewModel.pickPrescription,
                                          ),
                                          const SizedBox(height: 24),
                                          _promoCardsSection(),
                                        ],
                                      ),
                                    ),
                                  )
                                : EnableLocationWidget(
                                    enableLocation: viewModel.enableLocation,
                                    onLocationEnabled: _onLocationEnabled,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
