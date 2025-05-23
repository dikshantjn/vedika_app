import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:developer' as developer;
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:vedika_healthcare/shared/services/VoiceCommandService.dart';
import 'package:translator/translator.dart';

class VoiceRecognitionOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const VoiceRecognitionOverlay({Key? key, required this.onClose}) : super(key: key);

  @override
  _VoiceRecognitionOverlayState createState() => _VoiceRecognitionOverlayState();
}

class _VoiceRecognitionOverlayState extends State<VoiceRecognitionOverlay> with TickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  final GoogleTranslator _translator = GoogleTranslator();
  bool _isListening = false;
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
  List<LocaleName> _supportedLocales = [];
  bool _isLoadingLanguages = true;

  // Language options with their display names and codes
  final Map<String, Map<String, String>> _languageNames = {
    'en_US': {'name': 'English', 'code': 'en'},
    'hi_IN': {'name': 'हिंदी', 'code': 'hi'},
    'mr_IN': {'name': 'मराठी', 'code': 'mr'},
    'gu_IN': {'name': 'ગુજરાતી', 'code': 'gu'},
  };

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
    _initSpeech();
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
    _animationController.dispose();
    _suggestionController.dispose();
    _stopListening();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          developer.log('Speech recognition error: ${error.errorMsg}');
          developer.log('Error details: ${error.permanent ? 'Permanent' : 'Temporary'}');
          if (mounted) {
            setState(() {
              _isListening = false;
              _errorMessage = 'Error: ${error.errorMsg}';
              _showError = true;
            });
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _startListening();
              }
            });
          }
        },
        onStatus: (status) {
          developer.log('Speech recognition status: $status');
          if (status == 'done' || status == 'notListening' || status == 'doneNoResult') {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _startListening();
              }
            });
          }
        },
        debugLogging: true,
      );
      
      if (_isInitialized) {
        final locales = await _speechToText.locales();
        developer.log('Available locales: ${locales.map((e) => e.localeId).join(', ')}');
        
        if (mounted) {
          setState(() {
            _supportedLocales = locales;
            _isLoadingLanguages = false;
            
            // Try to find a supported language from our preferred list
            final preferredLocale = locales.firstWhere(
              (locale) => _languageNames.containsKey(locale.localeId),
              orElse: () => locales.first,
            );
            _currentLocaleId = preferredLocale.localeId;
            developer.log('Selected locale: $_currentLocaleId');
          });
          
          _startListening();
        }
      }
    } catch (e) {
      developer.log('Error initializing speech recognition: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error initializing speech recognition';
          _showError = true;
          _isLoadingLanguages = false;
        });
      }
    }
  }

  Future<void> _startListening() async {
    if (!_isInitialized || !mounted) return;

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: _currentLocaleId,
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 10),
        partialResults: true,
        onDevice: true,
        cancelOnError: false,
        listenMode: ListenMode.confirmation,
        onSoundLevelChange: (level) {
          developer.log('Sound level: $level');
        },
      );
      if (mounted) {
        setState(() {
          _isListening = true;
          _showError = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      developer.log('Error starting speech recognition: $e');
      if (mounted) {
        setState(() {
          _isListening = false;
          _errorMessage = 'Error starting speech recognition';
          _showError = true;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _startListening();
          }
        });
      }
    }
  }

  void _onSpeechResult(result) async {
    if (mounted) {
      setState(() {
        _lastWords = result.recognizedWords;
        _displayText = result.recognizedWords; // Keep original text for display
      });
      
      developer.log('Recognized words: $_lastWords');
      developer.log('Confidence: ${result.confidence}');
      developer.log('Final: ${result.finalResult}');
      
      if (_lastWords.isNotEmpty && result.finalResult) {
        String textToProcess = _lastWords;
        
        // Only translate if not English
        if (_currentLocaleId != 'en_US') {
          try {
            final translation = await _translator.translate(
              _lastWords,
              from: _languageNames[_currentLocaleId]!['code']!,
              to: 'en'
            );
            textToProcess = translation.text;
            developer.log('Translated text: $textToProcess');
          } catch (e) {
            developer.log('Translation error: $e');
            textToProcess = _lastWords;
          }
        }

        VoiceCommandService.handleVoiceCommand(context, textToProcess, (error) {
          if (mounted) {
            setState(() {
              _errorMessage = error;
              _showError = true;
            });
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _showError = false;
                  _errorMessage = null;
                });
              }
            });
          }
        });
      }
      
      if (!_speechToText.isListening) {
        _startListening();
      }
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speechToText.stop();
      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }
    } catch (e) {
      developer.log('Error stopping speech recognition: $e');
    }
  }

  void _changeLanguage(String localeId) {
    if (!_supportedLocales.any((locale) => locale.localeId == localeId)) {
      setState(() {
        _errorMessage = 'This language is not supported on your device';
        _showError = true;
      });
      return;
    }

    setState(() {
      _currentLocaleId = localeId;
      _displayText = ''; // Clear display text when changing language
    });
    _stopListening().then((_) {
      _startListening();
    });
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
                // Language selector
                if (!_isLoadingLanguages)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _languageNames.entries.map((entry) {
                          final isSupported = _supportedLocales.any((locale) => locale.localeId == entry.key);
                          final isSelected = entry.key == _currentLocaleId;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: isSupported ? () => _changeLanguage(entry.key) : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  entry.value['name']!,
                                  style: GoogleFonts.poppins(
                                    color: isSupported ? Colors.white : Colors.white.withOpacity(0.3),
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  )
                else
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                const SizedBox(height: 20),
                // Animated microphone icon with pulsing rings
                Stack(
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
                const SizedBox(height: 32),
                // Status text with modern typography
                Text(
                  _isListening ? 'Listening...' : 'Start speaking',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
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