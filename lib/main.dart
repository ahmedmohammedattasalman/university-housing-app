import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:google_fonts/google_fonts.dart';
import 'package:universityhousing/screens/login_screen.dart';
import 'package:universityhousing/screens/test_connection_screen.dart';
import 'package:universityhousing/screens/profile_screen.dart';
import 'package:universityhousing/providers/auth_provider.dart';
import 'package:universityhousing/providers/theme_provider.dart';
import 'package:universityhousing/constants/colors.dart';

// For easy access to Supabase client
final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://qjiblxygwilsxajbtkqn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqaWJseHlnd2lsc3hhamJ0a3FuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI4NDkyNjYsImV4cCI6MjA1ODQyNTI2Nn0.QoLuj-sxiVUdrTl5ZNzrgmftk_GuHKS4MDYBdzRDYJY',
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'University Housing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: themeProvider.themeMode,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/test_connection': (context) => const TestConnectionScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
