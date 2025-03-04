import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/HealthRecords/data/models/HealthRecord.dart';
import 'package:vedika_healthcare/features/HealthRecords/presentation/viewmodel/HealthRecordViewModel.dart';
import 'package:vedika_healthcare/features/HealthRecords/presentation/view/HealthRecordItem.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';

class HealthRecordsPage extends StatefulWidget {
  @override
  _HealthRecordsPageState createState() => _HealthRecordsPageState();
}

class _HealthRecordsPageState extends State<HealthRecordsPage> {
  final List<String> categories = [
    "All", // Added "All" category
    "Prescription",
    "Test Reports",
    "Medical Bills",
    "Mediclaim Policy",
    "Vaccine/Immunization History"
  ];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<HealthRecordViewModel>(context, listen: false).loadRecords());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Health Records"),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: ColorPalette.primaryColor,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickFile(),
        backgroundColor: ColorPalette.primaryColor,
        child: const Icon(Icons.upload_file, color: Colors.white),
      ),
      drawer: DrawerMenu(),
      body: Column(
        children: [
          _buildCategorySelector(),
          const SizedBox(height: 8),
          _buildRecordList(),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => setState(() => selectedIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              decoration: BoxDecoration(
                color: selectedIndex == index ? ColorPalette.primaryColor : Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  fontSize: 14,
                  color: selectedIndex == index ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordList() {
    return Expanded(
      child: Consumer<HealthRecordViewModel>(
        builder: (context, healthRecordVM, child) {
          String selectedCategory = categories[selectedIndex];

          List<HealthRecord> filteredRecords = selectedCategory == "All"
              ? healthRecordVM.records // Show all records
              : healthRecordVM.records.where((record) => record.type == selectedCategory).toList();

          if (filteredRecords.isEmpty) {
            return Center(
              child: Text(
                "No ${selectedCategory == "All" ? "health records" : "$selectedCategory records"} found.",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemCount: filteredRecords.length,
              itemBuilder: (context, index) {
                return HealthRecordItem(filteredRecords[index]);
              },
            ),
          );
        },
      ),
    );
  }

  /// Function to pick a file
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      // Upload file to ViewModel
      Provider.of<HealthRecordViewModel>(context, listen: false).uploadRecord(file, categories[selectedIndex]);
    }
  }
}

