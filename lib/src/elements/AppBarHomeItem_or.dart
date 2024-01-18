import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flyweb/i18n/AppLanguage.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/elements/WebViewElementState.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/models/navigationIcon.dart';
import 'package:flyweb/src/models/setting.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/pages/WebScreen.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:flyweb/src/themes/UIImages.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class AppBarHomeItem extends StatefulWidget implements PreferredSizeWidget {
  Settings settings;
  int currentIndex;
  List<GlobalKey<WebViewElementState>> listKey = [];
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  AppBarHomeItem(
      {Key? key,
      required this.settings,
      this.currentIndex = 0,
      required this.listKey,
      required this.scaffoldKey})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _AppBarHomeItem();
  }

  @override
  Size get preferredSize {
    return new Size.fromHeight(
        Setting.getValue(settings.setting!, "navigatin_bar_style") != "empty"
            ? double.tryParse(
                    Setting.getValue(settings.setting!, "height_header")) ??
                60
            : 0);
  }
}

class _AppBarHomeItem extends State<AppBarHomeItem> {
  bool goToWeb = true;

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeNotifier>(context);
    return (Setting.getValue(widget.settings.setting!, "navigatin_bar_style") !=
            "empty")
        ? AppBar(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _renderMenuIcon(
                      context,
                      widget.settings.leftNavigationIcon!,
                      widget.settings.rightNavigationIcon!,
                      Setting.getValue(
                          widget.settings.setting!, "navigatin_bar_style"),
                      widget.settings,
                      "left"),
                  _renderTitle(
                      Setting.getValue(
                          widget.settings.setting!, "navigatin_bar_style"),
                      widget.settings),
                  Row(
                      children: _renderMenuIconList(
                          context,
                          widget.settings.rightNavigationIconList!,
                          widget.settings.leftNavigationIcon!,
                          Setting.getValue(
                              widget.settings.setting!, "navigatin_bar_style"),
                          widget.settings,
                          "right")),
                ]),
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    themeProvider.isLightTheme
                        ? HexColor(Setting.getValue(
                            widget.settings.setting!, "firstColor"))
                        : themeProvider.darkTheme.primaryColor,
                    themeProvider.isLightTheme
                        ? HexColor(Setting.getValue(
                            widget.settings.setting!, "secondColor"))
                        : themeProvider.darkTheme.primaryColor,
                  ],
                ),
              ),
            ))
        : PreferredSize(
            preferredSize: Size(0.0, 0.0),
            child: Container(
              color: HexColor(
                  Setting.getValue(widget.settings.setting!, "secondColor")),
            ));
  }

  Widget _renderMenuIcon(
      BuildContext context,
      NavigationIcon navigationIcon,
      NavigationIcon navigationOtherIcon,
      String navigatinBarStyle,
      Settings settings,
      String direction) {
    var themeProvider = Provider.of<ThemeNotifier>(context);
    return navigationIcon.value != "icon_empty"
        ? Container(
            padding: direction == "right"
                ? new EdgeInsets.only(left: 0)
                : new EdgeInsets.only(right: 0),
            child: navigationIcon.value != "icon_back_forward"
                ? Row(children: <Widget>[
                    IconButton(
                      padding: const EdgeInsets.all(0.0),
                      icon: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi *
                              (I18n.current!.textDirection == TextDirection.ltr
                                  ? 2
                                  : 1)),
                          child: new Image.network(navigationIcon.iconUrl!,
                              height: 25,
                              width: 25,
                              color: HexColor(Setting.getValue(
                                  settings.setting!,
                                  themeProvider.isLightTheme
                                      ? "iconColor"
                                      : "iconColor_dark")))),
                      onPressed: () {
                        actionButtonMenu(navigationIcon, settings, context);
                      },
                    ),
                    Container(
                      width: (navigatinBarStyle == "center" &&
                              navigationOtherIcon.value == "icon_back_forward")
                          ? 50
                          : 0,
                    )
                  ])
                : Row(
                    children: <Widget>[
                      IconButton(
                        color: Colors.red,
                        padding: const EdgeInsets.all(0.0),
                        icon: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi *
                                (I18n.current!.textDirection ==
                                        TextDirection.ltr
                                    ? 2
                                    : 1)),
                            child: Image.asset(
                                UIImages.imageDir + "/icon_back.png",
                                height: 25,
                                width: 25,
                                color: Colors.white)),
                        onPressed: () {
                          getCurrentKey()!
                              .currentState!
                              .webViewController
                              ?.goBack();
                        },
                      ),
                      IconButton(
                        padding: const EdgeInsets.all(0.0),
                        icon: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi *
                                (I18n.current!.textDirection ==
                                        TextDirection.ltr
                                    ? 2
                                    : 1)),
                            child: Image.asset(
                                UIImages.imageDir + "/icon_forward.png",
                                height: 25,
                                width: 25,
                                color: Colors.white)),
                        onPressed: () {
                          getCurrentKey()!
                              .currentState!
                              .webViewController
                              ?.goForward();
                        },
                      ),
                    ],
                  ),
          )
        : Container(
            width: navigatinBarStyle == "center" ? 50 : 0,
          );
  }

  List<Widget> _renderMenuIconList(
      BuildContext context,
      List<NavigationIcon> navigationIcon,
      NavigationIcon navigationOtherIcon,
      String navigatinBarStyle,
      Settings settings,
      String direction) {
    return navigationIcon
        .map(
          (NavigationIcon navigationIcon) => _renderMenuIcon(
              context,
              navigationIcon,
              navigationOtherIcon,
              navigatinBarStyle,
              settings,
              direction),
        )
        .toList();
    ;
  }

  Widget _renderTitle(String type, Settings settings) {
    var direction = MainAxisAlignment.start;

    switch (type) {
      case "left":
        direction = MainAxisAlignment.start;
        break;
      case "right":
        direction = MainAxisAlignment.end;
        break;
      case "center":
        direction = MainAxisAlignment.center;
        break;
      default:
        direction = MainAxisAlignment.center;
    }

    return Expanded(
      child: Row(
        mainAxisAlignment: direction,
        children: [
          Flexible(
            child: Container(
              child: Setting.getValue(
                          widget.settings.setting!, "type_header") ==
                      "text"
                  ? Text(
                      renderLang("title"),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold),
                    )
                  : Setting.getValue(widget.settings.setting!, "type_header") ==
                          "image"
                      ? Image.network(
                          Setting.getValue(
                              widget.settings.setting!, "logo_header"),
                          height: 40)
                      : Container(),
            ),
          )
        ],
      ),
    );
  }

  actionButtonMenu(NavigationIcon navigationIcon, Settings settings,
      BuildContext context) async {
    if (navigationIcon.type == "url") {
      if (Setting.getValue(widget.settings.setting!, "tab_navigation_enable") ==
          "true") {
        /*if (goToWeb) {
          setState(() {
            goToWeb = false;
          });*/
        final result = await Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft,
                child: WebScreen(navigationIcon.url!, widget.settings)));
        /*setState(() {
            goToWeb = false;
          });
        }*/
      } else {
        widget.listKey[0].currentState!.webViewController?.loadUrl(
            urlRequest: URLRequest(url: Uri.parse(navigationIcon.url!)));
      }
    } else {
      switch (navigationIcon.value) {
        case "icon_menu":
          widget.scaffoldKey.currentState!.openDrawer();
          break;
        case "icon_home":
          if (Setting.getValue(
                  widget.settings.setting!, "tab_navigation_enable") ==
              "true") {
            /*if (goToWeb) {
              setState(() {
                goToWeb = false;
              });*/
            final result = Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: WebScreen(renderLang("url"), widget.settings)));
            /*setState(() {
                goToWeb = true;
              });
            }*/
          } else {
            widget.listKey[0].currentState!.webViewController?.loadUrl(
                urlRequest: URLRequest(url: Uri.parse(renderLang("url"))));
          }
          break;
        case "icon_reload":
          getCurrentKey()!.currentState!.webViewController?.reload();
          break;
        case "icon_share":
          shareApp(context, renderLang("title"),
              Setting.getValue(widget.settings.setting!, "share"));
          break;
        case "icon_back":
          getCurrentKey()!.currentState!.webViewController?.goBack();
          break;
        case "icon_forward":
          getCurrentKey()!.currentState!.webViewController?.goForward();
          break;
        case "icon_exit":
          _showDialog(context);
          break;
        case "icon_qrcode":
          scanQRCode();
          break;
        default:
          () {};
          break;
      }
    }
  }

  shareApp(BuildContext context, String text, String share) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    Share.share(share,
        subject: text,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  _showDialog(context) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text(I18n.current!.closeApp),
        content: new Text(I18n.current!.sureCloseApp),
        actions: <Widget>[
          new TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text(I18n.current!.cancel),
          ),
          SizedBox(height: 16),
          new TextButton(
            onPressed: () => exit(0),
            child: new Text(I18n.current!.ok),
          ),
        ],
      ),
    );
  }

  Future<void> scanQRCode() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );

      if (!mounted) return;
      setState(() {
        widget.listKey[0].currentState!.isLoading = true;
      });

      final response = await http.head(Uri.parse(qrCode));

      if (response.statusCode == 200) {
        setState(() {
          widget.listKey[0].currentState!.isLoading = false;
        });
        if (Setting.getValue(
                widget.settings.setting!, "tab_navigation_enable") ==
            "true") {
          /*if (goToWeb) {
            setState(() {
              goToWeb = false;
            });*/
          final result = await Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: WebScreen(qrCode, widget.settings)));

          /*setState(() {
              goToWeb = true;
            });
          }*/
        } else {
          widget.listKey[0].currentState!.webViewController
              ?.loadUrl(urlRequest: URLRequest(url: Uri.parse(qrCode)));
        }
      } else {
        setState(() {
          widget.listKey[0].currentState!.isLoading = false;
        });
      }
    } finally {
      setState(() {
        widget.listKey[0].currentState!.isLoading = false;
      });
      print('Failed to get platform version.');
    }
  }

  GlobalKey<WebViewElementState>? getCurrentKey() {
    switch (widget.currentIndex) {
      case 0:
        {
          return widget.listKey[0];
        }
        break;

      case 1:
        {
          return widget.listKey[1];
        }
        break;

      case 2:
        {
          return widget.listKey[2];
        }
        break;
      case 3:
        {
          return widget.listKey[3];
        }
        break;
      case 4:
        {
          return widget.listKey[4];
        }
        break;
      default:
        {
          return widget.listKey[0];
        }
        break;
    }
  }

  String renderLang(type) {
    var appLanguage = Provider.of<AppLanguage>(context, listen: false);
    var languageCode = appLanguage.appLocal.languageCode;
    if (widget.settings.translation[languageCode] != null) {
      if (widget.settings.translation[languageCode] != null)
        return widget.settings.translation[languageCode]![type]!;
    }
    return " ";
  }
}
