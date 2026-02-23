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
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F1923),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1B2838),
            foregroundColor: Colors.white,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
