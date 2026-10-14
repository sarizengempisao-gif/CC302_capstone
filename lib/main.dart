import 'package:flutter/material.dart';

import 'services/store.dart';
import 'screens/app.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Store.instance.init();
  runApp(const TaxiGoApp());
}

/// Root widget. Applies the centralized [appTheme] (Material 3, TaxiGo colors
/// and the bundled `TaxiGo` font) and starts at the [AppRoot] router.
class TaxiGoApp extends StatelessWidget {
  const TaxiGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaxiGo',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const AppRoot(),
    );
  }
}
