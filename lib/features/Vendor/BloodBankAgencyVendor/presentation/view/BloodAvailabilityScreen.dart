import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModel/BloodAvailabilityViewModel.dart';
import '../../data/model/BloodInventory.dart';
import 'package:logger/logger.dart';

class BloodAvailabilityScreen extends StatefulWidget {
  const BloodAvailabilityScreen({super.key});

  @override
  State<BloodAvailabilityScreen> createState() => _BloodAvailabilityScreenState();
}

class _BloodAvailabilityScreenState extends State<BloodAvailabilityScreen> {
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    // Load blood inventory when screen initializes
    Future.microtask(() {
      if (_mounted) {
        context.read<BloodAvailabilityViewModel>().loadBloodInventory();
      }
    });
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<BloodAvailabilityViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.bloodInventory.isEmpty) {
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

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_mounted) {
                        viewModel.loadBloodInventory();
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.bloodInventory.isEmpty) {
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

          return ListView.builder(
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BloodTypeDialog(
        onSave: (bloodType) {
          if (_mounted) {
            context.read<BloodAvailabilityViewModel>().addBloodType(bloodType);
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, BloodInventory bloodType) {
    showDialog(
      context: context,
      builder: (context) => EditBloodTypeDialog(
        bloodInventoryId: bloodType.bloodInventoryId!,
        initialBloodType: bloodType.bloodType,
        initialUnits: bloodType.unitsAvailable,
        initialIsAvailable: bloodType.isAvailable,
        onSave: (updatedBloodType) {
          if (_mounted) {
            context.read<BloodAvailabilityViewModel>().updateBloodType(updatedBloodType);
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, BloodInventory bloodType) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_mounted) {
                        context.read<BloodAvailabilityViewModel>().deleteBloodType(bloodType.bloodInventoryId!);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
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
                    color: theme.primaryColor,
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    bloodTypeController = TextEditingController(text: widget.bloodType?.bloodType ?? '');
    unitsController = TextEditingController(text: widget.bloodType?.unitsAvailable.toString() ?? '0');
    isAvailable = widget.bloodType?.isAvailable ?? true;
    
    // Use post-frame callback to load vendor ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVendorId();
    });
  }

  Future<void> _loadVendorId() async {
    if (mounted) {
      setState(() => _isLoading = true);
      await context.read<BloodAvailabilityViewModel>().loadVendorId();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    bloodTypeController.dispose();
    unitsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    final viewModel = context.read<BloodAvailabilityViewModel>();
    final newBloodType = BloodInventory(
      vendorId: viewModel.vendorId ?? '',
      bloodType: bloodTypeController.text,
      unitsAvailable: int.tryParse(unitsController.text) ?? 0,
      isAvailable: isAvailable,
    );

    final success = await viewModel.handleSave(newBloodType);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.bloodType != null;
    final theme = Theme.of(context);
    final viewModel = context.watch<BloodAvailabilityViewModel>();
    
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
            if (viewModel.error != null) ...[
              const SizedBox(height: 16),
              Text(
                viewModel.error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
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

class EditBloodTypeDialog extends StatefulWidget {
  final String bloodInventoryId;
  final String initialBloodType;
  final int initialUnits;
  final bool initialIsAvailable;
  final Function(BloodInventory) onSave;

  const EditBloodTypeDialog({
    super.key,
    required this.bloodInventoryId,
    required this.initialBloodType,
    required this.initialUnits,
    required this.initialIsAvailable,
    required this.onSave,
  });

  @override
  State<EditBloodTypeDialog> createState() => _EditBloodTypeDialogState();
}

class _EditBloodTypeDialogState extends State<EditBloodTypeDialog> {
  late TextEditingController bloodTypeController;
  late TextEditingController unitsController;
  late bool isAvailable;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    bloodTypeController = TextEditingController(text: widget.initialBloodType);
    unitsController = TextEditingController(text: widget.initialUnits.toString());
    isAvailable = widget.initialIsAvailable;
    
    // Use post-frame callback to load vendor ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVendorId();
    });
  }

  Future<void> _loadVendorId() async {
    if (mounted) {
      setState(() => _isLoading = true);
      await context.read<BloodAvailabilityViewModel>().loadVendorId();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    bloodTypeController.dispose();
    unitsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    final viewModel = context.read<BloodAvailabilityViewModel>();
    final updatedBloodType = BloodInventory(
      bloodInventoryId: widget.bloodInventoryId,
      vendorId: viewModel.vendorId ?? '',
      bloodType: bloodTypeController.text,
      unitsAvailable: int.tryParse(unitsController.text) ?? 0,
      isAvailable: isAvailable,
    );

    print('Updating blood type: ${updatedBloodType.toJson()}');
    final success = await viewModel.handleSave(updatedBloodType);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<BloodAvailabilityViewModel>();
    
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
                Icons.edit,
                color: theme.primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Edit Blood Type',
              style: TextStyle(
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
            if (viewModel.error != null) ...[
              const SizedBox(height: 16),
              Text(
                viewModel.error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
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
                      : const Text('Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 