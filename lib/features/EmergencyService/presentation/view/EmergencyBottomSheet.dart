import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/EmergencyService/data/services/EmergencyService.dart';
import 'package:vedika_healthcare/features/EmergencyService/presentation/viewmodel/EmergencyViewModel.dart';
import 'package:vedika_healthcare/features/membership/presentation/view/MembershipPage.dart';
import 'package:vedika_healthcare/features/membership/presentation/viewmodel/MembershipViewModel.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

class EmergencyBottomSheet extends StatefulWidget {
  final String doctorNumber;
  final String ambulanceNumber;
  final String bloodBankNumber;

  const EmergencyBottomSheet({
    Key? key,
    required this.doctorNumber,
    required this.ambulanceNumber,
    required this.bloodBankNumber,
  }) : super(key: key);

  @override
  State<EmergencyBottomSheet> createState() => _EmergencyBottomSheetState();
}

class _EmergencyBottomSheetState extends State<EmergencyBottomSheet> {
  late EmergencyViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EmergencyViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membershipVM = context.watch<MembershipViewModel>();
    final locationProvider = context.watch<LocationProvider>();

    final hasSubscription = membershipVM.hasActiveMembership;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<EmergencyViewModel>(
        builder: (context, vm, _) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 18,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
                    decoration: hasSubscription
                        ? BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ColorPalette.primaryColor,
                                ColorPalette.primaryColor.withOpacity(0.85),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          )
                        : BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                            ),
                          ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: hasSubscription ? Colors.white.withOpacity(0.2) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: hasSubscription ? null : Border.all(color: Colors.grey.shade200),
                          ),
                          child: Icon(
                            Icons.emergency_share,
                            color: hasSubscription ? Colors.white : ColorPalette.primaryColor,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasSubscription ? 'Emergency Assistance' : 'Emergency Assistance',
                                style: TextStyle(
                                  color: hasSubscription ? Colors.white : Colors.grey.shade900,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                hasSubscription
                                    ? 'We will connect you to emergency services.'
                                    : 'Get Vedika Plus to unlock priority emergency support and quick routing.',
                                style: TextStyle(
                                  color: hasSubscription ? Colors.white.withOpacity(0.9) : Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: hasSubscription ? Colors.white : Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),

                  if (!hasSubscription) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Promotion Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: ColorPalette.primaryColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.workspace_premium, color: ColorPalette.primaryColor, size: 20),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Vedika Plus Membership',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey.shade900),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Unlock emergency assistance and more:',
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                ),
                                SizedBox(height: 10),
                                _promoBullet(Icons.emergency, 'Priority routing for emergency calls'),
                                _promoBullet(Icons.support_agent, '24/7 member assistance'),
                                _promoBullet(Icons.speed, 'Faster connect with verified providers'),
                                SizedBox(height: 12),
                                Divider(color: Colors.grey.shade200, height: 20),
                                SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => MembershipPage()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ColorPalette.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Text('Explore Membership'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ] else ...[
                    if (!vm.showOptions)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Confirm emergency call', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey[800])),
                            SizedBox(height: 12),
                            vm.isLoading
                                ? Row(
                                    children: [
                                      SizedBox(width: 4),
                                      SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                                      SizedBox(width: 12),
                                      Expanded(child: Text('Checking your location...', style: TextStyle(color: Colors.grey[800]))),
                                    ],
                                  )
                                : SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        // Show options immediately; fetch location in background only if needed
                                        vm.showOptions = true;
                                        vm.notifyListeners();
                                        if (!locationProvider.isLocationLoaded) {
                                          vm.checkLocationEnabled(context);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ColorPalette.primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: Text('Yes, Call Emergency'),
                                    ),
                                  ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),

                    if (vm.showOptions)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildOptionBox(
                                context,
                                label: 'Doctor',
                                color: Colors.blueAccent,
                                icon: Icons.call,
                                onTap: () {
                                  if (EmergencyService.isInitialized) {
                                    EmergencyService.instance.triggerDoctorEmergency(widget.doctorNumber);
                                  } else {
                                    print("⚠️ EmergencyService not initialized yet");
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildOptionBox(
                                context,
                                label: 'Ambulance',
                                color: Colors.green,
                                icon: Icons.local_hospital,
                                onTap: () {
                                  if (EmergencyService.isInitialized) {
                                    EmergencyService.instance.triggerAmbulanceEmergency(widget.ambulanceNumber);
                                  } else {
                                    print("⚠️ EmergencyService not initialized yet");
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildOptionBox(
                                context,
                                label: 'Blood Bank',
                                color: Colors.pinkAccent,
                                icon: Icons.bloodtype,
                                onTap: () {
                                  if (EmergencyService.isInitialized) {
                                    EmergencyService.instance.triggerBloodBankEmergency(widget.bloodBankNumber);
                                  } else {
                                    print("⚠️ EmergencyService not initialized yet");
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionBox(
      BuildContext context, {
      required String label,
      required Color color,
      required IconData icon,
      required VoidCallback onTap,
    }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w700,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _promoBullet(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: ColorPalette.primaryColor),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
