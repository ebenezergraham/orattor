import 'package:flutter/material.dart';
import 'pages/landing.dart';
import 'state.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.I.load();
  runApp(const OrattorApp());
}

class OrattorApp extends StatelessWidget {
  const OrattorApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Orattor',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const LandingPage(),
      );
}
