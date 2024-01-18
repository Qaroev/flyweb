import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flyweb/src/helpers/SharedPref.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart';
import 'package:flyweb/src/models/settings.dart';

ValueNotifier<Settings> setting = new ValueNotifier(new Settings());

class SettingsService {
  Future<Settings> getSettings() async {

    print("API getSettings ");
    SharedPref sharedPref = SharedPref();

    var res = await get(
        Uri.parse('${GlobalConfiguration().getValue('api_base_url')}/api/settings/settings.php'));

    print("API DATA");
    print(res.statusCode);
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      sharedPref.save("settings", json["data"]);
      Settings settings = Settings.fromJson(json["data"]);
      return settings;
    } else {
      throw Exception('Failed to load api');
    }
  }
}