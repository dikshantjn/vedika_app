import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/home/presentation/view/HomePage.dart';
import 'package:vedika_healthcare/features/notifications/presentation/view/NotificationPage.dart';
import 'package:vedika_healthcare/features/HealthRecords/presentation/view/HealthRecordsPage.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/view/OrderHistoryPage.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/view/TrackOrderScreen.dart';
import 'package:vedika_healthcare/features/membership/presentation/view/MembershipPage.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/view/UserProfilePage.dart';
import 'package:vedika_healthcare/features/settings/presentation/view/SettingsPage.dart';
import 'package:vedika_healthcare/features/help/presentation/view/HelpCenterPage.dart';
import 'package:vedika_healthcare/shared/widgets/BottomNavBar.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';

// Global navigation service to manage MainScreen state
class MainScreenNavigator {
  static final MainScreenNavigator _instance = MainScreenNavigator._internal();
  factory MainScreenNavigator() => _instance;
  MainScreenNavigator._internal();

  static MainScreenNavigator get instance => _instance;

  // Flag to track if MainScreen is already created
  bool _isMainScreenCreated = false;
  
  // Store reference to the current MainScreen state
  MainScreenState? _currentState;
  
  // Method to register the current MainScreen state
  void registerState(MainScreenState state) {
    _currentState = state;
    _isMainScreenCreated = true;
  }

  // Method to unregister the current MainScreen state
  void unregisterState(MainScreenState state) {
    if (_currentState == state) {
      _currentState = null;
      _isMainScreenCreated = false;
    }
  }

  // Method to check if MainScreen is already created
  bool get isMainScreenCreated => _isMainScreenCreated;

  // Method to navigate to a specific index
  void navigateToIndex(int index) {
    if (_currentState != null && _currentState!.mounted) {
      _currentState!._handleSelectIndex(index);
    }
  }

  // Method to navigate to a transient child
  void navigateToTransientChild(Widget child) {
    if (_currentState != null && _currentState!.mounted) {
      _currentState!._handleTransientChild(child);
    }
  }

  // Method to navigate to index with transient child
  void navigateToIndexWithChild(int index, Widget child) {
    if (_currentState != null && _currentState!.mounted) {
      _currentState!._handleIndexWithTransientChild(index, child);
    }
  }

  // Control bottom navigation bar visibility
  void setBottomNavVisible(bool visible) {
    if (_currentState != null && _currentState!.mounted) {
      _currentState!._setBottomNavVisible(visible);
    }
  }

  // Method to go back (pop route)
  bool goBack() {
    if (_currentState != null && _currentState!.mounted) {
      return _currentState!._popRoute();
    }
    return false;
  }

