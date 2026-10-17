import 'package:flutter/material.dart';
import 'pages/landing.dart';
import 'state.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.I.load();
  runApp(const VocalImageApp());
}

class VocalImageApp extends StatelessWidget {
  const VocalImageApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Vocal Image',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const LandingPage(),
      );
}
