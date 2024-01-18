import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  Locale _appLocale = Locale('en', '');

  Locale get appLocal => _appLocale;

  fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      _appLocale =
          Locale('${GlobalConfiguration().getValue('defaultLanguage')}', '');
      return Null;
    }
    _appLocale = Locale(prefs.getString('language_code')!);
    return Null;
  }

  void changeLanguageCode(String code) async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      _appLocale = Locale(code, "");
      await prefs.setString('language_code', code);
      await prefs.setString('countryCode', code);
      notifyListeners();
    }
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
