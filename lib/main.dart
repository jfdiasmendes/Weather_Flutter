import 'package:flutter/material.dart';

import 'package:weather/screens/home.dart';

void main() {
  runApp(MaterialApp(
    title: "Weather",
    home: Home(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: Colors.white,
        hintColor: Colors.grey[300]
    ),
  ));
}
