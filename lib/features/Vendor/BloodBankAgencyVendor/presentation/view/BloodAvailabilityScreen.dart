import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/services/BloodInventoryService.dart';
import '../viewModel/BloodAvailabilityViewModel.dart';
import '../../data/model/BloodInventory.dart';
import 'dart:developer' as developer;

class BloodAvailabilityScreen extends StatefulWidget {
  const BloodAvailabilityScreen({super.key});

  @override
  State<BloodAvailabilityScreen> createState() => _BloodAvailabilityScreenState();
}

class _BloodAvailabilityScreenState extends State<BloodAvailabilityScreen> with AutomaticKeepAliveClientMixin {
  bool _mounted = true;
  bool _isAdding = false;
  late final BloodAvailabilityViewModel _viewModel;
  bool _isInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    developer.log('BloodAvailabilityScreen: initState called', name: 'BloodAvailability');
    _viewModel = context.read<BloodAvailabilityViewModel>();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    if (!_mounted || _isDisposed) return;
    
    developer.log('BloodAvailabilityScreen: Initializing screen', name: 'BloodAvailability');
    try {
      if (!_viewModel.isInitialized) {
        developer.log('BloodAvailabilityScreen: Loading initial inventory', name: 'BloodAvailability');
        await _viewModel.loadBloodInventory();
      }
      if (_mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e, stackTrace) {
      developer.log('BloodAvailabilityScreen: Error during initialization', name: 'BloodAvailability', error: e, stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    developer.log('BloodAvailabilityScreen: dispose called', name: 'BloodAvailability');
    _mounted = false;
    _isDisposed = true;
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _showAddDialog(BuildContext context) {
    if (_isDisposed) return;
    
    developer.log('BloodAvailabilityScreen: Showing add dialog', name: 'BloodAvailability');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => !_isAdding,
        child: BloodTypeDialog(
          onSave: (bloodType) async {
            if (_isDisposed) return;
            
            developer.log('BloodAvailabilityScreen: Saving new blood type: ${bloodType.bloodType}', name: 'BloodAvailability');
            if (_mounted) {
              setState(() => _isAdding = true);
              try {
                final success = await _viewModel.addBloodType(bloodType);
                developer.log('BloodAvailabilityScreen: Add blood type result: $success', name: 'BloodAvailability');
                if (_mounted && !_isDisposed) {
                  if (success) {
                    developer.log('BloodAvailabilityScreen: Reloading inventory after successful addition', name: 'BloodAvailability');
                    // Close the dialog first
                    if (Navigator.canPop(dialogContext)) {
                      Navigator.of(dialogContext).pop();
                    }
                    // Then reload the inventory
                    await _viewModel.loadBloodInventory();
                    if (_mounted && !_isDisposed) {
                      setState(() {}); // Force rebuild after inventory reload
                    }
                  } else {
                    final error = _viewModel.error;
                    developer.log('BloodAvailabilityScreen: Failed to add blood type: $error', name: 'BloodAvailability', error: error);
                    if (_mounted && !_isDisposed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error ?? 'Failed to add blood type'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              } catch (e, stackTrace) {
                developer.log('BloodAvailabilityScreen: Error adding blood type', name: 'BloodAvailability', error: e, stackTrace: stackTrace);
                if (_mounted && !_isDisposed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (_mounted && !_isDisposed) {
                  setState(() => _isAdding = false);
                }
              }
            }
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, BloodInventory bloodType) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => !_isAdding,
        child: BloodTypeDialog(
          bloodType: bloodType,
          onSave: (updatedBloodType) async {
            if (_mounted) {
              setState(() => _isAdding = true);
              try {
                final success = await _viewModel.updateBloodType(updatedBloodType);
                if (_mounted) {
                  if (success) {
                    Navigator.of(dialogContext).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_viewModel.error ?? 'Failed to update blood type'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } finally {
                if (_mounted) {
                  setState(() => _isAdding = false);
                }
              }
            }
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, BloodInventory bloodType) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => !_isAdding,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade700,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Delete Blood Type',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to delete ${bloodType.bloodType}?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: _isAdding ? null : () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _isAdding ? null : () async {
                        if (_mounted) {
                          setState(() => _isAdding = true);
                          try {
                            final success = await _viewModel.deleteBloodType(bloodType.bloodType);
                            if (_mounted) {
                              if (success) {
                                Navigator.of(dialogContext).pop();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(_viewModel.error ?? 'Failed to delete blood type'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } finally {
                            if (_mounted) {
                              setState(() => _isAdding = false);
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: _isAdding
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    developer.log('BloodAvailabilityScreen: Building screen', name: 'BloodAvailability');
    
    if (_isDisposed) {
      developer.log('BloodAvailabilityScreen: Screen is disposed, returning empty container', name: 'BloodAvailability');
      return Container();
    }
    
    return WillPopScope(
      onWillPop: () async {
        developer.log('BloodAvailabilityScreen: Back button pressed', name: 'BloodAvailability');
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<BloodAvailabilityViewModel>(
          builder: (context, viewModel, child) {
            developer.log(
              'BloodAvailabilityScreen: ViewModel state - isLoading: ${viewModel.isLoading}, error: ${viewModel.error}, inventoryCount: ${viewModel.bloodInventory.length}, isInitialized: ${viewModel.isInitialized}, _isInitialized: $_isInitialized',
              name: 'BloodAvailability'
            );

            // Show loading indicator during initial load
            if (!_isInitialized || (viewModel.isLoading && !viewModel.isInitialized)) {
              developer.log('BloodAvailabilityScreen: Showing initial loading state', name: 'BloodAvailability');
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading inventory...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Show error state
            if (viewModel.error != null) {
              developer.log('BloodAvailabilityScreen: Showing error state: ${viewModel.error}', name: 'BloodAvailability');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      viewModel.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_mounted && !_isDisposed) {
                          developer.log('BloodAvailabilityScreen: Retrying after error', name: 'BloodAvailability');
                          _initializeScreen();
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Show empty state
            if (viewModel.bloodInventory.isEmpty) {
              developer.log('BloodAvailabilityScreen: Showing empty state', name: 'BloodAvailability');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bloodtype,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No blood types available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add a new blood type to get started',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Show blood inventory list
            developer.log('BloodAvailabilityScreen: Showing inventory list with ${viewModel.bloodInventory.length} items', name: 'BloodAvailability');
            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    if (_mounted && !_isDisposed) {
                      developer.log('BloodAvailabilityScreen: Manual refresh triggered', name: 'BloodAvailability');
                      await _viewModel.loadBloodInventory();
                      if (_mounted && !_isDisposed) {
                        setState(() {}); // Force rebuild after refresh
                      }
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.bloodInventory.length,
                    itemBuilder: (context, index) {
                      final bloodType = viewModel.bloodInventory[index];
                      return BloodTypeCard(
                        bloodType: bloodType,
                        onEdit: () => _showEditDialog(context, bloodType),
                        onDelete: () => _showDeleteConfirmation(context, bloodType),
                      );
                    },
                  ),
                ),
                if (viewModel.isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.1),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _isAdding || _isDisposed ? null : () => _showAddDialog(context),
          backgroundColor: Theme.of(context).primaryColor,
          child: _isAdding
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.add),
        ),
      ),
    );
  }
}

class BloodTypeCard extends StatelessWidget {
  final BloodInventory bloodType;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BloodTypeCard({
    super.key,
    required this.bloodType,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.bloodtype,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    bloodType.bloodType,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bloodType.isAvailable
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bloodType.isAvailable ? 'Available' : 'Unavailable',
                    style: TextStyle(
                      color: bloodType.isAvailable ? Colors.green : Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${bloodType.unitsAvailable} units',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 18,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 18,
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BloodTypeDialog extends StatefulWidget {
  final BloodInventory? bloodType;
  final Function(BloodInventory) onSave;

  const BloodTypeDialog({
    super.key,
    this.bloodType,
    required this.onSave,
  });

  @override
  State<BloodTypeDialog> createState() => _BloodTypeDialogState();
}

class _BloodTypeDialogState extends State<BloodTypeDialog> {
  late TextEditingController bloodTypeController;
  late TextEditingController unitsController;
  late bool isAvailable;
  final BloodInventoryService _service = BloodInventoryService();
  String? _vendorId;
  bool _isLoading = false;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    developer.log('BloodTypeDialog: initState called', name: 'BloodAvailability');
    bloodTypeController = TextEditingController(text: widget.bloodType?.bloodType ?? '');
    unitsController = TextEditingController(text: widget.bloodType?.unitsAvailable.toString() ?? '0');
    isAvailable = widget.bloodType?.isAvailable ?? true;
    _loadVendorId();
  }

  @override
  void dispose() {
    developer.log('BloodTypeDialog: dispose called', name: 'BloodAvailability');
    _mounted = false;
    bloodTypeController.dispose();
    unitsController.dispose();
    super.dispose();
  }

  Future<void> _loadVendorId() async {
    if (!_mounted) return;
    
    try {
      setState(() => _isLoading = true);
      developer.log('BloodTypeDialog: Loading vendor ID', name: 'BloodAvailability');
      _vendorId = await _service.getVendorId();
      developer.log('BloodTypeDialog: Vendor ID loaded: $_vendorId', name: 'BloodAvailability');
      
      if (_vendorId == null && _mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Vendor ID not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      developer.log('BloodTypeDialog: Error loading vendor ID', name: 'BloodAvailability', error: e, stackTrace: stackTrace);
      if (_mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (_mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_mounted) return;

    if (_vendorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Vendor ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (bloodTypeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a blood type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    developer.log('BloodTypeDialog: Saving blood type', name: 'BloodAvailability');

    try {
      final newBloodType = BloodInventory(
        vendorId: _vendorId!,
        bloodType: bloodTypeController.text.toUpperCase(),
        unitsAvailable: int.tryParse(unitsController.text) ?? 0,
        isAvailable: isAvailable,
      );
      
      await widget.onSave(newBloodType);
      developer.log('BloodTypeDialog: Blood type saved successfully', name: 'BloodAvailability');
      
      if (_mounted) {
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      developer.log('BloodTypeDialog: Error saving blood type', name: 'BloodAvailability', error: e, stackTrace: stackTrace);
      if (_mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (_mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.bloodType != null;
    final theme = Theme.of(context);
    
    developer.log('BloodTypeDialog: Building dialog', name: 'BloodAvailability');
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEdit ? Icons.edit : Icons.add,
                color: theme.primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEdit ? 'Edit Blood Type' : 'Add Blood Type',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: bloodTypeController,
              decoration: InputDecoration(
                labelText: 'Blood Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.bloodtype),
              ),
              textCapitalization: TextCapitalization.characters,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: unitsController,
              decoration: InputDecoration(
                labelText: 'Units Available',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.inventory_2),
              ),
              keyboardType: TextInputType.number,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text('Available'),
                value: isAvailable,
                onChanged: _isLoading ? null : (value) => setState(() => isAvailable = value),
                activeColor: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(isEdit ? 'Update' : 'Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 