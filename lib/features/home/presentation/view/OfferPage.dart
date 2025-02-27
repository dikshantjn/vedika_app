import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/home/data/models/BannerModal.dart';

class OfferPage extends StatelessWidget {
  final BannerModal offer;

  const OfferPage({Key? key, required this.offer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(offer.title)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(offer.image, height: 200),
            SizedBox(height: 16),
            Text(offer.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(offer.description, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
