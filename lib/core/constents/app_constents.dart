import 'package:flutter/material.dart';

class AppConstants {
  static const String apiKey = '77bc46c03230f14e468c827c8d507820';

  static String weatherUrl(double lat, double lon) {
    return 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=77bc46c03230f14e468c827c8d507820';
  }

  static String searchWithCity({required String query}) {
    return 'https://api.openweathermap.org/data/2.5/weather?q=$query&appid=$apiKey&units=metric';
  }
  static String searchWithZip({required String zip}) {
    return 'https://api.openweathermap.org/data/2.5/weather?zip=$zip,IN&appid=$apiKey&units=metric';
  }

  static String getUv(double lat, double lon) {
    return 'https://api.openweathermap.org/data/2.5/uvi?lat=$lat&lon=$lon&appid=$apiKey';
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "🌞 Good Morning!";
    } else if (hour >= 12 && hour < 17) {
      return "☀️ Good Afternoon!";
    } else if (hour >= 17 && hour < 21) {
      return "🌇 Good Evening!";
    } else {
      return "🌙 Good Night!";
    }
  }

  static Color getUVColor(double uv) {
    if (uv < 3) return Colors.green; // Low
    if (uv < 6) return Colors.yellow; // Moderate
    if (uv < 8) return Colors.orange; // High
    if (uv < 11) return Colors.red; // Very High
    return Colors.purple; // Extreme
  }

  static String getWindDirection(int deg) {
    if (deg >= 348.75 || deg < 11.25) return 'N';
    if (deg >= 11.25 && deg < 33.75) return 'NNE';
    if (deg >= 33.75 && deg < 56.25) return 'NE';
    if (deg >= 56.25 && deg < 78.75) return 'ENE';
    if (deg >= 78.75 && deg < 101.25) return 'E';
    if (deg >= 101.25 && deg < 123.75) return 'ESE';
    if (deg >= 123.75 && deg < 146.25) return 'SE';
    if (deg >= 146.25 && deg < 168.75) return 'SSE';
    if (deg >= 168.75 && deg < 191.25) return 'S';
    if (deg >= 191.25 && deg < 213.75) return 'SSW';
    if (deg >= 213.75 && deg < 236.25) return 'SW';
    if (deg >= 236.25 && deg < 258.75) return 'WSW';
    if (deg >= 258.75 && deg < 281.25) return 'W';
    if (deg >= 281.25 && deg < 303.75) return 'WNW';
    if (deg >= 303.75 && deg < 326.25) return 'NW';
    if (deg >= 326.25 && deg < 348.75) return 'NNW';
    return '';
  }

  static int getBeaufort(double speed) {
    if (speed < 0.3) return 0;
    if (speed < 1.6) return 1;
    if (speed < 3.4) return 2;
    if (speed < 5.5) return 3;
    if (speed < 8.0) return 4;
    if (speed < 10.8) return 5;
    if (speed < 13.9) return 6;
    if (speed < 17.2) return 7;
    if (speed < 20.8) return 8;
    if (speed < 24.5) return 9;
    if (speed < 28.5) return 10;
    if (speed < 32.7) return 11;
    return 12;
  }

  static String getBackground(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'assets/images/clear.jpg';
      case 'clouds':
        return 'assets/images/clouds.png';
      case 'rain':
        return 'assets/images/rain.jpg';
      case 'thunderstorm':
        return 'assets/images/thunderstorm.png';
      case 'snow':
        return 'assets/images/snow.jpeg';
      case 'mist':
      case 'haze':
        return 'assets/images/foggy.jpg';
      default:
        return 'assets/images/clear.jpg';
    }
  }
}
