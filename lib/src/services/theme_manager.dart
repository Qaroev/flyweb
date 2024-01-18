import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import './storage_manager.dart';

class ThemeNotifier with ChangeNotifier {
  final darkTheme = ThemeData(
    primaryColor: Colors.black,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    //accentColor: Colors.white,
    //accentIconTheme: IconThemeData(color: Colors.black),
    dividerColor: Colors.black12,
    canvasColor: Colors.black,
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey)
        .copyWith(background: const Color(0xFF212121)),
  );

  final lightTheme = ThemeData(
      /* primarySwatch: Colors.grey,
    primaryColor: Colors.white,
    brightness: Brightness.light,
    backgroundColor: const Color(0xFFE5E5E5),
    accentColor: Colors.black,
    accentIconTheme: IconThemeData(color: Colors.white),
    dividerColor: Colors.white54,
    canvasColor:Colors.white,*/
      );

  ThemeData? _themeData;

  ThemeData? getTheme() => _themeData;
  bool isLightTheme = false;
  String default_google_font = "Robot";

  ThemeNotifier() {
    StorageManager.readData('themeMode').then((value) {
      print('value read from storage: ' + value.toString());
      var themeMode = value ?? 'light';
      if (themeMode == 'light') {
        _themeData = lightTheme;
        isLightTheme = true;
      } else {
        print('setting dark theme');
        _themeData = darkTheme;
        isLightTheme = false;
      }
      notifyListeners();
    });
  }

  void setDarkMode() async {
    _themeData = darkTheme.copyWith(
        textTheme:
            GoogleFonts.getTextTheme(default_google_font, darkTheme.textTheme));
    isLightTheme = false;
    StorageManager.saveData('themeMode', 'dark');
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = lightTheme.copyWith(
        textTheme: GoogleFonts.getTextTheme(
            default_google_font, lightTheme.textTheme));
    isLightTheme = true;
    StorageManager.saveData('themeMode', 'light');
    notifyListeners();
  }

  void setFont(google_font) async {
    default_google_font = google_font;
    _themeData = _themeData!.copyWith(
        textTheme:
            GoogleFonts.getTextTheme(google_font, _themeData!.textTheme));

    notifyListeners();
  }
}
