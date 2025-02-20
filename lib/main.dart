import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/bookAppointment/presentation/viewModal/BookAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/home/data/services/EmergencyService.dart';
import 'package:vedika_healthcare/features/home/presentation/view/HomePage.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure SharedPreferences is initialized before using it
  final locationProvider = LocationProvider();
  await locationProvider.loadSavedLocation();

  // Set Transparent Status Bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparent Status Bar
    statusBarIconBrightness: Brightness.dark, // Dark Icons for Light Background
  ));

  // Initialize Emergency Service Before Running App
  final EmergencyService emergencyService = EmergencyService();
  emergencyService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => locationProvider),
        ChangeNotifierProvider(create: (_) => BookAppointmentViewModel()),

      ],
      child: const MyApp(),
    ),
  );
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
      onGenerateRoute: AppRoutes.generateRoute, // Handles dynamic routes like BookAppointmentPage
      routes: {
        "/": (context) => const HomePage(),
        ...AppRoutes.getRoutes(), // Include All App Routes

      },
    );
  }
}
