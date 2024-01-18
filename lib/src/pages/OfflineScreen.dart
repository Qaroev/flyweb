import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/elements/RaisedGradientButton.dart';
import 'package:flyweb/src/enum/connectivity_status.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/models/setting.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:flyweb/src/themes/UIImages.dart';
import 'package:provider/provider.dart';

class OfflineScreen extends StatefulWidget {
  final Settings settings;

  const OfflineScreen({required this.settings});

  @override
  State<StatefulWidget> createState() {
    return new _OfflineScreen();
  }
}

class _OfflineScreen extends State<OfflineScreen> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    var bottomPadding = mediaQueryData.padding.bottom;
    var connectionStatus = Provider.of<ConnectivityStatus>(context);

    GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
    var themeProvider = Provider.of<ThemeNotifier>(context);

    return   Container(
          decoration: BoxDecoration(color: HexColor("#f5f4f4")),
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Scaffold(
            key: _scaffoldKey,
            body: Column(
              children: <Widget>[
                Container(
                  height: 80,
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          width: 100.0,
                          height: 100.0,
                          child: Image.asset(
                            UIImages.imageDir + "/wifi.png",
                            color: Colors.black26,
                            fit: BoxFit.contain,
                          )),
                      SizedBox(height: 40),
                      Text(
                        I18n.current!.whoops,
                        style: TextStyle(
                            color: Colors.black45,
                            fontSize: 40.0,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Text(
                        I18n.current!.noInternet,
                        style: TextStyle(color: Colors.black87, fontSize: 15.0),
                      ),
                      SizedBox(height: 5),
                      SizedBox(height: 60),
                      RaisedGradientButton(
                          child: Text(
                            I18n.current!.tryAgain,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                          width: 250,
                          gradient: LinearGradient(
                            colors: <Color>[
                              HexColor(Setting.getValue(
                                  widget.settings.setting!, "secondColor")),
                              HexColor(Setting.getValue(
                                  widget.settings.setting!, "firstColor"))
                            ],
                          ),
                          onPressed: () {}),
                    ]),
              ],
            ),
          ),
    );
  }

}
