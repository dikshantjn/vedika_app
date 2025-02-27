import 'package:vedika_healthcare/features/product/data/models/Product.dart';

class ProductRepository {
  List<Product> fetchProducts() {
    return [
      Product(
        id: "1",
        name: "Paracetamol 500mg",
        category: "Pain Relief",
        price: 20.0,
        manufacturer: "ABC Pharma",
        expiryDate: "2025-12-31",
        requiresPrescription: false,
        rating: 4.5,
        image: "assets/products/paracetamol.png",
      ),
      Product(
        id: "2",
        name: "Amoxicillin 250mg",
        category: "Antibiotic",
        price: 50.0,
        manufacturer: "XYZ Meds",
        expiryDate: "2026-06-15",
        requiresPrescription: true,
        rating: 4.7,
        image: "assets/products/amoxicillin.png",
      ),
      Product(
        id: "3",
        name: "Vitamin C Tablets",
        category: "Supplements",
        price: 30.0,
        manufacturer: "Wellness Corp",
        expiryDate: "2026-03-20",
        requiresPrescription: false,
        rating: 4.6,
        image: "assets/products/vitamin_c.png",
      ),
      Product(
        id: "4",
        name: "Cetirizine 10mg",
        category: "Allergy",
        price: 25.0,
        manufacturer: "MediHealth Ltd",
        expiryDate: "2025-08-22",
        requiresPrescription: false,
        rating: 4.4,
        image: "assets/products/cetirizine.png",
      ),
      Product(
        id: "5",
        name: "Omeprazole 20mg",
        category: "Acid Reducer",
        price: 40.0,
        manufacturer: "Heal Pharma",
        expiryDate: "2025-11-10",
        requiresPrescription: true,
        rating: 4.8,
        image: "assets/products/omeprazole.png",
      ),
    ];
  }
}