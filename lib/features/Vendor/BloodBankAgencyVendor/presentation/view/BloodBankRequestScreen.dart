import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankRequest.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/viewModel/BloodBankRequestViewModel.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodBankRequestScreen extends StatefulWidget {
  const BloodBankRequestScreen({super.key});

  @override
  State<BloodBankRequestScreen> createState() => _BloodBankRequestScreenState();
}

class _BloodBankRequestScreenState extends State<BloodBankRequestScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BloodBankRequestViewModel>().loadRequests());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<BloodBankRequestViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading requests...',
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
                    onPressed: () => viewModel.loadRequests(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Filter to show only pending requests
          final pendingRequests = viewModel.requests
              .where((request) => request.status.toLowerCase() == 'pending')
              .toList();

          if (pendingRequests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No pending requests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.loadRequests(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingRequests.length,
              itemBuilder: (context, index) {
                final request = pendingRequests[index];
                return RequestCard(request: request);
              },
            ),
          );
        },
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final BloodBankRequest request;

  const RequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
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
                    child: Text(
                      request.user.name?[0].toUpperCase() ?? 'A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.user.name ?? 'Anonymous',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${request.bloodType}',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${request.units} units',
                              style: TextStyle(
                                color: Colors.purple.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PENDING',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  dateFormat.format(request.createdAt),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (request.prescriptionUrls.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _showPrescriptionDialog(context, request),
                    icon: const Icon(Icons.medical_services, size: 14),
                    label: const Text('View Prescription'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (request.user.phoneNumber != null && request.user.phoneNumber!.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => _makeCall(request.user.phoneNumber!),
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                      side: BorderSide(color: theme.primaryColor),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                if (request.user.phoneNumber != null && request.user.phoneNumber!.isNotEmpty)
                  const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => context.read<BloodBankRequestViewModel>().acceptRequest(
                    request.requestId!,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Accept',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Handle error - could show a snackbar or dialog
        print('Could not launch phone call to $phoneNumber');
      }
    } catch (e) {
      // Handle error
      print('Error making phone call: $e');
    }
  }

  void _showPrescriptionDialog(BuildContext context, BloodBankRequest request) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Prescription Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...request.prescriptionUrls.map((url) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Image.network(
                      url,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
