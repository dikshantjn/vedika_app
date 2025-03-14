// mic_animation.dart

import 'package:flutter/material.dart';

class MicAnimation extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onClose;

  const MicAnimation({
    Key? key,
    required this.isRecording,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isRecording ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: isRecording
          ? Center(
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'AI Assistant',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              SizedBox(height: 20),
              // The animated audio line
              Container(
                width: 100,
                height: 5,
                color: Colors.green,
              ),
              SizedBox(height: 20),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: onClose,
              ),
            ],
          ),
        ),
      )
          : SizedBox.shrink(),
    );
  }
}
