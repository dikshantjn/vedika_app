import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/homePageWidgets/BannerSlider.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/homePageWidgets/BrandSection.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/homePageWidgets/CategoryGrid.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/homePageWidgets/HealthConcernSection.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/homePageWidgets/TestimonialSection.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/homePageWidgets/FeaturedArticlesSection.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/homePageWidgets/JustForYouSection.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/CartAndPlaceOrderViewModel.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'package:vedika_healthcare/shared/widgets/BottomNavBar.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/homePageWidgets/MedicalBox.dart';
import 'package:flutter/rendering.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/UserViewModel.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodel/SearchViewModel.dart';
import 'package:vedika_healthcare/features/home/presentation/view/ProductListScreen.dart';
import 'package:vedika_healthcare/features/home/presentation/view/ScanPrescriptionView.dart';
import 'package:logger/logger.dart';
import 'package:vedika_healthcare/features/VedikaAI/presentation/view/AIChatScreen.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  late AnimationController _placeholderAnimationController;
  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;
  int _currentPlaceholderIndex = 0;
  final List<String> _placeholders = [
    'Search medicines...',
    'Search doctors...',
    'Search hospitals...',
    'Search lab tests...',
  ];
  String _typedPlaceholder = '';
  int _typedCharIndex = 0;
  Duration _typingSpeed = const Duration(milliseconds: 60);
  Duration _pauseDuration = const Duration(milliseconds: 1200);
  Timer? _typingTimer;
  bool _isErasing = false;

  late FocusNode _searchFocusNode;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    Provider.of<LocationProvider>(context, listen: false).loadSavedLocation();
    _scrollController.addListener(_onScroll);
    _initializeAnimations();
    _refreshUserProfile();
    _setupCartCountListener();
    _searchFocusNode = FocusNode();

    // Add listener to search controller
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        context.read<SearchViewModel>().clearSearch();
      }
      setState(() {}); // Force rebuild when text changes
    });
    _startTypingPlaceholder();
  }

  void _startTypingPlaceholder() {
    _typedPlaceholder = '';
    _typedCharIndex = 0;
    _typingTimer?.cancel();
    _isErasing = false;
    _typingTimer = Timer.periodic(_typingSpeed, (timer) {
      if (!_isErasing) {
        // Typing forward
        if (_typedCharIndex < _placeholders[_currentPlaceholderIndex].length) {
          setState(() {
            _typedPlaceholder += _placeholders[_currentPlaceholderIndex][_typedCharIndex];
            _typedCharIndex++;
          });
        } else {
          // Pause, then start erasing
          timer.cancel();
          Future.delayed(_pauseDuration, () {
            _isErasing = true;
            _typingTimer = Timer.periodic(_typingSpeed, (timer) {
              if (_typedCharIndex > 0) {
                setState(() {
                  _typedPlaceholder = _typedPlaceholder.substring(0, _typedCharIndex - 1);
                  _typedCharIndex--;
                });
              } else {
                timer.cancel();
                setState(() {
                  _currentPlaceholderIndex = (_currentPlaceholderIndex + 1) % _placeholders.length;
                });
                _startTypingPlaceholder();
              }
            });
          });
        }
      }
    });
  }

  Future<void> _refreshUserProfile() async {
    final userViewModel = context.read<UserViewModel>();
    final userId = await StorageService.getUserId();
    if (userId != null) {
      await userViewModel.fetchUserDetails(userId);
    }
  }

  void _initializeAnimations() {
    // Initialize placeholder animation
    _placeholderAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _placeholderAnimationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          setState(() {
            _currentPlaceholderIndex = (_currentPlaceholderIndex + 1) % _placeholders.length;
          });
          _placeholderAnimationController.forward();
        }
      });

    // Initialize gradient animation
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _gradientAnimation = Tween<double>(begin: 0, end: 1).animate(_gradientController);

    // Start the placeholder animation
    _placeholderAnimationController.forward();
  }

  void _setupCartCountListener() {
    final cartViewModel = Provider.of<CartAndPlaceOrderViewModel>(context, listen: false);
    cartViewModel.onCartCountUpdate = () {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild of the cart icon with the new count
        });
      }
    };
  }

  @override
  void dispose() {
    _searchController.removeListener(() {});
    _searchController.dispose();
    _scrollController.dispose();
    _placeholderAnimationController.dispose();
    _typingTimer?.cancel();
    _gradientController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 80 && !_isCollapsed) {
      setState(() {
        _isCollapsed = true;
      });
    } else if (_scrollController.offset <= 80 && _isCollapsed) {
      setState(() {
        _isCollapsed = false;
      });
    }
  }

  void _onNavBarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      extendBody: true,
      drawer: DrawerMenu(),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavBarItemTapped,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          if (_searchController.text.isEmpty) {
            context.read<SearchViewModel>().clearSearch();
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    expandedHeight: 140.0,
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildHeader(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MedicalBoxRow(),
                        SizedBox(height: 8),
                        BannerSlider(),
                        JustForYouSection(),
                        HealthConcernSection(),
                        FeaturedArticlesSection(),
                        CategoryGrid(),
                        BrandSection(),
                        TestimonialSection(),
                        SizedBox(height: 54 + 12 + MediaQuery.of(context).padding.bottom),
                      ],
                    ),
                  ),
                ],
              ),
              _buildFloatingSearchBar(),
              Positioned(
                top: MediaQuery.of(context).padding.top + 104,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSearchSuggestions(),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Builder(
                  builder: (context) => GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                      _refreshUserProfile();
                    },
                    child: Consumer<UserViewModel>(
                      builder: (context, userViewModel, child) {
                        return _buildProfileAvatar(context, userViewModel);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Home',
                            style: TextStyle(
                              fontSize: 16,
                              color: ColorPalette.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: ColorPalette.primaryColor),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on, color: ColorPalette.primaryColor, size: 18),
                          SizedBox(width: 4),
                          Text(
                            '123 Random Street, City',
                            style: TextStyle(fontSize: 14, color: ColorPalette.primaryColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildCartIcon(),
              ],
            ),
          ),
          SizedBox(height: 12),
          if (!_isCollapsed)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildSearchBox(false),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingSearchBar() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      top: _isCollapsed ? MediaQuery.of(context).padding.top : -100,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: _buildSearchBox(true),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return Consumer<SearchViewModel>(
      builder: (context, searchViewModel, child) {
        if (searchViewModel.suggestions.isEmpty) {
          if (_searchController.text.isNotEmpty) {
            return Container(
              margin: EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF8E2DE2), // Vibrant Purple
                    Color(0xFF4A00E0), // Deep Indigo
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF8E2DE2).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  'Search with Vedika VedikaAI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Get intelligent search results powered by VedikaAI',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AIChatScreen(
                        initialQuery: _searchController.text,
                      ),
                    ),
                  );
                  searchViewModel.clearSearch();
                  _searchController.clear();
                  FocusScope.of(context).unfocus();
                },
              ),
            );
          }
          return SizedBox.shrink();
        }

        return Container(
          margin: EdgeInsets.only(top: 8),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: searchViewModel.isLoading
              ? _buildShimmerLoading()
              : ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: 4),
                  itemCount: searchViewModel.suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = searchViewModel.suggestions[index];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Icon(
                        suggestion['icon'] as IconData,
                        color: ColorPalette.primaryColor,
                        size: 20,
                      ),
                      title: Text(
                        suggestion['name'],
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: suggestion['type'] == 'subcategory'
                          ? Text(
                              'in ${suggestion['parentCategory']}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            )
                          : null,
                      onTap: () {
                        if (suggestion['type'] == 'service') {
                          Navigator.pushNamed(context, suggestion['route']);
                        } else if (suggestion['type'] == 'category' || suggestion['type'] == 'subcategory') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductListScreen(
                                category: suggestion['params']['category'],
                                subCategory: suggestion['params']['subCategory'],
                              ),
                            ),
                          );
                        }
                        searchViewModel.clearSearch();
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                      },
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: 4),
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            title: Container(
              width: double.infinity,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            subtitle: Container(
              width: 100,
              height: 12,
              margin: EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBox(bool isCollapsed) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(_searchFocusNode);
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: ColorPalette.primaryColor,
            width: 1.5,
          ),
          boxShadow: [
            if (isCollapsed)
              BoxShadow(
                color: ColorPalette.primaryColor.withOpacity(0.08),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            if (isCollapsed)
              Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Builder(
                  builder: (context) => GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                      _refreshUserProfile();
                    },
                    child: Consumer<UserViewModel>(
                      builder: (context, userViewModel, child) {
                        return _buildProfileAvatar(context, userViewModel, size: 35);
                      },
                    ),
                  ),
                ),
              ),
            SizedBox(width: isCollapsed ? 8 : 16),
            Icon(
              Icons.search,
              color: ColorPalette.primaryColor,
              size: 20,
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                    onChanged: (value) {
                      context.read<SearchViewModel>().search(value);
                    },
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                    },
                    textInputAction: TextInputAction.search,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  if (_searchController.text.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Text(
                        _placeholders[_currentPlaceholderIndex],
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, size: 20),
                onPressed: () {
                  _searchController.clear();
                  context.read<SearchViewModel>().clearSearch();
                  FocusScope.of(context).requestFocus(_searchFocusNode);
                },
              ),
            Container(
              width: 80,
              height: 40,
              margin: EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: ColorPalette.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AIChatScreen(
                              initialQuery: _searchController.text,
                            ),
                          ),
                        );
                      },
                      child: Tooltip(
                        message: 'Ask VedikaAI',
                        child: Image.asset(
                          'assets/ai.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: ColorPalette.primaryColor.withOpacity(0.2),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScanPrescriptionView(),
                          ),
                        );
                      },
                      child: Tooltip(
                        message: 'Scan prescription',
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: ColorPalette.primaryColor,
                          size: 20,
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

  Widget _buildCartIcon() {
    return Consumer<CartAndPlaceOrderViewModel>(
      builder: (context, cartViewModel, child) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: ColorPalette.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.goToCart);
                },
                icon: Icon(Icons.shopping_cart_outlined, color: ColorPalette.primaryColor),
              ),
            ),
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  cartViewModel.totalItemCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileAvatar(BuildContext context, UserViewModel userViewModel, {double size = 40}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorPalette.primaryColor,
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primaryColor.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: userViewModel.user?.photo?.isNotEmpty == true
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: userViewModel.user!.photo!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.person,
                  size: size * 0.6,
                  color: Colors.white,
                ),
              ),
            )
          : Icon(
              Icons.person,
              size: size * 0.6,
              color: Colors.white,
            ),
    );
  }
}
