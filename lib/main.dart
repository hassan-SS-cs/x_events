import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:x_events/widgets/app_navigation.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: AppNavigation()),
  );

  FlutterNativeSplash.remove();
}
