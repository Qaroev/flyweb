import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flyweb/i18n/AppLanguage.dart';
import 'package:flyweb/src/elements/AppBarHomeItem.dart';
import 'package:flyweb/src/elements/FloatingButton.dart';
import 'package:flyweb/src/elements/SideMenuElement.dart';
import 'package:flyweb/src/elements/TabNavigationMenu.dart';
import 'package:flyweb/src/elements/WebViewElement.dart';
import 'package:flyweb/src/elements/WebViewElementState.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/helpers/OneSignalHelper.dart';
import 'package:flyweb/src/models/setting.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/pages/WebScreen.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:flyweb/src/helpers/Deeplink.dart';

//import 'package:uni_links/uni_links.dart';
import 'package:app_links/app_links.dart';

GlobalKey<WebViewElementState> key0 = GlobalKey();
GlobalKey<WebViewElementState> key1 = GlobalKey();
GlobalKey<WebViewElementState> key2 = GlobalKey();
GlobalKey<WebViewElementState> key3 = GlobalKey();
GlobalKey<WebViewElementState> key4 = GlobalKey();
GlobalKey<WebViewElementState> keyMain = GlobalKey();
GlobalKey<WebViewElementState> keyWebView = GlobalKey();
List<GlobalKey<WebViewElementState>> listKey = [key0, key1, key2, key3, key4];

StreamController<int> _controllerStream0 = StreamController<int>();
StreamController<int> _controllerStream1 = StreamController<int>();
StreamController<int> _controllerStream2 = StreamController<int>();
StreamController<int> _controllerStream3 = StreamController<int>();
StreamController<int> _controllerStream4 = StreamController<int>();
List<StreamController<int>> listStream = [
  _controllerStream0,
  _controllerStream1,
  _controllerStream2,
  _controllerStream3,
  _controllerStream4
];

class HomeScreen extends StatefulWidget {
  final String url;
  final Settings settings;

  const HomeScreen(this.url, this.settings);

  @override
  State<StatefulWidget> createState() {
    return new _HomeScreen();
  }
}

