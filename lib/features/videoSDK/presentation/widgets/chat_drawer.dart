import 'package:flutter/material.dart';
import '../viewmodel/video_meeting_view_model.dart';

class ChatDrawer extends StatefulWidget {
  final List<ChatMessage> messages;
  final void Function(String text) onSend;

  const ChatDrawer({
    super.key,
    required this.messages,
    required this.onSend,
  });

  @override
  State<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    widget.onSend(text.trim());
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const ListTile(
              title: Text(
                'In-call Chat',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.messages.length,
                itemBuilder: (context, index) {
                  final m = widget.messages[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(m.senderName),
                    subtitle: Text(m.text),
                    dense: true,
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


