import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'shared/widgets/shimmer_loading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
  } catch (e) {
    debugPrint('Firebase config initialization error: $e');
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindEase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A1B9A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A1B9A),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      _user = FirebaseAuth.instance.currentUser;
      setState(() {
        _isLoading = false;
      });
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (mounted) {
          setState(() {
            _user = user;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              AppShimmer(width: 80, height: 80, borderRadius: 40),
              SizedBox(height: 24),
              AppShimmer(width: 150, height: 20, borderRadius: 10),
            ],
          ),
        ),
      );
    }
    if (_user != null) {
      return const DashboardScreen();
    }
    return const LoginScreen();
  }
}