class _HomeScreen extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController tabController;
  int _currentIndex = 0;
  static GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //late StreamSubscription _linkSubscription;
  bool goToWeb = true;
  var appLanguage;
  String url = "";

  /** deeplink */
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeeplink();
    tabController = new TabController(
        initialIndex: 0,
        length: Setting.getValue(
                    widget.settings.setting!, "tab_navigation_enable") ==
                "true"
            ? widget.settings.tab!.length
            : 1,
        vsync: this);
    tabController.addListener(_handleTabSelection);

    //_handleIncomingLinks();
  }

  @override
  void didChangeDependencies() {
    var appLanguage = Provider.of<AppLanguage>(context);
    appLanguage.addListener(() {
      changeLanguageListener(appLanguage);
    });

    super.didChangeDependencies();
  }

  void changeLanguageListener(listener) {
    if (Setting.getValue(widget.settings.setting!, "tab_navigation_enable") ==
        "true") {
      List.generate(widget.settings.tab!.length, (index) {
        getKeyByIndex(index).currentState!.webViewController?.loadUrl(
            urlRequest: URLRequest(
                url: Uri.parse(
                    renderTabUrl(index, listener!.appLocal!.languageCode))));
      });
    }
  }

  Future<ValueChanged<String?>?> roloadWebUrl(value) async {
    int index = int.parse(value.split("#")[0]);
    String local_language = value.split("#")[1];

    Uri? url =
        await getKeyByIndex(index).currentState!.webViewController?.getUrl();
    if (renderTabUrl(index, local_language) != url.toString()) {
      getKeyByIndex(index).currentState!.webViewController?.loadUrl(
          urlRequest:
              URLRequest(url: Uri.parse(renderTabUrl(index, local_language))));
    } else {
      getKeyByIndex(index).currentState!.webViewController?.reload();
    }
  }

  Future<void> _initDeeplink() async {
    print('GO TO Deeplink 0:');
    _appLinks = AppLinks();
    final appLink = await _appLinks.getInitialAppLink();

    if (appLink != null) {
      print('getInitialAppLink: $appLink');
    }

    _appLinks.uriLinkStream.listen((uri) async {
      print('GO TO Deeplink 1: $uri');
      if (!mounted) return;
      print('get uri 1: $uri');
      /*setState(() {
          _latestUri = uri;
        });*/
      var link = uri.toString().replaceAll(
          //'${GlobalConfiguration().getValue('deeplink')}://url/',
          '${Setting.getValue(widget.settings.setting!, "deeplink")}://url/',
          '');
      /* _webViewController?.loadUrl(
            urlRequest: URLRequest(url: Uri.parse(link)));*/

      if (Setting.getValue(widget.settings.setting!, "tab_navigation_enable") ==
          "true") {
        print('GO TO Deeplink 2: $uri');
        if (goToWeb) {
          setState(() {
            goToWeb = false;
          });
          final result = await Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: WebScreen(link, widget.settings)));
          setState(() {
            goToWeb = true;
          });
        } else {
          key0.currentState!.webViewController
              ?.loadUrl(urlRequest: URLRequest(url: Uri.parse(link)));
        }
      } else {
        print('GO TO Deeplink 3: $uri');
        key0.currentState!.webViewController
            ?.loadUrl(urlRequest: URLRequest(url: Uri.parse(link)));
      }
    }, onError: (Object err) {
      if (!mounted) return;
      print('got err: $err');
    });
  }

  /*
  void _handleIncomingLinks() {
    print('get uri :');
    _linkSubscription = uriLinkStream.listen((Uri? uri) async {
      if (!mounted) return;
      print('get uri 1: $uri');
      /*setState(() {
          _latestUri = uri;
        });*/
      var link = uri.toString().replaceAll(
          //'${GlobalConfiguration().getValue('deeplink')}://url/',
          '${Setting.getValue(widget.settings.setting!, "deeplink")}://url/',
          '');
      /* _webViewController?.loadUrl(
            urlRequest: URLRequest(url: Uri.parse(link)));*/

      if (Setting.getValue(widget.settings.setting!, "tab_navigation_enable") ==
          "true") {
        if (goToWeb) {
          setState(() {
            goToWeb = false;
          });
          final result = await Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: WebScreen(link, widget.settings)));
          setState(() {
            goToWeb = true;
          });
        } else {
          key0.currentState!.webViewController
              ?.loadUrl(urlRequest: URLRequest(url: Uri.parse(link)));
        }
      }
    }, onError: (Object err) {
      if (!mounted) return;
      print('got err: $err');
      /*setState(() {
          _latestUri = null;
        });*/
    });
  }
  */

  _handleTabSelection() {
    setState(() {
      _currentIndex = tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    var bottomPadding = mediaQueryData.padding.bottom;

    var appLanguage = Provider.of<AppLanguage>(context);
    var languageCode = appLanguage.appLocal.languageCode;

    final _oneSignalHelper = OneSignalHelper();
    Future<void> _listenerOneSignal() async {
      if (_oneSignalHelper.url! != null && _oneSignalHelper.url! != "") {
        if (Setting.getValue(
                widget.settings.setting!, "tab_navigation_enable") ==
            "true") {
          if (goToWeb) {
            setState(() {
              goToWeb = false;
            });
            final result = await Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: WebScreen(_oneSignalHelper.url!, widget.settings)));

            setState(() {
              goToWeb = true;
            });
          }
        } else {
          key0.currentState?.webViewController?.loadUrl(
              urlRequest: URLRequest(url: Uri.parse(_oneSignalHelper.url!)));
        }
      }
    }

    _oneSignalHelper.addListener(_listenerOneSignal);

    return WillPopScope(
        onWillPop: () async {
          getCurrentKey().currentState!.goBack();
          return false;
        },
        child: Container(
            decoration: BoxDecoration(color: HexColor("#f5f4f4")),
            //padding: EdgeInsets.only(bottom: bottomPadding),
            child: Scaffold(
              key: _scaffoldKey,
              appBar: AppBarHomeItem(
                  settings: widget.settings,
                  currentIndex: _currentIndex,
                  listKey: listKey,
                  scaffoldKey: _scaffoldKey),
              drawer:
                  ((widget.settings.leftNavigationIcon!.value == "icon_menu" ||
                              widget.settings.rightNavigationIcon!.value ==
                                  "icon_menu") &&
                          (Setting.getValue(widget.settings.setting!,
                                  "navigatin_bar_style") !=
                              "empty"))
                      ? SideMenuElement(settings: widget.settings, key0: key0)
                      : null,
              body: Stack(fit: StackFit.expand, children: [
                Column(children: [
                  if (Setting.getValue(
                          widget.settings.setting!, "tab_position") ==
                      "top")
                    TabNavigationMenu(
                        settings: widget.settings,
                        listStream: listStream,
                        tabController: tabController,
                        currentIndex: _currentIndex,
                        roloadWebUrl: roloadWebUrl),
                  //Text(Setting.getValue(widget.settings.setting!, "tab_position")),
                  Expanded(
                    child: Setting.getValue(widget.settings.setting!,
                                "tab_navigation_enable") ==
                            "true"
                        ? TabBarView(
                            controller: tabController,
                            physics: NeverScrollableScrollPhysics(),
                            children: List.generate(widget.settings.tab!.length,
                                (index) {
                              return WebViewElement(
                                  key: listKey[index],
                                  initialUrl: renderTabUrl(index, languageCode),
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
                                      widget.settings.setting!,
                                      "customJavascript"),
                                  nativeApplication:
                                      widget.settings.nativeApplication,
                                  settings: widget.settings);
                            }),
                          )
                        : TabBarView(
                            controller: tabController,
                            physics: NeverScrollableScrollPhysics(),
                            children: List.generate(1, (index) {
                              return WebViewElement(
                                  key: listKey[0],
                                  initialUrl: renderLang("url", languageCode),
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
                                      widget.settings.setting!,
                                      "customJavascript"),
                                  nativeApplication:
                                      widget.settings.nativeApplication,
                                  settings: widget.settings);
                            }),
                          ),
                  )
                ])
              ]),
              bottomNavigationBar:
                  Setting.getValue(widget.settings.setting!, "tab_position") ==
                          "bottom"
                      ? TabNavigationMenu(
                          settings: widget.settings,
                          listStream: listStream,
                          tabController: tabController,
                          currentIndex: _currentIndex,
                          roloadWebUrl: roloadWebUrl)
                      : null,
              floatingActionButton:
                  FloatingButton(settings: widget.settings, key0: key0),
            )));
  }

  String renderTabUrl(index, languageCode) {
    if (widget.settings.tab![index] != null) {
      if (widget.settings.tab![index].translation[languageCode] != null) {
        return widget.settings.tab![index].translation[languageCode]!["url"]!;
      }
    }
    return "";
  }

  GlobalKey<WebViewElementState> getCurrentKey() {
    switch (_currentIndex) {
      case 0:
        {
          return key0;
        }
      case 1:
        {
          return key1;
        }

      case 2:
        {
          return key2;
        }
      case 3:
        {
          return key3;
        }
      case 4:
        {
          return key4;
        }
      default:
        {
          return key0;
        }
    }
  }

  GlobalKey<WebViewElementState> getKeyByIndex(index) {
    switch (index) {
      case 0:
        {
          return key0;
        }

      case 1:
        {
          return key1;
        }

      case 2:
        {
          return key2;
        }
      case 3:
        {
          return key3;
        }
      case 4:
        {
          return key4;
        }
      default:
        {
          return key0;
        }
    }
  }

  String renderLang(type, languageCode) {
    if (widget.settings.translation[languageCode] != null) {
      if (widget.settings.translation[languageCode] != null) {
        return widget.settings.translation[languageCode]![type]!;
      }
    }
    return " ";
  }
}
