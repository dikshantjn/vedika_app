import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/HealthRecords/data/models/HealthRecord.dart';
import 'package:vedika_healthcare/features/HealthRecords/presentation/viewmodel/HealthRecordViewModel.dart';
import 'package:vedika_healthcare/features/HealthRecords/presentation/view/HealthRecordItem.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthRecordsPage extends StatefulWidget {
  @override
  _HealthRecordsPageState createState() => _HealthRecordsPageState();
}

class _HealthRecordsPageState extends State<HealthRecordsPage> with SingleTickerProviderStateMixin {
  final Map<String, String> categoryIdMap = {
    "All": "all",
    "Prescription": "prescription",
    "Test Reports": "test_report",
    "Medical Bills": "medical_bill",
    "Mediclaim Policy": "mediclaim_policy",
    "Vaccine/Immunization History": "vaccine_history"
  };
  final List<String> categories = [
    "All",
    "Prescription",
    "Test Reports",
    "Medical Bills",
    "Mediclaim Policy",
    "Vaccine/Immunization History"
  ];

  int selectedIndex = 0;
  bool isAuthenticated = false;
  bool isPasswordSet = false;
  bool isSettingPassword = false;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _setPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final String _dummyPassword = "123456"; // Dummy password for demonstration
  late TabController _tabController;
  static const String _authTimeKey = 'health_records_last_auth_time';
  static const int _authSessionMinutes = 15;
  
