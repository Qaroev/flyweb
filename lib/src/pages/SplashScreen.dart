import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flyweb/i18n/AppLanguage.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/data/config.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/helpers/SharedPref.dart';
import 'package:flyweb/src/models/setting.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/pages/HomeScreen.dart';
import 'package:flyweb/src/pages/OnBoardingScreen.dart';
import 'package:flyweb/src/repository/settings_service.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

//import 'package:uni_links/uni_links.dart';

class SplashScreen extends StatefulWidget {
  final Settings settings;
  final Uint8List bytesImgSplashBase64;
  final Uint8List byteslogoSplashBase64;

  SplashScreen(
      {required this.settings,
      required this.bytesImgSplashBase64,
      required this.byteslogoSplashBase64});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _SplashScreen(settings: this.settings);
  }
}

class _SplashScreen extends State<SplashScreen> {
  final SettingsService settingsService = SettingsService();
  SharedPref sharedPref = SharedPref();
  String url = "";
  String onesignalUrl = "";
  Settings settings = new Settings();
  bool applicationProblem = false;
  bool goBoarding = false;

  _SplashScreen({required this.settings});

  @override
  void initState() {
    super.initState();
    Timer.run(() {
      initSetting();
    });
    loadBoarding();
    initOneSignal();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initSetting() async {
    try {
      Settings _settings = await settingsService.getSettings();

      setState(() {
        settings = _settings;
      });

      AppLanguage appLanguage = AppLanguage();
      appLanguage.changeLanguageCode(
          Setting.getValue(_settings.setting!, "default_language_code"));

      I18n.refreshI18n(_settings);

      var themeProvider = Provider.of<ThemeNotifier>(context, listen: false);
      themeProvider
          .setFont(Setting.getValue(_settings.setting!, "google_font"));

      _mockCheckForSession().then((status) {
        var future = new Future.delayed(
            const Duration(milliseconds: 150), _navigateToHome);
      });
    } on Exception catch (exception) {
      setState(() {
        applicationProblem = true;
      });
    } catch (Excepetion) {
      setState(() {
        applicationProblem = true;
      });
    }
  }

  Future<void> initOneSignal() async {
    if (!mounted) return;
/*
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setRequiresUserPrivacyConsent(true);

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
       setState(() {});
    });

    OneSignal.shared
        .setInAppMessageClickedHandler((OSInAppMessageAction action) {
       setState(() {});
    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {});

    OneSignal.shared
        .setPermissionObserver((OSPermissionStateChanges changes) {});

    OneSignal.shared.setEmailSubscriptionObserver(
        (OSEmailSubscriptionStateChanges changes) {});

    // NOTE: Replace with your own app ID from https://www.onesignal.com
    await OneSignal.shared
        .setAppId(Setting.getValue(settings.setting!, "onesignal_id"));

    bool requiresConsent = await OneSignal.shared.requiresUserPrivacyConsent();

    OneSignal.shared.consentGranted(true);
    // The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    });
    */

    OneSignal.initialize(Setting.getValue(settings.setting!, "onesignal_id"));
    await Future.delayed(const Duration(
        milliseconds:
            1000)); // This must be added to ensure that initialize has been complete because initialize is not a future

    final permission = await OneSignal.Notifications
        .permissionNative(); // This will works ONLY if initialize is really initialized
    print(permission);
    final isGranted = await OneSignal.Notifications.requestPermission(
        true); // If permission is already granted this never ever complete even initialize is really initialized
    print(isGranted);
  }

  Future loadBoarding() async {
    try {
      var res = await sharedPref.read("boarding");
      if (res == null) {
        setState(() {
          goBoarding = true;
        });
      }
    } on Exception catch (exception) {
      setState(() {
        goBoarding = true;
      });
    } catch (Excepetion) {
      setState(() {
        goBoarding = true;
      });
    }
  }

  Future<bool> _mockCheckForSession() async {
    await Future.delayed(Duration(milliseconds: 3000), () {});
    return true;
  }

  Future<String?> networkImageToBase64(String imageUrl) async {
    Response response = await get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;
    return (bytes != null ? base64Encode(bytes) : null);
  }

  void _navigateToHome() {
    if (goBoarding &&
        Setting.getValue(settings.setting!, "boarding") == "true") {
      sharedPref.save("boarding", "true");
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => OnBoardingScreen(
              onesignalUrl != "" ? onesignalUrl : url, settings)));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) =>
              HomeScreen(onesignalUrl != "" ? onesignalUrl : url, settings)));
    }
  }

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    Color firstColor = (settings != null &&
            settings.splash != null &&
            settings.splash!.enable_img == "1")
        ? HexColor("#FFFFFF")
        : (settings.splash != null &&
                settings.splash!.firstColor != null &&
                settings.splash!.firstColor != "")
            ? HexColor(settings.splash!.firstColor!)
            : HexColor("#FFFFFF");

    Color secondColor = (settings != null &&
            settings.splash != null &&
            settings.splash!.enable_img == "1")
        ? HexColor("#FFFFFF")
        : (settings.splash != null &&
                settings.splash!.secondColor != null &&
                settings.splash!.secondColor != "")
            ? HexColor(settings.splash!.secondColor!)
            : HexColor("#FFFFFF");
    // TODO: implement build
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
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
          ),
          (settings.splash != null &&
                  settings.splash!.enable_img != null &&
                  settings.splash!.enable_img == "1")
              ? Positioned(
                  top: 0,
                  right: 0,
                  child: Image.memory(
                    widget.bytesImgSplashBase64,
                    fit: BoxFit.cover,
                    height: height,
                    width: width,
                    alignment: Alignment.center,
                  ))
              : Container(),
          (settings.splash != null && settings.splash!.enable_logo != null)
              ? settings.splash!.enable_logo == "1"
                  ? Align(
                      alignment: Alignment.center,
                      child: Image.memory(widget.byteslogoSplashBase64,
                          height: 150, width: 150),
                    )
                  : Container()
              : Align(alignment: Alignment.center, child: Config.logo),
          (applicationProblem == true)
              ? Positioned(
                  bottom: 160,
                  right: 0,
                  left: 0,
                  child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Column(
                        children: [
                          Text(
                            "System down for maintenance",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white),
                          ),
                          Text(
                            "We're sorry, our system is not avaible",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          )
                        ],
                      )))
              : Container()
        ],
      ),
    );
  }
}
