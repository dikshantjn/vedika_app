import 'package:flutter/material.dart';

class FindMoreMedicalShopsWidget extends StatelessWidget {
  final VoidCallback onFindMore;
  final VoidCallback onCancel;
  final bool noMoreVendors;

  const FindMoreMedicalShopsWidget({
    Key? key,
    required this.onFindMore,
    required this.onCancel,
    this.noMoreVendors = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Container
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: noMoreVendors 
                ? Colors.orange.withOpacity(0.1)
                : Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              noMoreVendors ? Icons.search_off_rounded : Icons.location_off_rounded,
              size: 50,
              color: noMoreVendors ? Colors.orange : Colors.redAccent,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: noMoreVendors 
                ? [Colors.orange, Colors.deepOrange]
                : [Colors.redAccent, Colors.red],
            ).createShader(bounds),
            child: Text(
              noMoreVendors 
                ? "No More Shops Found"
                : "Couldn't Find Medical Shops Nearby",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),

          // Message
          Text(
            noMoreVendors
              ? "We've searched in a wider area but couldn't find any additional medical stores. Please try again later."
              : "Would you like to search in a wider area? This will take about 5 minutes to find more options.",
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Buttons
          if (noMoreVendors)
            Container(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: Colors.orange.withOpacity(0.5),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.orange.withOpacity(0.05),
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onFindMore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(Icons.search, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          "Search More Shops",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
