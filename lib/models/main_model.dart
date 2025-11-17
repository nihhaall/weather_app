class MainModel {
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int humidity;

  MainModel({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
  });

  factory MainModel.fromMap(Map<String, dynamic> map) {
    return MainModel(
      temp: map['temp']?.toDouble() ?? 0.0,
      feelsLike: map['feels_like']?.toDouble() ?? 0.0,
      tempMin: map['temp_min']?.toDouble() ?? 0.0,
      tempMax: map['temp_max']?.toDouble() ?? 0.0,
      pressure: map['pressure'] ?? 0,
      humidity: map['humidity'] ?? 0,
    );
  }
}
