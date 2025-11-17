import 'package:flutter/material.dart';

class BottomControlBar extends StatelessWidget {
  final bool micEnabled;
  final bool camEnabled;
  final bool isScreenShareEnabled;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCam;
  final VoidCallback onToggleScreenShare;
  final VoidCallback onLeave;
  final VoidCallback onMoreOptions;

  const BottomControlBar({
    super.key,
    required this.micEnabled,
    required this.camEnabled,
    required this.isScreenShareEnabled,
    required this.onToggleMic,
    required this.onToggleCam,
    required this.onToggleScreenShare,
    required this.onLeave,
    required this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: LayoutBuilder(builder: (context, constraints) {
              final isTight = constraints.maxWidth < 360;
              final buttonPadding = isTight ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8) : const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
              final iconSize = isTight ? 20.0 : 24.0;
              final gap = isTight ? 4.0 : 8.0;
              final leaveText = const SizedBox.shrink(); // Using circular leave button

              Widget roundedIcon({
                required IconData icon,
                required String tooltip,
                required VoidCallback onTap,
                Color bg = const Color(0x221FFFFFF),
                Color border = const Color(0x33FFFFFF),
                Color iconColor = Colors.white,
              }) {
                return Tooltip(
                  message: tooltip,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      width: isTight ? 40 : 44,
                      height: isTight ? 40 : 44,
                      decoration: BoxDecoration(
                        color: bg,
                        shape: BoxShape.circle,
                        border: Border.all(color: border),
                      ),
                      child: Center(child: Icon(icon, size: iconSize, color: iconColor)),
                    ),
                  ),
                );
              }
              final content = [
                roundedIcon(
                  icon: micEnabled ? Icons.mic : Icons.mic_off,
                  tooltip: micEnabled ? 'Mute' : 'Unmute',
                  onTap: onToggleMic,
                  iconColor: micEnabled ? Colors.white : Colors.redAccent,
                ),
                SizedBox(width: gap),
                roundedIcon(
                  icon: camEnabled ? Icons.videocam : Icons.videocam_off,
                  tooltip: camEnabled ? 'Camera Off' : 'Camera On',
                  onTap: onToggleCam,
                  iconColor: camEnabled ? Colors.white : Colors.redAccent,
                ),
                SizedBox(width: gap),
                roundedIcon(
                  icon: isScreenShareEnabled ? Icons.stop_screen_share : Icons.screen_share,
                  tooltip: isScreenShareEnabled ? 'Stop Screen Share' : 'Start Screen Share',
                  onTap: onToggleScreenShare,
                ),
                SizedBox(width: gap),
                Tooltip(
                  message: 'Leave',
                  child: InkWell(
                    onTap: onLeave,
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      width: isTight ? 44 : 48,
                      height: isTight ? 44 : 48,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Icon(Icons.call_end, size: iconSize, color: Colors.white)),
                    ),
                  ),
                ),
                SizedBox(width: gap),
                roundedIcon(
                  icon: Icons.more_horiz,
                  tooltip: 'More options',
                  onTap: onMoreOptions,
                ),
              ];
              return isTight
                  ? Wrap(
                      alignment: WrapAlignment.center,
                      spacing: gap,
                      runSpacing: gap,
                      children: content,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: content,
                    );
            }),
          ),
        ),
      ),
    );
  }
}


