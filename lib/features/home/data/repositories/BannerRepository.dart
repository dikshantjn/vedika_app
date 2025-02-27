import 'package:vedika_healthcare/features/home/data/models/BannerModal.dart';
import 'package:vedika_healthcare/features/home/data/models/HealthDay.dart';
import 'package:vedika_healthcare/features/product/data/models/Product.dart';

class BannerRepository {
  List<BannerModal> fetchOffers() {
    return [
      // Existing Offers
      BannerModal(
        id: "1",
        title: "20% off on Medicines!",
        description: "Use code MED20 for 20% off.",
        image: "assets/offers/offer.png",
        color: 0xFF0D89C7,
        type: "discount",
      ),
      BannerModal(
        id: "2",
        title: "Buy 1 Get 1 Free on Lab Tests!",
        description: "Get one test free on purchase.",
        image: "assets/offers/offer.png",
        color: 0xFF0E76B5,
        type: "offer",
      ),
      BannerModal(
        id: "3",
        title: "Blood Bank Donation!",
        description: "Donate blood, save lives.",
        image: "assets/offers/offer.png",
        color: 0xFFFCD100,
        type: "offer",
      ),
      BannerModal(
        id: "4",
        title: "Flat 15% off on Orders!",
        description: "Get 15% off on all orders.",
        image: "assets/offers/offer.png",
        color: 0xFFF1E398,
        type: "discount",
      ),
      BannerModal(
        id: "5",
        title: "10% off on Health Checkups!",
        description: "Book a checkup and save 10%.",
        image: "assets/offers/offer.png",
        color: 0xFF874292,
        type: "discount",
      ),
      BannerModal(
        id: "6",
        title: "Free Delivery on Orders!",
        description: "Free delivery for all orders.",
        image: "assets/offers/offer.png",
        color: 0xFF6A5D7B,
        type: "offer",
      ),

      // World Health Days
      BannerModal(
        id: "7",
        title: "World Kidney Day - 13 March",
        description: "Get your kidney tested today for early detection and preventive measures.",
        image: "assets/healthDays/worldKidneyDay.png",
        color: 0xFF3B5998,
        type: "health_days",
        healthDay: HealthDay(
          id: "kidney_day",
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
      ),
      BannerModal(
        id: "8",
        title: "Glaucoma Day - 12 March",
        description: "Protect your eyes! Get tested today for early detection and preventive care.",
        image: "assets/healthDays/glaucoma.png",
        color: 0xFF2E86C1,
        type: "health_days",
        healthDay: HealthDay(
          id: "glaucoma_day",
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
      ),
      BannerModal(
        id: "9",
        title: "Measles Immunization Day - 16 March",
        description: "Vaccinate your children to prevent measles! Ensure they receive two doses.",
        image: "assets/healthDays/glaucoma.png",
        color: 0xFFE74C3C,
        type: "health_days",
        healthDay: HealthDay(
          id: "measles_day",
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
      ),
    ];
  }
}
