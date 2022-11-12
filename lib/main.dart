import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyStatelessWidget(),
    );
  }
}

class MyStatelessWidget extends StatelessWidget {
  const MyStatelessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Погода в трех регионах'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                text: "Moscow",
              ),
              Tab(
                text: "Vladivostok",
              ),
              Tab(
                text: "Tokio",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Center(
              child: RegionWeatherWidget('moscow'),
            ),
            Center(
              child: RegionWeatherWidget('vladivostok'),
            ),
            Center(
              child: RegionWeatherWidget('tokio'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegionWeatherWidget extends StatelessWidget{

  RegionWeatherWidget(this.region_name);

  String region_name;
  late Future<CurrentWeather> weather;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CurrentWeather>(
      future: getWeather(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text("Температура: ${snapshot.data!.getTemp()}°C"),
                Text("Ощущается как ${snapshot.data!.getFeelsLikeTemp()}°C"),
                Text("Скорость ветра: ${snapshot.data!.getWindSpeed()}км/ч"),
                Text("Видимоcть: ${snapshot.data!.getVisibility()}"),
                Text("Атмосферное давление: ${snapshot.data!.getPressure()} миллибар"),
              ],
            )
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }

  Future<CurrentWeather> getWeather() async {
    var response = await http.get(Uri.parse('http://api.worldweatheronline.com/premium/v1/weather.ashx?key=09e740b0d824463f9dc152803221111&q=${this.region_name}&format=json'));

    if (response.statusCode == 200) {
      return CurrentWeather.fromJson(jsonDecode(response.body));
    } else {
      print("code ${response.statusCode}");
      throw Exception('Failed to load weather data');
    }
  }
}

class CurrentWeather {
  int temp_C;
  int FeelsLikeC;
  int windspeedKmph;
  int visibility;
  int pressure;

  CurrentWeather({
    required this.temp_C,
    required this.FeelsLikeC,
    required this.windspeedKmph,
    required this.visibility,
    required this.pressure
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
        temp_C: int.parse(json['data']['current_condition'][0]['temp_C']),
        FeelsLikeC: int.parse(json['data']['current_condition'][0]['FeelsLikeC']),
        windspeedKmph: int.parse(json['data']['current_condition'][0]['windspeedKmph']),
        visibility: int.parse(json['data']['current_condition'][0]['visibility']),
        pressure: int.parse(json['data']['current_condition'][0]['pressure'])
    );
  }

  int getTemp() {
    return temp_C;
  }
  
  int getFeelsLikeTemp() {
    return FeelsLikeC;
  }

  int getWindSpeed() {
    return windspeedKmph;
  }

  int getVisibility() {
    return visibility;
  }

  int getPressure() {
    return pressure;
  }
}