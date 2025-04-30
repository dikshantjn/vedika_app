import 'package:vedika_healthcare/features/home/data/models/Product.dart';

class ProductService {
  // Mock data for products
  static final List<Product> _products = [
    // Dental Care Products
    Product(
      id: 'DC001',
      category: 'Dental Care',
      name: 'Transparent Aligners',
      imageUrl: 'https://images.unsplash.com/photo-1629909613654-28e377c37b09?w=800',
      additionalImages: [
        'https://images.unsplash.com/photo-1629909615184-74f495363b67?w=800',
        'https://images.unsplash.com/photo-1629909615184-74f495363b67?w=800',
        'https://images.unsplash.com/photo-1629909615184-74f495363b67?w=800',
      ],
      videoUrl: 'https://player.vimeo.com/external/434045526.sd.mp4?s=c27eecc69a27dbc4ff2b87d38afc35f1a9e7c02d&profile_id=164&oauth2_token_id=57447761',
      description: 'Professional clear aligners for teeth straightening',
      usp: 'Our clear braces for teeth are designed with your comfort in mind, making your orthodontic journey a breeze.',
      howToUse: 'Book a scan\nGet virtual results\nMeet our partner Orthodentist\nGet that smile of confidence',
      priceTiers: [
        PriceTier(
          name: 'Smile',
          price: 41999.0,
          description: 'Basic alignment package',
        ),
        PriceTier(
          name: 'Grin',
          price: 49999.0,
          description: 'Standard alignment package',
        ),
        PriceTier(
          name: 'Laugh',
          price: 59999.0,
          description: 'Premium alignment package',
        ),
      ],
      demoLink: 'https://guidelign.com/',
      highlights: [
        'Clear and comfortable aligners',
        'Professional orthodontic treatment',
        'Virtual treatment planning',
        'Expert orthodontist consultation',
        'Easy payment options',
      ],
    ),
    Product(
      id: 'DC002',
      name: 'Electric Toothbrush Pro',
      description: 'Smart electric toothbrush with pressure sensor and multiple modes',
      imageUrl: 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=800',
      additionalImages: [
        'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=800',
        'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=800',
      ],
      videoUrl: 'https://player.vimeo.com/external/434045526.sd.mp4?s=c27eecc69a27dbc4ff2b87d38afc35f1a9e7c02d&profile_id=164&oauth2_token_id=57447761',
      category: 'Dental Care',
      usp: 'Advanced cleaning technology with smart pressure sensors and multiple cleaning modes for optimal oral health.',
      howToUse: '1. Wet the brush head\n2. Apply toothpaste\n3. Select desired mode\n4. Brush for 2 minutes\n5. Rinse and clean',
      price: 2499.99,
      highlights: [
        'Smart pressure sensor',
        'Multiple cleaning modes',
        'Long battery life',
        'Travel case included',
        'Replaceable brush heads',
      ],
    ),

    // Heart Care Products
    Product(
      id: 'HC001',
      name: 'Smart Blood Pressure Monitor',
      description: 'Digital BP monitor with smartphone connectivity',
      imageUrl: 'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?w=800',
      additionalImages: [
        'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?w=800',
        'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?w=800',
        'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?w=800',
      ],
      videoUrl: 'https://player.vimeo.com/external/434045526.sd.mp4?s=c27eecc69a27dbc4ff2b87d38afc35f1a9e7c02d&profile_id=164&oauth2_token_id=57447761',
      category: 'Heart Care',
      usp: 'Accurate blood pressure monitoring with smartphone connectivity for easy tracking and sharing with healthcare providers.',
      howToUse: '1. Sit in a comfortable position\n2. Wrap the cuff around your arm\n3. Press start\n4. Stay still during measurement\n5. View results on your phone',
      price: 1999.99,
      highlights: [
        'Bluetooth connectivity',
        '90 reading memory',
        'Irregular heartbeat detection',
        'Multiple user profiles',
        'Free mobile app',
      ],
    ),
    Product(
      id: 'HC002',
      name: 'Portable ECG Monitor',
      description: 'Personal ECG device for heart rhythm monitoring',
      imageUrl: 'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?w=800',
      additionalImages: [
        'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?w=800',
        'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?w=800',
        'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?w=800',
      ],
      videoUrl: 'https://player.vimeo.com/external/434045526.sd.mp4?s=c27eecc69a27dbc4ff2b87d38afc35f1a9e7c02d&profile_id=164&oauth2_token_id=57447761',
      category: 'Heart Care',
      usp: 'Professional-grade ECG monitoring at home with instant results and expert analysis.',
      howToUse: '1. Place device on chest\n2. Hold for 30 seconds\n3. View results instantly\n4. Share with doctor\n5. Track trends over time',
      price: 4999.99,
      highlights: [
        '30-second readings',
        'Cloud storage',
        'Doctor sharing',
        'Trend analysis',
        'Battery powered',
      ],
    ),
    // New Product: Smart Health Monitor
    Product(
      id: 'HC003',
      name: 'Smart Health Monitor',
      description: 'Comprehensive health monitoring device with multiple vital sign tracking',
      imageUrl: 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800',
      additionalImages: [
        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800',
        'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800',
        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800',
      ],
      videoUrl: 'https://player.vimeo.com/external/434045526.sd.mp4?s=c27eecc69a27dbc4ff2b87d38afc35f1a9e7c02d&profile_id=164&oauth2_token_id=57447761',
      category: 'Heart Care',
      usp: 'Advanced health monitoring with real-time tracking of multiple vital signs and AI-powered health insights.',
      howToUse: '1. Wear the device\n2. Connect to smartphone app\n3. Monitor vital signs\n4. View health insights\n5. Share with healthcare provider',
      price: 3499.99,
      highlights: [
        '24/7 vital sign monitoring',
        'AI-powered health insights',
        'Smartphone connectivity',
        'Long battery life',
        'Water resistant',
      ],
    ),

    // Baby Care Products
    Product(
      id: 'BC001',
      name: 'Organic Baby Food Set',
      description: 'Complete set of organic baby food for 6+ months',
      imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=800',
      additionalImages: [
        'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=800',
        'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=800',
        'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=800',
      ],
      videoUrl: 'https://player.vimeo.com/external/434045526.sd.mp4?s=c27eecc69a27dbc4ff2b87d38afc35f1a9e7c02d&profile_id=164&oauth2_token_id=57447761',
      category: 'Baby Care',
      usp: '100% organic, nutritionally balanced baby food made with premium ingredients for healthy growth.',
      howToUse: '1. Check age recommendation\n2. Warm if desired\n3. Serve at room temperature\n4. Store unused portion\n5. Use within 24 hours',
      price: 899.99,
      highlights: [
        '100% organic ingredients',
        'No preservatives',
        'Rich in nutrients',
        'Easy to digest',
        'Multiple flavors',
      ],
    ),
  ];

  // Get all products
  static List<Product> getAllProducts() {
    return _products;
  }

  // Get products by category
  static List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  // Get products by subcategory
  static List<Product> getProductsBySubCategory(String subCategory) {
    return _products.where((product) => product.subCategory == subCategory).toList();
  }

  // Get product by ID
  static Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search products
  static List<Product> searchProducts(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
          product.description.toLowerCase().contains(lowercaseQuery) ||
          product.category.toLowerCase().contains(lowercaseQuery) ||
          product.usp.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
} 