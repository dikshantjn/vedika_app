import 'package:flutter/material.dart';

class IntentHeader extends StatelessWidget {
  final String userText;
  final bool isListening;
  final VoidCallback onMicTap;
  final VoidCallback onClose;

  const IntentHeader({
    super.key,
    required this.userText,
    required this.isListening,
    required this.onMicTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white70, size: 20),
                  SizedBox(width: 6),
                  Text('Vedika AI', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              if (userText.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  '"$userText"',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, fontStyle: FontStyle.italic),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        GestureDetector(
          onTap: onMicTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: const Icon(Icons.mic, color: Colors.white70, size: 18),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: onClose,
        ),
      ],
    );
  }
}


