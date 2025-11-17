import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/fechers/home/screens/home_screen.dart';
import 'package:weather_app/splash.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}
late double w;
late double h;
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    w=MediaQuery.of(context).size.width;
    h=MediaQuery.of(context).size.height;
    return GestureDetector(
    onTap: () {
      FocusManager.instance.primaryFocus!.unfocus();
    },
      child: MaterialApp(
        theme: ThemeData(
          textTheme: GoogleFonts.montserratTextTheme()
        ),
        debugShowCheckedModeBanner: false,
        title: 'Weather App',
        home: SplashScreen(),
      ),
    );
  }
}
