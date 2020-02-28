import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool isDarkTheme;

  ThemeProvider({this.isDarkTheme});

  ThemeData get getThemeData => isDarkTheme ? darkTheme : lightTheme;

  set setTheme(bool val) {
    if (val) {
      isDarkTheme = true;
    } else {
      isDarkTheme = false;
    }
    notifyListeners();
  }
}

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Google Sans',
);

final lightTheme = ThemeData(
  primaryColor: Color(0xFFEA4335),
  accentColor: Color(0xFFEA9F35),
  fontFamily: 'Google Sans',
);