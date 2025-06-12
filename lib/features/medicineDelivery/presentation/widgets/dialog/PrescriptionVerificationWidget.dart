import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

enum PrescriptionState {
  loading,
  verification,
  beforeVerification,
  afterVerification,
  findMoreShops,
}

class PrescriptionVerificationWidget extends StatefulWidget {
  final PrescriptionState state;
  final String? loadingMessage;
  final bool? isVerified;
  final String? reason;
  final Map<String, dynamic>? patientDetails;
  final String? doctorName;
  final List<dynamic>? medicines;
  final bool? signatureFound;
  final bool? stampFound;
  final int? remainingTime;
  final String? medicalStoreName;
  final bool? noMoreVendors;
  final VoidCallback? onProceed;
  final VoidCallback? onCancel;
  final VoidCallback? onTimeExpired;
  final VoidCallback? onFindMore;
  final VoidCallback? onTrackOrder;

  const PrescriptionVerificationWidget({
    Key? key,
    required this.state,
    this.loadingMessage,
    this.isVerified,
    this.reason,
    this.patientDetails,
    this.doctorName,
    this.medicines,
    this.signatureFound,
    this.stampFound,
    this.remainingTime,
    this.medicalStoreName,
    this.noMoreVendors,
    this.onProceed,
    this.onCancel,
    this.onTimeExpired,
    this.onFindMore,
    this.onTrackOrder,
  }) : super(key: key);

  static void show(BuildContext context, {
    required PrescriptionState state,
    String? loadingMessage,
    bool? isVerified,
    String? reason,
    Map<String, dynamic>? patientDetails,
    String? doctorName,
    List<dynamic>? medicines,
    bool? signatureFound,
    bool? stampFound,
    int? remainingTime,
    String? medicalStoreName,
    bool? noMoreVendors,
    VoidCallback? onProceed,
    VoidCallback? onCancel,
    VoidCallback? onTimeExpired,
    VoidCallback? onFindMore,
    VoidCallback? onTrackOrder,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PrescriptionVerificationWidget(
        state: state,
        loadingMessage: loadingMessage,
        isVerified: isVerified,
        reason: reason,
        patientDetails: patientDetails,
        doctorName: doctorName,
        medicines: medicines,
        signatureFound: signatureFound,
        stampFound: stampFound,
        remainingTime: remainingTime,
        medicalStoreName: medicalStoreName,
        noMoreVendors: noMoreVendors,
        onProceed: onProceed,
        onCancel: onCancel,
        onTimeExpired: onTimeExpired,
        onFindMore: onFindMore,
        onTrackOrder: onTrackOrder,
      ),
    );
  }

  @override
  State<PrescriptionVerificationWidget> createState() => _PrescriptionVerificationWidgetState();
}

class _PrescriptionVerificationWidgetState extends State<PrescriptionVerificationWidget> {
  Timer? _timer;
  late int _remainingTime;

  @override
  void initState() {
    super.initState();
    if (widget.state == PrescriptionState.beforeVerification && widget.remainingTime != null) {
      _remainingTime = widget.remainingTime!;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        widget.onTimeExpired?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (widget.state) {
      case PrescriptionState.loading:
        return _buildLoadingState();
      case PrescriptionState.verification:
        return _buildVerificationState();
      case PrescriptionState.beforeVerification:
        return _buildBeforeVerificationState();
      case PrescriptionState.afterVerification:
        return _buildAfterVerificationState();
      case PrescriptionState.findMoreShops:
        return _buildFindMoreShopsState();
    }
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Lottie.asset(
              'assets/animations/scanPrescription.json',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.loadingMessage ?? 'System is Verifying Prescription...',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we process your request',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationState() {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Prescription Verified Successfully',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.reason ?? 'Your prescription has been verified and is being processed.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBeforeVerificationState() {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              size: 40,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.blue, Colors.blue.shade700],
            ).createShader(bounds),
            child: const Text(
              'Searching Nearest Medical Shops...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Icon(
                  Icons.timer_rounded,
                  size: 18,
                  color: Colors.grey.shade700,
                ),
                Text(
                  '${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')} min',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'It will take up to 5 minutes to search. You can leave.',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAfterVerificationState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Lottie.asset(
            'assets/animations/verified.json',
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.green, Colors.green.shade700],
          ).createShader(bounds),
          child: const Text(
            'Prescription Verified!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.store_rounded,
                size: 20,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                widget.medicalStoreName ?? '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onTrackOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Track Your Order',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFindMoreShopsState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: widget.noMoreVendors == true 
              ? Colors.orange.withOpacity(0.1)
              : Colors.redAccent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.noMoreVendors == true ? Icons.search_off_rounded : Icons.location_off_rounded,
            size: 50,
            color: widget.noMoreVendors == true ? Colors.orange : Colors.redAccent,
          ),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: widget.noMoreVendors == true 
              ? [Colors.orange, Colors.deepOrange]
              : [Colors.redAccent, Colors.red],
          ).createShader(bounds),
          child: Text(
            widget.noMoreVendors == true 
              ? "No More Shops Found"
              : "Couldn't Find Medical Shops Nearby",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.noMoreVendors == true
            ? "We've searched in a wider area but couldn't find any additional medical stores. Please try again later."
            : "Would you like to search in a wider area? This will take about 5 minutes to find more options.",
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (widget.noMoreVendors == true)
          Container(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: widget.onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: Colors.orange.withOpacity(0.5),
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.orange.withOpacity(0.05),
              ),
              child: const Text(
                "Close",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        else
          Column(
            children: [
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onFindMore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(Icons.search, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        "Search More Shops",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: widget.onCancel,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPatientDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Patient Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text("Name: ${widget.patientDetails!['name']}"),
          Text("Age: ${widget.patientDetails!['age']} years"),
          Text("Gender: ${widget.patientDetails!['gender']}"),
          if (widget.doctorName != null) Text("Doctor: ${widget.doctorName}"),
        ],
      ),
    );
  }

  Widget _buildMedicinesList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Prescribed Medicines",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          ...widget.medicines!.map((medicine) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "• ${medicine['name']} ${medicine['dosage']} - ${medicine['frequency']} for ${medicine['duration']}",
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatusChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatusChip(
          "Signature",
          widget.signatureFound == true,
          Icons.draw,
        ),
        const SizedBox(width: 16),
        _buildStatusChip(
          "Stamp",
          widget.stampFound == true,
          Icons.verified_user,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: widget.isVerified == true ? Colors.green : Colors.red,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Cancel",
              style: TextStyle(
                fontSize: 16,
                color: widget.isVerified == true ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: widget.isVerified == true ? widget.onProceed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isVerified == true ? Colors.green : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Proceed",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, bool isPresent, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isPresent ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isPresent ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            "$label ${isPresent ? 'Present' : 'Missing'}",
            style: TextStyle(
              fontSize: 14,
              color: isPresent ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 