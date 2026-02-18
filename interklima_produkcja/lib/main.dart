import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/work_session_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const InterKlimaApp());
}

class InterKlimaApp extends StatelessWidget {
  const InterKlimaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkSessionProvider(),
      child: MaterialApp(
        title: 'INTERKLIMA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B3A5C),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0F1923),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
