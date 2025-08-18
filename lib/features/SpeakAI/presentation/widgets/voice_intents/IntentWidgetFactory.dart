import 'package:flutter/material.dart';

typedef ActionHandler = Future<void> Function(dynamic resultItem, Map action);

class IntentWidgetFactory {
  static Widget build({
    required String intent,
    required List<dynamic> results,
    required List<dynamic> suggestions,
    required String summary,
    required bool isMedicalAdvice,
    required ActionHandler onActionPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMedicalAdvice && summary.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            summary,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        ...results.map((r) => _buildResultItem(r, onActionPressed)).toList(),
        if (results.isEmpty)
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(16),
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF8A2BE2).withOpacity(0.18),
                    const Color(0xFF4169E1).withOpacity(0.14),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  SizedBox(height: 10),
                  Text(
                    'No results found',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((s) {
              final label = s.toString();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1115).withOpacity(0.94),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  static Widget _buildResultItem(dynamic r, ActionHandler onActionPressed) {
    final String type = (r is Map && r['type'] != null) ? r['type'].toString() : '';
    final String title = (r is Map && (r['title'] ?? r['name']) != null) ? (r['title'] ?? r['name']).toString() : '';
    final String subtitle = (r is Map && (r['subtitle'] ?? r['location']) != null) ? (r['subtitle'] ?? r['location']).toString() : '';
    final String rating = (r is Map && r['rating'] != null) ? r['rating'].toString() : '';
    final List<dynamic> badges = (r is Map && r['badges'] is List) ? List<dynamic>.from(r['badges']) : const [];
    final List<dynamic> actions = (r is Map && r['actions'] is List) ? List<dynamic>.from(r['actions']) : const [];

    IconData leadingIcon = Icons.local_hospital;
    if (type == 'bed') leadingIcon = Icons.king_bed_outlined;
    if (type == 'status') leadingIcon = Icons.receipt_long;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF8A2BE2).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(leadingIcon, color: Colors.white70, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.place, size: 14, color: Colors.white.withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        if (rating.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.star, size: 14, color: Colors.amber.shade400),
                          const SizedBox(width: 2),
                          Text(rating, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (badges.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: badges.map((b) {
                final label = b.toString();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.white.withOpacity(0.06),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Text(label, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11)),
                );
              }).toList(),
            ),
          ],
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: actions.map((a) {
                final String lbl = (a is Map && a['label'] != null) ? a['label'].toString() : 'Action';
                return OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () async {
                    await onActionPressed(r, a);
                  },
                  child: Text(lbl, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}


