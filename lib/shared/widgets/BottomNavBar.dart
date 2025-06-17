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
    final double barHeight = 80;
    final double circleDiameter = 72;
    final double iconSize = 28;
    final double shadowBlur = 16;
    final double barRadius = 28;
    final double margin = 8; // Equal margin around the circle
    final double notchWidth = circleDiameter + (margin * 2); // Width including margins
    
    // Emergency blink animation
    final AnimationController blinkController = _blinkController;
    final Animation<Color?> blinkAnimation = ColorTween(
      begin: Colors.red.withOpacity(0.4),
      end: Colors.red,
    ).animate(blinkController);
    
    return SafeArea(
      child: SizedBox(
        height: barHeight + circleDiameter / 2 + 8,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Curved bottom navigation bar with top notch
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
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
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: blinkAnimation,
                                builder: (context, child) {
                                  return Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: blinkAnimation.value,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.phone, color: Colors.white, size: 20),
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Emergency',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
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
              bottom: barHeight - (circleDiameter / 2) - 15, // Moved lower to fit in curve
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _onSpeakTap,
                  child: AnimatedBuilder(
                    animation: _gradientAnimation,
                    builder: (context, child) {
                      return Container(
                        width: circleDiameter + 6, // Extra width for border
                        height: circleDiameter + 6, // Extra height for border
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
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Container(
                          margin: EdgeInsets.all(3), // Creates the border effect
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
                                size: iconSize + 8,
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
          ],
        ),
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
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
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
    final double notchDepth = 20; // Depth of the curve extending downward
    final double cornerRadius = 8; // Radius for rounded corners
    
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