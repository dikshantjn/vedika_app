import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/HealthConcernColorPalette.dart';

class RecommendationModel {
  final String id;
  final String type;
  final String title;
  final String description;
  final String actionText;
  final IconData icon;
  final Color color;
  final VoidCallback? onAction;

  RecommendationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.actionText,
    required this.icon,
    required this.color,
    this.onAction,
  });
}

class JustForYouSection extends StatefulWidget {
  @override
  State<JustForYouSection> createState() => _JustForYouSectionState();
}

class _JustForYouSectionState extends State<JustForYouSection>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;

  // Mock data for recommendations with pastel colors
  final List<RecommendationModel> _recommendations = [
    RecommendationModel(
      id: '1',
      type: 'lab_test',
      title: 'Blood Sugar Test',
      description: 'Based on your age and family history',
      actionText: 'Book Now',
      icon: Icons.science,
      color: Color(0xFFE3F2FD), // Light blue
      onAction: () {
        // Navigate to lab test booking
      },
    ),
    RecommendationModel(
      id: '2',
      type: 'medicine',
      title: 'Reorder Paracetamol',
      description: 'You ordered this 2 weeks ago',
      actionText: 'Order',
      icon: Icons.medication,
      color: Color(0xFFE8F5E9), // Light green
      onAction: () {
        // Navigate to medicine reorder
      },
    ),
    RecommendationModel(
      id: '3',
      type: 'appointment',
      title: 'Follow-up Consultation',
      description: 'Dr. Smith - 30 days overdue',
      actionText: 'Book Now',
      icon: Icons.calendar_today,
      color: Color(0xFFFFF3E0), // Light orange
      onAction: () {
        // Navigate to appointment booking
      },
    ),
    RecommendationModel(
      id: '4',
      type: 'checkup',
      title: 'Complete Health Checkup',
      description: 'Special birthday month offer',
      actionText: 'See More',
      icon: Icons.health_and_safety,
      color: Color(0xFFF3E5F5), // Light purple
      onAction: () {
        // Navigate to health checkup packages
      },
    ),
    RecommendationModel(
      id: '5',
      type: 'blood_donation',
      title: 'Blood Donation Camp',
      description: 'Nearby - 2km from your location',
      actionText: 'Donate',
      icon: Icons.bloodtype,
      color: Color(0xFFFFEBEE), // Light red
      onAction: () {
        // Navigate to blood donation
      },
    ),
    RecommendationModel(
      id: '6',
      type: 'alternative',
      title: 'Alternative Medicine',
      description: 'Your prescription is out of stock',
      actionText: 'View Options',
      icon: Icons.swap_horiz,
      color: Color(0xFFE0F2F1), // Light teal
      onAction: () {
        // Navigate to alternatives
      },
    ),
    RecommendationModel(
      id: '7',
      type: 'discovery',
      title: 'Online Doctor Consultation',
      description: 'Try our new telemedicine service',
      actionText: 'Discover',
      icon: Icons.video_call,
      color: Color(0xFFE8EAF6), // Light indigo
      onAction: () {
        // Navigate to online consultation
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA), // Light attractive background
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.teal.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.person_pin,
                        color: Colors.teal,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Just for You",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _showMoreRecommendationsSheet(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor: Colors.teal.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "View All",
                        style: TextStyle(
                          color: Colors.teal,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.teal,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Empty state check
          if (_recommendations.isEmpty)
            _buildEmptyState()
          else
            Container(
              height: isTablet ? 200 : 160,
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollStartNotification) {
                    setState(() {
                      _isScrolling = true;
                    });
                  } else if (scrollNotification is ScrollEndNotification) {
                    setState(() {
                      _isScrolling = false;
                    });
                  }
                  return true;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _recommendations.length,
                  itemBuilder: (context, index) {
                    final recommendation = _recommendations[index];
                    return _buildRecommendationCard(
                      recommendation,
                      index,
                      isTablet,
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    RecommendationModel recommendation,
    int index,
    bool isTablet,
  ) {
    final cardWidth = isTablet ? 280.0 : 240.0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: cardWidth,
          margin: EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              _animationController.forward().then((_) {
                _animationController.reverse();
              });
              recommendation.onAction?.call();
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: recommendation.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: recommendation.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            recommendation.icon,
                            color: _getIconColor(recommendation.color),
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recommendation.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Text(
                                recommendation.description,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: recommendation.onAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _getIconColor(recommendation.color),
                          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          side: BorderSide(
                            color: _getIconColor(recommendation.color).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          recommendation.actionText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getIconColor(Color backgroundColor) {
    // Return appropriate icon color based on background
    if (backgroundColor == Color(0xFFE3F2FD)) return Color(0xFF1976D2); // Blue
    if (backgroundColor == Color(0xFFE8F5E9)) return Color(0xFF388E3C); // Green
    if (backgroundColor == Color(0xFFFFF3E0)) return Color(0xFFF57C00); // Orange
    if (backgroundColor == Color(0xFFF3E5F5)) return Color(0xFF7B1FA2); // Purple
    if (backgroundColor == Color(0xFFFFEBEE)) return Color(0xFFD32F2F); // Red
    if (backgroundColor == Color(0xFFE0F2F1)) return Color(0xFF00796B); // Teal
    if (backgroundColor == Color(0xFFE8EAF6)) return Color(0xFF3F51B5); // Indigo
    return Colors.teal; // Default
  }

  Widget _buildEmptyState() {
    return Container(
      height: 120,
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              color: Colors.grey.shade400,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              "✨ No suggestions right now.\nCheck back soon!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreRecommendationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        "All Recommendations",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: _recommendations.length,
                    itemBuilder: (context, index) {
                      final recommendation = _recommendations[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: recommendation.color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: recommendation.color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              recommendation.icon,
                              color: _getIconColor(recommendation.color),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            recommendation.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            recommendation.description,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          trailing: ElevatedButton(
                            onPressed: recommendation.onAction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: _getIconColor(recommendation.color),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                              side: BorderSide(
                                color: _getIconColor(recommendation.color).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              recommendation.actionText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
