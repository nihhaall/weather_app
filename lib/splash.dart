import 'package:flutter/material.dart';
import 'dart:async';

import 'fechers/home/screens/home_screen.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4A90E2),
              const Color(0xFF357ABD),
              const Color(0xFF2E5C8A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Weather Icon
              Container(
                padding: EdgeInsets.all(w * 0.08),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.wb_sunny_rounded,
                  size: w * 0.25,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: h * 0.04),

              // App Title
              Text(
                'Weather',
                style: TextStyle(
                  fontSize: w * 0.12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: h * 0.01),
              Text(
                'Stay updated, stay prepared',
                style: TextStyle(
                  fontSize: w * 0.04,
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 1,
                ),
              ),

              const Spacer(flex: 2),

              // Loading Indicator
              SizedBox(
                width: w * 0.08,
                height: w * 0.08,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              SizedBox(height: h * 0.02),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: w * 0.035,
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 1,
                ),
              ),

              SizedBox(height: h * 0.06),
            ],
          ),
        ),
      ),
    );
  }
}