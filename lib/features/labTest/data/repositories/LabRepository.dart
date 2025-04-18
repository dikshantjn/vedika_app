import 'package:vedika_healthcare/features/labTest/data/models/LabModel.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabTestModel.dart';

class LabRepository {
  static List<LabModel> getLabs() {
    return [
      LabModel(
        id: "1",
        name: "Diagnopein Diagnostic Centre & Dental Clinic - Camp",
        address: "Survey No. 161, Dr. B.R, Vivekanand Park, Shop No.7 & 8, Chinmaya Co - Op Housing Society, A & 398 B, Dr Baba Saheb Ambedkar Rd, Camp, Pune, Maharashtra 411001, India",
        lat: 18.5184,
        lng: 73.8768,
        contact: "+919204108108",
        tests: [
          LabTestModel(id: "1",name: "Blood Test", price: 100),
          LabTestModel(id: "2",name: "MRI", price: 300),
          LabTestModel(id: "3",name: "X-Ray", price: 150),
        ],
        price: 500,
        discount: 10,
        operatingHours: "9 AM - 6 PM",
        rating: 4.5,
        homeCollection: true,
        images: [
          "https://images.unsplash.com/photo-1614935151651-0bea6508db6b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8bGFib3JhdG9yeXxlbnwwfHwwfHx8MA%3D%3D",
          "https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fGxhYm9yYXRvcnl8ZW58MHx8MHx8fDA%3D",
          "https://images.unsplash.com/photo-1602052577122-f73b9710adba?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGxhYm9yYXRvcnl8ZW58MHx8MHx8fDA%3D",
          "https://media.istockphoto.com/id/1302454451/photo/science-opens-the-door-to-a-better-tomorrow.jpg?s=612x612&w=0&k=20&c=n20oOUl9waWD6AZo3fYoHe0jmyy34ozg-f04PzORST4=",
        ],
      ),
      LabModel(
        id: "2",
        name: "Vijaya Diagnostic Centre",
        address: "5, Karve Rd, opp. Bank of Maharashtra, Mayur Colony, Kothrud, Pune, Maharashtra 411038, India",
        lat: 18.502,
        lng: 73.8078,
        contact: "+919240222222",
        tests: [
          LabTestModel(id: "1",name: "Urine Test", price: 80),
          LabTestModel(id: "2",name: "CT Scan", price: 200),
          LabTestModel(id: "3",name: "COVID Test", price: 150),
        ],
        price: 800,
        discount: 5,
        operatingHours: "8 AM - 8 PM",
        rating: 4.2,
        homeCollection: false,
        images: [
          "https://images.unsplash.com/photo-1614935151651-0bea6508db6b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8bGFib3JhdG9yeXxlbnwwfHwwfHx8MA%3D%3D",
          "https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fGxhYm9yYXRvcnl8ZW58MHx8MHx8fDA%3D",
          "https://images.unsplash.com/photo-1602052577122-f73b9710adba?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGxhYm9yYXRvcnl8ZW58MHx8MHx8fDA%3D",
          "https://media.istockphoto.com/id/1302454451/photo/science-opens-the-door-to-a-better-tomorrow.jpg?s=612x612&w=0&k=20&c=n20oOUl9waWD6AZo3fYoHe0jmyy34ozg-f04PzORST4=",
        ],
      ),
      LabModel(
        id: "3",
        name: "Star Imaging Deccan",
        address: "Joshi Hospital Campus Opposite Kamla Nehru Park, Erandwane, Pune, Maharashtra 411004, India",
        lat: 18.5149,
        lng: 73.8420,
        contact: "+917942611126",
        tests: [
          LabTestModel(id: "1",name: "Blood Test", price: 100),
          LabTestModel(id: "2",name: "Ultrasound", price: 250),
          LabTestModel(id: "3",name: "CT Scan", price: 200),
        ],
        price: 600,
        discount: 7,
        operatingHours: "7 AM - 9 PM",
        rating: 4.3,
        homeCollection: true,
        images: [
          "https://images.unsplash.com/photo-1614935151651-0bea6508db6b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8bGFib3JhdG9yeXxlbnwwfHwwfHx8MA%3D%3D",
          "https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fGxhYm9yYXRvcnl8ZW58MHx8MHx8fDA%3D",
          "https://images.unsplash.com/photo-1602052577122-f73b9710adba?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGxhYm9yYXRvcnl8ZW58MHx8MHx8fDA%3D",
          "https://media.istockphoto.com/id/1302454451/photo/science-opens-the-door-to-a-better-tomorrow.jpg?s=612x612&w=0&k=20&c=n20oOUl9waWD6AZo3fYoHe0jmyy34ozg-f04PzORST4=",
        ],
      ),
      LabModel(
        id: "4",
        name: "PATEL CLINIC",
        address: "Door no13,14,15/ B #478 Ground floor Mittal court, Rasta Peth, Pune, Maharashtra 411011, India",
        lat: 18.5196,
        lng: 73.8645,
        contact: "+917775036200",
        tests: [
          LabTestModel(id: "1",name: "X-Ray", price: 150),
          LabTestModel(id: "2",name: "MRI", price: 300),
          LabTestModel(id: "3",name: "Blood Test", price: 100),
        ],
        price: 700,
        discount: 8,
        operatingHours: "9 AM - 7 PM",
        rating: 4.4,
        homeCollection: false,
        images: [
          "https://images.unsplash.com/photo-1614935151651-0bea6508db6b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8bGFib3JhdG9yeXxlbnwwfHwwfHx8MA%3D%3D",
          "https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fGxhYm9yYXRvcnl8ZW58MHx8MHx8fDA%3D",
          "https://images.unsplash.com/photo-1602052577122-f73b9710adba?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGxhYm9yYXRvcnl8ZW58MHx8MHx8fDA%3D",
          "https://media.istockphoto.com/id/1302454451/photo/science-opens-the-door-to-a-better-tomorrow.jpg?s=612x612&w=0&k=20&c=n20oOUl9waWD6AZo3fYoHe0jmyy34ozg-f04PzORST4=",
        ],
      ),
      LabModel(
        id: "5",
        name: "City Diagnostic Centre",
        address: "Shastri Nagar, Pune, Maharashtra 411043, India",
        lat: 18.5269,
        lng: 73.8560,
        contact: "+917767245678",
        tests: [
          LabTestModel(id: "1",name: "Blood Test", price: 120),
          LabTestModel(id: "2",name: "Urine Test", price: 80),
          LabTestModel(id: "3",name: "Pregnancy Test", price: 100),
        ],
        price: 550,
        discount: 12,
        operatingHours: "10 AM - 5 PM",
        rating: 4.1,
        homeCollection: true,
        images: [
          "https://images.unsplash.com/photo-1614935151651-0bea6508db6b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8bGFib3JhdG9yeXxlbnwwfHwwfHx8MA%3D%3D",
          "https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fGxhYm9yYXRvcnl8ZW58MHx8MHx8fDA%3D",
          "https://images.unsplash.com/photo-1602052577122-f73b9710adba?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGxhYm9yYXRvcnl8ZW58MHx8MHx8fDA%3D",
          "https://media.istockphoto.com/id/1302454451/photo/science-opens-the-door-to-a-better-tomorrow.jpg?s=612x612&w=0&k=20&c=n20oOUl9waWD6AZo3fYoHe0jmyy34ozg-f04PzORST4=",
        ],
      ),
      LabModel(
        id: "6",
        name: "Aarogya Diagnostic Centre",
        address: "J M Road, Pune, Maharashtra 411030, India",
        lat: 18.5335,
        lng: 73.8531,
        contact: "+917774212345",
        tests: [
          LabTestModel(id: "1",name: "CBC", price: 200),
          LabTestModel(id: "2",name: "Cholesterol Test", price: 150),
          LabTestModel(id: "3",name: "Liver Function Test", price: 180),
        ],
        price: 650,
        discount: 15,
        operatingHours: "9 AM - 8 PM",
        rating: 4.6,
        homeCollection: true,
        images: [
          "https://images.unsplash.com/photo-1614935151651-0bea6508db6b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8bGFib3JhdG9yeXxlbnwwfHwwfHx8MA%3D%3D",
          "https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fGxhYm9yYXRvcnl8ZW58MHx8MHx8fDA%3D",
          "https://images.unsplash.com/photo-1602052577122-f73b9710adba?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGxhYm9yYXRvcnl8ZW58MHx8MHx8fDA%3D",
          "https://media.istockphoto.com/id/1302454451/photo/science-opens-the-door-to-a-better-tomorrow.jpg?s=612x612&w=0&k=20&c=n20oOUl9waWD6AZo3fYoHe0jmyy34ozg-f04PzORST4=",
        ],
      ),
      LabModel(
        id: "7",
        name: "Medlife Labs",
        address: "Pune, Maharashtra 411044, India",
        lat: 18.5200,
        lng: 73.8800,
        contact: "+917778334455",
        tests: [
          LabTestModel(id: "1",name: "Urine Test", price: 90),
          LabTestModel(id: "2",name: "Blood Culture", price: 160),
          LabTestModel(id: "3",name: "Thyroid Test", price: 200),
        ],
        price: 550,
        discount: 10,
        operatingHours: "7 AM - 9 PM",
        rating: 4.2,
        homeCollection: true,
        images: [
          "https://images.unsplash.com/photo-1614935151651-0bea6508db6b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8bGFib3JhdG9yeXxlbnwwfHwwfHx8MA%3D%3D",
          "https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fGxhYm9yYXRvcnl8ZW58MHx8MHx8fDA%3D",
          "https://images.unsplash.com/photo-1602052577122-f73b9710adba?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGxhYm9yYXRvcnl8ZW58MHx8MHx8fDA%3D",
          "https://media.istockphoto.com/id/1302454451/photo/science-opens-the-door-to-a-better-tomorrow.jpg?s=612x612&w=0&k=20&c=n20oOUl9waWD6AZo3fYoHe0jmyy34ozg-f04PzORST4=",
        ],
      ),
      LabModel(
        id: "8",
        name: "Pune Diagnostic Clinic",
        address: "Opp. Patil Hospital, Shivaji Nagar, Pune, Maharashtra 411005, India",
        lat: 18.5220,
        lng: 73.8345,
        contact: "+919234562345",
        tests: [
          LabTestModel(id: "1", name: "Blood Test", price: 100),
          LabTestModel(id: "2",name: "Urine Culture", price: 120),
          LabTestModel(id: "3", name: "Thyroid Panel", price: 200),
        ],
        price: 800,
        discount: 5,
        operatingHours: "9 AM - 7 PM",
        rating: 4.4,
        homeCollection: false,
        images: [
          "https://images.unsplash.com/photo-1614935151651-0bea6508db6b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8bGFib3JhdG9yeXxlbnwwfHwwfHx8MA%3D%3D",
          "https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fGxhYm9yYXRvcnl8ZW58MHx8MHx8fDA%3D",
          "https://images.unsplash.com/photo-1602052577122-f73b9710adba?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGxhYm9yYXRvcnl8ZW58MHx8MHx8fDA%3D",
          "https://media.istockphoto.com/id/1302454451/photo/science-opens-the-door-to-a-better-tomorrow.jpg?s=612x612&w=0&k=20&c=n20oOUl9waWD6AZo3fYoHe0jmyy34ozg-f04PzORST4=",
        ],
      ),
      LabModel(
        id: "9",
        name: "Shree Labs",
        address: "Ghole Road, Pune, Maharashtra 411004, India",
        lat: 18.5158,
        lng: 73.8331,
        contact: "+917798334455",
        tests: [
          LabTestModel(id: "1",name: "Blood Test", price: 110),
          LabTestModel(id: "2",name: "Liver Test", price: 200),
          LabTestModel(id: "3", name: "Kidney Test", price: 220),
        ],
        price: 700,
        discount: 6,
        operatingHours: "8 AM - 7 PM",
        rating: 4.0,
        homeCollection: true,
        images: [
          "https://images.unsplash.com/photo-1614935151651-0bea6508db6b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8bGFib3JhdG9yeXxlbnwwfHwwfHx8MA%3D%3D",
          "https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fGxhYm9yYXRvcnl8ZW58MHx8MHx8fDA%3D",
          "https://images.unsplash.com/photo-1602052577122-f73b9710adba?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGxhYm9yYXRvcnl8ZW58MHx8MHx8fDA%3D",
          "https://media.istockphoto.com/id/1302454451/photo/science-opens-the-door-to-a-better-tomorrow.jpg?s=612x612&w=0&k=20&c=n20oOUl9waWD6AZo3fYoHe0jmyy34ozg-f04PzORST4=",
        ],
      ),
    ];
  }
}
