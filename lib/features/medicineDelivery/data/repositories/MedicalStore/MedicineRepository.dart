import 'package:vedika_healthcare/features/medicineDelivery/data/models/MedicalStore/MedicineProduct.dart';

class MedicineRepository {
  final List<MedicineProduct> _medicines = [
    MedicineProduct(
      id: "001",
      name: "Paracetamol 500mg",
      description: "Used for pain relief and fever reduction.",
      price: 25.0,
      stock: 150,
      manufacturer: "Cipla Ltd.",
      imageUrl: "https://cdn.farmako.in/inventory/images/624ee90845553a31f6e7e054f2adf6f1a5872a77/1712cdae1561643de0bc85420c451499cd42cd63.png",
        quantity: 20
    ),
    MedicineProduct(
      id: "002",
      name: "Ibuprofen 200mg",
      description: "Nonsteroidal anti-inflammatory drug (NSAID) for pain and inflammation.",
      price: 40.0,
      stock: 100,
      manufacturer: "Sun Pharma",
      imageUrl: "https://cdn.farmako.in/inventory/images/2a479f9955e59736c071309391662b510c30182f/51033f22abae6c1599e99d901e1e024963441810.png",
      quantity: 20
    ),
    MedicineProduct(
      id: "003",
      name: "Amoxicillin 500mg",
      description: "Antibiotic used to treat bacterial infections.",
      price: 120.0,
      stock: 80,
      manufacturer: "GlaxoSmithKline",
      imageUrl: "https://cdn.farmako.in/inventory/images/0a21f0ff127e2c6354fa051a4ca3273e6d771059/c284a659cff25b3c036294084cc03c8041698153.png",
        quantity: 20
    ),
    MedicineProduct(
      id: "004",
      name: "Cetirizine 10mg",
      description: "Antihistamine used to treat allergy symptoms.",
      price: 30.0,
      stock: 200,
      manufacturer: "Dr. Reddy's",
      imageUrl: "https://cdn.farmako.in/inventory/images/00c55a97c80e58c979599f58428e807ca5e0340b/2e5005e93b0e8cf99bb695dc3adf161e5b566595.png",
        quantity: 20

    ),
    MedicineProduct(
      id: "005",
      name: "Aspirin 75mg",
      description: "Blood thinner and pain reliever.",
      price: 50.0,
      stock: 90,
      manufacturer: "Bayer Pharmaceuticals",
      imageUrl: "https://cdn.farmako.in/inventory/images/00c55a97c80e58c979599f58428e807ca5e0340b/06d755306866ab65116d0bba8e47a731b5785494.png",
        quantity: 20

    ),
    MedicineProduct(
      id: "006",
      name: "Metformin 500mg",
      description: "Used to control high blood sugar in type 2 diabetes.",
      price: 85.0,
      stock: 120,
      manufacturer: "Lupin Ltd.",
      imageUrl: "https://cdn.farmako.in/inventory/images/cd3c4f3252ba54f7314063d52381cbb141800c7d/f56e38f60fe177abe19529a954eb3e6981d86bd6.png",
        quantity: 20

    ),
    MedicineProduct(
      id: "007",
      name: "Azithromycin 250mg",
      description: "Antibiotic used for bacterial infections like pneumonia and throat infections.",
      price: 140.0,
      stock: 75,
      manufacturer: "Zydus Cadila",
      imageUrl: "https://cdn.farmako.in/inventory/images/cd3c4f3252ba54f7314063d52381cbb141800c7d/24522f4f5d04fa23a9807d96ac8bb41480231b77.png",
        quantity: 20

    ),
    MedicineProduct(
      id: "008",
      name: "Pantoprazole 40mg",
      description: "Used to treat acid reflux and stomach ulcers.",
      price: 65.0,
      stock: 130,
      manufacturer: "Torrent Pharma",
      imageUrl: "https://cdn.farmako.in/inventory/images/ea48f7a92956182c03a1a392932f1816bd2adade/5ed0088374262c509c9daeacb53f8a4630c107d3.png",
        quantity: 20

    ),
    MedicineProduct(
      id: "009",
      name: "Dolo 650mg",
      description: "Pain reliever and fever reducer, commonly used for viral fevers.",
      price: 30.0,
      stock: 180,
      manufacturer: "Micro Labs Ltd.",
      imageUrl: "https://cdn.farmako.in/inventory/images/1f1edc845b3c07d4f3968ecb3af4f77a5c5cfb4d/df72678eaec5ef0922a095d1c684ce76f6a9fdac.png",
        quantity: 20

    ),
    MedicineProduct(
      id: "010",
      name: "ORS Powder",
      description: "Oral Rehydration Solution to treat dehydration.",
      price: 20.0,
      stock: 250,
      manufacturer: "Electral",
      imageUrl: "https://cdn.farmako.in/inventory/images/1f1edc845b3c07d4f3968ecb3af4f77a5c5cfb4d/e31d96856926df00b258635cf4a2482112627566.png",
        quantity: 20

    ),
  ];

  // Fetch all medicines
  List<MedicineProduct> getMedicines() {
    return _medicines;
  }

  // Fetch medicine by ID
  MedicineProduct? getMedicineById(String id) {
    return _medicines.firstWhere(
          (medicine) => medicine.id == id,
      orElse: () => null as MedicineProduct,
    );
  }

  // Add new medicine
  void addMedicine(MedicineProduct medicine) {
    _medicines.add(medicine);
  }

  // Update medicine details
  void updateMedicine(String id, MedicineProduct updatedMedicine) {
    final index = _medicines.indexWhere((medicine) => medicine.id == id);
    if (index != -1) {
      _medicines[index] = updatedMedicine;
    }
  }

  // Delete medicine
  void deleteMedicine(String id) {
    _medicines.removeWhere((medicine) => medicine.id == id);
  }
}
