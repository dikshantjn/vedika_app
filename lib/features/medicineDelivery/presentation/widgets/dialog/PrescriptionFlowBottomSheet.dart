import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'dart:math' as math;
import 'dart:async'; // Added for Timer

const double _minPromptHeight = 400.0;

// Add uploading state
enum PrescriptionFlowState {
  loading,
  uploading,
  verifying,
  searching,
  findMore,
  notVerified,
  accepted,
  searchMorePrompt,
}

// Controller for managing the state and content of the bottom sheet
class PrescriptionFlowController extends ChangeNotifier {
  PrescriptionFlowState state;
  String? message;
  int? countdown;
  String? lottieAsset;
  bool noMoreVendors;
  String? medicalStoreName;
  VoidCallback? onTrackOrder;
  VoidCallback? onFindMore;
  VoidCallback? onCancel;
  VoidCallback? onClose;

  PrescriptionFlowController(
    this.state, {
    this.message,
    this.countdown,
    this.lottieAsset,
    this.noMoreVendors = false,
    this.medicalStoreName,
    this.onTrackOrder,
    this.onFindMore,
    this.onCancel,
    this.onClose,
  });

  void update({
    PrescriptionFlowState? state,
    String? message,
    int? countdown,
    String? lottieAsset,
    bool? noMoreVendors,
    String? medicalStoreName,
    VoidCallback? onTrackOrder,
    VoidCallback? onFindMore,
    VoidCallback? onCancel,
    VoidCallback? onClose,
  }) {
    if (state != null) this.state = state;
    if (message != null) this.message = message;
    if (countdown != null) this.countdown = countdown;
    if (lottieAsset != null) this.lottieAsset = lottieAsset;
    if (noMoreVendors != null) this.noMoreVendors = noMoreVendors;
    if (medicalStoreName != null) this.medicalStoreName = medicalStoreName;
    if (onTrackOrder != null) this.onTrackOrder = onTrackOrder;
    if (onFindMore != null) this.onFindMore = onFindMore;
    if (onCancel != null) this.onCancel = onCancel;
    if (onClose != null) this.onClose = onClose;
    notifyListeners();
  }
}

