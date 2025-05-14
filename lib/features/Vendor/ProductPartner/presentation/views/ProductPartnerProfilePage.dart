import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/colorpalette/ProductPartnerColorPalette.dart';
import '../viewmodels/ProductPartnerProfileViewModel.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../../data/models/product_partner_model.dart';

class ProductPartnerProfilePage extends StatefulWidget {
  final String vendorId;
  
  const ProductPartnerProfilePage({
    Key? key,
    required this.vendorId,
  }) : super(key: key);

  @override
  State<ProductPartnerProfilePage> createState() => _ProductPartnerProfilePageState();
}

class _ProductPartnerProfilePageState extends State<ProductPartnerProfilePage> {
  final ScrollController _scrollController = ScrollController();
  bool _mounted = true;

  // Keys for different sections
  final GlobalKey _basicInfoKey = GlobalKey();
  final GlobalKey _businessDetailsKey = GlobalKey();
  final GlobalKey _locationKey = GlobalKey();
  final GlobalKey _documentsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
        context.read<ProductPartnerProfileViewModel>().initialize(widget.vendorId);
      }
    });
  }

  @override
  void dispose() {
    _mounted = false;
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      _scrollController.animateTo(
        position.dy - 100,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductPartnerProfileViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ProductPartnerColorPalette.primary),
            ),
          );
        }

        if (viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  viewModel.error!,
                  style: TextStyle(color: ProductPartnerColorPalette.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.loadProfile(widget.vendorId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ProductPartnerColorPalette.primary,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final profile = viewModel.profile;
        if (profile == null) {
          return const Center(child: Text('No profile found'));
        }

        return Scaffold(
          backgroundColor: ProductPartnerColorPalette.background,
          body: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(profile, viewModel),
                    const SizedBox(height: 24),
                    Container(key: _basicInfoKey, child: _buildBasicInfoSection(profile, viewModel)),
                    const SizedBox(height: 24),
                    Container(key: _businessDetailsKey, child: _buildBusinessDetailsSection(profile, viewModel)),
                    const SizedBox(height: 24),
                    Container(key: _locationKey, child: _buildLocationSection(profile, viewModel)),
                    const SizedBox(height: 24),
                    Container(key: _documentsKey, child: _buildDocumentsSection(profile, viewModel)),
                    
                    if (viewModel.isEditing) ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: OutlinedButton(
                          onPressed: () async {
                            final success = await viewModel.saveChanges();
                            if (success) {
                              _showSuccessSnackBar(context, 'Profile updated successfully');
                            } else {
                              _showErrorSnackBar(context, 'Failed to update profile');
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: ProductPartnerColorPalette.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.save_outlined,
                                color: ProductPartnerColorPalette.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Update Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: ProductPartnerColorPalette.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(ProductPartner profile, ProductPartnerProfileViewModel viewModel) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: ProductPartnerColorPalette.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: ProductPartnerColorPalette.primary, width: 3),
                          ),
                          child: profile.profilePicture.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    profile.profilePicture,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.business,
                                          size: 40,
                                          color: ProductPartnerColorPalette.primary,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Icon(
                                    Icons.business,
                                    size: 40,
                                    color: ProductPartnerColorPalette.primary,
                                  ),
                                ),
                        ),
                        if (viewModel.isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _showUploadDialog(context, 'Profile Photo'),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: ProductPartnerColorPalette.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.brandName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.companyLegalName,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (!viewModel.isEditing)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: ProductPartnerColorPalette.primary,
                      ),
                      onPressed: () {
                        viewModel.toggleEditMode();
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _scrollToSection(_basicInfoKey);
                        });
                      },
                      tooltip: 'Edit Profile',
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: profile.email,
                ),
                const SizedBox(height: 16),
                _buildProfileInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: profile.phoneNumber,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${profile.city}, ${profile.state}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.grey.shade700,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ProductPartnerColorPalette.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: ProductPartnerColorPalette.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(ProductPartner profile, ProductPartnerProfileViewModel viewModel) {
    return _buildSection(
      title: 'Basic Information',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildInfoTile(
            label: 'Brand Name',
            value: profile.brandName,
            icon: Icons.business,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(brandName: value),
            controller: viewModel.brandNameController,
          ),
          _buildInfoTile(
            label: 'Company Legal Name',
            value: profile.companyLegalName,
            icon: Icons.business_center,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(companyLegalName: value),
            controller: viewModel.companyLegalNameController,
          ),
          _buildInfoTile(
            label: 'GST Number',
            value: profile.gstNumber,
            icon: Icons.numbers,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(gstNumber: value),
            controller: viewModel.gstNumberController,
          ),
          _buildInfoTile(
            label: 'PAN Card Number',
            value: profile.panCardNumber,
            icon: Icons.credit_card,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(panCardNumber: value),
            controller: viewModel.panCardNumberController,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessDetailsSection(ProductPartner profile, ProductPartnerProfileViewModel viewModel) {
    return _buildSection(
      title: 'Business Details',
      icon: Icons.business_center,
      child: Column(
        children: [
          _buildInfoTile(
            label: 'Bank Account Number',
            value: profile.bankAccountNumber,
            icon: Icons.account_balance,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBusinessInfo(bankAccountNumber: value),
            controller: viewModel.bankAccountNumberController,
          ),
          _buildLicenseDetailsTile(
            label: 'License Details',
            licenses: profile.licenseDetails,
            isEditing: viewModel.isEditing,
            onAdd: () => _showAddLicenseDialog(context, viewModel),
            onDelete: (index) => viewModel.removeLicense(index),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(ProductPartner profile, ProductPartnerProfileViewModel viewModel) {
    return _buildSection(
      title: 'Location Details',
      icon: Icons.location_on_outlined,
      child: Column(
        children: [
          _buildInfoTile(
            label: 'Address',
            value: profile.address,
            icon: Icons.home,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateLocationInfo(address: value),
            controller: viewModel.addressController,
          ),
          _buildInfoTile(
            label: 'State',
            value: profile.state,
            icon: Icons.map,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateLocationInfo(state: value),
            controller: viewModel.stateController,
          ),
          _buildInfoTile(
            label: 'City',
            value: profile.city,
            icon: Icons.location_city,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateLocationInfo(city: value),
            controller: viewModel.cityController,
          ),
          _buildInfoTile(
            label: 'Pincode',
            value: profile.pincode,
            icon: Icons.pin,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateLocationInfo(pincode: value),
            controller: viewModel.pincodeController,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(ProductPartner profile, ProductPartnerProfileViewModel viewModel) {
    return _buildSection(
      title: 'Documents & Photos',
      icon: Icons.folder_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDocumentSectionHeader(
            label: 'License Documents',
            icon: Icons.assignment,
            onAddPressed: () => _showUploadDialog(context, 'License Document'),
            isEditing: viewModel.isEditing,
          ),
          if (viewModel.licenseDocuments.isNotEmpty)
            _buildDocumentList(
              documents: viewModel.licenseDocuments,
              isEditing: viewModel.isEditing,
              onDelete: (index) => viewModel.deleteDocument('license', index),
            ),

          const SizedBox(height: 16),

          _buildDocumentSectionHeader(
            label: 'Additional Photos',
            icon: Icons.photo_library,
            onAddPressed: () => _showUploadDialog(context, 'Additional Photo', isImage: true),
            isEditing: viewModel.isEditing,
          ),
          if (viewModel.additionalPhotos.isNotEmpty)
            _buildDocumentList(
              documents: viewModel.additionalPhotos,
              isEditing: viewModel.isEditing,
              onDelete: (index) => viewModel.deleteDocument('photo', index),
              isImage: true,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    required IconData icon,
    required bool isEditing,
    required Function(String?) onChanged,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                if (isEditing)
                  TextField(
                    controller: controller,
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: ProductPartnerColorPalette.primary),
                      ),
                      fillColor: Colors.grey.shade50,
                      filled: true,
                    ),
                  )
                else
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseDetailsTile({
    required String label,
    required List<Map<String, dynamic>> licenses,
    required bool isEditing,
    required VoidCallback onAdd,
    required Function(int) onDelete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.assignment, size: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const Spacer(),
            if (isEditing)
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline,
                  color: ProductPartnerColorPalette.primary,
                  size: 20,
                ),
                onPressed: onAdd,
                tooltip: 'Add License',
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (licenses.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(
              'No licenses added',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: licenses.length,
            itemBuilder: (context, index) {
              final license = licenses[index];
              return Card(
                margin: const EdgeInsets.only(left: 40, bottom: 8),
                child: ListTile(
                  title: Text(license['name'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Number: ${license['number'] ?? ''}'),
                      Text('Expiry: ${license['expiry'] ?? ''}'),
                      if (license['filePath'] != null)
                        Text(
                          'File: ${license['filePath'].split('/').last}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                  trailing: isEditing
                      ? IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => onDelete(index),
                        )
                      : null,
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildDocumentSectionHeader({
    required String label,
    required IconData icon,
    required VoidCallback onAddPressed,
    required bool isEditing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          const Spacer(),
          if (isEditing)
            IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                color: ProductPartnerColorPalette.primary,
                size: 20,
              ),
              onPressed: onAddPressed,
              tooltip: 'Add $label',
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentList({
    required List<Map<String, dynamic>> documents,
    required bool isEditing,
    required Function(int) onDelete,
    bool isImage = false,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isImage ? 1.2 : 0.8,
      ),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return _buildDocumentCard(
          url: document['url'] ?? '',
          name: document['name'] ?? 'Document ${index + 1}',
          isImage: isImage,
          isEditing: isEditing,
          onDelete: () => onDelete(index),
        );
      },
    );
  }

  Widget _buildDocumentCard({
    required String url,
    required String name,
    required bool isImage,
    required bool isEditing,
    required VoidCallback onDelete,
  }) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: isImage
                      ? Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade100,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey.shade400,
                                  size: 32,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: ProductPartnerColorPalette.primary.withOpacity(0.2),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.picture_as_pdf,
                                  color: ProductPartnerColorPalette.primary,
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'PDF Document',
                                  style: TextStyle(
                                    color: ProductPartnerColorPalette.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        if (isEditing)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red.shade700,
                  size: 18,
                ),
                onPressed: onDelete,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                tooltip: 'Delete document',
              ),
            ),
          ),
      ],
    );
  }

  void _showUploadDialog(BuildContext context, String title, {bool isImage = false}) {
    final viewModel = context.read<ProductPartnerProfileViewModel>();
    final TextEditingController nameController = TextEditingController();
    bool isNameValid = false;
    bool isFileSelected = false;
    File? selectedFile;
    String? selectedFileName;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ProductPartnerColorPalette.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isImage ? Icons.image : Icons.picture_as_pdf,
                            color: ProductPartnerColorPalette.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Add $title',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Document Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter a name for this document',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: ProductPartnerColorPalette.primary),
                        ),
                        prefixIcon: Icon(
                          Icons.label_outline,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          isNameValid = value.trim().isNotEmpty;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Select File',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: isUploading ? null : () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: isImage ? FileType.image : FileType.custom,
                          allowedExtensions: isImage ? null : ['pdf'],
                          allowMultiple: false,
                        );

                        if (result != null && result.files.isNotEmpty) {
                          setState(() {
                            selectedFile = File(result.files.single.path!);
                            selectedFileName = result.files.single.name;
                            isFileSelected = true;

                            if (nameController.text.isEmpty) {
                              String fileNameWithoutExt = path.basenameWithoutExtension(selectedFileName!);
                              nameController.text = fileNameWithoutExt;
                              isNameValid = true;
                            }
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: isFileSelected ? Colors.green.shade50 : ProductPartnerColorPalette.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isFileSelected ? Colors.green.shade200 : ProductPartnerColorPalette.primary,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              isFileSelected
                                  ? Icons.check_circle
                                  : (isImage ? Icons.image : Icons.picture_as_pdf),
                              color: isFileSelected ? Colors.green.shade700 : ProductPartnerColorPalette.primary,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isFileSelected
                                  ? selectedFileName ?? 'File Selected'
                                  : 'Click to select ${isImage ? 'image' : 'PDF'}',
                              style: TextStyle(
                                color: isFileSelected ? Colors.green.shade700 : ProductPartnerColorPalette.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (!isFileSelected) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Supported formats: ${isImage ? 'JPG, PNG' : 'PDF'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isUploading ? null : () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: (isNameValid && isFileSelected && !isUploading) ? () async {
                            setState(() {
                              isUploading = true;
                            });
                            
                            try {
                              await viewModel.uploadDocument(
                                selectedFile!,
                                'license',
                                nameController.text,
                              );
                              
                              _showSuccessSnackBar(context, 'Document uploaded successfully');
                              Navigator.pop(context);
                            } catch (e) {
                              setState(() {
                                isUploading = false;
                              });
                              _showErrorSnackBar(context, 'Failed to upload document: $e');
                            }
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ProductPartnerColorPalette.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: isUploading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Upload',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddLicenseDialog(BuildContext context, ProductPartnerProfileViewModel viewModel) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController numberController = TextEditingController();
    final TextEditingController expiryController = TextEditingController();
    String? selectedFilePath;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add License',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'License Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: numberController,
                      decoration: InputDecoration(
                        labelText: 'License Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: expiryController,
                      decoration: InputDecoration(
                        labelText: 'Expiry Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (picked != null) {
                          expiryController.text = '${picked.day}/${picked.month}/${picked.year}';
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload License',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Supported formats: PDF, JPG, JPEG, PNG',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Text(
                                    selectedFilePath != null 
                                        ? selectedFilePath!.split('/').last
                                        : 'No file selected',
                                    style: TextStyle(
                                      color: selectedFilePath != null ? Colors.grey[800] : Colors.grey[500],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                                  );
                                  if (result != null) {
                                    setState(() {
                                      selectedFilePath = result.files.single.path;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.upload_file, color: Colors.white),
                                label: Text(selectedFilePath != null ? 'Change' : 'Browse'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ProductPartnerColorPalette.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (nameController.text.isNotEmpty && 
                                numberController.text.isNotEmpty && 
                                expiryController.text.isNotEmpty) {
                              viewModel.addLicense({
                                'name': nameController.text,
                                'number': numberController.text,
                                'expiry': expiryController.text,
                                'filePath': selectedFilePath,
                              });
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ProductPartnerColorPalette.primary,
                          ),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Success!',
          message: message,
          contentType: ContentType.success,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error!',
          message: message,
          contentType: ContentType.failure,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
} 