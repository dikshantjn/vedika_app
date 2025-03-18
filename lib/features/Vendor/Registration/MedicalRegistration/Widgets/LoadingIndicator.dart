import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Loading indicator in the center
        Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }
}
