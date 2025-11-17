import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';

class ParticipantsDrawer extends StatelessWidget {
  final Map<String, Participant> participants;
  final bool isDoctor;
  final void Function(String participantId)? onAdmit;
  final VoidCallback? onAdmitAll;

  const ParticipantsDrawer({
    super.key,
    required this.participants,
    required this.isDoctor,
    this.onAdmit,
    this.onAdmitAll,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: const Text(
                'Participants',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: isDoctor && onAdmitAll != null
                  ? TextButton.icon(
                      onPressed: onAdmitAll,
                      icon: const Icon(Icons.how_to_reg),
                      label: const Text('Admit All'),
                    )
                  : null,
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  final p = participants.values.elementAt(index);
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(p.displayName ?? 'Guest'),
                    subtitle: Text(p.id),
                    trailing: isDoctor && onAdmit != null
                        ? IconButton(
                            icon: const Icon(Icons.how_to_reg),
                            onPressed: () => onAdmit!(p.id),
                          )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


