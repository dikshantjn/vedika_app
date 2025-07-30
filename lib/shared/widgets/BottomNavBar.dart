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
    final double barHeight = 54; // Slightly increased to accommodate padding
    final double circleDiameter = 50; // Keep button size
    final double iconSize = 24; // Keep icon size
    final double shadowBlur = 12;
    final double barRadius = 20;
    final double margin = 6;
    final double notchWidth = circleDiameter + (margin * 2); // Width including margins

    // Get bottom padding for safe area
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    // Emergency blink animation
    final AnimationController blinkController = _blinkController;
    final Animation<Color?> blinkAnimation = ColorTween(
      begin: Colors.red.withOpacity(0.4),
      end: Colors.red,
    ).animate(blinkController);

    return Container(
      height: barHeight + (circleDiameter / 2) + bottomPadding,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Curved bottom navigation bar with top notch
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding, // Position above system navigation
            child: Container(
              height: barHeight,
              child: CustomPaint(
                painter: CurvedBottomBarPainter(
                  color: ColorPalette.primaryColor,
                  circleDiameter: circleDiameter,
                  margin: margin,
                  barRadius: barRadius,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.home_filled,
                      label: 'Home',
                      selected: widget.selectedIndex == 0,
                      onTap: () => widget.onItemTapped(0),
                    ),
                    // Spacer for center button area
                    SizedBox(width: notchWidth),
                    // Emergency blinking phone icon
                    GestureDetector(
                      onTap: _onEmergencyTap,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4), // Reduced top padding
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min, // Added to prevent overflow
                          children: [
                            AnimatedBuilder(
                              animation: blinkAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: 28, // Reduced from 32
                                  height: 28, // Reduced from 32
                                  decoration: BoxDecoration(
                                    color: blinkAnimation.value,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.phone, color: Colors.white, size: 16), // Reduced from 20
                                );
                              },
                            ),
                            const SizedBox(height: 1), // Reduced spacing
                            Text(
                              'Emergency',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14, // Further reduced font size
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Floating center circular Speak button (positioned lower to fit in curve)
          Positioned(
            bottom: barHeight - (circleDiameter / 2) - 5 + bottomPadding, // Adjusted for smaller bar
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _onSpeakTap,
                child: AnimatedBuilder(
                  animation: _gradientAnimation,
                  builder: (context, child) {
                    return Container(
                      width: circleDiameter + 4, // Reduced border
                      height: circleDiameter + 4, // Reduced border
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
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
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12, // Reduced shadow
                            offset: Offset(0, 4), // Reduced offset
                            spreadRadius: 1, // Reduced spread
                          ),
                        ],
                      ),
                      child: Container(
                        margin: EdgeInsets.all(2), // Reduced margin
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: ShaderMask(
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
                              Icons.mic,
                              color: Colors.white,
                              size: iconSize + 4, // Reduced size
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Bottom safe area filler
          if (bottomPadding > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: bottomPadding,
                color: ColorPalette.primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 4), // Reduced top padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Added to prevent overflow
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28, // Reduced from 28
            ),
            const SizedBox(height: 1), // Reduced spacing
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14, // Further reduced font size
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for curved bottom bar with exact half-circular notch
class CurvedBottomBarPainter extends CustomPainter {
  final Color color;
  final double circleDiameter;
  final double margin;
  final double barRadius;

  CurvedBottomBarPainter({
    required this.color,
    required this.circleDiameter,
    required this.margin,
    required this.barRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path();

    // Start from bottom-left
    path.moveTo(0, size.height);

    // Draw bottom line
    path.lineTo(size.width, size.height);

    // Draw right side
    path.lineTo(size.width, barRadius);

    // Draw top-right corner
    path.quadraticBezierTo(
        size.width,
        0,
        size.width - barRadius,
        0
    );

    // Calculate circle center and notch dimensions
    final double circleCenterX = size.width / 2;
    final double circleRadius = circleDiameter / 2;
    final double notchRadius = circleRadius + margin; // Add margin to create space
    final double notchLeftX = circleCenterX - notchRadius;
    final double notchRightX = circleCenterX + notchRadius;
    final double notchDepth = 10; // Further reduced depth for smaller bar
    final double cornerRadius = 4; // Radius for rounded corners

    // Draw top line to notch right with rounded corner
    path.lineTo(notchRightX + cornerRadius, 0);

    // Draw rounded corner at notch right
    path.quadraticBezierTo(
        notchRightX,
        0,
        notchRightX,
        cornerRadius
    );

    // Draw the expanded half-circular notch with downward extension
    // Start the arc from the top
    path.arcToPoint(
      Offset(notchLeftX, notchDepth), // Extend downward
      radius: Radius.circular(notchRadius),
      clockwise: true,
    );

    // Draw rounded corner at notch left
    path.quadraticBezierTo(
        notchLeftX,
        0,
        notchLeftX - cornerRadius,
        0
    );

    // Draw top line from notch left to left corner
    path.lineTo(barRadius, 0);

    // Draw top-left corner
    path.quadraticBezierTo(
        0,
        0,
        0,
        barRadius
    );

    // Close the path
    path.close();

    // Add shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16);

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}