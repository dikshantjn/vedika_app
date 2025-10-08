import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/VedikaAI/presentation/viewmodel/AIViewModel.dart';
import 'package:vedika_healthcare/features/vedikaAI/presentation/widgets/AIMessageBubble.dart';
import 'package:vedika_healthcare/features/VedikaAI/presentation/widgets/AIResponseCard.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vedika_healthcare/features/VedikaAI/data/models/AIChatResponse.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/view/medicineOrderScreen.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';

class AIChatScreen extends StatefulWidget {
  final String initialQuery;

  const AIChatScreen({
    Key? key,
    required this.initialQuery,
  }) : super(key: key);

  // Open AIChat inside MainScreen to ensure bottom navigation is visible
  static Future<void> open(BuildContext context, {String initialQuery = ''}) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.aiChat,
      arguments: {
        'initialQuery': initialQuery,
      },
    );
  }

  @override
  _AIChatScreenState createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _shimmerController;
  late AnimationController _sendButtonGradientController;
  String? _extractedText;
  String? _selectedFilePath;
  bool _isProcessing = false;
  bool _isPdf = false;
  bool _isPreviewExpanded = false;
  String? _lastSentFilePath;
  bool _lastSentIsPdf = false;
  int? _editingMessageIndex;
  final Map<int, TextEditingController> _editControllers = {};
  int _lastHistoryLength = 0;
  bool _hasAutoScrolledOnce = false;

  // Speech to text
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';
  late AnimationController _micGlowController;
  late AnimationController _borderGradientController;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _handleInitialQuery();
    _speech = stt.SpeechToText();
    _micGlowController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
      lowerBound: 0.8,
      upperBound: 1.2,
    );
    _borderGradientController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
  }

  void _initializeControllers() {
    _shimmerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat();
    
    _sendButtonGradientController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
  }

  void _handleInitialQuery() {
    if (widget.initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AIViewModel>().interpretSymptoms(widget.initialQuery);
        // Add a small delay to ensure the message is added before scrolling
        Future.delayed(Duration(milliseconds: 100), () {
          _scrollToBottom();
        });
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _messageController.dispose();
    _scrollController.dispose();
    _shimmerController.dispose();
    _sendButtonGradientController.dispose();
    _micGlowController.dispose();
    _borderGradientController.dispose();
    _editControllers.values.forEach((controller) => controller.dispose());
    if (_speech.isListening) {
      _speech.stop();
    }
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onMicButtonPressed() async {
    if (!_isListening) {
      // Start listening
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if (!_isDisposed && mounted) {
            setState(() => _isListening = false);
            _borderGradientController.stop();
            }
          }
        },
        onError: (val) {
          if (!_isDisposed && mounted) {
          setState(() => _isListening = false);
          _borderGradientController.stop();
          }
        },
      );
      if (available) {
        try {
        setState(() {
          _isListening = true;
          _lastWords = '';
        });
        _borderGradientController.repeat();
          
          await _speech.listen(
          onResult: (val) {
              if (!_isDisposed && mounted) {
            setState(() {
              _lastWords = val.recognizedWords;
              _messageController.text = _lastWords;
              _messageController.selection = TextSelection.fromPosition(
                TextPosition(offset: _messageController.text.length),
              );
            });
              }
          },
          localeId: 'en_IN',
            cancelOnError: false,
          partialResults: true,
        );
        } catch (e) {
          if (!_isDisposed && mounted) {
            setState(() {
              _isListening = false;
            });
            _borderGradientController.stop();
          }
        }
      }
    } else {
      // Stop listening
      await _speech.stop();
      if (!_isDisposed && mounted) {
        setState(() {
          _isListening = false;
          _lastWords = '';
        });
      _borderGradientController.stop();
      }
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: ColorPalette.primaryColor),
              title: Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final ImagePicker picker = ImagePicker();
                try {
                  final XFile? image = await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    await _processFile(image.path);
                  }
                } catch (e) {
                  print('Error taking photo: $e');
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: ColorPalette.primaryColor),
              title: Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final ImagePicker picker = ImagePicker();
                try {
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    await _processFile(image.path);
                  }
                } catch (e) {
                  print('Error picking image: $e');
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: ColorPalette.primaryColor),
              title: Text('Choose PDF'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );
                  if (result != null && result.files.isNotEmpty) {
                    final file = result.files.first;
                    if (file.path != null) {
                      await _processFile(file.path!);
                    }
                  }
                } catch (e) {
                  print('Error picking PDF: $e');
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.medical_services, color: ColorPalette.primaryColor),
              title: Text('Choose from Health Records'),
              onTap: () async {
                Navigator.pop(context);
                final ImagePicker picker = ImagePicker();
                try {
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    await _processFile(image.path);
                  }
                } catch (e) {
                  print('Error picking health record: $e');
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _processFile(String filePath) async {
    try {
      setState(() {
        _isProcessing = true;
        _selectedFilePath = filePath;
        _isPdf = filePath.toLowerCase().endsWith('.pdf');
      });

      if (_isPdf) {
        // TODO: Implement PDF text extraction
        // For now, just set a placeholder text
        setState(() {
          _extractedText = "PDF content will be extracted here";
          _isProcessing = false;
        });
      } else {
        final inputImage = InputImage.fromFilePath(filePath);
        final textRecognizer = TextRecognizer();
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        
        String extractedText = recognizedText.text.replaceAll('\n', ' ').trim();
        print('Extracted Text: $extractedText');
        
        setState(() {
          _extractedText = extractedText;
          _isProcessing = false;
        });
        
        textRecognizer.close();
      }
    } catch (e) {
      print('Error processing file: $e');
      setState(() {
        _isProcessing = false;
        _selectedFilePath = null;
        _extractedText = null;
        _isPdf = false;
      });
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Error',
        desc: 'Failed to process file. Please try again.',
        btnOkColor: ColorPalette.primaryColor,
        btnOkOnPress: () {},
      ).show();
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      // Get the user's original prompt
      String userPrompt = _messageController.text;
      
      // Prepare text for API (include extracted text if exists)
      String apiText = userPrompt;
      if (_extractedText != null) {
        apiText = '${userPrompt} $_extractedText';
      }
      
      // Send to API with extracted text, but store original prompt and file for display
      context.read<AIViewModel>().interpretSymptoms(
        apiText,  // This goes to API
        displayMessage: userPrompt,  // This is shown in chat
        filePath: _selectedFilePath,  // This is shown in chat
        isPdf: _isPdf,
      );
      
      // Clear the input
      _messageController.clear();
      setState(() {
        _extractedText = null;
        _selectedFilePath = null;
        _isPdf = false;
      });
      
      // Scroll to bottom after a short delay to ensure the message is added
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final bool isUser = message['type'] == 'user';
    final String messageText = isUser ? (message['displayMessage'] ?? '') : message['response'].message;
    final String? filePath = message['filePath'];
    final bool isPdf = message['isPdf'] ?? false;
    final bool hasFile = isUser && filePath != null;
    final bool isPrescriptionAnalysis = message['isPrescriptionAnalysis'] ?? false;
    final int messageIndex = context.read<AIViewModel>().chatHistory.indexOf(message);
    final bool isEditing = _editingMessageIndex == messageIndex;

    // Initialize edit controller if not exists
    if (!_editControllers.containsKey(messageIndex)) {
      _editControllers[messageIndex] = TextEditingController(text: messageText);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          SizedBox(width: 8),
          Flexible(
            child: GestureDetector(
              onLongPress: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.copy, color: ColorPalette.primaryColor),
                          title: Text('Copy Message'),
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: messageText));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Message copied to clipboard'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            Navigator.pop(context);
                          },
                        ),
                        if (isUser) ListTile(
                          leading: Icon(Icons.edit, color: ColorPalette.primaryColor),
                          title: Text('Edit Message'),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _editingMessageIndex = messageIndex;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                  color: isEditing ? Colors.white : (isUser ? ColorPalette.primaryColor : Colors.white),
                borderRadius: BorderRadius.circular(16),
                  border: isEditing ? Border.all(
                    color: ColorPalette.primaryColor,
                    width: 1.5,
                  ) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasFile)
                    Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ColorPalette.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          if (isPdf)
                            Container(
                              decoration: BoxDecoration(
                                color: ColorPalette.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.picture_as_pdf,
                                      color: ColorPalette.primaryColor,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'PDF',
                                      style: TextStyle(
                                        color: ColorPalette.primaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(filePath!),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                    ),
                  if (messageText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(12),
                        child: isEditing
                            ? Row(
                                children: [
                                  Expanded(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: TextField(
                                        controller: _editControllers[messageIndex],
                                        decoration: InputDecoration(
                                          hintText: 'Edit message...',
                                          border: InputBorder.none,
                                                                                  contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        ),
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                        ),
                                        maxLines: null,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          colors: [
                                            Color(0xFF8A2BE2),
                                            Color(0xFF4169E1),
                                            Color(0xFFAC4A79),
                                            Color(0xFF8A2BE2),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds);
                                      },
                                      child: Icon(Icons.send, color: Colors.white, size: 24),
                                    ),
                                    onPressed: () {
                                      if (_editControllers[messageIndex]?.text.trim().isNotEmpty ?? false) {
                                        context.read<AIViewModel>().editMessage(
                                          messageIndex,
                                          _editControllers[messageIndex]!.text.trim(),
                                        );
                                        setState(() {
                                          _editingMessageIndex = null;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              )
                            : Text(
                        messageText,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  if (isPrescriptionAnalysis)
                    Padding(
                      padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ColorPalette.primaryColor,
                              ColorPalette.primaryColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: ColorPalette.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MedicineOrderScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(25),
                            child: const Center(
                              child: Text(
                                "Order Medicine",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xFF8A2BE2),
            Color(0xFF4169E1),
            Color(0xFFAC4A79),
            Color(0xFF8A2BE2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _buildChatList(),
                ),
                _buildMessageInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: ColorPalette.primaryColor),
            onPressed: () {
              if (MainScreenNavigator.instance.canGoBack) {
                MainScreenNavigator.instance.goBack();
              } else {
                MainScreenNavigator.instance.navigateToIndex(0);
              }
            },
          ),
          Expanded(
            child: Row(
              children: [
                _buildAIAvatar(),
                SizedBox(width: 12),
                _buildAITitle(),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: ColorPalette.primaryColor),
            onPressed: () => context.read<AIViewModel>().clearChat(),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAvatar() {
    return Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ColorPalette.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/ai.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
    );
  }

  Widget _buildAITitle() {
    return ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [
                    Color(0xFF8A2BE2),
                    Color(0xFF4169E1),
                    Color(0xFFAC4A79),
                    Color(0xFF8A2BE2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Text(
                'Vedika AI Assistant',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
    );
  }

  Widget _buildChatList() {
    return Consumer<AIViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.chatHistory.isEmpty) {
          return _buildEmptyState();
        }
        // Ensure we auto-scroll to the latest message when history exists or grows
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed && mounted && _scrollController.hasClients) {
            final int currentLength = viewModel.chatHistory.length + (viewModel.isLoading ? 1 : 0);
            if (!_hasAutoScrolledOnce || currentLength > _lastHistoryLength) {
              _scrollToBottom();
              _hasAutoScrolledOnce = true;
              _lastHistoryLength = currentLength;
            }
          }
        });

        return Container(
          color: Colors.white,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            reverse: false,
            itemCount: viewModel.chatHistory.length + (viewModel.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (viewModel.isLoading && index == viewModel.chatHistory.length) {
              return _buildLoadingShimmer();
            }

            final message = viewModel.chatHistory[index];
            if (message['type'] == 'user') {
              return _buildMessageBubble(message);
            } else if (message['type'] == 'error') {
              return _buildPrescriptionError(message);
            } else {
              return AIResponseCard(
                response: message['response'] as AIChatResponse,
                showOrderButton: message['showOrderButton'] ?? false,
                navigationScreen: message['navigationScreen'],
              );
            }
          },
        ),
      );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/ai.png',
            width: 64,
            height: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'How can I help you today?',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.of(context).padding.bottom, // Remove extra bottom nav bar height
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
              children: [
          Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                    colors: [
                      Color(0xFF8A2BE2),
                      Color(0xFF4169E1),
                      Color(0xFFAC4A79),
                      Color(0xFF8A2BE2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
              borderRadius: BorderRadius.circular(12),
          ),
            padding: EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isProcessing)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Processing ${_isPdf ? "PDF" : "image"}...',
                            style: TextStyle(
                              color: ColorPalette.primaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_selectedFilePath != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilePreview(),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: 150,
                              ),
                              child: SingleChildScrollView(
                                child: Material(
                                  color: Colors.transparent,
                                  child: TextField(
                                    controller: _messageController,
                                    decoration: InputDecoration(
                                      hintText: 'Ask Vedika AI...',
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                    ),
                                    maxLines: null,
                                    textCapitalization: TextCapitalization.sentences,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 150,
                      ),
                      child: SingleChildScrollView(
                        child: Material(
                          color: Colors.transparent,
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Ask Vedika AI...',
                              border: InputBorder.none,
                                                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      ),
                    ),
                  Divider(height: 1, color: Colors.grey[200]),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildAttachmentButton(),
                            const SizedBox(width: 16),
                            _buildMicButton(),
                          ],
                        ),
                        _buildSendButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton() {
    return GestureDetector(
      onTap: _showAttachmentOptions,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            colors: [
              Color(0xFF8A2BE2),
              Color(0xFF4169E1),
              Color(0xFFAC4A79),
              Color(0xFF8A2BE2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: Icon(
          Icons.attach_file_rounded,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _onMicButtonPressed,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            colors: [
              Color(0xFF8A2BE2),
              Color(0xFF4169E1),
              Color(0xFFAC4A79),
              Color(0xFF8A2BE2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Consumer<AIViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          _sendButtonGradientController.repeat();
        } else {
          _sendButtonGradientController.stop();
          _sendButtonGradientController.reset();
        }

        return IconButton(
          icon: viewModel.isLoading
              ? _buildLoadingIndicator()
              : ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        Color(0xFF8A2BE2),
                        Color(0xFF4169E1),
                        Color(0xFFAC4A79),
                        Color(0xFF8A2BE2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Icon(Icons.send, color: Colors.white, size: 24),
                ),
          onPressed: viewModel.isLoading 
              ? () {
                  // Stop loading when clicked
                  viewModel.stopLoading();
                  _sendButtonGradientController.stop();
                  _sendButtonGradientController.reset();
                }
              : _sendMessage,
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return SweepGradient(
                                          colors: [
                                            Color(0xFF8A2BE2),
                                            Color(0xFF4169E1),
                                            Color(0xFFAC4A79),
                                            Color(0xFF8A2BE2),
                                          ],
                                          stops: [0.0, 0.33, 0.66, 1.0],
                                          startAngle: 0.0,
                                          endAngle: 6.28319,
                                        ).createShader(bounds);
                                      },
                                      blendMode: BlendMode.srcATop,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                      ),
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/ai.png',
                                    width: 22,
                                    height: 22,
                                    fit: BoxFit.contain,
                                  ),
                                ],
    );
  }

  Widget _buildLoadingShimmer() {
    final lightGradient = LinearGradient(
      colors: [
        Color(0xFFB2E6E7),
        Color(0xFF81D4D6),
        Color(0xFF38A3A5),
        Color(0xFF2B7C7E),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageShimmer(lightGradient),
          const SizedBox(height: 24),
          _buildCardShimmer(lightGradient),
        ],
      ),
    );
  }

  Widget _buildMessageShimmer(LinearGradient gradient) {
    return Shimmer.fromColors(
      baseColor: Color(0xFFB2E6E7),
      highlightColor: Color(0xFFE0F7F7),
      period: const Duration(milliseconds: 1500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          4,
          (index) => Container(
            width: index == 0
                ? double.infinity
                : MediaQuery.of(context).size.width * (0.7 - (index * 0.1)),
            height: 16,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: gradient,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardShimmer(LinearGradient gradient) {
    return Shimmer.fromColors(
      baseColor: Color(0xFFB2E6E7),
      highlightColor: Color(0xFFE0F7F7),
      period: const Duration(milliseconds: 1500),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF8A2BE2).withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: gradient,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  4,
                  (index) => Container(
                    width: index == 0
                        ? double.infinity
                        : MediaQuery.of(context).size.width * (0.5 - (index * 0.1)),
                    height: index == 0 ? 16 : 14 - (index * 0.5),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: gradient,
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

  Widget _buildPrescriptionError(Map<String, dynamic> error) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error['error'] ?? 'Error',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            error['message'] ?? 'An error occurred',
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => context.read<AIViewModel>().retryLastQuery(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorPalette.primaryColor.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          if (_isPdf)
            Container(
              decoration: BoxDecoration(
                color: ColorPalette.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      color: ColorPalette.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PDF',
                      style: TextStyle(
                        color: ColorPalette.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_selectedFilePath!),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilePath = null;
                  _extractedText = null;
                  _isPdf = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for rotating gradient border
class _RotatingGradientBorderPainter extends CustomPainter {
  final Animation<double> animation;
  final double strokeWidth;
  const _RotatingGradientBorderPainter({required this.animation, this.strokeWidth = 3});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final Gradient gradient = SweepGradient(
      startAngle: 0.0,
      endAngle: 6.28319, // 2 * pi
      colors: const [
        Color(0xFF8A2BE2),
        Color(0xFF4169E1),
        Color(0xFFAC4A79),
        Color(0xFF8A2BE2),
      ],
      stops: const [0.0, 0.33, 0.66, 1.0],
      transform: GradientRotation(animation.value * 6.28319),
    );
    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final double radius = (size.width / 2) - (strokeWidth / 2);
    canvas.drawCircle(size.center(Offset.zero), radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RotatingGradientBorderPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
} 