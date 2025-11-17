import 'package:flutter/material.dart';

class ConnectionStatusBadge extends StatelessWidget {
  final int participantCount;
  const ConnectionStatusBadge({super.key, required this.participantCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.greenAccent),
          const SizedBox(width: 6),
          Text(
            'Connected • $participantCount',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}


