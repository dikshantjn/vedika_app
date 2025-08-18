import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/SpeakAI/presentation/viewmodel/VoiceRecognitionViewModel.dart';
import 'package:vedika_healthcare/main.dart' show navigatorKey;
import 'package:vedika_healthcare/features/SpeakAI/presentation/widgets/voice_intents/IntentResultsView.dart';
import 'package:vedika_healthcare/features/SpeakAI/presentation/widgets/voice_intents/intent_navigation.dart';
import 'package:vedika_healthcare/features/EmergencyService/presentation/view/EmergencyDialog.dart';

class VoiceRecognitionOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const VoiceRecognitionOverlay({Key? key, required this.onClose})
      : super(key: key);

  @override
  State<VoiceRecognitionOverlay> createState() =>
      _VoiceRecognitionOverlayState();
}

class _VoiceRecognitionOverlayState extends State<VoiceRecognitionOverlay>
    with TickerProviderStateMixin {
  late final VoiceRecognitionViewModel _vm;

  late final AnimationController _borderController;
  late final AnimationController _pulseController;
  late final AnimationController _rippleController;
  bool _handledIntentOnce = false;
  void _log(String message) {
    // Centralized logger for this overlay's navigation/debugging
    // Use debugPrint to avoid truncation of long logs
    debugPrint('[VoiceNav] $message');
  }

  @override
  void initState() {
    super.initState();
    _vm = VoiceRecognitionViewModel();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      lowerBound: 0.98,
      upperBound: 1.04,
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _vm.initialize();
    // Start listening immediately to reduce perceived latency
    _vm.ensurePermissionsAndStart().then((ok) {
      if (!ok && mounted) {
        _showPermissionDialog();
      }
    });
  }

  // Ripple controller follows VM listening state
  void _syncRippleWithState(bool isListening) {
    if (isListening) {
      if (!_rippleController.isAnimating) {
        _rippleController.repeat();
      }
    } else {
      if (_rippleController.isAnimating) {
        _rippleController.stop();
        _rippleController.value = 0.0;
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Microphone permission required'),
          content: const Text(
              'Please enable microphone permission to use voice features.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text('Open settings'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _borderController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VoiceRecognitionViewModel>.value(
      value: _vm,
      child: Consumer<VoiceRecognitionViewModel>(
        builder: (context, vm, _) {
          // side-effect: sync ripple animation
          _syncRippleWithState(vm.isListening);
          final bool showSuggestions = vm.error == null &&
              vm.text.isEmpty &&
              !vm.isListening &&
              !vm.isProcessing &&
              !vm.hasResult;
          // Compact base height for initial overlay
          final double baseHeight = 120;
          final double processingHeight = 170;
          final Size screenSize = MediaQuery.of(context).size;
          final double resultHeight = vm.hasResult
              ? math.min(420.0, screenSize.height * 0.6)
              : baseHeight;
          // Do not shrink; only expand when results require more space
          final double cardHeight = vm.hasResult ? resultHeight : baseHeight;

          final String currentSuggestion = vm.currentSuggestion;

          return Stack(
            children: [
              // Transparent background to allow "floating" look
              Positioned.fill(
                  child: IgnorePointer(ignoring: false, child: Container())),

              // Floating card near bottom center
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: AnimatedBuilder(
                    animation: _borderController,
                    builder: (context, _) {
                      final angle = _borderController.value * 2 * math.pi;
                      // Blurry gradient glow backdrop
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow behind card
                          ImageFiltered(
                            imageFilter:
                                ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                            child: Container(
                              constraints: const BoxConstraints(
                                  minWidth: 290, maxWidth: 380),
                              height: cardHeight + 12,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: RadialGradient(
                                  colors: const [
                                    Color(0x668A2BE2),
                                    Color(0x444169E1),
                                    Color(0x338A2BE2),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.2, 0.5, 0.8, 1.0],
                                ),
                              ),
                            ),
                          ),
                          // Animated gradient border
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            constraints: const BoxConstraints(
                                minWidth: 290, maxWidth: 380),
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: SweepGradient(
                                colors: const [
                                  Color(0xFF8A2BE2),
                                  Color(0xFF4169E1),
                                  Color(0xFFAC4A79),
                                  Color(0xFF8A2BE2),
                                ],
                                stops: const [0.0, 0.45, 0.75, 1.0],
                                transform: GradientRotation(angle),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              height: cardHeight,
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF0F1115).withOpacity(0.94),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              child: _buildCardContent(vm, currentSuggestion),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCardContent(
      VoiceRecognitionViewModel vm, String currentSuggestion) {
    if (vm.isProcessing) {
      return _buildProcessing();
    }
    if (vm.hasResult && vm.intentData != null) {
      return _buildResultsView();
    }
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.auto_awesome, color: Colors.white70, size: 20),
                  SizedBox(width: 6),
                  Text('Vedika AI',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => ClipRect(
                  child: FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                ),
                child: Text(
                  vm.isStarting
                      ? 'Starting…'
                      : (vm.isListening
                          ? 'Listening…'
                          : 'Tap the mic to start'),
                  key: ValueKey<String>(
                    vm.isStarting
                        ? 'starting'
                        : (vm.isListening ? 'listening' : 'idle'),
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              _buildTextOrSuggestion(currentSuggestion),
            ],
          ),
        ),
        _buildMicRippleButton(),
        const SizedBox(width: 6),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () async {
            await _vm.stopService();
            widget.onClose();
          },
        ),
      ],
    );
  }

  Widget _buildTextOrSuggestion(String currentSuggestion) {
    // Never show error text in the overlay card; keep UX clean.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => ClipRect(
        child: FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
      ),
      child: Text(
        _vm.text.isNotEmpty ? _vm.text : currentSuggestion,
        key: ValueKey<String>(
            _vm.text.isNotEmpty ? _vm.text : currentSuggestion),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white.withOpacity(0.85),
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildMicRippleButton() {
    const double micSize = 44;
    return GestureDetector(
      onTap: () async {
        if (_vm.isStarting) return;
        if (_vm.isListening) {
          await _vm.stopListening(sendFinalIfAny: true);
        } else {
          final ok = await _vm.startListening();
          if (!ok) _showPermissionDialog();
        }
      },
      child: SizedBox(
        width: 70,
        height: 70,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_vm.isListening)
              ...List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _rippleController,
                  builder: (context, _) {
                    final t = (_rippleController.value + i / 3) % 1.0;
                    final scale = 1.0 + t * 1.4;
                    final opacity = (1.0 - t) * 0.35;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: micSize,
                        height: micSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF8A2BE2).withOpacity(opacity),
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ScaleTransition(
              scale: _pulseController,
              child: Container(
                width: micSize,
                height: micSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Color(0xFF8A2BE2), Color(0xFF4169E1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcIn,
                    child: Icon(
                      _vm.isListening ? Icons.mic : Icons.mic_none,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessing() {
    final int dots = (((_pulseController.value * 3).floor() % 3) + 1);
    final String processingText = 'Processing' + ('.' * dots);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vedika AI header with circular loading around icon
              Row(
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF8A2BE2).withOpacity(0.85)),
                          ),
                        ),
                        const Icon(Icons.auto_awesome,
                            color: Colors.white70, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Vedika AI',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 8),
              // Animated typing dots for Processing...
              Text(
                processingText,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              if (_vm.text.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  '"${_vm.text}"',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.85), fontSize: 13),
                ),
              ],
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () async {
            await _vm.stopService();
            widget.onClose();
          },
        ),
      ],
    );
  }

  Widget _buildResultsView() {
    final intent = (_vm.intentData?['intent'] ?? '').toString();
    final rawResults = _vm.intentData?['results'];
    final List<dynamic> results =
        rawResults is List ? List<dynamic>.from(rawResults) : <dynamic>[];
    final String summary = (_vm.intentData?['summary'] ?? '').toString();
    final List<dynamic> suggestions = (_vm.intentData?['suggestions'] is List)
        ? List<dynamic>.from(_vm.intentData?['suggestions'])
        : const [];
    final bool isMedicalAdvice = intent.toUpperCase() == 'MEDICAL_ADVICE';

    return IntentResultsView(
      userText: _vm.text,
      isListening: _vm.isListening,
      onMicTap: () async {
        if (_vm.isStarting) return;
        _vm.hasResult = false;
        _vm.intentData = null;
        final ok = await _vm.startListening();
        if (!ok) _showPermissionDialog();
      },
      onClose: () async {
        await _vm.stopService();
        if (mounted) widget.onClose();
      },
      intent: intent,
      results: results,
      suggestions: suggestions,
      summary: summary,
      isMedicalAdvice: isMedicalAdvice,
      onActionPressed: (resultItem, a) async {
        final outcome = await handleIntentAction(
          context,
          resultItem,
          a,
          (route, {arguments}) => _pushNamed(route, arguments: arguments),
        );
        if (outcome.closeOverlay) {
          await _vm.stopService();
          if (mounted) {
            widget.onClose();
            if (outcome.showEmergencyDialog) {
              // Show EmergencyDialog after the overlay closes
              Future.delayed(const Duration(milliseconds: 120), () {
                showDialog(
                  context: context,
                  builder: (_) => EmergencyDialog(
                    doctorNumber: outcome.doctorNumber ?? '',
                    ambulanceNumber: outcome.ambulanceNumber ?? '',
                    bloodBankNumber: outcome.bloodBankNumber ?? '',
                  ),
                );
              });
            } else if (outcome.route != null) {
              // Defer navigation slightly to allow overlay to close cleanly
              Future.delayed(const Duration(milliseconds: 120), () {
                _pushNamed(outcome.route!, arguments: outcome.arguments);
              });
            }
          }
        }
      },
    );
  }

  void _pushNamed(String route, {Object? arguments}) {
    try {
      _log('pushNamed route=$route argsType=${arguments?.runtimeType}');
      Future.microtask(() {
        final ctx = navigatorKey.currentContext;
        if (ctx != null) {
          Navigator.of(ctx).pushNamed(route, arguments: arguments);
          return;
        }
        final navState = navigatorKey.currentState;
        if (navState != null) {
          navState.pushNamed(route, arguments: arguments);
          return;
        }
        final navigator = Navigator.of(context, rootNavigator: true);
        navigator.pushNamed(route, arguments: arguments);
      });
    } catch (e, st) {
      _log('Navigator.pushNamed failed for route=$route error=$e\n$st');
    }
  }
}
