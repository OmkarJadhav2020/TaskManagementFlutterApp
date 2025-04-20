import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/theme.dart';
import 'auth/auth_service.dart';
import 'auth/login_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'services/task_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://kmratxlwzcdvrvtlnpcl.supabase.co', // Replace with your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttcmF0eGx3emNkdnJ2dGxucGNsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUxMjg2OTQsImV4cCI6MjA2MDcwNDY5NH0.C7M7gP3dyE9-QjI-bUBqki0EbYf9A6Vj6L0FEwdqHZk', // Replace with your Supabase anon key
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => TaskService()),
      ],
      child: MaterialApp(
        title: 'DayTask',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        if (authService.currentUser != null) {
          return DashboardScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}