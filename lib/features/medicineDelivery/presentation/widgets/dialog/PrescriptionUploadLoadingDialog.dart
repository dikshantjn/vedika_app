import 'package:flutter/material.dart';

class LoadingDialog extends StatefulWidget {
  final String initialMessage;
  final Widget? initialContent;

  const LoadingDialog({Key? key, required this.initialMessage, this.initialContent}) : super(key: key);

  static void show(BuildContext context, String message, {Widget? content}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(initialMessage: message, initialContent: content),
    );
  }

  static void update(BuildContext context, Widget newContent) {
    if (context.mounted) {
      Navigator.of(context).pop(); // Close existing dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LoadingDialog(initialMessage: '', initialContent: newContent),
      );
    }
  }

  static void hide(BuildContext context) {
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> with SingleTickerProviderStateMixin {
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
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
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
            child: widget.initialContent ?? Column(
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

                // Message with Gradient
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.blue, Colors.blue.shade700],
                  ).createShader(bounds),
                  child: Text(
                    widget.initialMessage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                // Subtitle
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
      ),
    );
  }
}
