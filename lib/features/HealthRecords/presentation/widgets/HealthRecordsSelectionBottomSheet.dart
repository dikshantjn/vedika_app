import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/features/HealthRecords/data/models/HealthRecord.dart';
import 'package:vedika_healthcare/features/HealthRecords/presentation/viewmodel/HealthRecordViewModel.dart';

class HealthRecordsSelectionBottomSheet extends StatefulWidget {
  final List<String>? preSelectedIds;
  final Function(List<String>) onRecordsSelected;

  const HealthRecordsSelectionBottomSheet({
    Key? key,
    this.preSelectedIds,
    required this.onRecordsSelected,
  }) : super(key: key);

  @override
  State<HealthRecordsSelectionBottomSheet> createState() => _HealthRecordsSelectionBottomSheetState();
}

class _HealthRecordsSelectionBottomSheetState extends State<HealthRecordsSelectionBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  List<String> _selectedRecordIds = [];
  bool _isLoading = true;

  final List<String> _filterOptions = [
    'All',
    'Lab Reports',
    'Prescriptions',
    'Medical Certificates',
    'X-Ray Reports',
    'MRI Reports',
    'CT Scan Reports',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedRecordIds = List.from(widget.preSelectedIds ?? []);
    _loadHealthRecords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHealthRecords() async {
    setState(() => _isLoading = true);
    await context.read<HealthRecordViewModel>().loadRecords();
    setState(() => _isLoading = false);
  }

  List<HealthRecord> get _filteredRecords {
    final viewModel = context.read<HealthRecordViewModel>();
    List<HealthRecord> records = viewModel.records;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      records = records.where((record) =>
          record.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          record.type.toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }

    // Apply category filter
    if (_selectedFilter != 'All') {
      records = records.where((record) => record.type == _selectedFilter).toList();
    }

    return records;
  }

  void _toggleRecordSelection(String recordId) {
    setState(() {
      if (_selectedRecordIds.contains(recordId)) {
        _selectedRecordIds.remove(recordId);
      } else {
        _selectedRecordIds.add(recordId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedRecordIds = _filteredRecords.map((record) => record.healthRecordId).toList();
    });
  }

  void _clearAll() {
    setState(() {
      _selectedRecordIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(),
          _buildSearchAndFilter(),
          _buildRecordsList(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.medical_information,
              color: DoctorConsultationColorPalette.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Health Records',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: DoctorConsultationColorPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose records to share with your doctor',
                  style: TextStyle(
                    fontSize: 14,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_selectedRecordIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: DoctorConsultationColorPalette.primaryBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_selectedRecordIds.length} selected',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: DoctorConsultationColorPalette.backgroundCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search health records...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: DoctorConsultationColorPalette.primaryBlue),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[500]),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.2),
                    checkmarkColor: DoctorConsultationColorPalette.primaryBlue,
                    labelStyle: TextStyle(
                      color: isSelected 
                          ? DoctorConsultationColorPalette.primaryBlue 
                          : DoctorConsultationColorPalette.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected 
                          ? DoctorConsultationColorPalette.primaryBlue 
                          : Colors.grey[300]!,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    return Expanded(
      child: Consumer<HealthRecordViewModel>(
        builder: (context, viewModel, child) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: DoctorConsultationColorPalette.primaryBlue,
              ),
            );
          }

          final filteredRecords = _filteredRecords;

          if (filteredRecords.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Select All / Clear All buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: _selectAll,
                      icon: const Icon(Icons.select_all, size: 18),
                      label: const Text('Select All'),
                      style: TextButton.styleFrom(
                        foregroundColor: DoctorConsultationColorPalette.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: _clearAll,
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text('Clear All'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Records List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];
                    final isSelected = _selectedRecordIds.contains(record.healthRecordId);
                    return _buildRecordItem(record, isSelected);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecordItem(HealthRecord record, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected 
            ? DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? DoctorConsultationColorPalette.primaryBlue
              : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleRecordSelection(record.healthRecordId),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Selection Checkbox
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected 
                          ? DoctorConsultationColorPalette.primaryBlue
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                    color: isSelected 
                        ? DoctorConsultationColorPalette.primaryBlue
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // Record Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(record.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(record.type),
                    color: _getCategoryColor(record.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                // Record Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: DoctorConsultationColorPalette.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.type,
                        style: TextStyle(
                          fontSize: 14,
                          color: _getCategoryColor(record.type),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(record.uploadedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: DoctorConsultationColorPalette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // File Type Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getFileExtension(record.name),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medical_information_outlined,
                color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.6),
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Health Records Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DoctorConsultationColorPalette.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No records match your search criteria'
                  : 'You haven\'t uploaded any health records yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: DoctorConsultationColorPalette.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Navigate to upload health records screen
              },
              icon: const Icon(Icons.add),
              label: const Text('Upload Health Records'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey[400]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _selectedRecordIds.isNotEmpty
                  ? () {
                      widget.onRecordsSelected(_selectedRecordIds);
                      Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                _selectedRecordIds.isEmpty
                    ? 'Select Records'
                    : 'Share ${_selectedRecordIds.length} Record${_selectedRecordIds.length > 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String type) {
    switch (type.toLowerCase()) {
      case 'lab reports':
        return Colors.blue;
      case 'prescriptions':
        return Colors.green;
      case 'medical certificates':
        return Colors.orange;
      case 'x-ray reports':
        return Colors.purple;
      case 'mri reports':
        return Colors.teal;
      case 'ct scan reports':
        return Colors.indigo;
      default:
        return DoctorConsultationColorPalette.primaryBlue;
    }
  }

  IconData _getCategoryIcon(String type) {
    switch (type.toLowerCase()) {
      case 'lab reports':
        return Icons.science;
      case 'prescriptions':
        return Icons.medication;
      case 'medical certificates':
        return Icons.verified;
      case 'x-ray reports':
        return Icons.visibility;
      case 'mri reports':
        return Icons.scanner;
      case 'ct scan reports':
        return Icons.medical_services;
      default:
        return Icons.description;
    }
  }

  String _getFileExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : 'FILE';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
