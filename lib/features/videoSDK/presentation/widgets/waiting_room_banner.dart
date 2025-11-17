import 'package:flutter/material.dart';

class WaitingRoomBanner extends StatelessWidget {
  final bool visible;
  const WaitingRoomBanner({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: Colors.amber.shade700,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: const [
          Icon(Icons.hourglass_empty, color: Colors.white),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Waiting room: You will join when the doctor admits you.',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}


