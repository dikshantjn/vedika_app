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
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodel/ScannerViewModel.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/ScannedProductsBottomSheet.dart';
import 'package:logger/logger.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  late AnimationController _placeholderAnimationController;
  late Animation<double> _opacityAnimation;
  int _currentPlaceholderIndex = 0;
  final List<String> _placeholders = [
    'Search medicines...',
    'Search doctors...',
    'Search hospitals...',
    'Search lab tests...',
  ];

  late FocusNode _searchFocusNode;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  final textRecognizer = TextRecognizer();
  final Logger _logger = Logger();
  bool _isProcessing = false;

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

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _placeholderAnimationController,
      curve: Curves.easeInOut,
    ));

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

  Future<void> _initializeCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _disposeCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  Future<void> _scanPrescription() async {
    if (!_isCameraInitialized || _cameraController == null) return;

    // Set loading state immediately when capture button is clicked
    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile image = await _cameraController!.takePicture();
      await _processImage(image.path);
    } catch (e) {
      _logger.e('Error scanning prescription: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning prescription: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    // Set loading state immediately when gallery button is clicked
    setState(() {
      _isProcessing = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        await _processImage(image.path);
      } else {
        // If no image is selected, turn off loading
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      _logger.e('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _processImage(String imagePath) async {
    try {
      // Process the image
      await context.read<ScannerViewModel>().scanPrescription(imagePath);
      
      // Close camera and current screen
      await _disposeCamera();
      if (mounted) {
        Navigator.pop(context);
      }
      
      // Show bottom sheet with results
      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => ScannedProductsBottomSheet(
              products: context.read<ScannerViewModel>().scannedProducts,
              onClose: () {
                Navigator.pop(context);
                context.read<ScannerViewModel>().clearScan();
              },
              onScanAgain: () async {
                Navigator.pop(context);
                await _initializeCamera();
                if (_isCameraInitialized) {
                  _showCameraScreen();
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      _logger.e('Error processing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCameraScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                _disposeCamera();
                Navigator.pop(context);
              },
            ),
            title: Text(
              'Scan Prescription',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              // Camera Preview
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ColorPalette.primaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      CameraPreview(_cameraController!),
                      if (_isProcessing)
                        Container(
                          color: Colors.black.withOpacity(0.7),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
                                  strokeWidth: 3,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Processing prescription...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Please wait while we analyze the text',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),
              // Instructions
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Position the prescription within the frame',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom Buttons
              if (!_isProcessing)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery Button
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _pickImageFromGallery,
                            customBorder: CircleBorder(),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.5),
                              ),
                              child: Icon(
                                Icons.photo_library,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Capture Button
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _scanPrescription,
                            customBorder: CircleBorder(),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorPalette.primaryColor,
                              ),
                              child: Icon(
                                Icons.camera,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Placeholder for symmetry
                      SizedBox(width: 60, height: 60),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    ).then((_) {
      _disposeCamera();
    });
  }

  @override
  void dispose() {
    _disposeCamera();
    textRecognizer.close();
    _searchController.dispose();
    _scrollController.dispose();
    _placeholderAnimationController.dispose();
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
      body: GestureDetector(
        onTap: () {
          // Clear focus when tapping outside
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
                        HealthConcernSection(),
                        CategoryGrid(),
                        BrandSection(),
                        TestimonialSection(),
                        SizedBox(height: 70),
                      ],
                    ),
                  ),
                ],
              ),
              _buildFloatingSearchBar(),
              _buildSearchSuggestions(),
              Positioned(
                bottom: -10,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BottomNavBar(
                    selectedIndex: _selectedIndex,
                    onItemTapped: _onNavBarItemTapped,
                  ),
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
          return SizedBox.shrink();
        }

        return Positioned(
          top: MediaQuery.of(context).padding.top + 56,
          left: 0,
          right: 0,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: searchViewModel.isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: searchViewModel.suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = searchViewModel.suggestions[index];
                      return ListTile(
                        leading: Icon(
                          suggestion['icon'] as IconData,
                          color: ColorPalette.primaryColor,
                        ),
                        title: Text(
                          suggestion['name'],
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
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
          ),
        );
      },
    );
  }

  Widget _buildSearchBox(bool isCollapsed) {
    return GestureDetector(
      onTap: () {
        // Open keyboard when tapping anywhere on the search box
        FocusScope.of(context).requestFocus(FocusNode());
        Future.delayed(Duration(milliseconds: 100), () {
          FocusScope.of(context).requestFocus(_searchFocusNode);
        });
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
                      // Handle search completion
                      FocusScope.of(context).unfocus();
                    },
                    textInputAction: TextInputAction.search,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  if (_searchController.text.isEmpty)
                    FadeTransition(
                      opacity: _opacityAnimation,
                      child: Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Text(
                          _placeholders[_currentPlaceholderIndex],
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
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
              width: 40,
              height: 40,
              margin: EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: ColorPalette.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    await _initializeCamera();
                    if (_isCameraInitialized) {
                      _showCameraScreen();
                    }
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