class PrescriptionFlowBottomSheet extends StatelessWidget {
  final PrescriptionFlowController controller;
  const PrescriptionFlowBottomSheet({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        Widget content;
        switch (controller.state) {
      case PrescriptionFlowState.loading:
          content = _buildLoading(controller.message ?? 'Uploading prescription...');
        break;
      case PrescriptionFlowState.uploading:
          content = _buildUploading(controller.message ?? 'Uploading prescription...');
        break;
      case PrescriptionFlowState.verifying:
          content = _VerificationTimerWidget(
            initialTime: controller.countdown ?? 300,
            message: controller.message ?? 'Verifying prescription...',
            lottieAsset: controller.lottieAsset,
            onTimeExpired: controller.onClose ?? () {},
          );
        break;
      case PrescriptionFlowState.searching:
          content = _VerificationTimerWidget(
            initialTime: controller.countdown ?? 300,
            message: controller.message ?? 'Searching Nearest Medical Shops...',
            lottieAsset: controller.lottieAsset,
            onTimeExpired: () {
              controller.update(state: PrescriptionFlowState.searchMorePrompt);
            },
          );
        break;
      case PrescriptionFlowState.searchMorePrompt:
        content = _SearchMorePromptWidget(
          onSearchMore: () {
            controller.update(
              state: PrescriptionFlowState.searching,
              message: 'Prescription Verified!\nSearching Nearest Medical Shops...',
              countdown: 300,
              lottieAsset: 'assets/animations/scanPrescription.json',
              onFindMore: controller.onFindMore,
            );
          },
        );
        break;
      case PrescriptionFlowState.findMore:
          content = _FindMoreMedicalShopsWidget(
            onFindMore: controller.onFindMore ?? () {},
            onCancel: controller.onCancel ?? () {},
            noMoreVendors: controller.noMoreVendors,
          );
        break;
      case PrescriptionFlowState.notVerified:
          content = _VerificationTimerWidget(
            initialTime: controller.countdown ?? 300,
            message: controller.message ?? 'Prescription not verified',
            lottieAsset: controller.lottieAsset,
            onTimeExpired: () {},
            onClose: controller.onClose,
            showClose: true,
          );
        break;
      case PrescriptionFlowState.accepted:
          content = Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Success Animation Container
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Lottie.asset(
                    'assets/animations/verified.json',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                // Success Title with Gradient
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.green, Colors.green.shade700],
                  ).createShader(bounds),
                  child: const Text(
                    'Prescription Verified!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                // Store Name with Icon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.store_rounded,
                        size: 20,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        controller.medicalStoreName ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Track Order Button
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.onTrackOrder ?? () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_shipping_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Track Your Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        break;
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: SafeArea(
            child: Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: content,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoading(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Lottie.asset(
                'assets/animations/scanPrescription.json',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.blue, Colors.blue.shade700],
            ).createShader(bounds),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ColorPalette.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please wait while we process your request...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUploading(String message) {
    return _AnimatedScaleLoading(
      message: message,
    );
  }
}

class _AnimatedScaleLoading extends StatefulWidget {
  final String message;
  const _AnimatedScaleLoading({Key? key, required this.message}) : super(key: key);

  @override
  State<_AnimatedScaleLoading> createState() => _AnimatedScaleLoadingState();
}

class _AnimatedScaleLoadingState extends State<_AnimatedScaleLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Loading Animation Container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.blue, Colors.blue.shade700],
                ).createShader(bounds),
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please wait while we process your request...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget for search more prompt after countdown
class _SearchMorePromptWidget extends StatelessWidget {
  final VoidCallback onSearchMore;
  const _SearchMorePromptWidget({Key? key, required this.onSearchMore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: _minPromptHeight),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 60, color: Colors.blueAccent),
          const SizedBox(height: 24),
          Text(
            'Didn\'t find a medical shop yet?\nYou can search in a wider area.',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onSearchMore,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Search More',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Unified Verification Timer Widget (replaces BeforeVerificationWidget)
class _VerificationTimerWidget extends StatefulWidget {
  final int initialTime;
  final String? message;
  final String? lottieAsset;
  final VoidCallback onTimeExpired;
  final VoidCallback? onClose;
  final bool showClose;
  const _VerificationTimerWidget({
    Key? key,
    required this.initialTime,
    required this.onTimeExpired,
    this.message,
    this.lottieAsset,
    this.onClose,
    this.showClose = false,
  }) : super(key: key);

  @override
  State<_VerificationTimerWidget> createState() => _VerificationTimerWidgetState();
}

class _VerificationTimerWidgetState extends State<_VerificationTimerWidget> {
  late int _remainingTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.initialTime;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        widget.onTimeExpired();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lottie Animation (no background)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Lottie.asset(
                widget.lottieAsset ?? 'assets/animations/scanPrescription.json',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Title Text with Gradient
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.blue, Colors.blue.shade700],
            ).createShader(bounds),
            child: Text(
              widget.message ?? 'Searching Nearest Medical Shops...',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ColorPalette.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          // Timer Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Icon(
                  Icons.timer_rounded,
                  size: 18,
                  color: Colors.grey.shade700,
                ),
                Text(
                  ' ${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')} min',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Information Text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text(
              'It will take up to 5 minutes to search. You can leave.',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (widget.showClose && widget.onClose != null) ...[
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: widget.onClose,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: ColorPalette.primaryColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                foregroundColor: ColorPalette.primaryColor,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              child: const Text('Close'),
            ),
          ],
        ],
      ),
    );
  }
}

// Unified FindMoreMedicalShopsWidget
class _FindMoreMedicalShopsWidget extends StatelessWidget {
  final VoidCallback onFindMore;
  final VoidCallback onCancel;
  final bool noMoreVendors;
  const _FindMoreMedicalShopsWidget({
    Key? key,
    required this.onFindMore,
    required this.onCancel,
    this.noMoreVendors = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Container
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: noMoreVendors 
                ? Colors.orange.withOpacity(0.1)
                : Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              noMoreVendors ? Icons.search_off_rounded : Icons.location_off_rounded,
              size: 50,
              color: noMoreVendors ? Colors.orange : Colors.redAccent,
            ),
          ),
          const SizedBox(height: 20),
          // Title
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: noMoreVendors 
                ? [Colors.orange, Colors.deepOrange]
                : [Colors.redAccent, Colors.red],
            ).createShader(bounds),
            child: Text(
              noMoreVendors 
                ? "No More Shops Found"
                : "Couldn't Find Medical Shops Nearby",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          // Message
          Text(
            noMoreVendors
              ? "We've searched in a wider area but couldn't find any additional medical stores. Please try again later."
              : "Would you like to search in a wider area? This will take about 5 minutes to find more options.",
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Buttons
          if (noMoreVendors)
            Container(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: Colors.orange.withOpacity(0.5),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.orange.withOpacity(0.05),
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onFindMore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(Icons.search, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          "Search More Shops",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}           