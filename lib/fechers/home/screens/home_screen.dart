import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather_app/core/cmn_functions/pop_msg.dart';
import 'package:weather_app/core/constents/app_constents.dart';
import 'package:weather_app/models/perent_model.dart';
import 'package:weather_app/models/placemark_model.dart';

import '../../../main.dart';
import '../../../models/uv_response.dart';

final selectedOptionProvider=StateProvider((ref) => 'Pin',);
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PlacemarkModel address;
  late WeatherResponseModel weatherMap;
  TextEditingController searchController = TextEditingController();
  String? district;
  late String dir;
  late int force;

  bool isBright = false;
  bool isLoading = false;
  double uvInd = 0;
  bool refreshLoading = false;

  Future<Position> getLocation() async {
    var s = await Geolocator.checkPermission();
    if (kDebugMode) {
      print(s);
    }
    if (s == LocationPermission.deniedForever) {
      await openAppSettings();
    }
    if (s == LocationPermission.denied) {
      var requestStatus = await Geolocator.requestPermission();
      if (kDebugMode) {
        print('after req $requestStatus');
      }
      if (requestStatus == LocationPermission.always ||
          requestStatus == LocationPermission.whileInUse) {
        if (kDebugMode) {
          print('location access granted');
        }
      } else {
        if (mounted) {
          showMsg(
            context,
            text: 'Sorry! you cant use the app without location permission.',
          );
        }
        // await Future.delayed(Duration(seconds: 2));
        // SystemNavigator.pop();
      }
    }
    if (kDebugMode) {
      print('done');
    }
    var locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (kDebugMode) {
      print(locationEnabled);
    }
    if (!locationEnabled) {
      await Geolocator.openLocationSettings();
    }
    Position geo = await Geolocator.getCurrentPosition();
    return geo;
  }

  Future<void> getRequest([bool isRefresh = false]) async {
    isRefresh ? isLoading = false : isLoading = true;
    final dio = Dio();
    var geo = await getLocation();

    if (kDebugMode) {
      print(geo.longitude);
      print(geo.latitude);
    }
    await getAddress(latitude: geo.latitude, longitude: geo.longitude);
    uvInd = await getUVIndex(geo.latitude, geo.longitude);
    final response = await dio.get(
      AppConstants.weatherUrl(geo.latitude, geo.longitude),
    );
    var data = response.data;
    weatherMap = WeatherResponseModel.fromMap(data);
    isBright =
        DateTime.now().hour <
        DateTime.fromMicrosecondsSinceEpoch(weatherMap.sys.sunset).hour;
    dir = AppConstants.getWindDirection(weatherMap.wind.deg);
    force = AppConstants.getBeaufort(weatherMap.wind.speed);
    district = data['name'] ?? "N/A";
    if (kDebugMode) {
      print(data);
    }
    isLoading = false;
    setState(() {});
  }

  int getMostFilledIndex(List<PlacemarkModel> list) {
    int bestIndex = 0;
    int bestScore = -1;

    for (int i = 0; i < list.length; i++) {
      final p = list[i];

      // Count how many fields are non-empty
      int score = [
        p.name,
        p.street,
        p.isoCountryCode,
        p.country,
        p.postalCode,
        p.administrativeArea,
        p.subAdministrativeArea,
        p.locality,
        p.subLocality,
        p.thoroughfare,
        p.subThoroughfare,
      ].where((field) => field.isNotEmpty).length;

      // Keep the index with the highest score
      if (score > bestScore) {
        bestScore = score;
        bestIndex = i;
      }
    }

    return bestIndex;
  }

  Future<void> search({required String query,required String selected}) async {
    Dio dio = Dio();
    try {
      if(selected=='Pin'){
        var response = await dio.get(AppConstants.searchWithZip(zip: query));
        var data = response.data;
        weatherMap = WeatherResponseModel.fromMap(data);
        district = data['name'] ?? "N/A";
      }else{
        var response = await dio.get(AppConstants.searchWithCity(query: query));
        var data = response.data;
        weatherMap = WeatherResponseModel.fromMap(data);
        district = data['name'] ?? "N/A";
      }
      await getAddress(
        latitude: weatherMap.coord.lat,
        longitude: weatherMap.coord.lon,
      );
      isBright =
          DateTime.now().hour <
              DateTime.fromMicrosecondsSinceEpoch(weatherMap.sys.sunset).hour;
      dir = AppConstants.getWindDirection(weatherMap.wind.deg);
      force = AppConstants.getBeaufort(weatherMap.wind.speed);
      uvInd=await getUVIndex(weatherMap.coord.lat, weatherMap.coord.lon);

      setState(() {});
    } catch (e) {
      if (mounted) showMsg(context, text: 'Please Enter a correct city name or zipcode');
    }
  }

  Future<void> getAddress({
    required double latitude,
    required double longitude,
  }) async {
    List<Placemark> placeMark = await placemarkFromCoordinates(
      latitude,
      longitude,
    );

    List<PlacemarkModel> listOfPlaceModel = [];
    for (var place in placeMark) {
      listOfPlaceModel.add(PlacemarkModel.fromPlacemark(place));
    }
    int bestIndex = getMostFilledIndex(listOfPlaceModel);
    address = PlacemarkModel.fromPlacemark(placeMark[bestIndex]);
    if (kDebugMode) {
      print(placeMark[bestIndex]);
    }
  }

  Future<double> getUVIndex(double lat, double lon) async {
    final dio = Dio();
    final response = await dio.get(AppConstants.getUv(lat, lon));
    final uv = UVResponse.fromMap(response.data);
    return uv.value;
  }

  @override
  void initState() {
    getRequest();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var selectedItem=ref.watch(selectedOptionProvider);
    return Scaffold(
      backgroundColor: Colors.blue.shade200,
      extendBodyBehindAppBar: true,
      appBar: isLoading
          ? null
          : AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: Colors.transparent,
              toolbarHeight: h * 0.15,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.getGreeting(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: w * 0.06,
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(w * 0.03),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: TextFormField(
                      controller: searchController,
                      style: TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.search,
                      keyboardType: selectedItem=="Pin"? TextInputType.number:TextInputType.text,
                      decoration: InputDecoration(
                        prefixIcon: DropdownButton<String>(
                          style: TextStyle(
                            color: Colors.white
                          ),
                          dropdownColor: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(w*0.03),
                          value: selectedItem,
                          items: [
                            DropdownMenuItem(
                              value: 'Pin',
                              child: Text(
                                'Pin',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Name',
                              child: Text(
                                'City',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                              ref.read(selectedOptionProvider.notifier).state=value!;
                          },
                          underline: SizedBox(),
                        ),
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          onPressed: () async {
                            if (searchController.text.isNotEmpty) {
                              await search(query: searchController.text.trim(),selected: selectedItem);
                              searchController.clear();
                              setState(() {});
                            } else {
                              if (mounted) showMsg(context, text: 'Search Something...');
                            }
                          },
                          icon: Icon(
                            Icons.search,
                            color: Colors.white,
                            size: w * 0.06,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      body: isLoading
          ? Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(isBright?"assets/images/bg.png":'assets/images/clear_night.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LottieBuilder.asset(
                    'assets/lottie/weather_snow_sunny.json',
                    width: w * 0.4,
                    height: w * 0.4,
                  ),
                  SizedBox(height: h * 0.03),
                  Text(
                    'Getting weather data...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: w * 0.04,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    AppConstants.getBackground(weatherMap.weather[0].main),
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.6),
                    isBright ? BlendMode.lighten : BlendMode.darken,
                  ),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.4),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: w * 0.03,
                      right: w * 0.05,
                      left: w * 0.05,
                      bottom: w * 0.02,
                    ),
                    child: ListView(
                      children: [
                        Container(
                          padding: EdgeInsets.all(w * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(w * 0.04),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(w * 0.02),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                  color: Colors.black.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(w * 0.02),
                                ),
                                child: Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                  size: w * 0.06,
                                ),
                              ),
                              SizedBox(width: w * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      address.locality.isNotEmpty?address.locality:"Unknown Location",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: w * 0.045,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "$district, ${address.administrativeArea}, ${address.country}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: w * 0.032,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(w * 0.02),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: refreshLoading
                                    ? Padding(
                                        padding: EdgeInsets.all(w * 0.03),
                                        child: SizedBox(
                                          width: w * 0.04,
                                          height: w * 0.04,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : IconButton(
                                        onPressed: () async {
                                          setState(() {
                                            refreshLoading = true;
                                          });
                                          await getRequest(true);
                                          setState(() {
                                            refreshLoading = false;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.refresh_rounded,
                                          color: Colors.white,
                                          size: w * 0.055,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: h * 0.03),

                        Container(
                          width: w * 1,
                          padding: EdgeInsets.all(w * 0.06),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.2),
                                Colors.black.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(w * 0.06),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              CachedNetworkImage(
                                imageUrl:
                                    "https://openweathermap.org/img/wn/${weatherMap.weather[0].icon}@4x.png",
                                width: w * 0.25,
                                height: w * 0.25,
                              ),
                              SizedBox(height: h * 0.01),
                              Text(
                                "${weatherMap.main.temp.toStringAsFixed(1)}°C",
                                style: TextStyle(
                                  fontSize: w * 0.16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: h * 0.01),
                              Text(
                                weatherMap.weather[0].main,
                                style: TextStyle(
                                  fontSize: w * 0.055,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                weatherMap.weather[0].description.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                  fontSize: w * 0.035,
                                  letterSpacing: 1,
                                ),
                              ),

                              Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: h * 0.025,
                                ),
                                height: 1,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(w * 0.03),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.blueAccent.withValues(
                                              alpha: 0.2,
                                            ),
                                            Colors.blue.withValues(alpha: 0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          w * 0.03,
                                        ),
                                        border: Border.all(
                                          color: Colors.blue.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.wb_twilight_rounded,
                                            color: Colors.amber.shade300,
                                            size: w * 0.08,
                                          ),
                                          SizedBox(height: h * 0.008),
                                          Text(
                                            'Sunrise',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: w * 0.03,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: h * 0.003),
                                          Text(
                                            DateFormat('HH:mm').format(
                                              DateTime.fromMillisecondsSinceEpoch(
                                                weatherMap.sys.sunrise * 1000,
                                              ),
                                            ),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: w * 0.04,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: w * 0.03),

                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(w * 0.03),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.black.withValues(alpha: 0.3),
                                            Colors.black.withValues(alpha: 0.2),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          w * 0.03,
                                        ),
                                        border: Border.all(
                                          color: Colors.grey.withValues(
                                            alpha: 0.4,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.nightlight_rounded,
                                            color: Colors.grey.shade700,
                                            size: w * 0.08,
                                          ),
                                          SizedBox(height: h * 0.008),
                                          Text(
                                            'Sunset',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: w * 0.03,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: h * 0.003),
                                          Text(
                                            DateFormat('HH:mm').format(
                                              DateTime.fromMillisecondsSinceEpoch(
                                                weatherMap.sys.sunset * 1000,
                                              ),
                                            ),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: w * 0.04,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: h * 0.04),

                        Container(
                          width: w,
                          padding: EdgeInsets.all(w * 0.05),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.2),
                                Colors.black.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(w * 0.05),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Wrap(
                            runSpacing: h * 0.025,
                            alignment: WrapAlignment.spaceEvenly,
                            children: [
                              infoTile(
                                Icons.water_drop_rounded,
                                'Humidity',
                                '${weatherMap.main.humidity}%',
                              ),
                              infoTile(
                                Icons.air_rounded,
                                'Wind',
                                "${weatherMap.wind.speed} m/s",
                              ),
                              infoTile(
                                Icons.cloud_rounded,
                                'Clouds',
                                "${weatherMap.clouds.all}%",
                              ),
                              infoTile(
                                Icons.thermostat_rounded,
                                'Feels Like',
                                "${weatherMap.main.feelsLike.toStringAsFixed(1)}°C",
                              ),
                              infoTile(
                                Icons.speed_rounded,
                                'Pressure',
                                "${weatherMap.main.pressure} hPa",
                              ),
                              infoTile(
                                Icons.visibility_rounded,
                                'Visibility',
                                "${(weatherMap.visibility / 1000).toStringAsFixed(1)} km",
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: h * 0.025),

                        Container(
                          width: w,
                          padding: EdgeInsets.all(w * 0.05),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.2),
                                Colors.black.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(w * 0.05),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Wrap(
                                runSpacing: h * 0.025,
                                alignment: WrapAlignment.spaceEvenly,
                                children: [
                                  infoTile(
                                    Icons.wb_sunny_rounded,
                                    'UV Level',
                                    uvInd.toString(),
                                    AppConstants.getUVColor(uvInd),
                                  ),
                                  infoTile(
                                    Icons.wind_power,
                                    'Wind Force',
                                    "Force ${force.toString()}",
                                  ),
                                  infoTile(
                                    Icons.explore_rounded,
                                    'Wind Direction',
                                    dir,
                                  ),
                                  infoTile(
                                    Icons.thermostat_rounded,
                                    'Min Temp',
                                    '${weatherMap.main.tempMin.toStringAsFixed(1)}°C',
                                  ),
                                  infoTile(
                                    Icons.thermostat_rounded,
                                    'Max Temp',
                                    '${weatherMap.main.tempMax.toStringAsFixed(1)}°C',
                                  ),
                                  infoTile(
                                    Icons.opacity_rounded,
                                    'Dew Point',
                                    '${(weatherMap.main.temp - ((100 - weatherMap.main.humidity) / 5)).toStringAsFixed(1)}°C',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget infoTile(
    IconData icon,
    String title,
    String value, [
    Color? accentColor,
  ]) {
    return SizedBox(
      width: w * 0.25,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.025),
            decoration: BoxDecoration(
              color: accentColor != null
                  ? accentColor.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(w * 0.03),
              border: accentColor != null
                  ? Border.all(
                      color: accentColor.withValues(alpha: 0.5),
                      width: 1.5,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: accentColor ?? Colors.white,
              size: w * 0.06,
            ),
          ),
          SizedBox(height: h * 0.012),
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: w * 0.03,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: h * 0.005),
          Text(
            value,
            style: TextStyle(
              color: accentColor ?? Colors.white,
              fontSize: w * 0.036,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 2,
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
