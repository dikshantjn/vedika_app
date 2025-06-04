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
  final TextEditingController _passwordController = TextEditingController();
  final String _dummyPassword = "123456"; // Dummy password for demonstration
  late TabController _tabController;
  static const String _authTimeKey = 'health_records_last_auth_time';
  static const int _authSessionMinutes = 15;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _checkAuthSession();
    Future.microtask(() => Provider.of<HealthRecordViewModel>(context, listen: false).loadRecords());
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
      if (now.difference(lastAuth).inMinutes < _authSessionMinutes) {
        setState(() {
          isAuthenticated = true;
        });
      }
    }
  }

  void _authenticate() async {
    if (_passwordController.text == _dummyPassword) {
      setState(() {
        isAuthenticated = true;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_authTimeKey, DateTime.now().millisecondsSinceEpoch);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect password. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isAuthenticated) {
      return _buildPasswordScreen();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Health Records",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: ColorPalette.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline),
            onPressed: () {
              setState(() {
                isAuthenticated = false;
                _passwordController.clear();
              });
            },
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
                });
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
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
                    onPressed: _authenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Access Records',
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
              return HealthRecordItem(filteredRecords[index]);
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
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorPalette.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 2,
                              ),
                              icon: isUploading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.cloud_upload),
                              label: Text(isUploading ? 'Uploading...' : 'Upload', style: const TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: isUploading
                                  ? null
                                  : () async {
                                      if (!_formKey.currentState!.validate() || pickedFile == null) return;
                                      setState(() => isUploading = true);
                                      await Provider.of<HealthRecordViewModel>(context, listen: false)
                                          .uploadRecordWithDialog(name!, selectedType!, pickedFile!, context);
                                      setState(() => isUploading = false);
                                      Navigator.pop(context);
                                    },
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

