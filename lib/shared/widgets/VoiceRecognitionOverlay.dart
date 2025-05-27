import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:developer' as developer;
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:vedika_healthcare/shared/services/VoiceCommandService.dart';
import 'package:translator/translator.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:logger/logger.dart';

class VoiceRecognitionOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const VoiceRecognitionOverlay({Key? key, required this.onClose}) : super(key: key);

  @override
  _VoiceRecognitionOverlayState createState() => _VoiceRecognitionOverlayState();
}

class _VoiceRecognitionOverlayState extends State<VoiceRecognitionOverlay> with TickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  final GoogleTranslator _translator = GoogleTranslator();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true
    ),
  );
  bool _isListening = false;
  bool _isProcessing = false;
  String _lastWords = '';
  String _displayText = '';
  bool _isInitialized = false;
  String _currentLocaleId = 'en_US';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _pulseAnimation;
  late AnimationController _suggestionController;
  int _currentSuggestionIndex = 0;
  String? _errorMessage;
  bool _showError = false;
  Timer? _retryTimer;
  bool _isDisposed = false;
  bool _hasPermission = false;

  final List<String> _suggestions = [
    '"Emergency help"',
    '"Call doctor emergency"',
    '"Call ambulance emergency"',
    '"Call blood bank emergency"',
    '"Book an ambulance for emergency"',
    '"Find the nearest hospital"',
    '"Check blood bank availability"',
    '"Schedule a doctor appointment"',
    '"Get emergency contact numbers"',
    '"Find nearby pharmacies"',
    '"Book a lab test"',
    '"Get ambulance rates"',
    '"Find specialist doctors"',
    '"Check hospital facilities"',
    '"Show dental care products"',
    '"Open heart care category"',
    '"Go to baby care section"',
    '"Show women care products"',
    '"Open digital health tracker"',
    '"Go back"',
    '"Close overlay"',
    '"Return to previous screen"'
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkPermissions();
  }

  @override
  void didUpdateWidget(VoiceRecognitionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isInitialized) {
      _initSpeech();
    } else if (!_isListening) {
      _startListening();
    }
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _suggestionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentSuggestionIndex = (_currentSuggestionIndex + 1) % _suggestions.length;
        });
        _suggestionController.reset();
        _suggestionController.forward();
      }
    });

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _suggestionController.forward();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _retryTimer?.cancel();
    _animationController.dispose();
    _suggestionController.dispose();
    _stopListening();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    try {
      _logger.i('Starting permission check...');
      
      // Check microphone permission
      var status = await Permission.microphone.status;
      _logger.d('Initial microphone permission status: $status');
      
      if (!status.isGranted) {
        _logger.i('Requesting microphone permission...');
        status = await Permission.microphone.request();
        _logger.d('Microphone permission request result: $status');
      }
      
      // Check device info
      if (Theme.of(context).platform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        _logger.i('Device Info:', error: {
          'brand': androidInfo.brand,
          'manufacturer': androidInfo.manufacturer,
          'model': androidInfo.model,
          'androidVersion': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
        });
        
        final isRealme = androidInfo.brand.toLowerCase().contains('realme');
        _logger.i('Is Realme device: $isRealme');
        
        if (isRealme) {
          _logger.w('Realme device detected - showing special instructions');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'For Realme devices: Please ensure "Auto-start" and "Background pop-up" permissions are enabled in device settings.',
                  style: TextStyle(color: Colors.white),
                ),
                duration: Duration(seconds: 5),
                backgroundColor: Colors.blue,
              ),
            );
          }
        }
      }

      if (status.isGranted) {
        _logger.i('Microphone permission granted');
        _hasPermission = true;
        _initSpeech();
      } else {
        _logger.e('Microphone permission denied');
        if (mounted) {
          setState(() {
            _errorMessage = 'Microphone permission is required for voice recognition';
            _showError = true;
          });
        }
      }
    } catch (e, stackTrace) {
      _logger.e('Error checking permissions', error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _errorMessage = 'Error checking permissions: $e';
          _showError = true;
        });
      }
    }
  }

  Future<void> _initSpeech() async {
    if (_isDisposed || !_hasPermission) {
      _logger.w('Cannot initialize speech: disposed=$_isDisposed, hasPermission=$_hasPermission');
      return;
    }

    try {
      _logger.i('Starting speech initialization...');
      if (mounted) {
        setState(() {
          _isListening = false;
          _isInitialized = false;
          _isProcessing = true;
        });
      }

      _retryTimer?.cancel();

      if (_speechToText.isListening) {
        _logger.i('Stopping existing listening session...');
        await _speechToText.stop();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      _logger.i('Initializing speech recognition...');
      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          if (_isDisposed) return;
          _logger.e('Speech recognition error', error: {
            'errorMsg': error.errorMsg,
            'permanent': error.permanent,
          });
          
          if (error.errorMsg == 'error_language_unavailable') {
            _handleLanguageUnavailable();
          }
          
          if (mounted) {
            setState(() {
              _isListening = false;
              _errorMessage = 'Error: ${error.errorMsg}';
              _showError = true;
            });
          }

          Future.delayed(const Duration(milliseconds: 300), () {
            if (!_isDisposed && mounted) {
              _startListening();
            }
          });
        },
        onStatus: (status) {
          if (_isDisposed) return;
          _logger.d('Speech recognition status: $status');
          
          if (mounted) {
            setState(() {
              switch (status) {
                case 'listening':
                  _isListening = true;
                  break;
                case 'done':
                case 'notListening':
                case 'doneNoResult':
                  _isListening = false;
                  break;
                default:
                  _isListening = false;
              }
            });
          }
        },
        debugLogging: true,
      );
      
      _logger.i('Speech recognition initialized: $_isInitialized');
      
      if (_isInitialized && !_isDisposed) {
        // Check available locales
        final locales = await _speechToText.locales();
        _logger.i('Available locales: ${locales.map((e) => e.localeId).join(', ')}');
        
        // Try to find a suitable locale
        String? selectedLocale;
        if (locales.any((locale) => locale.localeId == 'en_US')) {
          selectedLocale = 'en_US';
        } else if (locales.any((locale) => locale.localeId == 'en_IN')) {
          selectedLocale = 'en_IN';
        } else if (locales.isNotEmpty) {
          selectedLocale = locales.first.localeId;
        }
        
        if (selectedLocale != null) {
          _currentLocaleId = selectedLocale;
          _logger.i('Selected locale: $_currentLocaleId');
        } else {
          _logger.w('No suitable locale found, using default');
        }

        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
          
          await Future.delayed(const Duration(milliseconds: 300));
          if (!_isDisposed) {
            _startListening();
          }
        }
      } else {
        _logger.e('Failed to initialize speech recognition');
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to initialize speech recognition';
            _showError = true;
            _isProcessing = false;
          });
        }
      }
    } catch (e, stackTrace) {
      _logger.e('Error initializing speech recognition', error: e, stackTrace: stackTrace);
      if (mounted && !_isDisposed) {
        setState(() {
          _errorMessage = 'Error initializing speech recognition: $e';
          _showError = true;
          _isInitialized = false;
          _isProcessing = false;
          _isListening = false;
        });
      }
    }
  }

  Future<void> _handleLanguageUnavailable() async {
    _logger.w('Handling language unavailable error');
    try {
      final locales = await _speechToText.locales();
      _logger.i('Available locales: ${locales.map((e) => e.localeId).join(', ')}');
      
      // Try to find a suitable locale
      String? selectedLocale;
      if (locales.any((locale) => locale.localeId == 'en_IN')) {
        selectedLocale = 'en_IN';
      } else if (locales.any((locale) => locale.localeId == 'en_US')) {
        selectedLocale = 'en_US';
      } else if (locales.isNotEmpty) {
        selectedLocale = locales.first.localeId;
      }
      
      if (selectedLocale != null) {
        _currentLocaleId = selectedLocale;
        _logger.i('Switched to locale: $_currentLocaleId');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Switched to ${_currentLocaleId} for speech recognition'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        _logger.e('No suitable locale found');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Speech recognition is not available in your language'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      _logger.e('Error handling language unavailable', error: e);
    }
  }

  Future<void> _startListening() async {
    if (!_isInitialized || !mounted || _isProcessing || _isDisposed) {
      _logger.w('Cannot start listening', error: {
        'initialized': _isInitialized,
        'mounted': mounted,
        'processing': _isProcessing,
        'disposed': _isDisposed
      });
      return;
    }

    try {
      _logger.i('Starting listening session...');
      if (mounted) {
        setState(() {
          _isProcessing = true;
          _isListening = false;
          _errorMessage = null;
          _showError = false;
        });
      }
      
      if (_speechToText.isListening) {
        _logger.i('Stopping existing listening session...');
        await _speechToText.stop();
        await Future.delayed(const Duration(milliseconds: 300));
      }

      if (!_speechToText.isListening && !_isDisposed) {
        _logger.i('Starting new listening session');
        await _speechToText.listen(
          onResult: (result) {
            _logger.i('Speech result received', error: {
              'recognizedWords': result.recognizedWords,
              'confidence': result.confidence,
              'finalResult': result.finalResult,
            });
            
            if (mounted && !_isDisposed) {
              setState(() {
                _lastWords = result.recognizedWords;
                _displayText = result.recognizedWords;
              });
              
              if (_lastWords.isNotEmpty && result.finalResult) {
                VoiceCommandService.handleVoiceCommand(context, _lastWords, (error) {
                  if (mounted && !_isDisposed) {
                    setState(() {
                      _errorMessage = error;
                      _showError = true;
                    });
                    Future.delayed(const Duration(seconds: 3), () {
                      if (mounted && !_isDisposed) {
                        setState(() {
                          _showError = false;
                          _errorMessage = null;
                        });
                      }
                    });
                  }
                });
              }
            }
          },
          localeId: _currentLocaleId,
          partialResults: true,
          onDevice: true,
          cancelOnError: false,
          listenMode: ListenMode.confirmation,
          onSoundLevelChange: (level) {
            _logger.v('Sound level: $level');
          },
        );
        
        if (mounted && !_isDisposed) {
          setState(() {
            _isListening = true;
            _isProcessing = false;
          });
          _logger.i('Listening session started successfully');
        }
      }
    } catch (e, stackTrace) {
      _logger.e('Error starting speech recognition', error: e, stackTrace: stackTrace);
      if (mounted && !_isDisposed) {
        setState(() {
          _isListening = false;
          _errorMessage = 'Error starting speech recognition: $e';
          _showError = true;
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _stopListening() async {
    if (_isProcessing || _isDisposed) return;
    
    try {
      _isProcessing = true;
      if (_speechToText.isListening) {
        await _speechToText.stop();
      }
      if (mounted && !_isDisposed) {
        setState(() {
          _isListening = false;
          _isProcessing = false;
        });
      }
    } catch (e) {
      developer.log('Error stopping speech recognition: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _isListening = false;
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8A2BE2),
            Color(0xFF4169E1),
            Color(0xFFAC4A79),
            Color(0xFF8A2BE2),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Animated microphone icon with pulsing rings
                GestureDetector(
                  onTap: () {
                    if (!_isListening) {
                      _startListening();
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulsing rings
                      ...List.generate(3, (index) {
                        return AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_pulseAnimation.value * 0.3 * (index + 1)),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.3 - (index * 0.1)),
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                      // Main microphone icon
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF8A2BE2),
                                    Color(0xFF4169E1),
                                    Color(0xFFAC4A79),
                                    Color(0xFF8A2BE2),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.mic,
                                size: 35,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Status text with modern typography
                Text(
                  _isProcessing ? 'Processing...' : (_isListening ? 'Listening...' : 'Tap the mic to start speaking'),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                if (!_isListening && !_isProcessing)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Tap the microphone icon to start listening',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                // Error message
                if (_showError && _errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // Spoken text or suggestions
                if (_displayText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _displayText,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  AnimatedBuilder(
                    animation: _suggestionController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _suggestionController.value,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - _suggestionController.value)),
                          child: Text(
                            _suggestions[_currentSuggestionIndex],
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 32),
                // Close button
                _buildActionButton(
                  icon: Icons.close,
                  onPressed: () {
                    _stopListening();
                    widget.onClose();
                  },
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.8),
                  color,
                ],
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
} 