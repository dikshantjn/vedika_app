import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/LabTestColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/LabTestBooking.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/viewModels/LabTestProcessViewModel.dart';

class LabTestProcessScreen extends StatelessWidget {
  final LabTestBooking booking;

  const LabTestProcessScreen({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LabTestProcessViewModel(booking: booking),
      child: const _LabTestProcessScreenContent(),
    );
  }
}

class _LabTestProcessScreenContent extends StatelessWidget {
  const _LabTestProcessScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LabTestColorPalette.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Process Booking',
          style: TextStyle(
            color: LabTestColorPalette.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: LabTestColorPalette.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: LabTestColorPalette.textPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<LabTestProcessViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientInfoCard(context, viewModel),
                  const SizedBox(height: 16),
                  _buildProcessTracker(context, viewModel),
                  const SizedBox(height: 16),
                  _buildTestsSection(context, viewModel),
                  const SizedBox(height: 24),
                  _buildActionButtons(context, viewModel),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard(BuildContext context, LabTestProcessViewModel viewModel) {
    final booking = viewModel.booking;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: LabTestColorPalette.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: LabTestColorPalette.primaryBlueLightest,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Text(
                    _getInitials(booking.user?.name ?? ""),
                    style: const TextStyle(
                      color: LabTestColorPalette.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.user?.name ?? "Unknown",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: LabTestColorPalette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Booking ID: ${booking.bookingId}",
                        style: const TextStyle(
                          color: LabTestColorPalette.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: LabTestColorPalette.primaryBlue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    "Processing",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  icon: Icons.phone_outlined,
                  title: "Phone",
                  value: booking.user?.phoneNumber ?? "N/A",
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.calendar_today_outlined,
                  title: "Appointment",
                  value: "${booking.bookingDate} | ${booking.bookingTime}",
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: booking.homeCollectionRequired == true
                      ? Icons.home_outlined
                      : Icons.local_hospital_outlined,
                  title: "Collection",
                  value: booking.homeCollectionRequired == true
                      ? "Home Collection"
                      : "At Center",
                ),
                if (booking.homeCollectionRequired == true &&
                    booking.userAddress != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 34),
                    child: Text(
                      booking.userAddress!,
                      style: const TextStyle(
                        color: LabTestColorPalette.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessTracker(BuildContext context, LabTestProcessViewModel viewModel) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: LabTestColorPalette.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Process Status",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: LabTestColorPalette.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${(viewModel.progressValue * 100).toInt()}%",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: LabTestColorPalette.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 8,
              width: double.infinity,
              color: LabTestColorPalette.progressInactive,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: viewModel.progressValue,
                child: Container(
                  color: LabTestColorPalette.progressActive,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 18,
                color: LabTestColorPalette.primaryBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Current Stage: ${viewModel.currentStage}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: LabTestColorPalette.primaryBlue,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light().copyWith(
                primary: LabTestColorPalette.primaryBlue,
              ),
            ),
            child: Stepper(
              currentStep: viewModel.currentStep,
              type: StepperType.vertical,
              physics: const ClampingScrollPhysics(),
              controlsBuilder: (context, details) {
                final bool isFirstStep = details.currentStep == 0;
                final bool isLastStep = details.currentStep == 3;
                
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      if (!isFirstStep)
                        OutlinedButton(
                          onPressed: viewModel.isUpdatingStatus ? null : details.onStepCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: LabTestColorPalette.primaryBlue,
                            side: BorderSide(color: LabTestColorPalette.primaryBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: viewModel.isUpdatingStatus 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(LabTestColorPalette.primaryBlue),
                                  ),
                                )
                              : const Text('Previous'),
                        ),
                      if (!isFirstStep)
                        const SizedBox(width: 12),
                      if (!isLastStep)
                        ElevatedButton(
                          onPressed: viewModel.isUpdatingStatus ? null : details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LabTestColorPalette.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: viewModel.isUpdatingStatus
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Next'),
                        ),
                    ],
                  ),
                );
              },
              onStepContinue: () {
                viewModel.updateProgress();
              },
              onStepCancel: () {
                viewModel.goToPreviousStep();
              },
              onStepTapped: (step) {
                // Only allow going backward, not forward
                if (step <= viewModel.currentStep) {
                  // Handle step tap if needed
                }
              },
              steps: [
                _buildStep(
                  context: context,
                  viewModel: viewModel,
                  title: "Sample Collection",
                  subtitle: "Collect sample from patient",
                  isCompleted: viewModel.currentStep > 0,
                  isActive: viewModel.currentStep == 0,
                ),
                _buildStep(
                  context: context,
                  viewModel: viewModel,
                  title: "Sample Processing",
                  subtitle: "Lab processing of collected sample",
                  isCompleted: viewModel.currentStep > 1,
                  isActive: viewModel.currentStep == 1,
                ),
                _buildStep(
                  context: context,
                  viewModel: viewModel,
                  title: "Report Generation",
                  subtitle: "Generate and upload test reports",
                  isCompleted: viewModel.currentStep > 2,
                  isActive: viewModel.currentStep == 2,
                ),
                _buildStep(
                  context: context,
                  viewModel: viewModel,
                  title: "Completed",
                  subtitle: "Process complete and reports delivered",
                  isCompleted: viewModel.currentStep > 3,
                  isActive: viewModel.currentStep == 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestsSection(BuildContext context, LabTestProcessViewModel viewModel) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: LabTestColorPalette.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Test Reports",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: LabTestColorPalette.textPrimary,
                ),
              ),
              SizedBox(
                width: 36,
                height: 36,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          value: viewModel.getUploadPercentage(),
                          backgroundColor: LabTestColorPalette.progressInactive,
                          valueColor: AlwaysStoppedAnimation<Color>(LabTestColorPalette.progressActive),
                          strokeWidth: 4,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "${(viewModel.getUploadPercentage() * 100).toInt()}%",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: LabTestColorPalette.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          ...viewModel.reportUploads.map((report) => _buildTestReportItem(context, viewModel, report)).toList(),
        ],
      ),
    );
  }

