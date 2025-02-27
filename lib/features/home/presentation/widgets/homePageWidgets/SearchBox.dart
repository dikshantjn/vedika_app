import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

class SearchBox extends StatefulWidget {
  final TextEditingController controller;

  const SearchBox({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final List<String> _placeholders = [
    'Search Medicine',
    'Search Test',
    'Search Health Products',
    'Search Doctors',
  ];
  int _currentPlaceholderIndex = 0;

  @override
  void initState() {
    super.initState();
    _startPlaceholderAnimation();
  }

  void _startPlaceholderAnimation() {
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentPlaceholderIndex =
              (_currentPlaceholderIndex + 1) % _placeholders.length;
        });
        _startPlaceholderAnimation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        height: 50, // Reduced height for a more compact search box
        child: TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: _placeholders[_currentPlaceholderIndex], // Dynamic placeholder
            hintStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
            filled: true,
            fillColor: ColorPalette.whiteColor,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            suffixIcon: Icon(Icons.search, color: ColorPalette.primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: ColorPalette.primaryColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: ColorPalette.primaryColor),
            ),
          ),
        ),
      ),
    );
  }
}