  // Method to check if we can go back
  bool get canGoBack {
    if (_currentState != null && _currentState!.mounted) {
      return _currentState!.canPop;
    }
    return false;
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;
  final Widget? transientChild;

  const MainScreen({Key? key, this.initialIndex = 0, this.transientChild}) : super(key: key);

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Debug tracking
  static int _instanceCount = 0;
  final int _instanceId = ++_instanceCount;
  
  // Single source of truth for visible screen
  late int _selectedIndex = widget.initialIndex;
  
  // Track transient child separately to handle updates
  Widget? _currentTransientChild;

  // Route stack to track navigation history within MainScreen
  final List<Map<String, dynamic>> _routeStack = [];
  
  // Map route names to stack indices for DrawerMenu coordination
  late final Map<String, int> _routeIndexMap = <String, int>{
    AppRoutes.home: 0,
    AppRoutes.orderHistory: 1,
    AppRoutes.notification: 2,
    AppRoutes.healthRecords: 3,
    AppRoutes.trackOrderScreen: 4,
    AppRoutes.userProfile: 6,
    AppRoutes.settings: 7,
    '/help': 8,
    '/terms': 9,
  };

  // Lazy loading mechanism for pages
  final Map<int, Widget> _pageCache = {};

  // Bottom navigation visibility
  bool _bottomNavVisible = true;

  @override
  void initState() {
    super.initState();
    debugPrint('🚨 MainScreen INITIALIZED - Instance #$_instanceId (Total: $_instanceCount)');
    debugPrint('🚨 MainScreen initState - initialIndex: ${widget.initialIndex}, transientChild: ${widget.transientChild != null ? 'YES' : 'NO'}');
    
    // Register this state with the global navigator
    MainScreenNavigator.instance.registerState(this);
    
    // Initialize transient child
    _currentTransientChild = widget.transientChild;
    
    // Add initial route to stack
    _addToRouteStack(widget.initialIndex, widget.transientChild);
    
    // Handle route arguments if passed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleRouteArguments();
    });
  }

  void _handleRouteArguments() {
    final route = ModalRoute.of(context);
    if (route != null && route.settings.arguments != null) {
      final args = route.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        debugPrint('🚨 MainScreen route arguments: $args');
        
        bool needsUpdate = false;
        
        if (args.containsKey('initialIndex')) {
          final index = args['initialIndex'] as int?;
          if (index != null && index != _selectedIndex) {
            debugPrint('🚨 MainScreen updating index from $_selectedIndex to $index');
            _selectedIndex = index;
            needsUpdate = true;
          }
        }
        
        if (args.containsKey('transientChild')) {
          final newTransientChild = args['transientChild'] as Widget?;
          if (newTransientChild != _currentTransientChild) {
            debugPrint('🚨 MainScreen updating transientChild from ${_currentTransientChild.runtimeType} to ${newTransientChild.runtimeType}');
            _currentTransientChild = newTransientChild;
            needsUpdate = true;
            
            // Clear the page cache for index 9 to force rebuild
            _pageCache.remove(9);
          }
        }
        
        if (args.containsKey('hideBottomNav')) {
          final hideBottomNav = args['hideBottomNav'] as bool?;
          if (hideBottomNav != null) {
            _bottomNavVisible = !hideBottomNav;
            needsUpdate = true;
          }
        }

        if (needsUpdate) {
          // Add the new route to stack
          if (args.containsKey('initialIndex') || args.containsKey('transientChild')) {
            _addToRouteStack(_selectedIndex, _currentTransientChild);
          }
          setState(() {});
        }
      }
    }
  }

  @override
  void dispose() {
    debugPrint('🚨 MainScreen DISPOSED - Instance #$_instanceId');
    // Unregister this state from the global navigator
    MainScreenNavigator.instance.unregisterState(this);
    // Clear page cache to free memory
    _pageCache.clear();
    super.dispose();
  }

  Widget _createPage(int index) {
    switch (index) {
      case 0:
        return const HomePage(embed: true);
      case 1:
        return OrderHistoryPage();
      case 2:
        return NotificationPage();
      case 3:
        return HealthRecordsPage();
      case 4:
        return const TrackOrderScreen();
      case 5:
        return const MembershipPage();
      case 6:
        return UserProfilePage();
      case 7:
        return const SettingsPage();
      case 8:
        return const HelpCenterPage();
      case 9:
        return _TransientHostPage(
          key: ValueKey('transient_${_currentTransientChild.hashCode}'),
          transientChild: _currentTransientChild,
        );
      default:
        return const HomePage(embed: true);
    }
  }

  Widget _getPage(int index) {
    // Only create pages when they are actually needed
    if (_pageCache.containsKey(index)) {
      return _pageCache[index]!;
    }

    // Only initialize the current page and keep a placeholder for others
    if (index == _selectedIndex) {
      final page = _createPage(index);
      _pageCache[index] = page;
      return page;
    } else {
      // Return a placeholder for non-selected pages to save memory
      return const SizedBox.shrink();
    }
  }

  void _handleSelectIndex(int newIndex) {
    if (newIndex == _selectedIndex) {
      return; // no-op to prevent reloading the same screen
    }
    
    // Add to route stack before updating
    _addToRouteStack(newIndex, null);
    
    // Clear the page cache for the new index to force initialization
    _pageCache.remove(newIndex);
    
    setState(() {
      _selectedIndex = newIndex;
      // Clear transient child when navigating to a different index
      // unless we're specifically going to index 9 (which handles transient children)
      if (newIndex != 9) {
        _currentTransientChild = null;
      }
      // Ensure bottom nav is visible when navigating to a standard index
      if (newIndex != 9) {
        _bottomNavVisible = true;
      }
    });
  }

  // Method to handle transient child updates
  void _handleTransientChild(Widget child) {
    if (child != _currentTransientChild) {
      setState(() {
        _currentTransientChild = child;
        _selectedIndex = 9; // Switch to transient child index
      });
      // Clear the page cache for index 9 to force rebuild
      _pageCache.remove(9);
    }
  }

  // Method to handle index with transient child
  void _handleIndexWithTransientChild(int index, Widget child) {
    // Add to route stack before updating
    _addToRouteStack(index, child);
    
    setState(() {
      _selectedIndex = index;
      _currentTransientChild = child;
      // Keep current bottom nav visibility as-is unless explicitly changed
    });
    // Clear the page cache for the new index to force rebuild
    _pageCache.remove(index);
  }

  // Method to add route to stack
  void _addToRouteStack(int index, Widget? child) {
    _routeStack.add({
      'index': index,
      'child': child,
      'timestamp': DateTime.now(),
      'bottomNavVisible': _bottomNavVisible,
    });
    debugPrint('🚨 Route added to stack: index=$index, child=${child.runtimeType}, stack size: ${_routeStack.length}');
  }

  // Method to pop route from stack
  bool _popRoute() {
    if (_routeStack.length > 1) {
      // Remove current route
      _routeStack.removeLast();
      
      // Get previous route
      final previousRoute = _routeStack.last;
      final previousIndex = previousRoute['index'] as int;
      final previousChild = previousRoute['child'] as Widget?;
      final previousBottomNavVisible = previousRoute['bottomNavVisible'] as bool? ?? true;
      
      debugPrint('🚨 Popping route: going back to index=$previousIndex, child=${previousChild.runtimeType}');
      
      setState(() {
        _selectedIndex = previousIndex;
        _currentTransientChild = previousChild;
        // Restore the recorded bottom nav visibility for the previous route
        _bottomNavVisible = previousBottomNavVisible;
      });
      
      // Clear the page cache for the new index to force rebuild
      _pageCache.remove(previousIndex);
      
      return true;
    }
    return false;
  }
  // Setter used by navigator to control bottom nav visibility
  void _setBottomNavVisible(bool visible) {
    if (!mounted) return;
    setState(() {
      _bottomNavVisible = visible;
    });
    if (_routeStack.isNotEmpty) {
      _routeStack[_routeStack.length - 1]['bottomNavVisible'] = _bottomNavVisible;
    }
  }

  // Method to check if we can pop
  bool get canPop => _routeStack.length > 1;

  // Method to clear unused page cache (keep only current page)
  void _clearUnusedCache() {
    final keysToRemove = _pageCache.keys.where((key) => key != _selectedIndex).toList();
    for (final key in keysToRemove) {
      _pageCache.remove(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🚨 MainScreen BUILD - Instance #$_instanceId, selectedIndex: $_selectedIndex, transientChild: ${_currentTransientChild.runtimeType}');
    
    return WillPopScope(
      onWillPop: () async {
        // If we're on home (index 0), allow app to close
        if (_selectedIndex == 0) {
          return true;
        }
        
        // If we can pop back in our route stack, do that instead of going to home
        if (canPop) {
          _popRoute();
          return false; // Don't close the app
        }
        
        // If we can't pop back, go to home
        _handleSelectIndex(0);
        return false; // Don't close the app
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        drawer: DrawerMenu(
          onSelectIndex: _handleSelectIndex,
          currentIndex: _selectedIndex,
          routeIndexMap: _routeIndexMap,
        ),
        body: MainScreenScope(
          currentIndex: _selectedIndex,
          setIndex: _handleSelectIndex,
          transientChild: _currentTransientChild,
          child: IndexedStack(
            index: _selectedIndex,
            children: List.generate(10, (index) => 
              index == _selectedIndex ? _getPage(index) : const SizedBox.shrink()
            ),
          ),
        ),
        // Do not extend body under the BottomNavBar to avoid overlap
        extendBody: false,
        bottomNavigationBar: _bottomNavVisible
            ? BottomNavBar(
                selectedIndex: _selectedIndex,
                onItemTapped: (int index) {
                  // Bottom bar only switches to Home in current design
                  if (index == 0) {
                    _handleSelectIndex(0);
                  }
                },
              )
            : null,
      ),
    );
  }
}

class MainScreenScope extends InheritedWidget {
  final void Function(int index) setIndex;
  final int currentIndex;
  final Widget? transientChild;

  const MainScreenScope({
    Key? key,
    required Widget child,
    required this.setIndex,
    required this.currentIndex,
    this.transientChild,
  }) : super(key: key, child: child);

  static MainScreenScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainScreenScope>();
  }

  static MainScreenScope of(BuildContext context) {
    final MainScreenScope? result = maybeOf(context);
    assert(result != null, 'No MainScreenScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(MainScreenScope oldWidget) {
    return oldWidget.currentIndex != currentIndex || oldWidget.setIndex != setIndex || oldWidget.transientChild != transientChild;
  }
}

class _TransientHostPage extends StatefulWidget {
  final Widget? transientChild;

  const _TransientHostPage({Key? key, this.transientChild}) : super(key: key);

  @override
  State<_TransientHostPage> createState() => _TransientHostPageState();
}

class _TransientHostPageState extends State<_TransientHostPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('🚨 _TransientHostPage INITIALIZED - transientChild: ${widget.transientChild != null ? 'YES' : 'NO'}');
  }

  @override
  Widget build(BuildContext context) {
    final scope = MainScreenScope.maybeOf(context);
    final child = scope?.transientChild ?? widget.transientChild;
    
    if (child != null) {
      debugPrint('🚨 _TransientHostPage displaying transient child: ${child.runtimeType}');
      return child;
    }
    
    debugPrint('🚨 _TransientHostPage displaying default welcome screen');
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Welcome to Vedika Healthtech',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Use the navigation to explore our services',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
