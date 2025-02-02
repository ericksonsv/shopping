import 'package:flutter/material.dart';
import 'package:shopping/screens/products.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://fexjtvsnhtvkqinoajsj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZleGp0dnNuaHR2a3Fpbm9hanNqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzgzODA1NDksImV4cCI6MjA1Mzk1NjU0OX0.xTKsSIeXekzeWk3NbGVG8iO5k7KiFmVKsB8k01en7gQ',
    debug: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ESV ShoppingApp',
      home: Products()
    );
  }
}