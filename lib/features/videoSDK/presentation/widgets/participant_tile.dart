import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';

class ParticipantTile extends StatefulWidget {
  final Participant participant;
  final bool highlight;
  const ParticipantTile({
    super.key,
    required this.participant,
    this.highlight = false,
  });

  @override
  State<ParticipantTile> createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<ParticipantTile> {
  Stream? _videoStream;
  bool _audioEnabled = true;

  @override
  void initState() {
    super.initState();
    widget.participant.streams.forEach((_, Stream stream) {
      if (stream.kind == 'video') {
        _videoStream = stream;
      } else if (stream.kind == 'audio') {
        _audioEnabled = true;
      }
    });
    _initListeners();
  }

  void _initListeners() {
    widget.participant.on(Events.streamEnabled, (Stream stream) {
      if (stream.kind == 'video') {
        if (mounted) {
          setState(() => _videoStream = stream);
        }
      } else if (stream.kind == 'audio') {
        if (mounted) {
          setState(() => _audioEnabled = true);
        }
      }
    });
    widget.participant.on(Events.streamDisabled, (Stream stream) {
      if (stream.kind == 'video') {
        if (mounted) {
          setState(() => _videoStream = null);
        }
      } else if (stream.kind == 'audio') {
        if (mounted) {
          setState(() => _audioEnabled = false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.participant.displayName ?? 'Guest';
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.highlight ? Colors.greenAccent : Colors.transparent,
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: _videoStream != null
                ? RTCVideoView(
                    _videoStream?.renderer as RTCVideoRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                : Container(
                    color: Colors.grey.shade900,
                    child: const Center(
                      child: Icon(Icons.person, size: 72, color: Colors.white70),
                    ),
                  ),
          ),
          // Top-right status icons (mic/video)
          Positioned(
            right: 8,
            top: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _audioEnabled ? Icons.mic : Icons.mic_off,
                      size: 16,
                      color: _audioEnabled ? Colors.white : Colors.redAccent,
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _videoStream != null ? Icons.videocam : Icons.videocam_off,
                      size: 16,
                      color: _videoStream != null ? Colors.white : Colors.redAccent,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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
}


