import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import './providers/cart_provider.dart';
import './screens/auth_screen.dart';
import './screens/product_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Anchor Sports',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B1F24), // Deep Charcoal
            primary: const Color(0xFF1B1F24),
            secondary: const Color(0xFF007BFF), // Electric Blue
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1B1F24),
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007BFF),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (userSnapshot.hasData) {
              return const ProductListScreen();
            }
            return const AuthScreen();
          },
        ),
      ),
    );
  }
}