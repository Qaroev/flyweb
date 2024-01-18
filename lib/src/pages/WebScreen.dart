import 'package:flutter/material.dart';
import 'package:flyweb/src/elements/AppBarItem.dart';
import 'package:flyweb/src/elements/WebViewElement.dart';
import 'package:flyweb/src/elements/WebViewElementState.dart';
import 'package:flyweb/src/enum/connectivity_status.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/models/setting.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:provider/provider.dart';

class WebScreen extends StatefulWidget {
  final String url;
  final Settings settings;

  const WebScreen(this.url, this.settings);

  @override
  State<StatefulWidget> createState() {
    return new _WebScreen();
  }
}

class _WebScreen extends State<WebScreen> {
  static GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<WebViewElementState> keyWebView = GlobalKey();
  String? title = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    var bottomPadding = mediaQueryData.padding.bottom;
    var connectionStatus = Provider.of<ConnectivityStatus>(context);
    var themeProvider = Provider.of<ThemeNotifier>(context);

    return Container(
        decoration: BoxDecoration(color: HexColor("#f5f4f4")),
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBarItem(settings: widget.settings, title: title!),
            body: Stack(
              fit: StackFit.expand,
              children: [
                Column(children: [
                  Expanded(
                      child: WebViewElement(
                          key: keyWebView,
                          initialUrl: widget.url,
                          loader: Setting.getValue(
                              widget.settings.setting!, "loader"),
                          loaderColor: Setting.getValue(
                              widget.settings.setting!, "loaderColor"),
                          pullRefresh: Setting.getValue(
                              widget.settings.setting!, "pull_refresh"),
                          userAgent: widget.settings.userAgent,
                          customCss: Setting.getValue(
                              widget.settings.setting!, "customCss"),
                          customJavascript: Setting.getValue(
                              widget.settings.setting!, "customJavascript"),
                          nativeApplication: widget.settings.nativeApplication,
                          settings: widget.settings,
                          onLoadEnd: () => {
                                keyWebView.currentState!.webViewController!
                                    .getTitle()
                                    .then((String? result) {
                                  setState(() {
                                    title = result;
                                  });
                                })
                              }))
                ]),
              ],
            )));
  }
}
