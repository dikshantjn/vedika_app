import 'dart:developer';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/EmergencyService/data/services/EmergencyService.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'package:vedika_healthcare/features/EmergencyService/presentation/view/EmergencyDialog.dart';
import 'package:vedika_healthcare/shared/widgets/VoiceRecognitionOverlay.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;
  EmergencyService? _emergencyService;
  late NotchBottomBarController _controller;
  late Animation<Color?> _blinkAnimation;
  late AnimationController _blinkController;
  bool _showVoiceRecognition = false;

  @override
  void initState() {
    super.initState();
    _controller = NotchBottomBarController(index: 1);

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _gradientAnimation = Tween<double>(begin: 0, end: 1).animate(_gradientController);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _blinkAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.red.withOpacity(0.9),
    ).animate(_blinkController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _emergencyService ??= EmergencyService(context.read<LocationProvider>());
  }

  @override
  void didUpdateWidget(BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Force the Speak button to always appear active
    _controller.index = 1; // Speak button index
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _gradientController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onEmergencyTap() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EmergencyDialog(ambulanceNumber: "9370320066",bloodBankNumber: "9370320066",doctorNumber: "9370320066",);
      },
    );
  }

  void _onSpeakTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      enableDrag: false,
      isDismissible: false,
      builder: (context) => VoiceRecognitionOverlay(
        onClose: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedNotchBottomBar(
            notchBottomBarController: _controller,
            color: ColorPalette.primaryColor,
            showLabel: true,
            textOverflow: TextOverflow.visible,
            maxLine: 1,
            shadowElevation: 5,
            kBottomRadius: 28.0,
            notchColor: Colors.black,
            removeMargins: false,
            bottomBarWidth: MediaQuery.of(context).size.width,
            showShadow: false,
            durationInMilliSeconds: 300,
            itemLabelStyle: const TextStyle(fontSize: 11, color: Colors.white),
            elevation: 2,
            bottomBarItems: [
              BottomBarItem(
                inActiveItem: const Icon(Icons.home_filled, color: Colors.white, size: 20,),
                activeItem: const Icon(Icons.home_filled, color: Colors.blueAccent,size: 20,),
                itemLabel: 'Home',
              ),
              BottomBarItem(
                inActiveItem: AnimatedBuilder(
                  animation: _gradientAnimation,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [
                            Color(0xFF8A2BE2),
                            Color(0xFF4169E1),
                            Color(0xFFAC4A79),
                            Color(0xFF8A2BE2),
                          ],
                          stops: [0.0, 0.33, 0.66, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          transform: GradientRotation(_gradientAnimation.value * 2 * 3.14),
                        ).createShader(bounds);
                      },
                      child: Icon(
                        Icons.mic_none,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                activeItem: AnimatedBuilder(
                  animation: _gradientAnimation,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [
                            Color(0xFFB76EF9),
                            Color(0xFF708EE8),
                            Color(0xFFF172AF),
                            Color(0xFFB271EE),
                          ],
                          stops: [0.0, 0.33, 0.66, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          transform: GradientRotation(_gradientAnimation.value * 2 * 3.14),
                        ).createShader(bounds);
                      },
                      child: Icon(
                        Icons.mic,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                itemLabel: 'Speak',
              ),
              BottomBarItem(
                inActiveItem: AnimatedBuilder(
                  animation: _blinkAnimation,
                  builder: (context, child) {
                    return CircleAvatar(
                      radius: 28,
                      backgroundColor: _blinkAnimation.value,
                      child: const Icon(Icons.call, color: Colors.white, size: 20),
                    );
                  },
                ),
                activeItem: AnimatedBuilder(
                  animation: _blinkAnimation,
                  builder: (context, child) {
                    return CircleAvatar(
                      radius: 82,
                      backgroundColor: _blinkAnimation.value,
                      child: const Icon(Icons.call, color: Colors.white, size: 20),
                    );
                  },
                ),
                itemLabel: 'Emergency',
              ),
            ],
            onTap: (index) {
              if (index == 1) {
                _onSpeakTap();
              } else if (index == 2) {
                _onEmergencyTap();
              } else {
                widget.onItemTapped(index);
              }
              _controller.index = 1;
            },
            kIconSize: 24.0,
          ),
        ],
      ),
    );
  }
}