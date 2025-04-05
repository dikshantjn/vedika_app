import 'package:flutter/material.dart';
class WrapWithBackHandler extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;

  const WrapWithBackHandler({required this.child, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        onClose();
        return false;
      },
      child: Material(
        color: Colors.white,
        child: Column(
          children: [
            // Row(
            //   children: [
            //     IconButton(
            //       icon: const Icon(Icons.arrow_back),
            //       onPressed: onClose,
            //     ),
            //     const SizedBox(width: 8),
            //     // const Text("Back", style: TextStyle(fontSize: 18)),
            //   ],
            // ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
