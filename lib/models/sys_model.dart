class SysModel {
  final String country;
  final int sunrise;
  final int sunset;

  SysModel({
    required this.country,
    required this.sunrise,
    required this.sunset,
  });

  factory SysModel.fromMap(Map<String, dynamic> map) {
    return SysModel(
      country: map['country'] ?? "",
      sunrise: map['sunrise'] ?? 0,
      sunset: map['sunset'] ?? 0,
    );
  }
}
