import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool isDarkTheme;

  ThemeProvider({this.isDarkTheme});

  ThemeData get getTheme => isDarkTheme ? darkTheme : lightTheme;

  set setTheme(bool val) {
    if (val) {
      isDarkTheme = true;
    } else {
      isDarkTheme = false;
    }
    notifyListeners();
  }
}

final _blue = Color(0xFF4885ed);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  accentColor: _blue,
  fontFamily: 'Google Sans',
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

final lightTheme = ThemeData(
  primaryColor: Colors.white,
  accentColor: _blue,
  scaffoldBackgroundColor: Colors.white,
  fontFamily: 'Google Sans',
  visualDensity: VisualDensity.adaptivePlatformDensity,
);