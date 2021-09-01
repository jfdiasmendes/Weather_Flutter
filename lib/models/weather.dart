import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:weather/models/location.dart';

class Weather {
  final String apiKey = "cda95ca8086740b197d144017213008&q"; //'3ef171058f28b690a82e767a7cbb2559';
  final String base = "https://api.weatherapi.com/v1/current.json?key={API key}={lat},{lon}&aqi=no"; // "https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&units=metric&appid={API key}&lang=pt_br";

  static final Weather _instance = Weather.internal();

  factory Weather() => _instance;

  Weather.internal();
  String city;
  String country;
  String icon;
  String temp;
  String status;
  String dyNght;

  Weather.fromMap(Map map) {
    city = map['city'];
    country = map['country'];
    icon = map['icon'];
    temp = map['temp'];
    status = map['status'];
    dyNght = map['dyNght'];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "city": city,
      "country": country,
      "icon": icon,
      "temp": temp,
      "status": status,
      "dyNght": dyNght,
    };
    return map;
  }

  Future<void> fetchForecast(Location location) async {
    if (location.geocode == null) return null;

    String urlRequest = base
        .replaceAll("{lat}", location.geocode.split(",")[0])
        .replaceAll("{lon}", location.geocode.split(",")[1])
        .replaceAll("{API key}", apiKey);

    http.Response response = await http.get(urlRequest);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode("[" + response.body + "]");

      Map<String, dynamic> map = data[0];
      Map<String, dynamic> current = map['main'];
      Map<String, dynamic> condition = map['condition'];

      temp = current['temp_c'].toString();
      status = condition['text'].toString();
      icon = condition['icon'].toString();

      if (icon.contains('day'))
        dyNght = 'D';
      else
        dyNght = 'N';

      city = location.cityNm;
      country = location.stCd;
    }
  }

  @override
  String toString() {
    return "Weather (icon: $icon, temp: $temp, status: $status, DayNight: $dyNght, CityName:$city)";
  }
}
