import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Services/JitsiMeetService.dart';

class JitsiMeetScreen extends StatefulWidget {
  final String roomName;
  final String userDisplayName;
  final String? userEmail;
  final String? userAvatarUrl;
  final String? jwtToken;
  final bool isDoctor;
  final VoidCallback? onMeetingClosed;
  final String? meetingUrl;

  const JitsiMeetScreen({
    Key? key,
    required this.roomName,
    required this.userDisplayName,
    this.userEmail,
    this.userAvatarUrl,
    this.jwtToken,
    this.isDoctor = false,
    this.onMeetingClosed,
    this.meetingUrl,
  }) : super(key: key);

  @override
  State<JitsiMeetScreen> createState() => _JitsiMeetScreenState();
}

class _JitsiMeetScreenState extends State<JitsiMeetScreen> {
  final JitsiMeetService _jitsiMeetService = JitsiMeetService();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _joinMeeting();
    });
  }

  @override
  void dispose() {
    if (mounted) {
      _jitsiMeetService.hangUp();
    }
    super.dispose();
  }

  Future<void> _joinMeeting() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      debugPrint("\n====== JOINING JITSI MEETING ======");
      
      if (widget.meetingUrl != null) {
        // Join using the complete meeting URL
        await _jitsiMeetService.joinFromUrl(
          meetingUrl: widget.meetingUrl!,
          userDisplayName: widget.userDisplayName,
          userEmail: widget.userEmail,
          userAvatarUrl: widget.userAvatarUrl,
          onConferenceTerminated: () {
            if (widget.onMeetingClosed != null) {
              widget.onMeetingClosed!();
            }
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          onError: (error) {
            setState(() {
              _isLoading = false;
              _errorMessage = error;
            });
          },
        );
      } else {
        // Join using room name and JWT
        await _jitsiMeetService.joinMeeting(
          roomName: widget.roomName,
          userDisplayName: widget.userDisplayName,
          userEmail: widget.userEmail,
          userAvatarUrl: widget.userAvatarUrl,
          jwtToken: widget.jwtToken,
          onConferenceTerminated: () {
            if (widget.onMeetingClosed != null) {
              widget.onMeetingClosed!();
            }
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          onError: (error) {
            setState(() {
              _isLoading = false;
              _errorMessage = error;
            });
          },
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Exception while joining: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _jitsiMeetService.hangUp();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: DoctorConsultationColorPalette.primaryBlue,
          title: const Text(
            'Video Consultation',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              await _jitsiMeetService.hangUp();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: DoctorConsultationColorPalette.primaryBlue,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Joining video consultation...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: DoctorConsultationColorPalette.errorRed,
                          size: 60,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Failed to join meeting',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _joinMeeting,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Go Back',
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
      ),
    );
  }
} 