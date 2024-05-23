import 'package:evitecompanion/pages/AttendanceView.dart';
import 'package:evitecompanion/pages/EventAttendanceView.dart';
import 'package:evitecompanion/pages/EventSelectionListView.dart';
import 'package:evitecompanion/pages/EventSelectionView.dart';
import 'package:evitecompanion/pages/ReleasingView.dart';
import 'package:evitecompanion/pages/TrackSelectionView.dart';
import 'package:evitecompanion/pages/login.dart';
import 'package:evitecompanion/pages/splash.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'e-vite pro Companion App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: const ColorScheme.light(surface: Colors.black).copyWith(primary: Colors.blueAccent),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blueAccent,
          textTheme: ButtonTextTheme.primary,
          colorScheme: const ColorScheme.light().copyWith(primary: Colors.blueAccent),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const SplashView(),
        '/login': (BuildContext context) => const LoginView(),
        '/eventSelection': (BuildContext context) => const EventSelectionView(),
        '/eventList': (BuildContext context) => const EventSelectionListView(),
        '/trackSelection': (BuildContext context) => const TrackSelectionView(),
        '/attendance': (BuildContext context) => const AttendanceView(),
        '/eventAttendance': (BuildContext context) => const EventAttendanceView(),
        '/releasingView': (BuildContext context) => const ReleasingView(),
      }
    );
  }
}