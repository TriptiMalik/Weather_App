import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/home_page.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';
import 'package:weather_app/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:permission_handler/permission_handler.dart';



class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String cachedWeatherDataKey = 'cached_weather_data';
  late Future<Map<String, dynamic>> weather;
  TextEditingController cityController = TextEditingController();
  late String temperatureUnit;
  late String selectedCity = ''; // Added for city selection
  late SharedPreferences prefs;


  // Future<void> requestLocationPermission() async {
  //   var status = await Permission.location.request();
  //
  //   if (status == PermissionStatus.granted) {
  //     // User granted permission, proceed with accessing the location.
  //     getCurrentLocationWeather();
  //   } else {
  //     // Handle the case where the user denied permission.
  //     // You can show a message to the user explaining why location is needed.
  //     print('Location permission denied');
  //   }
  // }
  //
  // Future<Map<String, dynamic>> getCurrentLocationWeather() async {
  //   try {
  //     var status = await Permission.location.status;
  //
  //     if (status == PermissionStatus.granted) {
  //       Position position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high,
  //       );
  //
  //       List<Placemark> placemarks = await placemarkFromCoordinates(
  //         position.latitude,
  //         position.longitude,
  //       );
  //
  //       String currentCity = placemarks.first.locality ?? 'Unknown';
  //       setState(() {
  //         selectedCity = currentCity;
  //         weather = getCurrentWeather(selectedCity);
  //       });
  //     } else {
  //       // Location permission not granted, request permission.
  //       await requestLocationPermission();
  //     }
  //
  //     // Add a return statement at the end.
  //     return Map<String, dynamic>();
  //   } catch (e) {
  //     print('Error getting current location: $e');
  //     return Map<String, dynamic>();
  //   }
  // }



  Future<Map<String, dynamic>> getCurrentWeather(String cityName) async {
    try {
      final cachedData = await _getWeatherData(selectedCity);
      if(cachedData != null) {
        return cachedData;
      }
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey',
        ),
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'An unexpected error occurred';
      }

      await _saveWeatherData(selectedCity, data);

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  String convertTemperature(double temperature, String unit) {
    if (temperatureUnit == 'K') {
      return '$temperature K';
    } else if (temperatureUnit == '°C') {
      double celsius = temperature - 273.15;
      return '${celsius.toStringAsFixed(2)} °C';
    } else if (temperatureUnit == '°F') {
      double fahrenheit = (temperature - 273.15) * 9 / 5 + 32;
      return '${fahrenheit.toStringAsFixed(2)} °F';
    }
    return 'Invalid Unit';
  }



  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather('Pilani');
    temperatureUnit = 'K';// Default to Kelvin
    selectedCity = 'Pilani';
    _initSharedPreferences();
  }

  void _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      weather = getCurrentWeather(selectedCity);
    });
  }

  Future<void> _saveWeatherData(String cityName, Map<String, dynamic> weatherData) async {
    final String jsonString = jsonEncode(weatherData);
    await prefs.setString('$cachedWeatherDataKey-$cityName', jsonString);
  }

  Future<Map<String, dynamic>?> _getWeatherData(String cityName) async {
    final String? jsonString = prefs.getString('$cachedWeatherDataKey-$cityName');
    if (jsonString != null) {
      return jsonDecode(jsonString);
    } else {
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          elevation: 20,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20.0),
            ),
          ),
          title: const Text(
            'Weather App',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              setState(() {
                Navigator.pop(context);
              });
            },
            icon: Icon(Icons.arrow_circle_left),
            iconSize: 30,
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  weather = getCurrentWeather(selectedCity);
                });
              },
              icon: const Icon(Icons.refresh),
              iconSize: 30,
            ),
            PopupMenuButton(
              icon: const Icon(Icons.menu),
              iconSize: 30,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'ThemeMode',
                  child: Row(
                    children: [
                      Icon(Icons.light_mode_outlined),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Select Theme'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'temperatureUnit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Change Unit')
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if(value == 'temperatureUnit'){
                  _showTemperatureUnitBottomSheet();
                }
                else{
                  _showThemeChangeBottomSheet();
                }
              },
            ),
      
            // ElevatedButton(
            //   onPressed: () {
            //     Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            //   },
            //   child: Text('Toggle Theme'),
            // ),
            // ElevatedButton(
            //   onPressed: () {
            //     setState(() {
            //       isDarkMode = !isDarkMode;
            //     });
            //   },
            //   child: Text('Toggle Theme'),
            // ),
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: FutureBuilder(
            future: weather,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }
      
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
      
              final data = snapshot.data!;
      
              if (data['list'] == null || data['list'].isEmpty) {
                return const Center(
                  child: Text('No weather data available.'),
                );
              }
      
              final currentWeatherData = data['list'][0];
      
              final currentTemp = currentWeatherData['main']['temp'];
              final maxTemp = currentWeatherData['main']['temp_max'];
              final minTemp = currentWeatherData['main']['temp_min'];
              final currentSky = currentWeatherData['weather'][0]['main'];
              final mainIcon = currentWeatherData['weather'][0]['icon'];
              final shortDescription = currentWeatherData['weather'][0]['description'];
              final currentPressure = currentWeatherData['main']['pressure'];
              final currentWindSpeed = currentWeatherData['wind']['speed'];
              final currentHumidity = currentWeatherData['main']['humidity'];
              final seaLevel = currentWeatherData['main']['sea_level'];
              final groundLevel = currentWeatherData['main']['grnd_level'];
      
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black12, //background color
                          onPrimary: Colors.white,  //text color
                          elevation: 20,
                        ),
                        onPressed: _showCitySelectionBottomSheet,
                        child: const Text(
                            'Click here to select a city',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal
                          ),
                        ),
                      ),
                    ),
                    // TextField(
                    //   controller: cityController,
                    //   decoration: InputDecoration(
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10.0),
                    //     ),
                    //     labelText: 'Enter City Name',
                    //     suffixIcon: IconButton(
                    //       icon: Icon(Icons.arrow_circle_right),
                    //       onPressed: () {
                    //         setState(() {
                    //           weather = getCurrentWeather(cityController.text);
                    //         });
                    //       },
                    //     )
                    //   ),
                    // ),
                    const SizedBox(
                        height: 16,
                    ),
                    // main card
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 1,
                              sigmaY: 10,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: [
                                  Text(
                                    '$selectedCity',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${convertTemperature(currentTemp, temperatureUnit)}',
                                    style: const TextStyle(
                                      fontSize: 50,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          getWeatherIcon(mainIcon,size: 70),
                                          // Icon(
                                          //   getWeatherIcon(
                                          //     mainIcon
                                          //   ),
                                          //   currentSky == 'Clouds' || currentSky == 'Rain'
                                          //       ? Icons.cloud
                                          //       : Icons.sunny,
                                          //   size: 70,
                                          Text(
                                            currentSky,
                                            style: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            'Max = ${convertTemperature(maxTemp, temperatureUnit)}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          Text(
                                            'Min = ${convertTemperature(minTemp, temperatureUnit)}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          // const SizedBox(height: 16),
                                          Text(
                                            shortDescription,
                                            style: const TextStyle(
                                              fontSize: 25,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
      
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Weather Forecast',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        itemCount: 8,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final hourlyForecast = data['list'][index + 1];
                          final hourlySky = data['list'][index + 1]['weather'][0]['icon'];
                          final hourlyTemp = hourlyForecast['main']['temp'];
                          final time = DateTime.parse(hourlyForecast['dt_txt']);
                          return HourlyForecastItem(
                            time: DateFormat.j().format(time),
                            temperature: convertTemperature(hourlyTemp, temperatureUnit),
                            icon: getWeatherIcon(hourlySky, size: 30),
                            // hourlySky == 'Clouds' || hourlySky == 'Rain'
                            //     ? Icons.cloud
                            //     : Icons.sunny,
                          );
                        },
                      ),
                    ),
      
                    const SizedBox(height: 20),
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AdditionalInfoItem(
                              icon: Icons.electric_meter,
                              label: 'Pressure',
                              value: currentPressure.toString(),
                            ),
                            AdditionalInfoItem(
                              icon: Icons.water_drop,
                              label: 'Humidity',
                              value: currentHumidity.toString(),
                            ),
                            AdditionalInfoItem(
                              icon: Icons.wind_power,
                              label: 'Wind Speed',
                              value: currentWindSpeed.toString(),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AdditionalInfoItem(
                              icon: Icons.water,
                              label: 'Sea Level',
                              value: seaLevel.toString(),
                            ),
                            AdditionalInfoItem(
                              icon: Icons.landscape,
                              label: 'Ground Level',
                              value: groundLevel.toString(),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }


  Icon getWeatherIcon(String weatherCode, {double size = 24.0}) {
    switch (weatherCode) {
      case "01d":
      case "01n":
        return Icon(Icons.wb_sunny, size: size);
      // case "01n":
      //   return Icon(Icons.nightlight_round, size: size);
      case "02d":
      case "02n":
        return Icon(Icons.cloud, size: size);
      case "03d":
      case "03n":
        return Icon(Icons.cloud_queue, size: size);
      case "04d":
      case "04n":
        return Icon(Icons.cloud, size: size);
      case "09d":
      case "09n":
        return Icon(Icons.beach_access, size: size);
      case "10d":
      case "10n":
        return Icon(Icons.cloudy_snowing, size: size);
      case "11d":
      case "11n":
        return Icon(Icons.flash_on, size: size);
      case "13d":
      case "13n":
        return Icon(Icons.ac_unit, size: size);
      case "50d":
      case "50n":
        return Icon(Icons.legend_toggle_outlined, size: size);
      default:
        return Icon(Icons.wb_sunny, size: size);
    }
  }
  





  void _showTemperatureUnitBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Kelvin'),
                onTap: () {
                  setState(() {
                    temperatureUnit = 'K';
                    Navigator.pop(context);
                  });
                },
              ),
              ListTile(
                title: const Text('Celsius'),
                onTap: () {
                  setState(() {
                    temperatureUnit = '°C';
                    Navigator.pop(context);
                  });
                },
              ),
              ListTile(
                title: const Text('Fahrenheit'),
                onTap: () {
                  setState(() {
                    temperatureUnit = '°F';
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }


  void _showThemeChangeBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Light Theme'),
                onTap: () {
                  setState(() {
                    _updateTheme(ThemeMode.light);
                    Navigator.pop(context);
                  });
                },
              ),
              ListTile(
                title: const Text('Dark Theme'),
                onTap: () {
                  setState(() {
                    _updateTheme(ThemeMode.dark);
                    Navigator.pop(context);
                  });
                },
              ),
              ListTile(
                title: const Text('System Theme'),
                onTap: () {
                  setState(() {
                    _updateTheme(ThemeMode.system);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }


  void _updateTheme(ThemeMode mode) {
    Provider.of<ThemeProvider>(context, listen: false).setThemeMode(mode);
    setState(() {}); // Trigger a rebuild of the WeatherApp widget
  }



  void _showCitySelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Pilani'),
                  onTap: () {
                    _updateSelectedCity('Pilani');
                  },
                ),
                ListTile(
                  title: const Text('Delhi'),
                  onTap: () {
                    _updateSelectedCity('Delhi');
                  },
                ),
                ListTile(
                  title: const Text('Bangalore'),
                  onTap: () {
                    _updateSelectedCity('Bangalore');
                  },
                ),
                ListTile(
                  title: const Text('Visakhapatnam'),
                  onTap: () {
                    _updateSelectedCity('Visakhapatnam');
                  },
                ),
                ListTile(
                  title: const Text('Hyderabad'),
                  onTap: () {
                    _updateSelectedCity('Hyderabad');
                  },
                ),
                ListTile(
                  title: const Text('Lucknow'),
                  onTap: () {
                    _updateSelectedCity('Lucknow');
                  },
                ),
                ListTile(
                  title: const Text('Indore'),
                  onTap: () {
                    _updateSelectedCity('Indore');
                  },
                ),
                ListTile(
                  title: const Text('Pune'),
                  onTap: () {
                    _updateSelectedCity('Pune');
                  },
                ),
                ListTile(
                  title: const Text('Ahmedabad'),
                  onTap: () {
                    _updateSelectedCity('Ahmedabad');
                  },
                ),
                ListTile(
                  title: const Text('Bhopal'),
                  onTap: () {
                    _updateSelectedCity('Bhopal');
                  },
                ),
                ListTile(
                  title: const Text('Surat'),
                  onTap: () {
                    _updateSelectedCity('Surat');
                  },
                ),
                ListTile(
                  title: const Text('Meerut'),
                  onTap: () {
                    _updateSelectedCity('Meerut');
                  },
                ),
                ListTile(
                  title: const Text('Mumbai'),
                  onTap: () {
                    _updateSelectedCity('Mumbai');
                  },
                ),
                ListTile(
                  title: const Text('Chennai'),
                  onTap: () {
                    _updateSelectedCity('Chennai');
                  },
                ),
                ListTile(
                  title: const Text('Warangal'),
                  onTap: () {
                    _updateSelectedCity('Warangal');
                  },
                ),
                ListTile(
                  title: const Text('Kolkata'),
                  onTap: () {
                    _updateSelectedCity('Kolkata');
                  },
                ),
                ListTile(
                  title: const Text('Jaipur'),
                  onTap: () {
                    _updateSelectedCity('Jaipur');
                  },
                ),
                ListTile(
                  title: const Text('Kanpur'),
                  onTap: () {
                    _updateSelectedCity('Kanpur');
                  },
                ),
                ListTile(
                  title: const Text('Nagpur'),
                  onTap: () {
                    _updateSelectedCity('Nagpur');
                  },
                ),
                ListTile(
                  title: const Text('Thane'),
                  onTap: () {
                    _updateSelectedCity('Thane');
                  },
                ),
                ListTile(
                  title: const Text('Patna'),
                  onTap: () {
                    _updateSelectedCity('Patna');
                  },
                ),
                ListTile(
                  title: const Text('Vadodra'),
                  onTap: () {
                    _updateSelectedCity('Vadodra');
                  },
                ),
                ListTile(
                  title: const Text('Ghaziabad'),
                  onTap: () {
                    _updateSelectedCity('Ghaziabad');
                  },
                ),
                ListTile(
                  title: const Text('Ludhiana'),
                  onTap: () {
                    _updateSelectedCity('Ludhiana');
                  },
                ),
                ListTile(
                  title: const Text('Agra'),
                  onTap: () {
                    _updateSelectedCity('Agra');
                  },
                ),
                ListTile(
                  title: const Text('Nashik'),
                  onTap: () {
                    _updateSelectedCity('Nashik');
                  },
                ),
                ListTile(
                  title: const Text('Faridabad'),
                  onTap: () {
                    _updateSelectedCity('Faridabad');
                  },
                ),
                ListTile(
                  title: const Text('Meerut'),
                  onTap: () {
                    _updateSelectedCity('Meerut');
                  },
                ),
                ListTile(
                  title: const Text('Rajkot'),
                  onTap: () {
                    _updateSelectedCity('Rajkot');
                  },
                ),
                ListTile(
                  title: const Text('Varanasi'),
                  onTap: () {
                    _updateSelectedCity('Varanasi');
                  },
                ),
                ListTile(
                  title: const Text('Amritsar'),
                  onTap: () {
                    _updateSelectedCity('Amritsar');
                  },
                ),
                ListTile(
                  title: const Text('Gurugram'),
                  onTap: () {
                    _updateSelectedCity('Gurugram');
                  },
                ),
                ListTile(
                  title: const Text('Mangalore'),
                  onTap: () {
                    _updateSelectedCity('Mangalore');
                  },
                ),
                ListTile(
                  title: const Text('Mysore'),
                  onTap: () {
                    _updateSelectedCity('Mysore');
                  },
                ),
                ListTile(
                  title: const Text('Dehradun'),
                  onTap: () {
                    _updateSelectedCity('Dehradun');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _updateSelectedCity(String city) {
    setState(() {
      selectedCity = city;
      weather = getCurrentWeather(selectedCity);
    });
    Navigator.pop(context);
  }



}