import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import 'package:lottie/lottie.dart';

class WeatherPage extends StatefulWidget {
  final bool isDarkMode;
  final Function toggleDarkMode;

  const WeatherPage({Key? key, required this.isDarkMode, required this.toggleDarkMode}) : super(key: key);

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService('5b92d3116d9dabe51679f4b576dc73ba');
  Weather? _weather;
  final TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];

  _fetchWeather([String? cityName]) async {
    if (cityName == null) {
      cityName = await _weatherService.getCurrentCity();
    }

    print('City Name: $cityName');

    try {
      final weather = await _weatherService.getWeather(cityName);
      print('Weather Data: $weather');
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloud.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  _fetchSuggestions(String query) async {
    if (query.length < 3) return;
    try {
      final suggestions = await _weatherService.getCitySuggestions(query);
      setState(() {
        _suggestions = suggestions;
      });
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: widget.isDarkMode,
                onChanged: (value) {
                  widget.toggleDarkMode();
                  Navigator.of(context).pop(); // Close the drawer
                },
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty || textEditingValue.text.length < 2) {
                    return const Iterable<String>.empty();
                  }
                  _fetchSuggestions(textEditingValue.text);
                  return _suggestions;
                },
                onSelected: (String selection) {
                  _fetchWeather(selection);
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  _controller.text = controller.text;
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'Search for a city',
                      hintStyle: TextStyle(color: Colors.black), // Ensuring black hint text color
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black), // Ensuring black text color
                    onChanged: (text) {
                      if (text.length >= 2) {
                        _fetchSuggestions(text);
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                _weather?.cityName ?? "Loading..",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),
              Text(
                '${_weather?.temperature?.round() ?? ''}C',
                style: TextStyle(
                  fontSize: 32,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Text(
                _weather?.mainCondition ?? '',
                style: TextStyle(
                  fontSize: 24,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
