import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/ai/presentation/viewmodel/AIViewModel.dart';
import 'package:vedika_healthcare/features/ai/presentation/widgets/AIMessageBubble.dart';
import 'package:vedika_healthcare/features/ai/presentation/widgets/AIResponseCard.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vedika_healthcare/features/ai/data/models/AIChatResponse.dart';

class AIChatScreen extends StatefulWidget {
  final String initialQuery;

  const AIChatScreen({
    Key? key,
    required this.initialQuery,
  }) : super(key: key);

  @override
  _AIChatScreenState createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _shimmerController;
  late AnimationController _sendButtonGradientController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _handleInitialQuery();
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
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _shimmerController.dispose();
    _sendButtonGradientController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
                  Expanded(
            child: _buildChatList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
          _buildAIAvatar(),
          SizedBox(width: 12),
          _buildAITitle(),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.delete_outline, color: ColorPalette.primaryColor),
          onPressed: () => context.read<AIViewModel>().clearChat(),
        ),
      ],
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

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(16),
          itemCount: viewModel.chatHistory.length + (viewModel.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (viewModel.isLoading && index == viewModel.chatHistory.length) {
              return _buildLoadingShimmer();
            }

            final message = viewModel.chatHistory[index];
            return message['type'] == 'user'
                ? AIMessageBubble(
                    message: message['message'],
                    isUser: true,
                  )
                : AIResponseCard(
                    response: message['response'] as AIChatResponse,
                  );
          },
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
                        SizedBox(height: 16),
                        Text(
                          'How can I help you today?',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

  Widget _buildMessageInput() {
    return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
            child: _buildMessageTextField(),
          ),
          SizedBox(width: 12),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildMessageTextField() {
    return Container(
                    padding: EdgeInsets.all(2),
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
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Ask Vedika AI...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
            suffixIcon: _buildMicButton(),
          ),
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
                            onTap: () {
                              // TODO: Implement speech-to-text functionality
                            },
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
                                Icons.mic,
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

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: viewModel.isLoading
                ? _buildLoadingIndicator()
                : Icon(Icons.send, color: Color(0xFF8A2BE2)),
            onPressed: viewModel.isLoading
                ? null
                : () {
                    if (_messageController.text.trim().isNotEmpty) {
                      viewModel.interpretSymptoms(_messageController.text);
                      _messageController.clear();
                      _scrollToBottom();
                    }
                  },
          ),
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
          SizedBox(height: 24),
          _buildCardShimmer(lightGradient),
        ],
      ),
    );
  }

  Widget _buildMessageShimmer(LinearGradient gradient) {
    return Shimmer.fromColors(
      baseColor: Color(0xFFB2E6E7),
      highlightColor: Color(0xFFE0F7F7),
      period: Duration(milliseconds: 1500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          4,
          (index) => Container(
            width: index == 0
                ? double.infinity
                : MediaQuery.of(context).size.width * (0.7 - (index * 0.1)),
            height: 16,
            margin: EdgeInsets.only(bottom: 10),
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
      period: Duration(milliseconds: 1500),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF8A2BE2).withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
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
            SizedBox(width: 16),
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
                    margin: EdgeInsets.only(bottom: 8),
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
}

// Custom painter for rotating gradient border
class _RotatingGradientBorderPainter extends CustomPainter {
  final Animation<double> animation;
  final double strokeWidth;
  _RotatingGradientBorderPainter({required this.animation, this.strokeWidth = 3});

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