  Widget _buildTestReportItem(BuildContext context, LabTestProcessViewModel viewModel, ReportUpload report) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: report.isUploaded
                      ? LabTestColorPalette.successGreen.withOpacity(0.1)
                      : LabTestColorPalette.warningYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  report.isUploaded ? Icons.check_circle : Icons.description_outlined,
                  color: report.isUploaded
                      ? LabTestColorPalette.successGreen
                      : LabTestColorPalette.warningYellow,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.testName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: LabTestColorPalette.textPrimary,
                      ),
                    ),
                    if (report.isUploaded && report.fileName != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.insert_drive_file_outlined,
                            size: 14,
                            color: LabTestColorPalette.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              report.fileName!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: LabTestColorPalette.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (report.fileSize != null)
                            Text(
                              " · ${report.fileSize!}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: LabTestColorPalette.textSecondary,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (!report.isUploaded)
                ElevatedButton.icon(
                  onPressed: viewModel.isUploadingFile ? null : () => viewModel.uploadReport(report),
                  icon: viewModel.isUploadingFile 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.upload_file, size: 16),
                  label: Text(viewModel.isUploadingFile ? "Uploading..." : "Upload"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LabTestColorPalette.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    disabledBackgroundColor: LabTestColorPalette.primaryBlue.withOpacity(0.5),
                  ),
                )
              else
                TextButton.icon(
                  onPressed: () {
                    // Handle view report
                    if (report.fileUrl != null) {
                      // TODO: Implement view report functionality
                      print('View report: ${report.fileUrl}');
                    }
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text("View"),
                  style: TextButton.styleFrom(
                    foregroundColor: LabTestColorPalette.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, LabTestProcessViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: viewModel.allReportsUploaded() ? () async {
            // Show loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(LabTestColorPalette.primaryBlue),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Marking as completed...",
                        style: TextStyle(
                          color: LabTestColorPalette.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

            final success = await viewModel.markAsCompleted();
            
            // Close loading dialog
            Navigator.pop(context);

            if (success) {
              // Show success dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: LabTestColorPalette.successGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: LabTestColorPalette.successGreen,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Success!",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: LabTestColorPalette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "The booking has been marked as completed successfully.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: LabTestColorPalette.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context, true); // Return to previous screen
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LabTestColorPalette.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Done",
                              style: TextStyle(
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
              );
            } else {
              // Show error dialog
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
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: LabTestColorPalette.errorRed.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            color: LabTestColorPalette.errorRed,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Error",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: LabTestColorPalette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Failed to mark the booking as completed. Please try again.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: LabTestColorPalette.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LabTestColorPalette.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Try Again",
                              style: TextStyle(
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
              );
            }
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: LabTestColorPalette.successGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            disabledBackgroundColor: LabTestColorPalette.successGreen.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "MARK AS COMPLETED",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: LabTestColorPalette.primaryBlue,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: LabTestColorPalette.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: LabTestColorPalette.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    
    final nameParts = name.split(" ");
    if (nameParts.length == 1) return nameParts[0][0].toUpperCase();
    
    return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
  }

  Step _buildStep({
    required BuildContext context,
    required LabTestProcessViewModel viewModel,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
  }) {
    return Step(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isActive || isCompleted ? FontWeight.w600 : FontWeight.w400,
          fontSize: 15,
          color: isActive 
              ? LabTestColorPalette.primaryBlue
              : isCompleted 
                  ? LabTestColorPalette.textPrimary 
                  : LabTestColorPalette.textSecondary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: isActive 
              ? LabTestColorPalette.primaryBlue.withOpacity(0.7)
              : LabTestColorPalette.textSecondary,
        ),
      ),
      content: isActive ? _buildStepContent(context, viewModel, title) : const SizedBox.shrink(),
      isActive: isActive,
      state: isCompleted 
          ? StepState.complete 
          : isActive 
              ? StepState.indexed
              : StepState.disabled,
    );
  }

  Widget _buildStepContent(BuildContext context, LabTestProcessViewModel viewModel, String stepTitle) {
    switch(stepTitle) {
      case "Sample Collection":
        return _buildSampleCollectionContent(context, viewModel);
      case "Sample Processing":
        return _buildSampleProcessingContent(context, viewModel);
      case "Report Generation":
        return _buildReportGenerationContent(context, viewModel);
      case "Completed":
        return _buildCompletedContent(context, viewModel);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSampleCollectionContent(BuildContext context, LabTestProcessViewModel viewModel) {
    final booking = viewModel.booking;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LabTestColorPalette.primaryBlueLightest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                booking.homeCollectionRequired == true
                    ? Icons.home_outlined
                    : Icons.local_hospital_outlined,
                size: 16,
                color: LabTestColorPalette.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                booking.homeCollectionRequired == true
                    ? "Home Collection"
                    : "Center Collection",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: LabTestColorPalette.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (booking.homeCollectionRequired == true &&
              booking.userAddress != null)
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                booking.userAddress!,
                style: const TextStyle(
                  fontSize: 13,
                  color: LabTestColorPalette.textSecondary,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 16,
                color: LabTestColorPalette.successGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Verify patient identity",
                  style: const TextStyle(
                    fontSize: 13,
                    color: LabTestColorPalette.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 16,
                color: LabTestColorPalette.successGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Confirm tests to be conducted",
                  style: const TextStyle(
                    fontSize: 13,
                    color: LabTestColorPalette.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSampleProcessingContent(BuildContext context, LabTestProcessViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LabTestColorPalette.primaryBlueLightest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.science_outlined,
                size: 16,
                color: LabTestColorPalette.primaryBlue,
              ),
              SizedBox(width: 8),
              Text(
                "Lab Analysis",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: LabTestColorPalette.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 16,
                color: LabTestColorPalette.successGreen,
              ),
              const SizedBox(width: 8),
              const Text(
                "Sample preparation",
                style: TextStyle(
                  fontSize: 13,
                  color: LabTestColorPalette.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 16,
                color: LabTestColorPalette.successGreen,
              ),
              const SizedBox(width: 8),
              const Text(
                "Run tests and analysis",
                style: TextStyle(
                  fontSize: 13,
                  color: LabTestColorPalette.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportGenerationContent(BuildContext context, LabTestProcessViewModel viewModel) {
    final uploadedCount = viewModel.reportUploads.where((r) => r.isUploaded).length;
    final totalCount = viewModel.reportUploads.length;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LabTestColorPalette.primaryBlueLightest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 16,
                color: LabTestColorPalette.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                "Reports Upload: $uploadedCount of $totalCount",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: LabTestColorPalette.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Please upload all test reports to proceed",
            style: TextStyle(
              fontSize: 13,
              color: viewModel.allReportsUploaded() 
                  ? LabTestColorPalette.successGreen 
                  : LabTestColorPalette.warningYellow,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedContent(BuildContext context, LabTestProcessViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LabTestColorPalette.successGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: LabTestColorPalette.successGreen.withOpacity(0.3),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: LabTestColorPalette.successGreen,
              ),
              SizedBox(width: 8),
              Text(
                "All steps completed",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: LabTestColorPalette.successGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            "Process is ready to be marked as completed",
            style: TextStyle(
              fontSize: 13,
              color: LabTestColorPalette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
} 