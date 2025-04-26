import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/HospitalVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/HospitalRegistrationViewModel.dart';

// Create a global key to access the state from anywhere
final GlobalKey<_CertificationSectionState> certificationSectionKey = GlobalKey<_CertificationSectionState>();

class CertificationSection extends StatefulWidget {
  const CertificationSection({Key? key}) : super(key: key);

  @override
  _CertificationSectionState createState() => _CertificationSectionState();
}

class _CertificationSectionState extends State<CertificationSection> with AutomaticKeepAliveClientMixin {
  // Keep state alive between page changes
  @override
  bool get wantKeepAlive => true;

  List<Map<String, Object>> _certificationFiles = [];
  List<Map<String, Object>> _licenseFiles = [];
  List<Map<String, Object>> _businessDocFiles = [];
  Map<String, Object>? _panCardFile;
  bool _filesLoaded = false;
  
  // Text controllers for document names
  final TextEditingController _documentNameController = TextEditingController();

  @override
  void dispose() {
    _documentNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Ensure we load data when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFilesFromViewModel();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load files when dependencies change (like when the ViewModel updates)
    _loadFilesFromViewModel();
  }

  void _loadFilesFromViewModel() {
    if (_filesLoaded) return;

    try {
      final viewModel = Provider.of<HospitalRegistrationViewModel>(context, listen: false);
      
      // Load PAN card
      if (viewModel.panCardFile != null) {
        final fileData = viewModel.panCardFile!['file'];
        if (fileData != null) {
          setState(() {
            _panCardFile = {
              'name': viewModel.panCardFile!['name'] as String? ?? 'PAN Card',
              'file': fileData,
            };
          });
          print('Loaded PAN card: ${viewModel.panCardFile!['name']}');
        }
      }
      
      // Load business documents - ensuring null safety
      final businessDocs = viewModel.businessDocuments;
      if (businessDocs.isNotEmpty) {
        final newBusinessDocs = <Map<String, Object>>[];
        for (var doc in businessDocs) {
          final fileData = doc['file'];
          if (fileData != null) {
            newBusinessDocs.add({
              'name': doc['name'] as String? ?? 'Document',
              'file': fileData,
            });
          }
        }
        
        if (newBusinessDocs.isNotEmpty) {
          setState(() {
            _businessDocFiles = newBusinessDocs;
          });
          print('Loaded ${newBusinessDocs.length} business documents');
        }
      }
      
      // Load certification files from ViewModel
      if (viewModel.certifications.isNotEmpty && viewModel.certificationFiles.isNotEmpty) {
        final newCertFiles = <Map<String, Object>>[];
        for (int i = 0; i < viewModel.certifications.length && i < viewModel.certificationFiles.length; i++) {
          newCertFiles.add({
            'name': viewModel.certifications[i]['name'] ?? 'Certification',
            'file': viewModel.certificationFiles[i],
          });
        }
        
        if (newCertFiles.isNotEmpty) {
          setState(() {
            _certificationFiles = newCertFiles;
          });
          print('Loaded ${newCertFiles.length} certification files');
        }
      }
      
      // Load license files from ViewModel
      if (viewModel.licenses.isNotEmpty && viewModel.licenseFiles.isNotEmpty) {
        final newLicFiles = <Map<String, Object>>[];
        for (int i = 0; i < viewModel.licenses.length && i < viewModel.licenseFiles.length; i++) {
          newLicFiles.add({
            'name': viewModel.licenses[i]['name'] ?? 'License',
            'file': viewModel.licenseFiles[i],
          });
        }
        
        if (newLicFiles.isNotEmpty) {
          setState(() {
            _licenseFiles = newLicFiles;
          });
          print('Loaded ${newLicFiles.length} license files');
        }
      }
      
      setState(() {
        _filesLoaded = true;
      });
    } catch (e) {
      print("Error loading files: $e");
      setState(() {
        _filesLoaded = true; // Mark as loaded to prevent repeated attempts
      });
    }
  }

  // Method to manually reload all files (can be called externally)
  void reloadFiles() {
    setState(() {
      _filesLoaded = false;
    });
    _loadFilesFromViewModel();
  }

