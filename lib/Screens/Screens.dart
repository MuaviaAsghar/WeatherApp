import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather_app/api_key.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isExpanded = false;
  final WeatherFactory _wf = WeatherFactory(openWeatherApiKey);
  Weather? _weather;

  String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  @override
  void initState() {
    super.initState();
    _getLocationAndWeather();
    _getStringData();
  }

  Future<String> _getStringData() async {
    if (_weather != null) {
      return 'Place Name: ${_weather!.areaName} [${_weather!.country}] (${_weather!.latitude}, ${_weather!.longitude}),\n'
          'Date: ${_weather!.date},\n'
          'Weather: ${_weather!.weatherMain}, ${_weather!.weatherDescription},\n'
          'Temp: ${_weather!.temperature},\n'
          'Temp (min): ${_weather!.tempMin},\n'
          'Temp (max): ${_weather!.tempMax},\n'
          'Temp (feels like): ${_weather!.tempFeelsLike},\n'
          'Sunrise: ${_weather!.sunrise},\n'
          'Sunset: ${_weather!.sunset},\n'
          'Wind: speed ${_weather!.windSpeed}, degree: ${_weather!.windDegree}, gust ${_weather!.windGust},\n'
          'Weather Condition code: ${_weather!.weatherConditionCode}';
    } else {
      return '';
    }
  }

  Future<void> _getLocationAndWeather() async {
    // Check if location permissions are granted
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      _showLocationServiceDisabledMessage();
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      _showLocationPermissionDeniedMessage();
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    String cityName = await _getCityName(position.latitude, position.longitude);

    Weather weather = await _wf.currentWeatherByCityName(cityName);

    setState(() {
      _weather = weather;
    });
  }

  Future<String> _getCityName(double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    return placemarks.first.locality ?? 'Unknown';
  }

  void _showLocationServiceDisabledMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text('Please enable location services to use this app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLocationPermissionDeniedMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permissions Denied'),
        content:
            const Text('Please grant location permissions to use this app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on),
            Text(
              'City: ${_weather?.areaName ?? 'Unknown'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
                border: const Border.symmetric(
                  vertical: BorderSide(width: 2, color: Colors.black),
                  horizontal: BorderSide(width: 2, color: Colors.black),
                ),
              ),
              height: 250,
              child: _weather == null
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 25, bottom: 10, left: 20, right: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Temperatures",
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '${_weather!.temperature!.celsius!.truncate()}°C',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.network(
                                    getWeatherIconUrl(_weather!.weatherIcon!),
                                    width: 100,
                                    height: 100,
                                  ),
                                  Text(
                                    _weather!.weatherMain!,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Feels Like ${_weather!.tempFeelsLike!.celsius!.truncate()}°C',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Weather Details ",
                    style: TextStyle(
                      color: Color(0xff181725),
                      fontSize: 38,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      color: Colors.black,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
            if (isExpanded)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                child: FutureBuilder<String>(
                  future: _getStringData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Text(
                        snapshot.data ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xff7C7C7C),
                        ),
                      );
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
