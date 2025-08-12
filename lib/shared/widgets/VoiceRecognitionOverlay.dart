import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/shared/services/VoiceCommandService.dart';
import 'package:vedika_healthcare/shared/services/native_speech.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceRecognitionOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const VoiceRecognitionOverlay({Key? key, required this.onClose}) : super(key: key);

  @override
  State<VoiceRecognitionOverlay> createState() => _VoiceRecognitionOverlayState();
}

class _VoiceRecognitionOverlayState extends State<VoiceRecognitionOverlay>
    with TickerProviderStateMixin {
  bool _isListening = false;
  bool _isStarting = false;
  String _text = '';
  String? _error;
  DateTime? _lastEventTime;

  late final AnimationController _borderController;
  late final AnimationController _pulseController;
  StreamSubscription? _nativeSub;

  // Suggestions cycling
  final List<String> _suggestions = const [
    '"Emergency help"',
    '"Call doctor emergency"',
    '"Call ambulance emergency"',
    '"Call blood bank emergency"',
    '"Book an ambulance for emergency"',
    '"Find the nearest hospital"',
    '"Check blood bank availability"',
    '"Schedule a doctor appointment"',
    '"order medicine"',
  ];
  int _suggestionIndex = 0;
  Timer? _suggestionTimer;
  Timer? _clearTextTimer;

  @override
  void initState() {
    super.initState();
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

    // Cycle suggestions
    _startSuggestionTimer();

    // Start native continuous recognizer for smoother experience
    _nativeSub = NativeSpeech.events().listen((event) {
      final type = event['type'] as String?;
      final now = DateTime.now();
      final timeSinceLastEvent = _lastEventTime != null 
          ? now.difference(_lastEventTime!) 
          : Duration.zero;
      _lastEventTime = now;

      if (type == 'status') {
        final status = event['status'] as String?;
        if (!mounted) return;
        setState(() {
          _isStarting = status == 'starting';
          _isListening = status == 'listening' || status == 'ready';
          _error = null;
        });
      } else if (type == 'result') {
        final text = (event['text'] ?? '') as String;
        final isFinal = (event['final'] ?? false) as bool;
        if (!mounted) return;
        // Pause suggestions while showing recognized text
        _stopSuggestionTimer();
        setState(() => _text = text);
        // Keep recognized text visible for 5 seconds since the last update
        _clearTextTimer?.cancel();
        final shownText = text;
        _clearTextTimer = Timer(const Duration(seconds: 5), () {
          if (!mounted) return;
          if (_text == shownText) {
            setState(() => _text = '');
            _startSuggestionTimer();
          }
        });
        if (isFinal && text.isNotEmpty) {
          VoiceCommandService.handleVoiceCommand(context, text, (_) {});
        }
      } else if (type == 'error') {
        final err = (event['error'] ?? '').toString();
        if (!mounted) return;
        setState(() {
          _error = err;
          _isListening = false;
        });
      }
    });
    _ensurePermissionsAndStart();
  }

  void _startSuggestionTimer() {
    _suggestionTimer?.cancel();
    _suggestionTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        _suggestionIndex = (_suggestionIndex + 1) % _suggestions.length;
      });
    });
  }

  void _stopSuggestionTimer() {
    _suggestionTimer?.cancel();
    _suggestionTimer = null;
  }

  Future<void> _ensurePermissionsAndStart() async {
    final mic = await Permission.microphone.request();
    if (mic.isGranted) {
      // Notification permission for Android 13+
      final notif = await Permission.notification.status;
      if (notif.isDenied) {
        await Permission.notification.request();
      }
      if (mounted) setState(() { _isStarting = true; _error = null; });
      await NativeSpeech.start();
      } else {
      setState(() {
        _error = 'Microphone permission is required';
        _isListening = false;
        _isStarting = false;
      });
    }
  }

  @override
  void dispose() {
    _borderController.dispose();
    _pulseController.dispose();
    _nativeSub?.cancel();
    _stopSuggestionTimer();
    _clearTextTimer?.cancel();
    NativeSpeech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showSuggestions = _error == null && _text.isEmpty;
    final double cardHeight = _error != null
        ? 130
        : (showSuggestions ? 125 : 110);

    final String currentSuggestion = 'say: ${_suggestions[_suggestionIndex]}';

    return Stack(
      children: [
        // Transparent background to allow "floating" look
        Positioned.fill(child: IgnorePointer(ignoring: false, child: Container())),

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
                      imageFilter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 280, maxWidth: 360),
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
                    Container(
                      constraints: const BoxConstraints(minWidth: 280, maxWidth: 360),
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
                      child: Container(
                        height: cardHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1115).withOpacity(0.94),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            // Mic button with gradient icon only
                            GestureDetector(
                              onTap: () async {
                                if (_isStarting) return; // ignore taps while starting
                                if (_isListening) {
                                  await NativeSpeech.stop();
                                  if (!mounted) return;
                                  setState(() => _isListening = false);
                                } else {
                                  await _ensurePermissionsAndStart();
                                }
                              },
                              child: ScaleTransition(
                                scale: _pulseController,
                                child: Container(
                                  width: 44,
                                  height: 44,
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
                                        _isListening ? Icons.mic : Icons.mic_none,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Text(
                                      _isStarting
                                          ? 'Starting…'
                                          : (_isListening ? 'Listening…' : 'Tap the mic to start'),
                                      key: ValueKey(_isListening),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, animation) => FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0.1, 0),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    ),
                                    child: Text(
                                      _error != null
                                          ? _error!
                                          : (_text.isNotEmpty ? _text : currentSuggestion),
                                      key: ValueKey<String>(_error ?? (_text.isNotEmpty ? _text : currentSuggestion)),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: _error != null
                                            ? Colors.redAccent
                                            : Colors.white.withOpacity(0.85),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white70),
                              onPressed: () async {
                                await NativeSpeech.stop();
                                widget.onClose();
                              },
                            ),
                          ],
                        ),
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
  }
} 