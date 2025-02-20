import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/home/data/services/EmergencyService.dart';
import 'package:vedika_healthcare/features/home/presentation/view/HomePage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set Transparent Status Bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparent Status Bar
    statusBarIconBrightness: Brightness.dark, // Dark Icons for Light Background
  ));

  // Initialize Emergency Service Before Running App
  final EmergencyService emergencyService = EmergencyService();
  emergencyService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vedika Healthcare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const HomePage(),
        ...AppRoutes.getRoutes(), // Include All App Routes
      },
    );
  }
}
