import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:weather/models/location.dart';

class Weather {
  final String apiKey = '3ef171058f28b690a82e767a7cbb2559';
  final String base = "https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&units=metric&appid={API key}&lang=pt_br";
  final String iconsUrl = "https://openweathermap.org/img/wn/{iconCode}@4x.png";

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

    String urlRequest = base.replaceAll("{lat}", location.geocode.split(",")[0]).replaceAll("{lon}", location.geocode.split(",")[1]).replaceAll("{API key}", apiKey);

    debugPrint("URL Request: " + urlRequest);
    debugPrint("Geocode: " + location.geocode);
    debugPrint("State Code: " + location.stCd);

    http.Response response = await http.get(urlRequest);

    debugPrint("Response Code: " + response.statusCode.toString());

    if (response.statusCode == 200) {
      //Map<String, dynamic> data = json.decode(response.body)['main'];
      List<dynamic> data = json.decode(response.body)['main'];

      List<String> itensLista = data.map((e) => e as String).toList();

      temp = itensLista[0].toString();

      data = json.decode(response.body)['weather'];
      //status = data['description'];
      //icon = data['icon'];

      if (icon.contains('c')) dyNght='D'; else dyNght='N';

      city = location.cityNm;
      country = location.stCd;

      debugPrint("Weather dados: " + this.toString());
    }

    debugPrint("Weather dados: " + this.toString());
  }


  @override
  String toString() {
    return "Weather (icon: $icon, temp: $temp, status: $status, DayNight: $dyNght, CityName:$city)";
  }
}