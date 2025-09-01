import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/NewOrders/NewOrdersViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/NewOrders/PrescriptionCard.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/NewOrders/OrderCard.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/NewOrders/NewProcessOrderScreen.dart';

class NewOrdersScreen extends StatefulWidget {
  final int? initialTab;

  const NewOrdersScreen({
    Key? key,
    this.initialTab,
  }) : super(key: key);

  @override
  State<NewOrdersScreen> createState() => _NewOrdersScreenState();
}

class _NewOrdersScreenState extends State<NewOrdersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  void _initializeAnimations() {
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab ?? 0,
    );
    _searchController = TextEditingController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<NewOrdersViewModel>();
      viewModel.initialize();

      // Set the initial tab based on the argument
      if (widget.initialTab != null) {
        final tabName = widget.initialTab == 0 ? 'prescriptions' : 'orders';
        viewModel.changeTab(tabName);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: _buildTabBarView(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'New Orders',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: ColorPalette.primaryColor),
          onPressed: () {
            final viewModel = context.read<NewOrdersViewModel>();
            viewModel.refresh();
          },
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Consumer<NewOrdersViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            onTap: (index) {
              viewModel.changeTab(index == 0 ? 'prescriptions' : 'orders');
            },
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: ColorPalette.primaryColor,
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[600],
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.medical_services, size: 16),
                    SizedBox(width: 6),
                    Text('Prescriptions'),
                    if (viewModel.pendingPrescriptionsCount > 0) ...[
                      SizedBox(width: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${viewModel.pendingPrescriptionsCount}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart, size: 16),
                    SizedBox(width: 6),
                    Text('Orders'),
                    if (viewModel.pendingOrdersCount > 0) ...[
                      SizedBox(width: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${viewModel.pendingOrdersCount}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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

  Widget _buildTabBarView() {
    return Consumer<NewOrdersViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return _buildLoadingState();
        }

        if (viewModel.errorMessage != null) {
          return _buildErrorState(viewModel.errorMessage!);
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildPrescriptionsTab(viewModel),
            _buildOrdersTab(viewModel),
          ],
        );
      },
    );
  }

  Widget _buildPrescriptionsTab(NewOrdersViewModel viewModel) {
    final prescriptions = viewModel.prescriptions;
    
    if (prescriptions.isEmpty) {
      return _buildEmptyState(
        icon: Icons.medical_services_outlined,
        title: 'No Prescriptions',
        subtitle: 'You don\'t have any prescription requests yet',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.refresh();
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: prescriptions.length,
        itemBuilder: (context, index) {
          final prescription = prescriptions[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: PrescriptionCard(
              prescription: prescription,
              onAccept: (note) => viewModel.acceptPrescription(
                prescription.prescriptionId,
                note,
                prescription.userId
              ),
              onReject: (note) => viewModel.rejectPrescription(
                prescription.prescriptionId,
                note,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrdersTab(NewOrdersViewModel viewModel) {
    final orders = viewModel.orders;

    if (orders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.shopping_cart_outlined,
        title: 'No Orders',
        subtitle: 'You don\'t have any orders yet',
      );
    }

    return Column(
      children: [
        // Search and Filter Box
        Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              // Implement search filtering logic
              viewModel.searchOrders(value);
            },
            decoration: InputDecoration(
              hintText: 'Search orders by ID, customer name, or status...',
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey[500],
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: Colors.grey[500],
                  size: 20,
                ),
                onPressed: () {
                  // Show filter options
                  _showFilterOptions(context, viewModel);
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),

        // Orders List
        Expanded(
          child: viewModel.filteredOrders.isEmpty
              ? _buildSearchEmptyState(viewModel)
              : RefreshIndicator(
                  onRefresh: () async {
                    await viewModel.refresh();
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: viewModel.filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = viewModel.filteredOrders[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: OrderCard(
                          order: order,
                          onProcessRequest: () => _navigateToProcessOrder(order),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
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
            'Loading orders...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(32),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[600],
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                final viewModel = context.read<NewOrdersViewModel>();
                viewModel.refresh();
              },
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProcessOrder(dynamic order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewProcessOrderScreen(order: order),
      ),
    );
  }

  void _showFilterOptions(BuildContext context, NewOrdersViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: ColorPalette.primaryColor, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Filter Orders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Filter Options
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Filter
                    Text(
                      'Order Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          context,
                          'All',
                          viewModel.selectedStatusFilter == null,
                          () => viewModel.setStatusFilter(null),
                        ),
                        _buildFilterChip(
                          context,
                          'Pending',
                          viewModel.selectedStatusFilter == 'pending',
                          () => viewModel.setStatusFilter('pending'),
                        ),
                        _buildFilterChip(
                          context,
                          'Payment Completed',
                          viewModel.selectedStatusFilter == 'payment_completed',
                          () => viewModel.setStatusFilter('payment_completed'),
                        ),
                        _buildFilterChip(
                          context,
                          'Out for Delivery',
                          viewModel.selectedStatusFilter == 'out_for_delivery',
                          () => viewModel.setStatusFilter('out_for_delivery'),
                        ),
                        _buildFilterChip(
                          context,
                          'Delivered',
                          viewModel.selectedStatusFilter == 'delivered',
                          () => viewModel.setStatusFilter('delivered'),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Date Range Filter
                    Text(
                      'Date Range',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          context,
                          'All Time',
                          viewModel.selectedDateFilter == null,
                          () => viewModel.setDateFilter(null),
                        ),
                        _buildFilterChip(
                          context,
                          'Today',
                          viewModel.selectedDateFilter == 'today',
                          () => viewModel.setDateFilter('today'),
                        ),
                        _buildFilterChip(
                          context,
                          'This Week',
                          viewModel.selectedDateFilter == 'week',
                          () => viewModel.setDateFilter('week'),
                        ),
                        _buildFilterChip(
                          context,
                          'This Month',
                          viewModel.selectedDateFilter == 'month',
                          () => viewModel.setDateFilter('month'),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Amount Range Filter
                    Text(
                      'Amount Range',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          context,
                          'All',
                          viewModel.selectedAmountFilter == null,
                          () => viewModel.setAmountFilter(null),
                        ),
                        _buildFilterChip(
                          context,
                          'Under ₹500',
                          viewModel.selectedAmountFilter == 'under_500',
                          () => viewModel.setAmountFilter('under_500'),
                        ),
                        _buildFilterChip(
                          context,
                          '₹500 - ₹1000',
                          viewModel.selectedAmountFilter == '500_1000',
                          () => viewModel.setAmountFilter('500_1000'),
                        ),
                        _buildFilterChip(
                          context,
                          'Above ₹1000',
                          viewModel.selectedAmountFilter == 'above_1000',
                          () => viewModel.setAmountFilter('above_1000'),
                        ),
                      ],
                    ),

                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Apply and Clear Buttons
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        viewModel.clearAllFilters();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        viewModel.applyFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Apply Filters',
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
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ColorPalette.primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ColorPalette.primaryColor : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchEmptyState(NewOrdersViewModel viewModel) {
    // Determine if user has active search or filters
    final hasSearch = viewModel.searchQuery.isNotEmpty;
    final hasFilters = viewModel.selectedStatusFilter != null ||
                      viewModel.selectedDateFilter != null ||
                      viewModel.selectedAmountFilter != null;

    IconData icon;
    String title;
    String subtitle;
    String? actionText;
    VoidCallback? action;

    if (hasSearch || hasFilters) {
      // No results found for search/filter
      icon = Icons.search_off;
      title = 'No Results Found';
      subtitle = hasSearch && hasFilters
          ? 'No orders match your search and filter criteria. Try adjusting your filters.'
          : hasSearch
              ? 'No orders found matching "${viewModel.searchQuery}". Try different keywords.'
              : 'No orders found with the selected filters. Try changing your filter options.';
      actionText = 'Clear All Filters';
      action = () {
        viewModel.clearAllFilters();
        // Clear search field
        _searchController.clear();
      };
    } else {
      // No orders at all
      icon = Icons.shopping_cart_outlined;
      title = 'No Orders Yet';
      subtitle = 'You don\'t have any orders yet. New orders will appear here when available.';
      actionText = null;
      action = null;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 56,
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (actionText != null && action != null) ...[
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: action,
                    icon: Icon(Icons.clear_all, size: 16),
                    label: Text(actionText),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
                // Add some bottom padding to ensure content doesn't touch the keyboard
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
