import 'dart:developer';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'dart:async';
import 'package:vedika_healthcare/features/home/data/services/EmergencyService.dart';
import 'package:vedika_healthcare/shared/widgets/EmergencyDialog.dart';

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
  late AnimationController _animationController;
  late Timer _timer;
  bool _isBlinking = true;
  late AnimationController _gradientController;
  late Animation<Color?> _gradientAnimation;
  final EmergencyService _emergencyService = EmergencyService(); // ✅ Initialize EmergencyService

  /// Controller to handle Notch Bottom Bar and also handle the initial page
  final NotchBottomBarController _controller = NotchBottomBarController(index: 1);

  @override
  void initState() {
    super.initState();

    // Pulsating effect for Emergency button (Not required anymore)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.8,
      upperBound: 1.2,
    );

    // Blinking effect for Emergency button
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _isBlinking = !_isBlinking;
      });
    });

    // Gradient animation for Speak button
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _gradientAnimation = TweenSequence<Color?>(
      [
        TweenSequenceItem(tween: ColorTween(begin: Color(0xFF8A2BE2), end: Color(0xFF4169E1)), weight: 1),
        TweenSequenceItem(tween: ColorTween(begin: Color(0xFF4169E1), end: Color(0xFFAC4A79)), weight: 1),
        TweenSequenceItem(tween: ColorTween(begin: Color(0xFF4169E1), end: Color(0xFF8A2BE2)), weight: 1),
        TweenSequenceItem(tween: ColorTween(begin: Color(0xFF8A2BE2), end: Color(0xFF8A2BE2)), weight: 1),
      ],
    ).animate(_gradientController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _gradientController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _onEmergencyTap() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EmergencyDialog(
          onCallPressed: () {
            _emergencyService.triggerEmergency(); // Trigger emergency call & SMS
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Using AnimatedNotchBottomBar instead of BottomNavigationBar
          AnimatedNotchBottomBar(
            notchBottomBarController: _controller,
            color: ColorPalette.primaryColor,
            showLabel: true,
            textOverflow: TextOverflow.visible,
            maxLine: 1,
            shadowElevation: 5,
            kBottomRadius: 28.0,
            notchColor: Colors.black87,
            removeMargins: false,
            bottomBarWidth: 500,
            showShadow: false,
            durationInMilliSeconds: 300,
            itemLabelStyle: const TextStyle(fontSize: 10),
            elevation: 1,
            bottomBarItems: [
              BottomBarItem(
                inActiveItem: Icon(
                  Icons.home_filled,
                  color: Colors.white,
                ),
                activeItem: Icon(
                  Icons.home_filled,
                  color: Colors.blueAccent,
                ),
                itemLabel: 'Home',
              ),
              BottomBarItem(
                inActiveItem: Icon(Icons.mic, color: Colors.white),
                activeItem: Icon(
                  Icons.mic,
                  color: Colors.blueAccent,
                ),
                itemLabel: 'Speak',
              ),
              // Emergency button (No animation here)
              BottomBarItem(
                inActiveItem: Icon(
                  Icons.call,
                  color: Colors.white,
                ),
                activeItem: GestureDetector(
                  onTap: () {
                    _onEmergencyTap(); // Trigger emergency call
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: const Icon(
                      Icons.call,
                      color: Colors.white,
                    ),
                  ),
                ),
                itemLabel: 'Emergency',
              ),
            ],
            onTap: (index) {
              log('current selected index $index');
              widget.onItemTapped(index); // Update selected index from widget

              // Keep the animation always running for "Speak" (index == 1)
              if (index != 1) {
                _animationController.stop(); // Stop animation for other buttons
              }
            },
            kIconSize: 24.0,
          ),
        ],
      ),
    );
  }
}