  // Add selection state
  Set<String> selectedRecordIds = {};
  bool isSelectionMode = false;
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _setPasswordFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isCheckingPassword = true;
  bool _isDeleting = false;
  String? _selectedRecordId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _checkAuthSession();
    _checkPasswordStatus();
    Future.microtask(() => Provider.of<HealthRecordViewModel>(context, listen: false).loadRecords());
  }

  // Add method to handle selection
  void _toggleSelection(String recordId) {
    setState(() {
      if (selectedRecordIds.contains(recordId)) {
        selectedRecordIds.remove(recordId);
        if (selectedRecordIds.isEmpty) {
          isSelectionMode = false;
        }
      } else {
        selectedRecordIds.add(recordId);
        isSelectionMode = true;
      }
    });
  }

  // Add method to clear selection
  void _clearSelection() {
    setState(() {
      selectedRecordIds.clear();
      isSelectionMode = false;
    });
  }

  // Add method to show share bottom sheet
  void _showShareBottomSheet(BuildContext context, HealthRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Share ${selectedRecordIds.length > 1 ? 'Records' : 'Record'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: FutureBuilder(
                      future: Future.delayed(Duration.zero, () {
                        return context.read<HealthRecordViewModel>().loadOngoingMeetings();
                      }),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final meetings = context.watch<HealthRecordViewModel>().ongoingMeetings;
                        if (meetings.isEmpty) {
                          return const Center(
                            child: Text('No ongoing appointments found'),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: meetings.length,
                          itemBuilder: (context, index) {
                            final meeting = meetings[index];
                            // Format date and time
                            final date = meeting.date;
                            final formattedDate = '${date.day}/${date.month}/${date.year}';
                            final time = meeting.time.split(':');
                            final formattedTime = '${time[0]}:${time[1]} ${int.parse(time[0]) >= 12 ? 'PM' : 'AM'}';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    // Get the list of selected record IDs
                                    final recordIds = selectedRecordIds.isNotEmpty 
                                        ? selectedRecordIds.toList() 
                                        : [record.healthRecordId];

                                    final success = await context.read<HealthRecordViewModel>()
                                        .shareHealthRecordsWithDoctor(
                                      clinicAppointmentId: meeting.clinicAppointmentId,
                                      healthRecordIds: recordIds,
                                    );

                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Shared ${recordIds.length} record${recordIds.length > 1 ? 's' : ''} with Dr. ${meeting.doctor?.doctorName}',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pop(context);
                                      _clearSelection();
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Failed to share health records'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Doctor's Profile Picture
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: ColorPalette.primaryColor.withOpacity(0.2),
                                              width: 2,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(30),
                                            child: meeting.doctor?.profilePicture != null
                                                ? Image.network(
                                                    meeting.doctor!.profilePicture!,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context, child, loadingProgress) {
                                                      if (loadingProgress == null) return child;
                                                      return Container(
                                                        color: Colors.grey[100],
                                                        child: Center(
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor: AlwaysStoppedAnimation<Color>(
                                                              ColorPalette.primaryColor,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        color: Colors.grey[100],
                                                        child: Icon(
                                                          Icons.person,
                                                          size: 30,
                                                          color: Colors.grey[400],
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : Container(
                                                    color: Colors.grey[100],
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 30,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Doctor's Information
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                meeting.doctor?.doctorName ?? 'Unknown Doctor',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2D3142),
                                                ),
                                              ),
                                              if (meeting.doctor?.specializations != null) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  meeting.doctor!.specializations.join(', '),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[600],
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                              const SizedBox(height: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: ColorPalette.primaryColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_today,
                                                      size: 14,
                                                      color: ColorPalette.primaryColor,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        '$formattedDate at $formattedTime',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: ColorPalette.primaryColor,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Share Icon
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: ColorPalette.primaryColor.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.share_rounded,
                                            size: 20,
                                            color: ColorPalette.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthSession() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAuthMillis = prefs.getInt(_authTimeKey);
    
    if (lastAuthMillis != null) {
      final lastAuth = DateTime.fromMillisecondsSinceEpoch(lastAuthMillis);
      final now = DateTime.now();
      final difference = now.difference(lastAuth).inMinutes;
      
      print('🔐 Session check:');
      print('   Last auth: $lastAuth');
      print('   Current time: $now');
      print('   Minutes passed: $difference');
      print('   Session valid: ${difference < _authSessionMinutes}');
      
      if (difference < _authSessionMinutes) {
        setState(() {
          isAuthenticated = true;
        });
      } else {
        // Clear expired session
        await prefs.remove(_authTimeKey);
        setState(() {
          isAuthenticated = false;
        });
      }
    }
  }

  Future<void> _checkPasswordStatus() async {
    setState(() {
      _isCheckingPassword = true;
    });
    
    final viewModel = Provider.of<HealthRecordViewModel>(context, listen: false);
    final isSet = await viewModel.checkHealthRecordPasswordSet();
    
    setState(() {
      isPasswordSet = isSet;
      _isCheckingPassword = false;
    });
  }

  Future<void> _setPassword() async {
    if (!_setPasswordFormKey.currentState!.validate()) return;

    if (_setPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final viewModel = Provider.of<HealthRecordViewModel>(context, listen: false);
    final success = await viewModel.setHealthRecordPassword(_setPasswordController.text);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password set successfully'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        isPasswordSet = true;
        isSettingPassword = false;
        _setPasswordController.clear();
        _confirmPasswordController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to set password. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _verifyPassword() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final viewModel = Provider.of<HealthRecordViewModel>(context, listen: false);
    final success = await viewModel.verifyPassword(_passwordController.text);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Save the authentication time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_authTimeKey, DateTime.now().millisecondsSinceEpoch);
      
      setState(() {
        isAuthenticated = true;
        _passwordController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid password. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _lockSession() async {
    setState(() {
      isAuthenticated = false;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTimeKey);
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPassword) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Checking security...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!isPasswordSet) {
      setState(() {
        isSettingPassword = true;
      });
      return _buildPasswordScreen();
    }

    if (!isAuthenticated) {
      return _buildPasswordScreen();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          isSelectionMode ? '${selectedRecordIds.length} Selected' : "Health Records",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: ColorPalette.primaryColor,
        elevation: 0,
        actions: [
          if (isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () => _showShareBottomSheet(
                context,
                HealthRecord(
                  healthRecordId: '',
                  userId: '',
                  name: '',
                  type: '',
                  fileUrl: '',
                  uploadedAt: DateTime.now(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearSelection,
            ),
          ],
          IconButton(
            icon: const Icon(Icons.lock_outline),
            onPressed: _lockSession,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            height: 50,
            padding: const EdgeInsets.only(left: 0, right: 16, top: 8, bottom: 8),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: categories.map((category) => Tab(text: category)).toList(),
              onTap: (index) {
                setState(() {
                  selectedIndex = index;
                  _clearSelection();
                });
              },
            ),
          ),
        ),
      ),
      floatingActionButton: isSelectionMode ? null : FloatingActionButton.extended(
        onPressed: () => _showUploadDialog(),
        backgroundColor: ColorPalette.primaryColor,
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: const Text('Upload Record', style: TextStyle(color: Colors.white)),
      ),
      drawer: DrawerMenu(),
      body: TabBarView(
        controller: _tabController,
        children: categories.map((category) => _buildRecordList(category)).toList(),
      ),
    );
  }

  Widget _buildPasswordScreen() {
    if (isSettingPassword) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _setPasswordFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: ColorPalette.primaryColor.withOpacity(0.1),
                            spreadRadius: 5,
                            blurRadius: 15,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        size: 80,
                        color: ColorPalette.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Set Password',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Please set a password to secure your health records',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _setPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Enter Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _setPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _setPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Set Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ColorPalette.primaryColor.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 15,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.health_and_safety,
                    size: 80,
                    color: ColorPalette.primaryColor,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Health Records',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please enter password to access your health records',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Enter Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Access Records',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // TODO: Implement forgot password functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Forgot password functionality coming soon'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: ColorPalette.primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordList(String category) {
    return Consumer<HealthRecordViewModel>(
      builder: (context, healthRecordVM, child) {
        if (healthRecordVM.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Loading health records...",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }

        String? categoryId = categoryIdMap[category];
        List<HealthRecord> filteredRecords = categoryId == "all"
            ? healthRecordVM.records
            : healthRecordVM.records.where((record) => record.type == categoryId).toList();

        if (filteredRecords.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.folder_open,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "No ${category == "All" ? "health records" : "$category records"} found.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Tap the upload button to add records",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: filteredRecords.length,
            itemBuilder: (context, index) {
              final record = filteredRecords[index];
              return HealthRecordItem(
                record,
                isSelected: selectedRecordIds.contains(record.healthRecordId),
                onSelect: () => _toggleSelection(record.healthRecordId),
                isSelectionMode: selectedRecordIds.isNotEmpty,
              );
            },
          ),
        );
      },
    );
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? name;
        String? selectedType = categoryIdMap[categories[selectedIndex]] == 'all' ? null : categoryIdMap[categories[selectedIndex]];
        PlatformFile? pickedFile;
        bool isUploading = false;
        final _formKey = GlobalKey<FormState>();

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 8,
              backgroundColor: Colors.white,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: ColorPalette.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(18),
                                child: const Icon(Icons.upload_file, size: 40, color: ColorPalette.primaryColor),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Upload Health Record',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ColorPalette.primaryColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Name',
                            prefixIcon: const Icon(Icons.edit_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          onChanged: (val) => name = val,
                          validator: (val) => val == null || val.isEmpty ? 'Enter a name' : null,
                        ),
                        const SizedBox(height: 18),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return DropdownButtonFormField<String>(
                              value: selectedType,
                              isExpanded: true,
                              items: categoryIdMap.entries
                                .where((e) => e.key != 'All')
                                .map((e) => DropdownMenuItem(
                                  value: e.value,
                                  child: Text(e.key),
                                )).toList(),
                              onChanged: (val) => setState(() => selectedType = val),
                              decoration: InputDecoration(
                                labelText: 'Type',
                                prefixIcon: const Icon(Icons.category_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (val) => val == null ? 'Select a type' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: isUploading
                              ? null
                              : () async {
                                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                                  );
                                  if (result != null) {
                                    setState(() => pickedFile = result.files.first);
                                  }
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: pickedFile != null ? ColorPalette.primaryColor : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  pickedFile != null ? Icons.check_circle : Icons.attach_file,
                                  color: pickedFile != null ? Colors.green : Colors.grey[600],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    pickedFile?.name ?? 'Select file or image',
                                    style: TextStyle(
                                      color: pickedFile != null ? Colors.black87 : Colors.grey[600],
                                      fontWeight: pickedFile != null ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (pickedFile != null)
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                                    onPressed: isUploading ? null : () => setState(() => pickedFile = null),
                                    tooltip: 'Remove file',
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: isUploading ? null : () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorPalette.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 2,
                                ),
                                icon: isUploading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.cloud_upload),
                                label: Text(
                                  isUploading ? 'Uploading...' : 'Upload',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onPressed: isUploading
                                    ? null
                                    : () async {
                                        if (!_formKey.currentState!.validate() || pickedFile == null) return;
                                        setState(() => isUploading = true);
                                        await context.read<HealthRecordViewModel>()
                                            .uploadRecordWithDialog(name!, selectedType!, pickedFile!, context);
                                        setState(() => isUploading = false);
                                        Navigator.pop(context);
                                      },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

