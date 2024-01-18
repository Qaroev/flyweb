import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flyweb/i18n/AppLanguage.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/elements/AppBarItem.dart';
import 'package:flyweb/src/elements/SocialItem.dart';
import 'package:flyweb/src/models/setting.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/models/social.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  final Settings settings;

  const AboutScreen(this.settings);

  @override
  State<StatefulWidget> createState() => _AboutScreen();
}

class _AboutScreen extends State<AboutScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: '',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      appBar: AppBarItem(settings: widget.settings, title: I18n.current!.about),
      body: ListView(
        children: <Widget>[
          /*
          Padding(
            padding: EdgeInsets.only(left: 0, top: 80, right: 0, bottom: 10),
            child: Center(
                child: Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                //color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(100),
                    topRight: Radius.circular(100),
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 3,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                  padding: EdgeInsets.all(13),
                  child: Image.network(Setting.getValue(
                      widget.settings.setting!, "logo_header"))),
            )),
          ),
          */
          /*Padding(
            padding: EdgeInsets.only(left: 0, top: 10, right: 0, bottom: 10),
            child: Center(
                child: Text(
              renderLang("title"),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
          ),
          Text(
            "v " + _packageInfo.version,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
          ),
          */
          Padding(
            padding: EdgeInsets.only(left: 20, top: 40, right: 20, bottom: 10),
            child: Center(
                child: Text(
              renderDescription(),
              //textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
            )),
          ),
          SizedBox(height: 40),
          Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                I18n.current!.follow_us,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )),
          Padding(
            padding: EdgeInsets.only(left: 50, right:50),
            child: _renderSocialList(widget.settings.socials!, context),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _renderSocialList(List<Social> socials, context) {
    return new Wrap(
      spacing: 20.0,
      runSpacing: 30,
      alignment: WrapAlignment.center,
      children: socials
          .map(
            (Social social) => SocialItem(
                icon_url: social.iconUrl!,
                text: I18n.current!.social(social.title!),
                onTap: () async {
                  if (await canLaunch(
                      social.linkUrl!.replaceAll("id_app", social.idApp!))) {
                    await launch(
                        social.linkUrl!.replaceAll("id_app", social.idApp!));
                  } else {
                    launch(social.url!.replaceAll("id_app", social.idApp!));
                  }
                }),
          )
          .toList(),
    );
  }

  String renderDescription() {
    var appLanguage = Provider.of<AppLanguage>(context);
    var languageCode = appLanguage.appLocal.languageCode;
    if (widget.settings.about != null) {
      if (widget.settings.about![0].translation[languageCode] != null)
        return widget
            .settings.about![0].translation[languageCode]!["description"]!;
    }
    return " ";
  }

  String renderLang(type) {
    var appLanguage = Provider.of<AppLanguage>(context);
    var languageCode = appLanguage.appLocal.languageCode;
    if (widget.settings.translation[languageCode] != null) {
      if (widget.settings.translation[languageCode] != null)
        return widget.settings.translation[languageCode]![type]!;
    }
    return " ";
  }
}
