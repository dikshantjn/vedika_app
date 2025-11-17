import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';

class ScreenShareView extends StatefulWidget {
  final Participant? participant;
  const ScreenShareView({super.key, required this.participant});

  @override
  State<ScreenShareView> createState() => _ScreenShareViewState();
}

class _ScreenShareViewState extends State<ScreenShareView> {
  Stream? _shareStream;

  @override
  void initState() {
    super.initState();
    _initShareStream();
    _attachListeners();
  }

  void _initShareStream() {
    _shareStream = null;
    widget.participant?.streams.forEach((_, stream) {
      if (stream.kind == 'share') {
        _shareStream = stream;
      }
    });
    setState(() {});
  }

  void _attachListeners() {
    final p = widget.participant;
    if (p == null) return;
    p.on(Events.streamEnabled, (Stream stream) {
      if (stream.kind == 'share' && mounted) {
        setState(() => _shareStream = stream);
      }
    });
    p.on(Events.streamDisabled, (Stream stream) {
      if (stream.kind == 'share' && mounted) {
        setState(() => _shareStream = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: _shareStream != null
                ? RTCVideoView(
                    _shareStream?.renderer as RTCVideoRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                  )
                : const Center(
                    child: Text('Waiting for screenshare...', style: TextStyle(color: Colors.white70)),
                  ),
          ),
          // Mic is off for screen share tile indicator
          Positioned(
            top: 8,
            right: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stop_screen_share, size: 14, color: Colors.redAccent),
                    SizedBox(width: 6),
                    Icon(Icons.mic_off, size: 14, color: Colors.redAccent),
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


