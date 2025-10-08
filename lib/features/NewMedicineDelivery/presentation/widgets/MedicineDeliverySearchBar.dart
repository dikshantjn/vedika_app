import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/NewMedicineDelivery/presentation/viewmodel/MedicineDeliveryViewModel.dart';

class MedicineDeliverySearchBar extends StatefulWidget {
  const MedicineDeliverySearchBar({Key? key}) : super(key: key);

  @override
  State<MedicineDeliverySearchBar> createState() => _MedicineDeliverySearchBarState();
}

class _MedicineDeliverySearchBarState extends State<MedicineDeliverySearchBar>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupListeners();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupListeners() {
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    _searchController.addListener(() {
      final viewModel = context.read<MedicineDeliveryViewModel>();
      if (mounted) {
        viewModel.searchStores(_searchController.text);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _isFocused
                      ? ColorPalette.primaryColor.withOpacity(0.2)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: _isFocused ? 12 : 8,
                  offset: Offset(0, _isFocused ? 6 : 4),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isFocused
                      ? ColorPalette.primaryColor
                      : Colors.grey[300]!,
                  width: _isFocused ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  _buildSearchIcon(),
                  _buildSearchField(),
                  _buildClearButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchIcon() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Icon(
        Icons.search,
        color: _isFocused ? ColorPalette.primaryColor : Colors.grey[600],
        size: 24,
      ),
    );
  }

  Widget _buildSearchField() {
    return Expanded(
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Search medicines, stores, or locations...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          _focusNode.unfocus();
        },
      ),
    );
  }

  Widget _buildClearButton() {
    if (_searchController.text.isEmpty) return SizedBox.shrink();
    
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: IconButton(
        onPressed: () {
          _searchController.clear();
          _focusNode.requestFocus();
        },
        icon: Icon(
          Icons.clear,
          color: Colors.grey[600],
          size: 20,
        ),
        style: IconButton.styleFrom(
          backgroundColor: Colors.grey[200],
          padding: EdgeInsets.all(8),
        ),
      ),
    );
  }
}
