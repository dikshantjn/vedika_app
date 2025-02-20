import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/home/data/services/EmergencyService.dart';

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

  @override
  void initState() {
    super.initState();

    // Pulsating effect for Emergency button
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
    print("🚨 Emergency button clicked!"); // Debugging log
    _emergencyService.triggerEmergency(); // ✅ Call EmergencyService function
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Color(0xFF38A3A5), // Your Teal Navbar Color
              borderRadius: BorderRadius.circular(30),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              currentIndex: widget.selectedIndex,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white,
              onTap: widget.onItemTapped,
              elevation: 0,
              iconSize: 16,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home, color: Colors.white),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: SizedBox(height: 20), // Placeholder for floating button
                  label: 'Speak',
                ),
                BottomNavigationBarItem(
                  icon: GestureDetector(
                    onTap: _onEmergencyTap, // ✅ Emergency button click event
                    child: ScaleTransition(
                      scale: _animationController,
                      child: AnimatedOpacity(
                        opacity: _isBlinking ? 1.0 : 0.3,
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          padding: const EdgeInsets.all(2),
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
                    ),
                  ),
                  label: 'Emergency',
                ),
              ],
            ),
          ),

          // Floating Gradient Mic Button
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 30,
            bottom: 25,
            child: AnimatedBuilder(
              animation: _gradientController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_gradientAnimation.value ?? Colors.blue).withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                    border: Border.all(
                      width: 3,
                      color: _gradientAnimation.value ?? Colors.blue,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
