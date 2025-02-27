import 'package:vedika_healthcare/features/home/data/models/HealthDay.dart';
import 'package:vedika_healthcare/features/product/data/models/Product.dart';

class HealthDayRepository {
  Future<List<HealthDay>> fetchHealthDays() async {
    try {
      return [
        HealthDay(
          id: "7",
          title: "World Kidney Day",
          description: "Raise awareness about the importance of kidney health.",
          image: "assets/healthDays/worldKidneyDay.png",
          importance: "Regular kidney tests help detect issues early.",
          preventiveMeasures: ["Stay hydrated", "Reduce salt intake", "Exercise regularly"],
          recommendedProducts: [
            Product(
              id: "P001",
              name: "Kidney Health Supplement",
              category: "Supplements",
              price: 19.99,
              manufacturer: "HealthCare Inc.",
              expiryDate: "2026-12-31",
              requiresPrescription: false,
              rating: 4.5,
              image: "assets/healthDays/worldKidneyDay.png",
            ),
          ],
          suggestedLabTests: ["Kidney Function Test", "Urinalysis"],
        ),
        HealthDay(
          id: "8",
          title: "Glaucoma Awareness Day",
          description: "Encouraging regular eye checkups to prevent blindness due to Glaucoma.",
          image: "assets/healthDays/glaucoma.png",
          importance: "Early detection can save vision.",
          preventiveMeasures: ["Regular eye exams", "Healthy diet", "Manage blood pressure"],
          recommendedProducts: [
            Product(
              id: "P002",
              name: "Eye Drops for Glaucoma",
              category: "Eye Care",
              price: 14.99,
              manufacturer: "Vision Pharma",
              expiryDate: "2025-08-20",
              requiresPrescription: true,
              rating: 4.2,
              image: "assets/healthDays/glaucoma.png",
            ),
          ],
          suggestedLabTests: ["Ophthalmic Exam", "Intraocular Pressure Test"],
        ),
        HealthDay(
          id: "9",
          title: "Measles Immunization Day",
          description: "Promoting measles vaccination to protect children from this disease.",
          image: "assets/healthDays/glaucoma.png",
          importance: "Vaccination is the most effective way to prevent measles.",
          preventiveMeasures: ["Get vaccinated", "Boost immune system", "Avoid contact with infected individuals"],
          recommendedProducts: [
            Product(
              id: "P003",
              name: "Measles Vaccine",
              category: "Vaccines",
              price: 29.99,
              manufacturer: "Global Pharma",
              expiryDate: "2027-04-15",
              requiresPrescription: true,
              rating: 4.8,
              image: "assets/healthDays/glaucoma.png",
            ),
          ],
          suggestedLabTests: ["Measles Antibody Test"],
        ),
      ];
    } catch (e) {
      throw Exception("Failed to load Health Days: $e");
    }
  }
}