  void _showDocumentNameDialog(String documentType) {
    _documentNameController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Name Your $documentType'),
          content: TextField(
            controller: _documentNameController,
            decoration: InputDecoration(
              hintText: 'Enter document name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: HospitalVendorColorPalette.textSecondary,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_documentNameController.text.trim().isNotEmpty) {
                  Navigator.pop(context, _documentNameController.text.trim());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a document name'),
                      backgroundColor: HospitalVendorColorPalette.errorRed,
                    ),
                  );
                }
              },
              child: Text('Continue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: HospitalVendorColorPalette.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    ).then((documentName) {
      if (documentName != null) {
        _pickFileWithName(documentType, documentName);
      }
    });
  }

  Future<void> _pickFileWithName(String documentType, String documentName) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final file = File(path);
      final viewModel = Provider.of<HospitalRegistrationViewModel>(context, listen: false);
      
      switch (documentType) {
        case 'PAN Card':
          final panData = {
            'name': documentName,
            'file': file,
          };
          setState(() {
            _panCardFile = panData;
          });
          
          // Update ViewModel
          viewModel.setPanCardFile(panData);
          print('Added PAN card: $documentName');
          break;
        
        case 'Certifications':
          final certData = {
            'name': documentName,
            'file': file,
          };
          setState(() {
            _certificationFiles.add(certData);
          });
          
          // Update ViewModel
          viewModel.uploadCertifications([certData]);
          print('Added certification: $documentName');
          break;
        
        case 'Licenses':
          final licData = {
            'name': documentName,
            'file': file,
          };
          setState(() {
            _licenseFiles.add(licData);
          });
          
          // Update ViewModel
          viewModel.uploadLicenses([licData]);
          print('Added license: $documentName');
          break;
        
        case 'Business Documents':
          // First check if this document already exists to avoid duplicates
          bool documentExists = _businessDocFiles.any((doc) => 
            doc['name'] == documentName && 
            ((doc['file'] as File).path == file.path));
            
          if (!documentExists) {
            final docData = {
              'name': documentName,
              'file': file,
            };
            
            setState(() {
              _businessDocFiles.add(docData);
            });
            
            // Update ViewModel - make sure we're creating a new object
            viewModel.addBusinessDocument(Map<String, dynamic>.from(docData));
            print('Added business document: $documentName');
          }
          break;
        
        default:
          break;
      }
    }
  }

  void _removeFile(String label, int index) {
    final viewModel = Provider.of<HospitalRegistrationViewModel>(context, listen: false);
    
    switch (label) {
      case 'PAN Card':
        setState(() {
          _panCardFile = null;
        });
        viewModel.panCardFile = null;
        print('Removed PAN card');
        break;
      
      case 'Certifications':
        if (index < _certificationFiles.length) {
          final name = _certificationFiles[index]['name'];
          setState(() {
            _certificationFiles.removeAt(index);
          });
          viewModel.removeCertificationFile(index);
          print('Removed certification: $name');
        }
        break;
      
      case 'Licenses':
        if (index < _licenseFiles.length) {
          final name = _licenseFiles[index]['name'];
          setState(() {
            _licenseFiles.removeAt(index);
          });
          viewModel.removeLicenseFile(index);
          print('Removed license: $name');
        }
        break;
      
      case 'Business Documents':
        if (index < _businessDocFiles.length) {
          final name = _businessDocFiles[index]['name'];
          setState(() {
            _businessDocFiles.removeAt(index);
          });
          viewModel.removeBusinessDocument(index);
          print('Removed business document: $name');
        }
        break;
      
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    // Force refresh the file lists from ViewModel if needed
    if (!_filesLoaded) {
      _loadFilesFromViewModel();
    }
    
    // Keep reference to ViewModel for debugging
    final viewModel = Provider.of<HospitalRegistrationViewModel>(context, listen: false);
    print('Business docs count in ViewModel: ${viewModel.businessDocuments.length}');
    print('PAN card in ViewModel: ${viewModel.panCardFile != null ? viewModel.panCardFile!['name'] : 'null'}');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Certifications & Licenses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: HospitalVendorColorPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        
        // PAN Card
        _buildFileSection('PAN Card', _panCardFile != null ? [_panCardFile!] : [], true),
        const SizedBox(height: 24),
        
        // Certifications
        _buildFileSection('Certifications', _certificationFiles, false),
        const SizedBox(height: 24),
        
        // Licenses
        _buildFileSection('Licenses', _licenseFiles, false),
        const SizedBox(height: 24),
        
        // Business Documents
        _buildFileSection('Business Documents', _businessDocFiles, false),
        
        // Debug button - only for testing
        if (false) // Set to true for debugging
          ElevatedButton(
            onPressed: reloadFiles,
            child: Text('Reload Files (Debug)'),
          ),
      ],
    );
  }

  Widget _buildFileSection(String label, List<Map<String, Object>> files, bool isSingleFile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: HospitalVendorColorPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload ${isSingleFile ? 'your' : 'all relevant'} $label documents',
          style: TextStyle(
            fontSize: 12,
            color: HospitalVendorColorPalette.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        if (files.isEmpty || !isSingleFile)
          _buildFilePickerButton(label),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: files.length,
          itemBuilder: (context, index) {
            final name = files[index]['name'] as String? ?? 'Document';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildFileListItem(name, () => _removeFile(label, index)),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildFilePickerButton(String label) {
    return ElevatedButton.icon(
      onPressed: () => _showDocumentNameDialog(label),
      icon: const Icon(Icons.upload_file, size: 18),
      label: Text('Add $label'),
      style: ElevatedButton.styleFrom(
        backgroundColor: HospitalVendorColorPalette.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  Widget _buildFileListItem(String name, VoidCallback onDelete) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: HospitalVendorColorPalette.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: HospitalVendorColorPalette.neutralGrey200,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.insert_drive_file_outlined,
            size: 20,
            color: HospitalVendorColorPalette.primaryBlue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: HospitalVendorColorPalette.errorRed,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
} 