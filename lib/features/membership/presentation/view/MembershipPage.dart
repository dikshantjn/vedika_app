import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import '../viewmodel/MembershipViewModel.dart';
import '../../data/models/MembershipPlan.dart';
import '../widgets/PlanCard.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/features/membership/data/services/MembershipPaymentService.dart';
import 'package:vedika_healthcare/features/membership/presentation/utils/PlanVisuals.dart';
import 'package:shimmer/shimmer.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({Key? key}) : super(key: key);

  @override
  _MembershipPageState createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  String? _currentUserId;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;
  final MembershipPaymentService _paymentService = MembershipPaymentService();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _paymentService.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showTitle = _scrollController.hasClients && _scrollController.offset > 120;
    if (showTitle != _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = showTitle;
      });
    }
  }

  Future<void> _initializeData() async {
    final userId = await StorageService.getUserId();
    setState(() {
      _currentUserId = userId;
    });

    if (userId != null && mounted) {
      final membershipViewModel = context.read<MembershipViewModel>();
      await Future.wait([
        membershipViewModel.loadPlans(),
        membershipViewModel.loadCurrentMembership(userId),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<MembershipViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.plans.isEmpty) {
            return _buildLoadingState();
          }

          if (viewModel.error != null && viewModel.plans.isEmpty) {
            return _buildErrorState(viewModel.error!);
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildPlansSection(viewModel),
                    _buildCompareButton(viewModel),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      backgroundColor: ColorPalette.primaryColor,
      automaticallyImplyLeading: false,
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: const Text(
          'Vedika Plus Membership',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorPalette.primaryColor,
                ColorPalette.primaryColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Stack(
            children: [
              // Geometric shapes for premium design
              _buildGeometricShapes(),
              // Main header content
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 30, right: 20),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: _buildNewHeaderContent(),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeometricShapes() {
    return Stack(
      children: [
        // Large circle
        Positioned(
          top: -50,
          right: -30,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
        // Medium circle
        Positioned(
          top: 30,
          right: 100,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        // Diamond shape
        Positioned(
          top: 80,
          left: -20,
          child: Transform.rotate(
            angle: 0.785398, // 45 degrees
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        // Triangle shape
        Positioned(
          bottom: 20,
          right: 200,
          child: CustomPaint(
            size: Size(40, 40),
            painter: TrianglePainter(Colors.white.withOpacity(0.07)),
          ),
        ),
        // Small circles
        Positioned(
          top: 150,
          left: 50,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: 10,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewHeaderContent() {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '💎',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 8),
                Text(
                  'Premium Membership',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Vedika Plus',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.3),
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Choose your plan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Unlock smarter healthcare with unlimited access to doctors, labs, and medicines—anytime, anywhere. Stay protected with exclusive savings and priority care.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '3 Plans Available',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Yearly Basis',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlansSection(MembershipViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          if (viewModel.isLoading && viewModel.plans.isEmpty)
            _buildShimmerPlans()
          else
            ...viewModel.plans.map((plan) => Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: PlanCard(
                    plan: plan,
                    isSelected: viewModel.selectedPlan?.membershipPlanId == plan.membershipPlanId,
                    onSelect: () => viewModel.selectPlan(plan),
                    onPurchase: () => _handlePurchase(plan, viewModel),
                    hasActiveMembership: viewModel.hasActiveMembership,
                    currentPlanId: viewModel.currentMembership?.planId,
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildShimmerPlans() {
    return Column(
      children: List.generate(3, (index) => _buildShimmerPlanCard(index)).toList(),
    );
  }

  Widget _buildShimmerPlanCard(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with emoji box and titles
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: 16,
                          width: 140,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: 12,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 24,
                    width: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Gradient banner placeholder
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Features bullets
            Column(
              children: List.generate(4, (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
            SizedBox(height: 16),
            // Footer: price and button
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: 14,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: 22,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 44,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }



  Widget _buildCompareButton(MembershipViewModel viewModel) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _showComparisonBottomSheet(viewModel),
          icon: Icon(Icons.compare_arrows),
          label: Text('Compare Plans'),
          style: OutlinedButton.styleFrom(
            foregroundColor: ColorPalette.primaryColor,
            side: BorderSide(color: ColorPalette.primaryColor, width: 2),
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            'Loading membership plans...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _initializeData,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase(MembershipPlan plan, MembershipViewModel viewModel) async {
    if (_currentUserId == null) {
      _showMessage('Please login to purchase a membership plan');
      return;
    }

    if (viewModel.hasActiveMembership) {
      _showMessage('You already have an active membership plan');
      return;
    }

    _showPurchaseSheet(plan, viewModel);
  }

  void _showPurchaseSheet(MembershipPlan plan, MembershipViewModel viewModel) {
    final paymentService = _paymentService;
    // Local state for coupon and taxes across sheet rebuilds
    double discountPct = 0; // percent
    String appliedCode = '';
    bool showAllBenefits = false;
    bool isCreatingOrder = false;
    final TextEditingController couponController = TextEditingController();
    const double gstRate = 0.18; // 18% GST
    // Payment state
    String paymentStage = 'idle'; // idle | processing | success | failure
    String paymentErrorMessage = '';
    String? lastPaymentId;
    String? lastOrderId;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final Map<String, double> coupons = {
              'WELCOME10': 10,
              'HEALTH15': 15,
              'VEDIKA20': 20,
            };

            final double subtotal = plan.price;
            final double discount = (subtotal * discountPct) / 100;
            final double taxable = subtotal - discount;
            final double gst = taxable * gstRate;
            final double total = taxable + gst;

            void applyCoupon() {
              final code = couponController.text.trim().toUpperCase();
              if (coupons.containsKey(code)) {
                discountPct = coupons[code]!;
                appliedCode = code;
                setSheetState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Coupon $code applied (−${discountPct.toStringAsFixed(0)}%)')),
                );
              } else {
                discountPct = 0;
                appliedCode = '';
                setSheetState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid coupon')),
                );
              }
            }

            return Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Decorative header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(16, 16, 8, 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: paymentStage == 'success'
                              ? [Colors.green[600]!, Colors.green[500]!]
                              : paymentStage == 'failure'
                                  ? [Colors.red[600]!, Colors.red[500]!]
                                  : [
                                      PlanVisuals.gradientStart(plan.type),
                                      PlanVisuals.gradientEnd(plan.type),
                                    ],
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: paymentStage == 'idle'
                                ? Text(
                                    PlanVisuals.emoji(plan.type),
                                    style: TextStyle(fontSize: 20, color: Colors.white),
                                  )
                                : Icon(
                                    paymentStage == 'success'
                                        ? Icons.check_circle
                                        : paymentStage == 'failure'
                                            ? Icons.error
                                            : Icons.lock_clock,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (paymentStage == 'idle') ...[
                                  Text(plan.name, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text('Yearly · ₹${plan.price.toStringAsFixed(0)}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                                ] else ...[
                                  Text(
                                    paymentStage == 'success' ? 'Payment Successful' : paymentStage == 'failure' ? 'Payment Failed' : 'Processing Payment...',
                                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    paymentStage == 'success'
                                        ? 'Your ${plan.name} membership is now active.'
                                        : paymentStage == 'failure'
                                            ? (paymentErrorMessage.isNotEmpty ? paymentErrorMessage : 'Something went wrong. Please try again.')
                                            : 'Please wait while we initialize your checkout.',
                                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
                    ),

                    if (paymentStage == 'processing') ...[
                      // Processing content
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: Row(
                          children: [
                            SizedBox(width: 8),
                            CircularProgressIndicator(color: ColorPalette.primaryColor, strokeWidth: 2),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Opening Razorpay... Complete the payment in the popup.',
                                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (paymentStage == 'success') ...[
                      // Success content
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _priceRow('Plan', plan.name, color: Colors.green[700]),
                            _priceRow('Amount Paid', '₹${total.toStringAsFixed(0)}', color: Colors.green[700]),
                            if (lastPaymentId != null) _priceRow('Payment ID', lastPaymentId!, color: Colors.green[700]),
                            if (lastOrderId != null) _priceRow('Order ID', lastOrderId!, color: Colors.green[700]),
                          ],
                        ),
                      ),
                    ] else if (paymentStage == 'failure') ...[
                      // Failure content
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('We could not process your payment.', style: TextStyle(fontSize: 14, color: Colors.red[700], fontWeight: FontWeight.w600)),
                            SizedBox(height: 8),
                            if (paymentErrorMessage.isNotEmpty)
                              Text(paymentErrorMessage, style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                          ],
                        ),
                      ),
                    ],

                    if (paymentStage == 'idle' || paymentStage == 'processing') ...[
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('What you get', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[800])),
                            SizedBox(height: 8),
                            ...plan.highlights.take(showAllBenefits ? plan.highlights.length : 5).map((h) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, size: 16, color: ColorPalette.primaryColor),
                                  SizedBox(width: 8),
                                  Expanded(child: Text(h, style: TextStyle(fontSize: 13, color: Colors.grey[800]))),
                                ],
                              ),
                            )),
                            if (plan.highlights.length > 5) ...[
                              SizedBox(height: 6),
                              GestureDetector(
                                onTap: () {
                                  showAllBenefits = !showAllBenefits;
                                  setSheetState(() {});
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      showAllBenefits
                                          ? 'Show fewer benefits'
                                          : '+ ${plan.highlights.length - 5} more benefits',
                                      style: TextStyle(fontSize: 12, color: ColorPalette.primaryColor, fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(showAllBenefits ? Icons.expand_less : Icons.expand_more, size: 16, color: ColorPalette.primaryColor),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Coupon
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Apply Coupon', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[800])),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: TextField(
                                      controller: couponController,
                                      textInputAction: TextInputAction.done,
                                      keyboardType: TextInputType.text,
                                      autofocus: false,
                                      textCapitalization: TextCapitalization.characters,
                                      decoration: InputDecoration(
                                        hintText: 'Enter code (e.g., WELCOME10)',
                                        border: InputBorder.none,
                                      ),
                                      onSubmitted: (_) => applyCoupon(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: applyCoupon,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorPalette.primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(appliedCode.isEmpty ? 'Apply' : 'Applied'),
                                ),
                              ],
                            ),
                            if (appliedCode.isNotEmpty) ...[
                              SizedBox(height: 6),
                              Text('Applied: $appliedCode (−${discountPct.toStringAsFixed(0)}%)', style: TextStyle(fontSize: 12, color: Colors.green[700])),
                            ],
                          ],
                        ),
                      ),

                      // Receipt / cost breakdown
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              children: [
                                _priceRow('Plan fee', '₹${subtotal.toStringAsFixed(0)}'),
                                if (discount > 0)
                                  _priceRow('Discount', '−₹${discount.toStringAsFixed(0)}', color: Colors.green[700]),
                                _priceRow('GST (18%)', '₹${gst.toStringAsFixed(0)}'),
                                Divider(height: 16, color: Colors.grey[300]),
                                _priceRow('Total', '₹${total.toStringAsFixed(0)}', color: ColorPalette.primaryColor),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Price summary and pay now / actions
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(paymentStage == 'success' ? 'Paid' : 'Total', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                Text(
                                  paymentStage == 'success' ? '₹${total.toStringAsFixed(0)} / year' : '₹${total.toStringAsFixed(0)} / year',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: paymentStage == 'success' ? Colors.green[700] : ColorPalette.primaryColor),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            child: paymentStage == 'idle' || paymentStage == 'processing'
                                ? GestureDetector(
                                    onTap: (isCreatingOrder || paymentStage == 'processing') ? null : () async {
                                      // Create order first
                                      try {
                                        if (context.mounted) {
                                          setSheetState(() {
                                            isCreatingOrder = true;
                                          });
                                        }
                                        
                                        print('🚀 Creating order for plan: ${plan.membershipPlanId}');
                                        print('👤 Current user ID: $_currentUserId');
                                        print('📋 Complete Plan Object:');
                                        print('   - membershipPlanId: ${plan.membershipPlanId}');
                                        print('   - type: ${plan.type}');
                                        print('   - name: ${plan.name}');
                                        print('   - title: ${plan.title}');
                                        print('   - price: ${plan.price}');
                                        print('   - duration: ${plan.duration}');
                                        
                                        // Validate membershipPlanId
                                        if (plan.membershipPlanId.isEmpty) {
                                          _showMessage('Invalid plan ID');
                                          return;
                                        }
                                        
                                        print('🔍 Validating plan ID: ${plan.membershipPlanId}');
                                        
                                        final orderData = await paymentService.createOrder(plan.membershipPlanId);
                                        print('✅ Order created successfully: $orderData');
                                        
                                        if (orderData == null) {
                                          _showMessage('Failed to create order');
                                          return;
                                        }
                                        
                                        // Extract order id for Razorpay checkout (handle multiple possible shapes)
                                        final String orderId = (
                                          (orderData['orderId']?.toString()) ??
                                          (orderData['razorpayOrderId']?.toString()) ??
                                          ((orderData['order'] is Map && orderData['order']['id'] != null) ? orderData['order']['id'].toString() : '')
                                        );
                                        print('🧾 Extracted Razorpay orderId: $orderId');
                                        
                                        // Set up payment success callback
                                        paymentService.onPaymentSuccess = (resp) async {
                                          try {
                                            print('🎉 Payment Success Response: ${resp.toString()}');
                                            print('💳 Payment ID: ${resp.paymentId}');
                                            print('🔑 Order ID: ${resp.orderId}');
                                            print('💰 Signature: ${resp.signature}');

                                            // Reflect ids in UI
                                            lastPaymentId = resp.paymentId;
                                            lastOrderId = resp.orderId;
                                            if (context.mounted) setSheetState(() { paymentStage = 'processing'; });

                                            // Verify payment with backend
                                            final paymentVerified = await paymentService.verifyPayment(
                                              plan.membershipPlanId, 
                                              resp.paymentId ?? ''
                                            );

                                            print('✅ Payment Verification Result: $paymentVerified');

                                            if (paymentVerified) {
                                              // Update membership in view model
                                              final success = await viewModel.purchasePlan(_currentUserId!, plan.membershipPlanId, 'razorpay');
                                              if (success) {
                                                if (context.mounted) setSheetState(() { paymentStage = 'success'; });
                                                _showMessage('Membership purchased successfully!', isSuccess: true);
                                              } else {
                                                if (context.mounted) setSheetState(() { paymentStage = 'failure'; paymentErrorMessage = viewModel.error ?? 'Failed to update membership'; });
                                                _showMessage(viewModel.error ?? 'Failed to update membership');
                                              }
                                            } else {
                                              if (context.mounted) setSheetState(() { paymentStage = 'failure'; paymentErrorMessage = 'Payment verification failed'; });
                                              _showMessage('Payment verification failed');
                                            }
                                          } catch (e) {
                                            print('❌ Payment Verification Error: $e');
                                            if (context.mounted) setSheetState(() { paymentStage = 'failure'; paymentErrorMessage = e.toString(); });
                                            _showMessage('Payment verification error: ${e.toString()}');
                                          }
                                        };

                                        paymentService.onPaymentError = (err) {
                                          print('❌ Payment Error Response: ${err.toString()}');
                                          print('💥 Error Code: ${err.code}');
                                          print('💥 Error Description: ${err.message}');
                                          if (context.mounted) setSheetState(() { paymentStage = 'failure'; paymentErrorMessage = err.message ?? 'Payment failed'; });
                                          _showMessage('Payment failed: ${err.message}');
                                        };

                                        // Set processing state and open checkout
                                        if (context.mounted) setSheetState(() { paymentStage = 'processing'; });
                                        paymentService.openPaymentGateway(
                                          amount: total,
                                          key: ApiConstants.razorpayApiKey,
                                          planName: plan.name,
                                          orderId: orderId.isNotEmpty ? orderId : null,
                                        );
                                        
                                      } catch (e) {
                                        print('❌ Order Creation Error: $e');
                                        _showMessage('Failed to create order: ${e.toString()}');
                                      } finally {
                                        // Check if context is still mounted before updating state
                                        if (context.mounted) {
                                          setSheetState(() {
                                            isCreatingOrder = false;
                                          });
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        gradient: (isCreatingOrder || paymentStage == 'processing') ? null : LinearGradient(
                                          colors: [
                                            PlanVisuals.gradientStart(plan.type),
                                            PlanVisuals.gradientEnd(plan.type),
                                          ],
                                        ),
                                        color: (isCreatingOrder || paymentStage == 'processing') ? Colors.grey[400] : null,
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                      alignment: Alignment.center,
                                      child: (isCreatingOrder || paymentStage == 'processing')
                                          ? Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                                ),
                                                SizedBox(width: 10),
                                                Text('Processing...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                              ],
                                            )
                                          : Text('Pay Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: ColorPalette.primaryColor,
                                            side: BorderSide(color: ColorPalette.primaryColor, width: 2),
                                            padding: EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                          ),
                                          child: Text(paymentStage == 'success' ? 'Done' : 'Try Again'),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
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

  Widget _priceRow(String label, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color ?? Colors.grey[800])),
        ],
      ),
    );
  }

  Future<bool> _showPurchaseConfirmation(MembershipPlan plan) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Purchase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are about to purchase:'),
            SizedBox(height: 8),
            Text(
              '${plan.name} - ₹${plan.price.toStringAsFixed(0)}/${plan.duration}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ColorPalette.primaryColor,
              ),
            ),
            SizedBox(height: 16),
            Text('This plan includes:'),
            SizedBox(height: 8),
            ...plan.highlights.take(3).map((highlight) => Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(Icons.check, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(child: Text(highlight, style: TextStyle(fontSize: 12))),
                ],
              ),
            )),
            if (plan.highlights.length > 3)
              Text('...and ${plan.highlights.length - 3} more benefits'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<String?> _showPaymentMethodSelection() async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.credit_card, color: ColorPalette.primaryColor),
              title: Text('Credit/Debit Card'),
              onTap: () => Navigator.of(context).pop('card'),
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet, color: ColorPalette.primaryColor),
              title: Text('UPI Payment'),
              onTap: () => Navigator.of(context).pop('upi'),
            ),
            ListTile(
              leading: Icon(Icons.account_balance, color: ColorPalette.primaryColor),
              title: Text('Net Banking'),
              onTap: () => Navigator.of(context).pop('netbanking'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showComparisonBottomSheet(MembershipViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header with drag handle
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        SizedBox(width: 16),
                        Icon(Icons.compare_arrows, color: ColorPalette.primaryColor),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Compare Plans',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ColorPalette.primaryColor,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: ColorPalette.primaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey[200]),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(16),
                  child: _buildTabularComparison(viewModel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabularComparison(MembershipViewModel viewModel) {
    // Order plans Silver -> Gold -> Platinum if present
    final List<String> orderTypes = ['Silver', 'Gold', 'Platinum'];
    final plansOrdered = [...viewModel.plans]
      ..sort((a, b) => orderTypes.indexOf(a.type).compareTo(orderTypes.indexOf(b.type)));

    // Build ordered unique feature titles (prefer a meaningful order)
    final desiredOrder = [
      'Online Consultations',
      'Emergency Services',
      'Health Records Storage',
      'Nutrition Plans',
      'Medico Legal Assistance',
      'Early Access',
      'Medicine Discount',
      'Lab Test Discount',
      'Product Discount',
      'Mediclaim',
    ];

    final Set<String> allTitles = {};
    for (final plan in plansOrdered) {
      for (final f in plan.features) {
        allTitles.add(f.title);
      }
    }
    final featureTitles = [
      ...desiredOrder.where(allTitles.contains),
      ...allTitles.where((t) => !desiredOrder.contains(t)),
    ];

    return Column(
      children: [
        // Header
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Table(
            columnWidths: {
              0: FlexColumnWidth(2.5),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                children: [
                  _buildTableHeaderCell('Benefits'),
                  ...plansOrdered.map((p) => _buildTableHeaderCell('${PlanVisuals.emoji(p.type)} ${p.name.split(' ').first}\n₹${p.price.toStringAsFixed(0)}')),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        // Body
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Table(
            columnWidths: {
              0: FlexColumnWidth(2.5),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
            },
            children: featureTitles.map((title) {
              return TableRow(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[100]!, width: 1),
                  ),
                ),
                children: [
                  _buildTableBenefitCell(title),
                  ...plansOrdered.map((plan) {
                    final match = plan.features.where((f) => f.title == title);
                    final included = match.isNotEmpty ? match.first.isIncluded : false;
                    return _buildTableValueCell(included);
                  }).toList(),
                ],
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 24),
        // Actions
        Row(
          children: plansOrdered.map((plan) {
            final isCurrentPlan = viewModel.currentMembership?.planId == plan.membershipPlanId;
            final canPurchase = !viewModel.hasActiveMembership || isCurrentPlan;
            return Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton(
                  onPressed: canPurchase && !isCurrentPlan
                      ? () {
                          Navigator.pop(context);
                          _handlePurchase(plan, viewModel);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isCurrentPlan ? Colors.grey[400] : PlanVisuals.primaryColor(plan.type),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    isCurrentPlan ? 'Current' : 'Choose ${plan.name.split(' ')[0]}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: ColorPalette.primaryColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableBenefitCell(String text) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildTableValueCell(dynamic value) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Center(
        child: value is bool
            ? Icon(
                value ? Icons.check_circle : Icons.cancel,
                color: value ? Colors.green : Colors.red,
                size: 20,
              )
            : Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
