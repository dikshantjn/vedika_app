import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/JitsiMeet/JitsiMeetScreen.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import '../Models/ClinicAppointment.dart';
import '../Services/AppointmentService.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Services/JitsiMeetService.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Services/DoctorClinicService.dart';
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';

enum AppointmentFilter { upcoming, completed, cancelled, all }
enum AppointmentSortOrder { newest, oldest }
enum ClinicAppointmentFetchState { initial, loading, loaded, error }

class ClinicAppointmentViewModel extends ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();
  final JitsiMeetService _jitsiMeetService = JitsiMeetService();
  final DoctorClinicService _doctorClinicService = DoctorClinicService();
  
  List<ClinicAppointment> _appointments = [];
  List<ClinicAppointment> _filteredAppointments = [];
  DoctorClinicProfile? _doctorProfile;
  
  ClinicAppointmentFetchState _fetchState = ClinicAppointmentFetchState.initial;
  String? _errorMessage;
  AppointmentFilter _currentFilter = AppointmentFilter.all; // Changed to show all appointments by default
  AppointmentSortOrder _sortOrder = AppointmentSortOrder.newest;
  String _searchQuery = '';
  DateTime? _selectedDate;

  // Getters
  List<ClinicAppointment> get appointments => _filteredAppointments;
  ClinicAppointmentFetchState get fetchState => _fetchState;
  String get errorMessage => _errorMessage ?? '';
  AppointmentFilter get currentFilter => _currentFilter;
  AppointmentSortOrder get sortOrder => _sortOrder;
  String get searchQuery => _searchQuery;
  DateTime? get selectedDate => _selectedDate;
  DoctorClinicProfile? get doctorProfile => _doctorProfile;

  // Initialize view model
  Future<void> initialize() async {
    print('[ClinicAppointmentViewModel] Initializing...');
    await fetchDoctorProfile();
    await fetchUserClinicAppointments();
  }

  // Fetch doctor profile information
  Future<void> fetchDoctorProfile() async {
    try {
      String? vendorId = await VendorLoginService().getVendorId();
      _doctorProfile = await _doctorClinicService.getCurrentDoctorProfile();
      notifyListeners();
    } catch (e) {
      print('[ClinicAppointmentViewModel] Error fetching doctor profile: $e');
    }
  }

  // Fetch appointments from service
  Future<void> fetchUserClinicAppointments() async {
    print('[ClinicAppointmentViewModel] fetchUserClinicAppointments() called');
    _fetchState = ClinicAppointmentFetchState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Use the appointmentService to fetch data
      print('[ClinicAppointmentViewModel] Calling appointmentService.fetchPendingAppointments()');
      _appointments = await _appointmentService.fetchPendingAppointments();
      
      // Debug output to verify appointments are loaded
      print('[ClinicAppointmentViewModel] Loaded ${_appointments.length} appointments from service');
      for (var appointment in _appointments) {
        print('[ClinicAppointmentViewModel] - ID: ${appointment.clinicAppointmentId}, isOnline: ${appointment.isOnline}, status: ${appointment.status}');
      }
      
      _applyFilters();
      _fetchState = ClinicAppointmentFetchState.loaded;
      notifyListeners();
    } catch (e) {
      print('[ClinicAppointmentViewModel] Error in fetchUserClinicAppointments: $e');
      _fetchState = ClinicAppointmentFetchState.error;
      _errorMessage = 'Failed to load appointments: ${e.toString()}';
      print('[ClinicAppointmentViewModel] Error loading appointments: $e');
      notifyListeners();
    }
  }

  // Apply filters to the appointments list
  void _applyFilters() {
    print('[ClinicAppointmentViewModel] _applyFilters() called');
    print('[ClinicAppointmentViewModel] Current filter: $_currentFilter');
    print('[ClinicAppointmentViewModel] Before filtering: ${_appointments.length} appointments');
    
    var filtered = List<ClinicAppointment>.from(_appointments);
    
    // Apply status filter
    if (_currentFilter != AppointmentFilter.all) {
      print('[ClinicAppointmentViewModel] Applying status filter: $_currentFilter');
      filtered = filtered.where((appointment) {
        final bool shouldInclude = switch (_currentFilter) {
          AppointmentFilter.upcoming => appointment.status == 'pending' || appointment.status == 'confirmed',
          AppointmentFilter.completed => appointment.status == 'completed',
          AppointmentFilter.cancelled => appointment.status == 'cancelled',
          AppointmentFilter.all => true,
        };
        
        print('[ClinicAppointmentViewModel] - ID: ${appointment.clinicAppointmentId}, status: ${appointment.status}, include: $shouldInclude');
        return shouldInclude;
      }).toList();
    }
    
    // Apply date filter
    if (_selectedDate != null) {
      print('[ClinicAppointmentViewModel] Applying date filter: $_selectedDate');
      filtered = filtered.where((appointment) {
        final bool matchesDate = appointment.date.year == _selectedDate!.year &&
               appointment.date.month == _selectedDate!.month &&
               appointment.date.day == _selectedDate!.day;
               
        print('[ClinicAppointmentViewModel] - ID: ${appointment.clinicAppointmentId}, date: ${appointment.date}, matches: $matchesDate');
        return matchesDate;
      }).toList();
    }
    
    // Apply search query
    if (_searchQuery.isNotEmpty) {
      print('[ClinicAppointmentViewModel] Applying search query: $_searchQuery');
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((appointment) {
        final patientName = appointment.user?.name?.toLowerCase() ?? '';
        final patientId = appointment.userId.toLowerCase();
        final appointmentId = appointment.clinicAppointmentId.toLowerCase();
        
        final bool matchesSearch = patientName.contains(query) || 
               patientId.contains(query) || 
               appointmentId.contains(query);
               
        print('[ClinicAppointmentViewModel] - ID: ${appointment.clinicAppointmentId}, patient: ${appointment.user?.name}, matches: $matchesSearch');
        return matchesSearch;
      }).toList();
    }
    
    // Apply sorting
    print('[ClinicAppointmentViewModel] Applying sorting: $_sortOrder');
    filtered.sort((a, b) {
      final dateA = DateTime(
        a.date.year, 
        a.date.month, 
        a.date.day,
        int.parse(a.time.split(':')[0]),
        int.parse(a.time.split(':')[1]),
      );
      
      final dateB = DateTime(
        b.date.year, 
        b.date.month, 
        b.date.day,
        int.parse(b.time.split(':')[0]),
        int.parse(b.time.split(':')[1]),
      );
      
      return _sortOrder == AppointmentSortOrder.newest
          ? dateB.compareTo(dateA)
          : dateA.compareTo(dateB);
    });
    
    _filteredAppointments = filtered;
    // Debug output after filtering
    print('[ClinicAppointmentViewModel] After filtering: ${_filteredAppointments.length} appointments');
    print('[ClinicAppointmentViewModel] Filtered appointments breakdown:');
    int onlineCount = 0;
    int offlineCount = 0;
    
    for (var appointment in _filteredAppointments) {
      if (appointment.isOnline) {
        onlineCount++;
      } else {
        offlineCount++;
      }
      print('[ClinicAppointmentViewModel] - ID: ${appointment.clinicAppointmentId}, isOnline: ${appointment.isOnline}, status: ${appointment.status}');
    }
    
    print('[ClinicAppointmentViewModel] Online appointments: $onlineCount, Offline appointments: $offlineCount');
    
    notifyListeners();
  }

  // Set filter
  void setFilter(AppointmentFilter filter) {
    print('[ClinicAppointmentViewModel] setFilter() called with: $filter (previous: $_currentFilter)');
    if (_currentFilter != filter) {
      _currentFilter = filter;
      _applyFilters();
    }
  }

  // Set sort order
  void setSortOrder(AppointmentSortOrder order) {
    print('[ClinicAppointmentViewModel] setSortOrder() called with: $order (previous: $_sortOrder)');
    if (_sortOrder != order) {
      _sortOrder = order;
      _applyFilters();
    }
  }

  // Set search query
  void setSearchQuery(String query) {
    print('[ClinicAppointmentViewModel] setSearchQuery() called with: $query');
    _searchQuery = query;
    _applyFilters();
  }

  // Set selected date
  void setSelectedDate(DateTime? date) {
    print('[ClinicAppointmentViewModel] setSelectedDate() called with: $date');
    _selectedDate = date;
    _applyFilters();
  }

  // Clear date filter
  void clearDateFilter() {
    print('[ClinicAppointmentViewModel] clearDateFilter() called');
    _selectedDate = null;
    _applyFilters();
  }

  // Update appointment status
  Future<bool> updateAppointmentStatus(String appointmentId, String newStatus) async {
    print('[ClinicAppointmentViewModel] updateAppointmentStatus() called with ID: $appointmentId, status: $newStatus');
    _fetchState = ClinicAppointmentFetchState.loading;
    notifyListeners();
    
    try {
      // Call API to update appointment status
      final success = await _appointmentService.updateAppointmentStatus(appointmentId, newStatus);
      
      if (success) {
        print('[ClinicAppointmentViewModel] Status updated successfully, refreshing appointments');
        // Update local state - fetch fresh appointments instead of manual update
        await fetchUserClinicAppointments();
      } else {
        print('[ClinicAppointmentViewModel] Failed to update status');
        _errorMessage = 'Failed to update appointment status';
        notifyListeners();
      }
      
      _fetchState = ClinicAppointmentFetchState.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      print('[ClinicAppointmentViewModel] Error updating status: $e');
      _fetchState = ClinicAppointmentFetchState.error;
      _errorMessage = 'Failed to update appointment: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Cancel an appointment
  Future<bool> cancelAppointment(String appointmentId) async {
    print('[ClinicAppointmentViewModel] cancelAppointment() called with ID: $appointmentId');
    return await updateAppointmentStatus(appointmentId, 'cancelled');
  }
  
  // Generate meeting URL for online appointments
  Future<String?> generateMeetingUrl(String appointmentId) async {
    print('[ClinicAppointmentViewModel] generateMeetingUrl() called with ID: $appointmentId');
    try {
      final meetingUrl = await _appointmentService.generateMeetingUrl(appointmentId);
      
      if (meetingUrl != null) {
        print('[ClinicAppointmentViewModel] Meeting URL generated successfully: $meetingUrl');
        // Update local state - fetch fresh appointments
        await fetchUserClinicAppointments();
      } else {
        print('[ClinicAppointmentViewModel] Failed to generate meeting URL');
      }
      
      return meetingUrl;
    } catch (e) {
      print('[ClinicAppointmentViewModel] Error generating meeting URL: $e');
      _errorMessage = 'Failed to generate meeting URL: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Refresh appointments
  Future<void> refreshAppointments() async {
    print('[ClinicAppointmentViewModel] refreshAppointments() called');
    await fetchUserClinicAppointments();
  }

  // Join a Jitsi meeting using the service
  Future<bool> joinMeeting({
    required String appointmentId,
    required String userDisplayName,
    String? userEmail,
    String? userAvatarUrl,
    bool isDoctor = false,
  }) async {
    try {
      // Find the appointment
      final appointment = _appointments.firstWhere(
        (a) => a.clinicAppointmentId == appointmentId,
        orElse: () => throw Exception('Appointment not found'),
      );
      
      // Generate meeting URL if not already set
      String? meetingUrl = appointment.meetingUrl;
      if (meetingUrl == null || meetingUrl.isEmpty) {
        meetingUrl = await generateMeetingUrl(appointmentId);
        if (meetingUrl == null) {
          return false;
        }
      }
      
      // Extract server URL, room name, and JWT token from meetingUrl
      String roomName;
      String? jwtToken;
      // Default to meet.jit.si if no server URL can be extracted
      String serverUrl = "https://vpaas-magic-cookie-8162f5c330b748ceb26b57660afbf8db.8x8.vc";
      
      debugPrint('Meeting URL: $meetingUrl');
      
      // Extract server URL from the meeting URL
      if (meetingUrl.startsWith('http')) {
        Uri uri = Uri.parse(meetingUrl);
        // Get server URL (e.g., https://meet.jit.si)
        serverUrl = '${uri.scheme}://${uri.host}';
        debugPrint('Server URL extracted: $serverUrl');
      }
      
      // Extract room name and JWT token from the meeting URL
      if (meetingUrl.contains('#jwt=')) {
        // Format: https://meet.jit.si/roomName#jwt=token
        final parts = meetingUrl.split('#jwt=');
        
        // Extract the room name from the first part (URL before the #jwt=)
        String urlPart = parts[0];
        roomName = urlPart.contains('/') ? urlPart.split('/').last : urlPart;
        
        // Extract the JWT token from the second part
        jwtToken = parts.length > 1 ? parts[1].trim() : null;
        
        debugPrint('Extracted from #jwt format - Room: $roomName, JWT available: ${jwtToken != null}');
      } else if (meetingUrl.contains('?jwt=')) {
        // Alternative format: https://meet.jit.si/roomName?jwt=token
        final parts = meetingUrl.split('?jwt=');
        
        // Extract the room name from the first part
        String urlPart = parts[0];
        roomName = urlPart.contains('/') ? urlPart.split('/').last : urlPart;
        
        // Extract the JWT token from the second part
        jwtToken = parts.length > 1 ? parts[1].trim() : null;
        
        // Remove any additional query parameters if present
        if (jwtToken != null && jwtToken.contains('&')) {
          jwtToken = jwtToken.split('&')[0];
        }
        
        debugPrint('Extracted from ?jwt format - Room: $roomName, JWT available: ${jwtToken != null}');
      } else if (meetingUrl.contains('/')) {
        // Format: https://meet.jit.si/roomName (no JWT)
        roomName = meetingUrl.split('/').last;
        debugPrint('Extracted from URL path - Room: $roomName');
      } else {
        // The meetingUrl is just the room name
        roomName = meetingUrl;
        debugPrint('Using meetingUrl as room name: $roomName');
      }
      
      // Use appointment ID as a fallback if roomName is empty
      if (roomName.isEmpty) {
        roomName = 'vedika-consultation-$appointmentId';
        debugPrint('Using fallback room name: $roomName');
      }
      
      // Log JWT token status (but not the actual token for security reasons)
      if (jwtToken != null) {
        debugPrint('JWT token found. First 8 chars: ${jwtToken.length > 8 ? jwtToken.substring(0, 8) : jwtToken}...');
      } else {
        debugPrint('No JWT token found in the meeting URL');
      }
      
      // Join the meeting
      await _jitsiMeetService.joinMeeting(
        roomName: roomName,
        userDisplayName: userDisplayName,
        userEmail: userEmail,
        avatarUrl: userAvatarUrl,
      );


      return true;
    } catch (e) {
      debugPrint('Error joining meeting: $e');
      return false;
    }
  }
  
  // Hang up the current meeting
  Future<void> hangUpMeeting() async {
    // await _jitsiMeetService.hangUp();
  }
  
  @override
  void dispose() {
    // Clean up any Jitsi resources if needed
    super.dispose();
  }

  // Get mock appointments for demonstration
  List<ClinicAppointment> _getMockAppointments() {
    // Implement mock data here
    // This is just placeholder implementation
    return [];
  }

  // Mark appointment as completed after meeting ends
  Future<bool> completeAppointmentAfterMeeting(String appointmentId) async {
    print('[ClinicAppointmentViewModel] completeAppointmentAfterMeeting() called with ID: $appointmentId');
    
    try {
      final success = await _appointmentService.completeAppointmentAfterMeeting(appointmentId);
      
      if (success) {
        print('[ClinicAppointmentViewModel] Appointment marked as completed after meeting, refreshing appointments');
        // Update local state to reflect the change
        await fetchUserClinicAppointments();
      } else {
        print('[ClinicAppointmentViewModel] Failed to mark appointment as completed');
        _errorMessage = 'Failed to mark appointment as completed';
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      print('[ClinicAppointmentViewModel] Error completing appointment after meeting: $e');
      _errorMessage = 'Error marking appointment as completed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Extract server URL, room name, and JWT token from meeting URL
  Map<String, String?> extractMeetingData(String meetingUrl) {
    String? serverUrl;
    String? roomName;
    String? jwtToken;

    try {
      Uri uri = Uri.parse(meetingUrl);
      
      // Extract the server URL
      serverUrl = '${uri.scheme}://${uri.host}';
      if (uri.port != 80 && uri.port != 443) {
        serverUrl += ':${uri.port}';
      }
      
      // Extract room name from path segments
      if (uri.pathSegments.isNotEmpty) {
        roomName = uri.pathSegments.last;
      }
      
      // Extract JWT token from query parameters
      jwtToken = uri.queryParameters['jwt'];
      
      debugPrint('Extracted meeting data:');
      debugPrint('Server URL: $serverUrl');
      debugPrint('Room name: $roomName');
      debugPrint('JWT token: ${jwtToken != null ? "Present" : "Not present"}');
    } catch (e) {
      debugPrint('Error parsing meeting URL: $e');
    }
    
    return {
      'serverUrl': serverUrl,
      'roomName': roomName,
      'jwtToken': jwtToken,
    };
  }

  // Enhanced method to extract meeting data from various URL formats
  Map<String, String?> extractMeetingDataFromUrl(String meetingUrl) {
    String? serverUrl = "https://vpaas-magic-cookie-8162f5c330b748ceb26b57660afbf8db.8x8.vc"; // Default server URL
    String? roomName;
    String? jwtToken;

    debugPrint('Extracting meeting data from URL: $meetingUrl');

    // Handle URL with @ prefix (sometimes copied from browser)
    if (meetingUrl.startsWith("@")) {
      meetingUrl = meetingUrl.substring(1);
    }

    try {
      // Try standard URI parsing first
      if (meetingUrl.startsWith('http')) {
        Uri uri = Uri.parse(meetingUrl.split('#')[0]); // Remove fragment before parsing
        
        // Extract the server URL
        serverUrl = '${uri.scheme}://${uri.host}';
        if (uri.port != 80 && uri.port != 443 && uri.port > 0) {
          serverUrl += ':${uri.port}';
        }
        
        // Special handling for 8x8.vc URLs
        if (serverUrl.contains("8x8.vc") && !serverUrl.contains("vpaas-magic-cookie")) {
          serverUrl = "https://vpaas-magic-cookie-8162f5c330b748ceb26b57660afbf8db.8x8.vc";
        }
        
        // Extract JWT token from query parameters
        jwtToken = uri.queryParameters['jwt'];
        
        // Extract room name from path segments
        if (uri.pathSegments.isNotEmpty) {
          // Remove any 'vedika/' prefix from the room name
          roomName = uri.pathSegments.last.replaceAll('vedika/', '');
        }
      }
      
      // Handle special formats with fragment (#jwt=) that Uri.parse doesn't handle well
      if (meetingUrl.contains('#jwt=')) {
        // Format: https://meet.jit.si/roomName#jwt=token
        final parts = meetingUrl.split('#jwt=');
        
        // Extract the room name from the first part (URL before the #jwt=)
        String urlPart = parts[0];
        if (urlPart.contains('/')) {
          // Extract server URL if not already set
          if (urlPart.startsWith('http')) {
            Uri baseUri = Uri.parse(urlPart);
            serverUrl = '${baseUri.scheme}://${baseUri.host}';
            if (baseUri.port != 80 && baseUri.port != 443 && baseUri.port > 0) {
              serverUrl += ':${baseUri.port}';
            }
            
            // Special handling for 8x8.vc URLs
            if (serverUrl.contains("8x8.vc") && !serverUrl.contains("vpaas-magic-cookie")) {
              serverUrl = "https://vpaas-magic-cookie-8162f5c330b748ceb26b57660afbf8db.8x8.vc";
            }
          }
          
          // Remove any 'vedika/' prefix from the room name
          roomName = urlPart.split('/').last.replaceAll('vedika/', '');
        } else {
          roomName = urlPart;
        }
        
        // Extract the JWT token from the second part
        jwtToken = parts.length > 1 ? parts[1].trim() : null;
        
        // Make sure token doesn't have any URL fragments or other parameters
        if (jwtToken != null && jwtToken.contains('#')) {
          jwtToken = jwtToken.split('#')[0].trim();
        }
        
        debugPrint('Extracted from #jwt format:');
        debugPrint('- Room: $roomName');
        debugPrint('- JWT token length: ${jwtToken?.length ?? 0}');
        if (jwtToken != null && jwtToken.length > 10) {
          debugPrint('- JWT token first 10 chars: ${jwtToken.substring(0, 10)}...');
        }
      } else if (meetingUrl.contains('?jwt=') && jwtToken == null) {
        // Alternative format: https://meet.jit.si/roomName?jwt=token
        final parts = meetingUrl.split('?jwt=');
        
        // Extract the room name from the first part
        String urlPart = parts[0];
        if (urlPart.contains('/')) {
          // Extract server URL if not already set
          if (urlPart.startsWith('http')) {
            Uri baseUri = Uri.parse(urlPart);
            serverUrl = '${baseUri.scheme}://${baseUri.host}';
            if (baseUri.port != 80 && baseUri.port != 443 && baseUri.port > 0) {
              serverUrl += ':${baseUri.port}';
            }
            
            // Special handling for 8x8.vc URLs
            if (serverUrl.contains("8x8.vc") && !serverUrl.contains("vpaas-magic-cookie")) {
              serverUrl = "https://vpaas-magic-cookie-8162f5c330b748ceb26b57660afbf8db.8x8.vc";
            }
          }
          
          // Remove any 'vedika/' prefix from the room name
          roomName = urlPart.split('/').last.replaceAll('vedika/', '');
        } else {
          roomName = urlPart;
        }
        
        // Extract the JWT token from the second part
        jwtToken = parts.length > 1 ? parts[1].trim() : null;
        
        // Remove any additional query parameters if present
        if (jwtToken != null && jwtToken.contains('&')) {
          jwtToken = jwtToken.split('&')[0].trim();
        }
        
        debugPrint('Extracted from ?jwt format:');
        debugPrint('- Room: $roomName');
        debugPrint('- JWT token length: ${jwtToken?.length ?? 0}');
        if (jwtToken != null && jwtToken.length > 10) {
          debugPrint('- JWT token first 10 chars: ${jwtToken.substring(0, 10)}...');
        }
      } else if (roomName == null && meetingUrl.contains('/')) {
        // Format: https://meet.jit.si/roomName (no JWT)
        // Remove any 'vedika/' prefix from the room name
        roomName = meetingUrl.split('/').last.replaceAll('vedika/', '');
        debugPrint('Extracted from URL path - Room: $roomName');
      } else if (roomName == null) {
        // The meetingUrl is just the room name
        roomName = meetingUrl;
        debugPrint('Using meetingUrl as room name: $roomName');
      }
      
      // Use a fallback if roomName is empty
      if (roomName == null || roomName.isEmpty) {
        roomName = 'vedika-consultation-' + DateTime.now().millisecondsSinceEpoch.toString();
        debugPrint('Using fallback room name: $roomName');
      }
      
      // Final token check and cleanup
      if (jwtToken != null) {
        // Remove any whitespace that might cause issues
        jwtToken = jwtToken.trim();
        
        debugPrint('Final JWT token details:');
        debugPrint('- Length: ${jwtToken.length}');
        debugPrint('- First 10 chars: ${jwtToken.length > 10 ? jwtToken.substring(0, 10) : jwtToken}...');
      } else {
        debugPrint('No JWT token found in the meeting URL');
      }
      
      debugPrint('Final room name to be used: $roomName');
      debugPrint('JWT token available: ${jwtToken != null}');
      debugPrint('Server URL: $serverUrl');
      
    } catch (e) {
      debugPrint('Error extracting meeting data: $e');
      // Use defaults in case of error
      if (roomName == null) {
        roomName = 'vedika-consultation-' + DateTime.now().millisecondsSinceEpoch.toString();
      }
    }
    
    return {
      'serverUrl': serverUrl,
      'roomName': roomName,
      'jwtToken': jwtToken,
    };
  }

  Future<void> launchMeetingLink(String meetingUrl, BuildContext context, String userName, bool isDoctor) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              color: DoctorConsultationColorPalette.primaryBlue,
            ),
          );
        },
      );

      // Generate new meeting URL
      final newMeetingUrl = await _appointmentService.generateMeetingUrl(meetingUrl);
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (newMeetingUrl == null) {
        if (context.mounted) {
          showSnackBar(context, "Failed to generate meeting URL");
        }
        return;
      }

      Map<String, String?> meetingData = extractMeetingDataFromUrl(newMeetingUrl);
      String? serverUrl = meetingData['serverUrl'];
      String? roomName = meetingData['roomName'];
      String? jwtToken = meetingData['jwtToken'];

      if (roomName != null && serverUrl != null) {
        debugPrint('Launching meeting with:');
        debugPrint('Server URL: $serverUrl');
        debugPrint('Room name: $roomName');
        debugPrint('User display name: $userName');
        debugPrint('Original meeting URL: $newMeetingUrl');
        
        // Show confirmation dialog
        if (context.mounted) {
          bool shouldJoin = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Join Meeting"),
                content: const Text("Meeting room has been created. Would you like to join now?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("CANCEL"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("JOIN"),
                  ),
                ],
              );
            },
          ) ?? false;

          if (shouldJoin) {
            // Navigate to Jitsi Meet screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JitsiMeetScreen(
                  roomName: roomName,
                  displayName: userName,
                  email: isDoctor ? "doctor@vedika.com" : "user@vedika.com",
                  avatarUrl: "",  // or pass a real avatar URL if you have one
                ),
              ),

            );
          }
        }
      } else {
        if (context.mounted) {
          showSnackBar(context, "Invalid meeting URL");
        }
      }
    } catch (e) {
      debugPrint('Error launching meeting: $e');
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog if open
        showSnackBar(context, "Error launching meeting: $e");
      }
    }
  }

  Future<void> launchMeetingWithDebug(String meetingUrl, BuildContext context, String userName, bool isDoctor) async {
    try {
      // Present debug option
      bool useDebug = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Launch Options"),
            content: Text("How would you like to join the meeting?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Normal launch
                },
                child: Text("Normal"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Debug launch
                },
                child: Text("Debug Mode"),
              ),
            ],
          );
        },
      ) ?? false;

      if (useDebug) {
        // Launch using normal method instead of debug since the debug launcher is not available
        launchMeetingLink(meetingUrl, context, userName, isDoctor);
      } else {
        // Normal launch
        launchMeetingLink(meetingUrl, context, userName, isDoctor);
      }
    } catch (e) {
      debugPrint('Error with meeting launch choice: $e');
      // Fallback to normal launch
      launchMeetingLink(meetingUrl, context, userName, isDoctor);
    }
  }
}

// Extension for creating copies of ClinicAppointment
extension ClinicAppointmentExtension on ClinicAppointment {
  ClinicAppointment copyWith({
    String? clinicAppointmentId,
    String? userId,
    String? doctorId,
    String? vendorId,
    DateTime? date,
    String? time,
    String? status,
    String? paymentStatus,
    DateTime? adminUpdatedAt,
    String? userResponseStatus,
    double? paidAmount,
    bool? isOnline,
    String? meetingUrl,
    UserModel? user,
    DoctorClinicProfile? doctor,
  }) {
    return ClinicAppointment(
      clinicAppointmentId: clinicAppointmentId ?? this.clinicAppointmentId,
      userId: userId ?? this.userId,
      doctorId: doctorId ?? this.doctorId,
      vendorId: vendorId ?? this.vendorId,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      adminUpdatedAt: adminUpdatedAt ?? this.adminUpdatedAt,
      userResponseStatus: userResponseStatus ?? this.userResponseStatus,
      paidAmount: paidAmount ?? this.paidAmount,
      isOnline: isOnline ?? this.isOnline,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      user: user ?? this.user,
      doctor: doctor ?? this.doctor,
    );
  }
} 