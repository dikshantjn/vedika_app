import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabModel.dart';

class LabInfoWidget extends StatelessWidget {
  final LabModel lab;

  const LabInfoWidget({Key? key, required this.lab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.lighterPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageCarousel(),
          SizedBox(height: 10),
          Text(
            lab.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.red, size: 18),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  lab.address,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.phone, color: Colors.green, size: 18),
              SizedBox(width: 5),
              Text(
                lab.contact,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 180,
          autoPlay: true,
          aspectRatio: 16 / 9,
          enlargeCenterPage: true,
          enableInfiniteScroll: true,
        ),
        items: lab.images.map((imageUrl) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
