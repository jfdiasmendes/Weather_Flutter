import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    debugPrint(DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString() + ":" + DateTime.now().second.toString() + " === Iniciando busca ===");

    await _getCurrentLocation();
    if (_currentPosition != null){
      geocode = _currentPosition.latitude.toString() + "," + _currentPosition.longitude.toString();
      cityNm = "Seu local atual.";
      stCd = "Aqui";

      await prefs.setStringList('location', asList());
    }

    debugPrint(DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString() + ":" + DateTime.now().second.toString() + " === Passei pela busca ===");
    List list = prefs.getStringList('location');
    if (list != null) fromList(list);

  }

  _getCurrentLocation() async {
    await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true)
        .then((Position position) {
      _currentPosition = position;
      debugPrint(DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString() + ":" + DateTime.now().second.toString() + ":" + " LATITUDE: " + position.latitude.toString());
      geocode = _currentPosition.latitude.toString() + "," + _currentPosition.longitude.toString();
      cityNm = "Seu local atual.";
      stCd = "Aqui";
      //getLocalLocation();
    }).catchError((e) {
      print("HOUVE UM ERRO AO OBTER LOCALIZAÇÃO");
      print(e);
    });
  }

  @override
  String toString() {
    return "Location (geocode: $geocode, cityNm: $cityNm, stCd: $stCd)";
  }
}
