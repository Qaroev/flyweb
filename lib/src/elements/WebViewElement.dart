import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flyweb/src/elements/WebViewElementState.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/models/userAgent.dart';
//import 'package:store_redirect/store_redirect.dart';

class WebViewElement extends StatefulWidget {
  String? initialUrl;
  String? loader;
  String? loaderColor;
  String? pullRefresh = "true";
  UserAgent? userAgent;
  String? customCss;
  String? customJavascript;
  List<String>? nativeApplication = [];
  Settings settings;
  void Function()? onLoadEnd = ()=>{};

  WebViewElement(
      {Key? key,
      this.initialUrl,
      this.loader,
      this.loaderColor,
      this.pullRefresh,
      this.userAgent,
      this.customCss,
      this.customJavascript,
      this.nativeApplication,
      required this.settings,
      this.onLoadEnd})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => WebViewElementState();
}
