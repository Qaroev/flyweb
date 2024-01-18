import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flyweb/i18n/AppLanguage.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/elements/Loader.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/helpers/SharedPref.dart';
import 'package:flyweb/src/models/setting.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/pages/SplashScreen.dart';
import 'package:flyweb/src/repository/settings_service.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:flyweb/src/themes/UIImages.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class InitialScreen extends StatefulWidget {
  InitialScreen();

  @override
  State<InitialScreen> createState() => _InitialScreen();
}

class _InitialScreen extends State<InitialScreen> {
  final SettingsService settingsService = SettingsService();

  bool applicationProblem = false;

  Uint8List? bytesImgSplashBase64;

  Uint8List? byteslogoSplashBase64;

  @override
  void initState() {
    super.initState();
    //Timer.run(() {
    getSetting();
    //});
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getSetting() async {
    AppLanguage appLanguage = AppLanguage();

    try {
      Settings _settings = await settingsService.getSettings();

      appLanguage.changeLanguageCode(
          Setting.getValue(_settings.setting!, "default_language_code"));

      I18n.refreshI18n(_settings);

      var themeProvider = Provider.of<ThemeNotifier>(context, listen: false);
      if (Setting.getValue(_settings.setting!, "initial_dark_mode") == "true") {
        themeProvider.setDarkMode();
      } else {
        themeProvider.setLightMode();
      }

      themeProvider
          .setFont(Setting.getValue(_settings.setting!, "google_font"));

      Uint8List imgSplashBase64 =
          await networkImageToBase64(_settings.splash!.img_splash_url!);

      Uint8List logoSplashBase64 =
          await networkImageToBase64(_settings.splash!.logo_splash_url!);

      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => SplashScreen(
              settings: _settings,
              bytesImgSplashBase64: imgSplashBase64,
              byteslogoSplashBase64: logoSplashBase64)));
    } on Exception catch (exception) {
      print(exception);
      this.setState(() {
        applicationProblem = true;
      });
    } catch (exception) {
      print(exception);
      this.setState(() {
        applicationProblem = true;
      });
    }
  }

  Future<Uint8List> networkImageToBase64(String imageUrl) async {
    Response response = await get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    Color firstColor = HexColor("#FFFFFF");
    Color secondColor = HexColor("#FFFFFF");

    return Scaffold(
      backgroundColor: HexColor("#FFFFFF"),
      body: Column(children: [
        if (applicationProblem == true)
          Center(
              child: Padding(
                  padding: EdgeInsets.only(top: 200),
                  child: Column(
                    children: [
                      Container(
                          width: 110.0,
                          height: 110.0,
                          child: Image.asset(
                            UIImages.imageDir + "/maintenance.png",
                            color: Colors.black,
                            fit: BoxFit.contain,
                          )),
                      SizedBox(height: 70),
                      Text(
                        "System down for maintenance",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black),
                      ),
                      Text(
                        "We're sorry, our system is not avaible",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      )
                    ],
                  ))),
        if (applicationProblem == false)
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [
                  0,
                  1
                ],
                    colors: [
                  firstColor,
                  secondColor,
                ])),
            child: Loader(
              type: "Circle",
              color: HexColor("#000000"),
            ),
          )
      ]),
    );
  }
}
