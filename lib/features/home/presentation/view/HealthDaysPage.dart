import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/home/data/models/BannerModal.dart';
import 'package:vedika_healthcare/features/home/data/models/HealthDay.dart';
import 'package:vedika_healthcare/features/product/data/models/Product.dart';

class HealthDayDetailPage extends StatelessWidget {
  final HealthDay healthDay;
  final BannerModal offer;

  const HealthDayDetailPage({Key? key, required this.healthDay, required this.offer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(healthDay.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(offer.color), Color(offer.color).withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            const SizedBox(height: 16),
            _buildTitleSection(),
            _buildInfoBox("Why is this day important?", healthDay.importance),
            _buildInfoBox("Preventive Measures", null, points: healthDay.preventiveMeasures),
            _buildProductSection(),
            _buildLabTestSection(),
            _buildOfferSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        healthDay.image,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          healthDay.title,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          healthDay.description,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildInfoBox(String title, String? content, {List<String>? points}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          if (content != null) Text(content, style: const TextStyle(fontSize: 16)),
          if (points != null) _buildBulletPoints(points),
        ],
      ),
    );
  }

  Widget _buildBulletPoints(List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: points.map((point) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              const Icon(Icons.check_circle, size: 20, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(child: Text(point, style: const TextStyle(fontSize: 16))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recommended Products", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: healthDay.recommendedProducts.length,
            itemBuilder: (context, index) {
              final product = healthDay.recommendedProducts[index];
              return Container(
                width: 120,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Image.asset(product.image, height: 70, width: 70, fit: BoxFit.cover),
                    const SizedBox(height: 8),
                    Text(product.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLabTestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Suggested Lab Tests", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Column(
          children: healthDay.suggestedLabTests.map((test) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(test, style: const TextStyle(fontSize: 16)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOfferSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Color(offer.color), Color(offer.color).withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(offer.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text(offer.description, style: const TextStyle(fontSize: 18, color: Colors.white70)),
        ],
      ),
    );
  }
}
