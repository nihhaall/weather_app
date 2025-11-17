class WeatherModel {
  final int id;
  final String main;
  final String description;
  final String icon;

  WeatherModel({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory WeatherModel.fromMap(Map<String, dynamic> map) {
    return WeatherModel(
      id: map['id'] ?? 0,
      main: map['main'] ?? "",
      description: map['description'] ?? "",
      icon: map['icon'] ?? "",
    );
  }
}
