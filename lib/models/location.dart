import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../global.dart' as globals;

class Location {
  static final Location _instance = Location.internal();

  factory Location() => _instance;

  Position _currentPosition;

  Location.internal();

  String geocode;
  String cityNm;
  String stCd;

  fromMap(Map map) {
    geocode = map['geocode'];
    cityNm = map['cityNm'];
    stCd = map['stCd'];
  }

  fromList(List list) {
    geocode = list[0];
    cityNm = list[1];
    stCd = list[2];
  }

  List<String> asList() {
    return [geocode, cityNm, stCd];
  }

  Future<void> setStoredLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('location', asList());
  }

  Future<void> getStoredLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List list = prefs.getStringList('location');
    if (list != null) fromList(list);
  }

  Future<void> getLocalLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //debugPrint(DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString() + ":" + DateTime.now().second.toString() + " === Iniciando busca ===");

    await _getCurrentLocation();

    List list = prefs.getStringList('location');
    if (list != null) fromList(list);

  }

  _getCurrentLocation() async {
    await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: false)
        .then((Position position) {
      _currentPosition = Position(longitude: position.longitude-0.025,latitude: position.latitude+0.01 );
      debugPrint(DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString() + ":" + DateTime.now().second.toString() + ":" + " LATITUDE: " + _currentPosition.latitude.toString()+ " LONGITUDE: " + _currentPosition.longitude.toString());
      geocode = _currentPosition.latitude.toString() + "," + _currentPosition.longitude.toString();

      //getLocalLocation();
    }).catchError((e) {
      print("HOUVE UM ERRO AO OBTER LOCALIZAÇÃO");
      print(e);
    });

    String urlRequest = globals.base
        .replaceAll("{lat}", _currentPosition.latitude.toString())
        .replaceAll("{lon}", _currentPosition.longitude.toString())
        .replaceAll("{API key}", globals.apiKey);

    http.Response response = await http.get(urlRequest);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode("[" + response.body + "]");

      Map<String, dynamic> map = data[0];
      Map<String, dynamic> currentLocation = map['location'];

      cityNm = currentLocation["name"].toString();
      stCd = currentLocation["region"].toString();

    }else{
      cityNm = "Seu local atual";
      stCd = "Aqui";
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('location', asList());
  }

  @override
  String toString() {
    return "Location (geocode: $geocode, cityNm: $cityNm, stCd: $stCd)";
  }
}
