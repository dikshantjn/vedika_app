import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart';
import 'package:vedika_healthcare/features/blog/data/models/BlogCategoryModel.dart';
import 'package:vedika_healthcare/features/blog/presentation/viewmodel/BlogCategoryViewModel.dart';
import 'package:vedika_healthcare/features/blog/presentation/view/BlogListPage.dart';

class BlogCategoriesPage extends StatefulWidget {
  const BlogCategoriesPage({Key? key}) : super(key: key);

  @override
  State<BlogCategoriesPage> createState() => _BlogCategoriesPageState();
}

class _BlogCategoriesPageState extends State<BlogCategoriesPage> {
  late BlogCategoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = BlogCategoryViewModel();
    _viewModel.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () {
                final scope = MainScreenScope.maybeOf(context);
                if (scope != null) {
                  scope.setIndex(0);
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          title: const Text(
            'Health Blog Categories',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: ColorPalette.primaryColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Consumer<BlogCategoryViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (viewModel.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading categories',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.error!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.loadCategories(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.primaryColor,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            final categories = viewModel.categories;
            if (categories.isEmpty) {
              return const Center(
                child: Text(
                  'No categories found.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorPalette.primaryColor.withOpacity(0.1),
                          ColorPalette.primaryColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.category_rounded,
                          size: 28,
                          color: ColorPalette.primaryColor,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Explore Health Topics',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Discover articles and insights across different health categories',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Categories grid
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _buildCategoryCard(context, category);
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Editorial Policy and Disclaimer Section
                  _buildPolicySection(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, BlogCategoryModel category) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogListPage(
                categoryId: category.categoryId,
                categoryName: category.name,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category.name).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(category.name),
                    size: 24,
                    color: _getCategoryColor(category.name),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Category name
                Flexible(
                  child: Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'healthcare':
        return Colors.blue;
      case 'nutrition':
        return Colors.green;
      case 'fitness':
        return Colors.orange;
      case 'mental health':
        return Colors.purple;
      case 'wellness':
        return Colors.teal;
      case 'medicine':
        return Colors.red;
      default:
        return ColorPalette.primaryColor;
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'healthcare':
        return Icons.health_and_safety_rounded;
      case 'nutrition':
        return Icons.restaurant_rounded;
      case 'fitness':
        return Icons.fitness_center_rounded;
      case 'mental health':
        return Icons.psychology_rounded;
      case 'wellness':
        return Icons.spa_rounded;
      case 'medicine':
        return Icons.medication_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  Widget _buildPolicySection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: ColorPalette.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Important Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Editorial Policy Button
          _buildPolicyButton(
            context: context,
            title: 'Editorial Policy',
            subtitle: 'Learn about our content standards and guidelines',
            icon: Icons.edit_note_rounded,
            onTap: () => _showPolicyBottomSheet(context, 'editorial'),
          ),
          
          const SizedBox(height: 12),
          
          // Disclaimer Button
          _buildPolicyButton(
            context: context,
            title: 'Disclaimer',
            subtitle: 'Important information about our health content',
            icon: Icons.warning_amber_rounded,
            onTap: () => _showPolicyBottomSheet(context, 'disclaimer'),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ColorPalette.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: ColorPalette.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPolicyBottomSheet(BuildContext context, String policyType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPolicyBottomSheet(context, policyType),
    );
  }

  Widget _buildPolicyBottomSheet(BuildContext context, String policyType) {
    final isEditorial = policyType == 'editorial';
    final title = isEditorial ? 'Editorial Policy' : 'Disclaimer';
    final icon = isEditorial ? Icons.edit_note_rounded : Icons.warning_amber_rounded;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ColorPalette.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: ColorPalette.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isEditorial) ...[
                    _buildPolicyContentSection(
                      'Content Standards',
                      'Our editorial team ensures all health content is accurate, evidence-based, and reviewed by qualified healthcare professionals. We follow strict guidelines to maintain the highest quality of information.',
                    ),
                    _buildPolicyContentSection(
                      'Medical Review Process',
                      'All medical content undergoes thorough review by licensed healthcare professionals before publication. We prioritize peer-reviewed research and established medical guidelines.',
                    ),
                    _buildPolicyContentSection(
                      'Transparency',
                      'We clearly identify the sources of our information and maintain transparency about our editorial process. Any conflicts of interest are disclosed appropriately.',
                    ),
                    _buildPolicyContentSection(
                      'Regular Updates',
                      'Health information is regularly reviewed and updated to reflect the latest medical research and guidelines. Content is marked with publication and last updated dates.',
                    ),
                  ] else ...[
                    _buildPolicyContentSection(
                      'Medical Disclaimer',
                      'The information provided in our health blogs is for educational purposes only and should not be considered as medical advice, diagnosis, or treatment recommendations.',
                    ),
                    _buildPolicyContentSection(
                      'Professional Consultation',
                      'Always consult with qualified healthcare professionals for medical advice, diagnosis, or treatment. Do not delay seeking professional medical care based on information from our content.',
                    ),
                    _buildPolicyContentSection(
                      'Individual Differences',
                      'Health information may not apply to everyone. Individual health conditions, medications, and circumstances vary, and what works for one person may not work for another.',
                    ),
                    _buildPolicyContentSection(
                      'Emergency Situations',
                      'In case of medical emergencies, contact emergency services immediately. Do not rely on our content for urgent medical situations.',
                    ),
                    _buildPolicyContentSection(
                      'Third-Party Content',
                      'We may include links to external websites or references to third-party content. We are not responsible for the accuracy or content of external sources.',
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'For questions about our ${isEditorial ? 'editorial policy' : 'disclaimer'}, please contact our support team.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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

  Widget _buildPolicyContentSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
