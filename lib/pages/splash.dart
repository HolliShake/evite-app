import 'package:evitecompanion/config/appstyle.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {

  Future<void> onSplash() async {
    Future.delayed(const Duration(seconds: 2), () {
      var accessToken = localStorage.getItem('accessToken');
      if (accessToken == null) {
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        Navigator.of(context).pushReplacementNamed('/eventSelection');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    onSplash();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Image.asset('assets/images/evite.ico')
        )
      ),
    );
  }
}