import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:perfect_pour/services/game_state.dart';
import 'package:perfect_pour/screens/home_screen.dart';
import 'package:perfect_pour/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const PerfectPourApp());
}

class PerfectPourApp extends StatelessWidget {
  const PerfectPourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState()..loadProgress(),
      child: MaterialApp(
        title: 'Perfect Pour',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themeData,
        home: const HomeScreen(),
      ),
    );
  }
}
