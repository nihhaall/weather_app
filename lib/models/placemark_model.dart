import 'package:geocoding/geocoding.dart';

class PlacemarkModel {
  final String name;
  final String street;
  final String isoCountryCode;
  final String country;
  final String postalCode;
  final String administrativeArea;
  final String subAdministrativeArea;
  final String locality;
  final String subLocality;
  final String thoroughfare;
  final String subThoroughfare;

  PlacemarkModel({
    required this.name,
    required this.street,
    required this.isoCountryCode,
    required this.country,
    required this.postalCode,
    required this.administrativeArea,
    required this.subAdministrativeArea,
    required this.locality,
    required this.subLocality,
    required this.thoroughfare,
    required this.subThoroughfare,
  });

  factory PlacemarkModel.fromPlacemark(Placemark place) {
    return PlacemarkModel(
      name: place.name ?? "",
      street: place.street ?? "",
      isoCountryCode: place.isoCountryCode ?? "",
      country: place.country ?? "",
      postalCode: place.postalCode ?? "",
      administrativeArea: place.administrativeArea ?? "",
      subAdministrativeArea: place.subAdministrativeArea ?? "",
      locality: place.locality ?? "",
      subLocality: place.subLocality ?? "",
      thoroughfare: place.thoroughfare ?? "",
      subThoroughfare: place.subThoroughfare ?? "",
    );
  }
}
