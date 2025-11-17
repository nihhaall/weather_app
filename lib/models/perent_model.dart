import 'package:weather_app/models/sys_model.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/models/wind_model.dart';

import 'main_model.dart';

class CoordModel {
  final double lon;
  final double lat;

  CoordModel({required this.lon, required this.lat});

  factory CoordModel.fromMap(Map<String, dynamic> map) {
    return CoordModel(
      lon: map['lon']?.toDouble() ?? 0.0,
      lat: map['lat']?.toDouble() ?? 0.0,
    );
  }
}


class CloudsModel {
  final int all;

  CloudsModel({required this.all});

  factory CloudsModel.fromMap(Map<String, dynamic> map) {
    return CloudsModel(
      all: map['all'] ?? 0,
    );
  }
}


class WeatherResponseModel {
  final CoordModel coord;
  final List<WeatherModel> weather;
  final String base;
  final MainModel main;
  final int visibility;
  final WindModel wind;
  final CloudsModel clouds;
  final int dt;
  final SysModel sys;
  final int timezone;
  final int id;
  final String name;
  final int cod;

  WeatherResponseModel({
    required this.coord,
    required this.weather,
    required this.base,
    required this.main,
    required this.visibility,
    required this.wind,
    required this.clouds,
    required this.dt,
    required this.sys,
    required this.timezone,
    required this.id,
    required this.name,
    required this.cod,
  });

  factory WeatherResponseModel.fromMap(Map<String, dynamic> map) {
    return WeatherResponseModel(
      coord: CoordModel.fromMap(map['coord']),
      weather: (map['weather'] as List)
          .map((item) => WeatherModel.fromMap(item))
          .toList(),
      base: map['base'] ?? "",
      main: MainModel.fromMap(map['main']),
      visibility: map['visibility'] ?? 0,
      wind: WindModel.fromMap(map['wind']),
      clouds: CloudsModel.fromMap(map['clouds']),
      dt: map['dt'] ?? 0,
      sys: SysModel.fromMap(map['sys']),
      timezone: map['timezone'] ?? 0,
      id: map['id'] ?? 0,
      name: map['name'] ?? "",
      cod: map['cod'] ?? 0,
    );
  }
}
