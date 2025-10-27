import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/isar_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.open();
  runApp(const ProviderScope(child: ExpenseApp()));
}

// Theme Colors
class AppColors {
  static const violetPrimary = Color(0xFF6A1B9A); // Deep Purple
  static const violetSecondary = Color(0xFF9C27B0); // Medium Purple
  static const yellowAccent = Color(0xFFFFC107); // Amber Yellow
  static const yellowLight = Color(0xFFFFD54F); // Light Yellow
  static const violetLight = Color(0xFFBA68C8); // Light Purple
  
  // Consumption colors (Yellow theme)
  static const consumptionStart = Color(0xFFFFC107);
  static const consumptionEnd = Color(0xFFFFD54F);
  
  // Investment colors (Violet theme)
  static const investmentStart = Color(0xFF6A1B9A);
  static const investmentEnd = Color(0xFF9C27B0);
}

// Gradient Definitions
class AppGradients {
  static const primary = LinearGradient(
    colors: [AppColors.violetPrimary, AppColors.violetSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const accent = LinearGradient(
    colors: [AppColors.yellowAccent, AppColors.yellowLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const consumption = LinearGradient(
    colors: [AppColors.consumptionStart, AppColors.consumptionEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const investment = LinearGradient(
    colors: [AppColors.investmentStart, AppColors.investmentEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const cardBackground = LinearGradient(
    colors: [Colors.white, Color(0xFFFAFAFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.violetPrimary,
          primary: AppColors.violetPrimary,
          secondary: AppColors.yellowAccent,
          surface: const Color(0xFFF5F5F5),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        cardTheme: const CardTheme(
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: AppColors.violetPrimary,
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppColors.violetPrimary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          iconColor: AppColors.violetPrimary,
          prefixIconColor: AppColors.violetPrimary,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white, size: 26),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 6,
          backgroundColor: AppColors.violetPrimary,
          foregroundColor: Colors.white,
          extendedPadding: EdgeInsets.symmetric(horizontal: 20),
          extendedTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.violetPrimary,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.violetPrimary,
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.violetPrimary),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.violetPrimary),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.violetPrimary),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF2C2C2C)),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
