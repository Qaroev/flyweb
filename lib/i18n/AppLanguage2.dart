import 'package:flutter/material.dart';
import 'package:flyweb/src/helpers/SharedPref.dart';
import 'package:flyweb/src/models/setting.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  Locale _appLocale = Locale('en', '');

  Locale get appLocal => _appLocale;

  fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    SharedPref sharedPref = SharedPref();
    Settings settings = new Settings();

    var set = await sharedPref.read("settings");
    if (set != null) {
      settings = Settings.fromJson(set);
    }

    if (prefs.getString('language_code') == null) {
      _appLocale =
          Locale(Setting.getValue(settings.setting!, "default_language"), '');
      return Null;
    }
    _appLocale = Locale(prefs.getString('language_code')!);
    return Null;
  }

  void changeLanguage(Locale type, String code) async {
    var prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) {
      return;
    }

    _appLocale = Locale(code, "");
    await prefs.setString('language_code', code);
    await prefs.setString('countryCode', code);
    notifyListeners();
  }
}
