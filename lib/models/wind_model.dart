class WindModel {
  final double speed;
  final int deg;
  final double gust;

  WindModel({
    required this.speed,
    required this.deg,
    required this.gust,
  });

  factory WindModel.fromMap(Map<String, dynamic> map) {
    return WindModel(
      speed: map['speed']?.toDouble() ?? 0.0,
      deg: map['deg'] ?? 0,
      gust: map['gust']?.toDouble() ?? 0.0,
    );
  }
}
