import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
//flutter_downloader
//import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/elements/Loader.dart';
import 'package:flyweb/src/elements/WebViewElement.dart';
import 'package:flyweb/src/enum/connectivity_status.dart';
import 'package:flyweb/src/helpers/AdMobService.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/models/setting.dart';
import 'package:flyweb/src/pages/OfflineScreen.dart';
import 'package:flyweb/src/position/PositionOptions.dart';
import 'package:flyweb/src/position/PositionResponse.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:location/location.dart' as Location hide LocationAccuracy;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

//import 'package:location/location.dart' hide LocationAccuracy;
//import 'package:store_redirect/store_redirect.dart';

class WebViewElementState extends State<WebViewElement>
    with AutomaticKeepAliveClientMixin<WebViewElement>, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;
  final ChromeSafariBrowser browser = new MyChromeSafariBrowser();

  //final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  bool isLoading = true;
  String url = "";
  late PullToRefreshController pullToRefreshController;
  double progress = 0;
  final urlController = TextEditingController();

  // TODO: Add _bannerAd
  BannerAd? _bannerAd;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
          allowFileAccess: true,
          allowContentAccess: true),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  List<StreamSubscription<Position>> webViewGPSPositionStreams = [];

  bool isWasConnectionLoss = false;
  bool _permissionReady = false;
  bool mIsPermissionGrant = false;
  bool mIsLocationPermissionGrant = false;

  late var _localPath;
  ReceivePort _port = ReceivePort();

  final Set<Factory<OneSequenceGestureRecognizer>> _gSet = [
    Factory<VerticalDragGestureRecognizer>(
        () => VerticalDragGestureRecognizer()),
    Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
    Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
  ].toSet();

  @override
  void initState() {
    super.initState();

    _bindBackgroundIsolate();
    //flutter_downloader
    //FlutterDownloader.registerCallback(downloadCallback);

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );

    if (Setting.getValue(widget.settings.setting!, "ad_banner") == "true") {
      String bannerAdUnitId = Platform.isAndroid
          ? Setting.getValue(widget.settings.setting!, "admob_key_ad_banner")
          : Setting.getValue(
              widget.settings.setting!, "admob_key_ad_banner_ios");

      BannerAd(
        adUnitId: bannerAdUnitId,
        request: AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              _bannerAd = ad as BannerAd;
            });
          },
          onAdFailedToLoad: (ad, err) {
            print('Failed to load a banner ad: ${err.message}');
            ad.dispose();
          },
        ),
      ).load();
    }

    if (Setting.getValue(widget.settings.setting!, "ad_interstitial") ==
        "true") {
      String adInterstitialId = Platform.isAndroid
          ? Setting.getValue(
              widget.settings.setting!, "admob_key_ad_interstitial")
          : Setting.getValue(
              widget.settings.setting!, "admob_key_ad_interstitial_ios");

      AdMobService.interstitialAdId = adInterstitialId;

      AdMobService.createInterstitialAd();

      Timer.periodic(
          new Duration(
              seconds: int.parse(
                  Setting.getValue(widget.settings.setting!, "admob_dealy"))),
          (timer) {
        AdMobService.showInterstitialAd();
      });
    }
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
  }

  //flutter_downloader
  /*static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }*/

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    webViewGPSPositionStreams.forEach(
        (StreamSubscription<Position> _flutterGeolocationStream) =>
            _flutterGeolocationStream.cancel());
    super.dispose();
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  Future<bool> checkPermission() async {
    print("check permission");
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt! > 28) {
        await Permission.notification.isDenied.then((value) async {
          if (value) {
            await Permission.notification.request();
          }
        });
        return true;
      }

      final status = await Permission.storage.status;
      print("SSSSSSSSSSSSSSS"+status.toString());
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          mIsPermissionGrant = true;
          setState(() {});
          return true;
        }
      } else {
        return true;
      }
      return true;
    } else {
      return true;
    }
    return false;
  }

  Future<bool> _checkPermission() async {
    if (Platform.isIOS) {
      return true;
    }

    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt > 28) {
        return true;
      }

      final status = await Permission.storage.status;
      if (status == PermissionStatus.granted) {
        return true;
      }

      final result = await Permission.storage.request();
      return result == PermissionStatus.granted;
    }

    throw StateError('unknown platform');
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await _getSavedDir())!;
    final savedDir = Directory(_localPath);
    if (!savedDir.existsSync()) {
      await savedDir.create();
    }
  }

  Future<String?> _getSavedDir() async {
    String? externalStorageDirPath;

    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = await AndroidPathProvider.downloadsPath;
      } catch (err, st) {
        print('failed to get downloads path: $err, $st');

        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }
  //flutter_downloader
  /*
  Future<void> downloadFile(String url, [String? filename]) async {
    var hasStoragePermission = await Permission.storage.isGranted;
    if (!hasStoragePermission) {
      final status = await Permission.storage.request();
      hasStoragePermission = status.isGranted;
    }
    if (hasStoragePermission) {
      final taskId = await FlutterDownloader.enqueue(
          url: url,
          headers: {},
          // optional: header send with url (auth token etc)
          savedDir: (await getApplicationDocumentsDirectory()).absolute.path,
          saveInPublicStorage: true,
          fileName: filename);
    }
  }
   */

  bool contains(List<String> list, String item) {
    for (String i in list) {
      if (item.contains(i)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeNotifier>(context);

    var connectionStatus = Provider.of<ConnectivityStatus>(context);
    if (connectionStatus == ConnectivityStatus.Offline)
      return OfflineScreen(settings: widget.settings);

    return Stack(
      fit: StackFit.expand,
      children: [
        Column(children: [
          Expanded(
              child: InAppWebView(
                  initialUrlRequest:
                      URLRequest(url: Uri.parse(widget.initialUrl!)),
                  gestureRecognizers: _gSet,
                  initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                          supportZoom: false,
                          useShouldOverrideUrlLoading: true,
                          useOnDownloadStart: true,
                          mediaPlaybackRequiresUserGesture: false,
                          userAgent: Platform.isAndroid
                              ? widget.userAgent!.valueAndroid!
                              : widget.userAgent!.valueIOS!),
                      android: AndroidInAppWebViewOptions(
                        allowFileAccess: true,
                        allowContentAccess: true,
                        useHybridComposition: true,
                      ),
                      ios: IOSInAppWebViewOptions(
                        allowsInlineMediaPlayback: true,
                      )),
                  pullToRefreshController: widget.pullRefresh == "true"
                      ? pullToRefreshController
                      : null,
                  onLoadStart: (controller, url) {
                    setState(() {
                      this.url = url.toString();
                      isLoading = true;
                    });
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController.endRefreshing();
                    Future.delayed(const Duration(milliseconds: 500), () {
                      _geolocationAlertFix();
                    });

                    /** CSS and Javascript */
                    webViewController!.injectCSSCode(source: widget.customCss!);
                    webViewController!
                        .evaluateJavascript(source: widget.customJavascript!);

                    this.setState(() {
                      this.url = url.toString();
                      isLoading = false;
                    });
                    if (widget.onLoadEnd != null) {
                      widget.onLoadEnd!();
                    }
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {

                        return NavigationActionPolicy.ALLOW;
                    var uri = navigationAction.request.url;
                    var url = navigationAction.request.url.toString();
                    //log("URL" + url.toString());

                    if (Platform.isAndroid && url.contains("intent")) {
                      if (url.contains("maps")) {
                        var mNewURL = url.replaceAll("intent://", "https://");
                        if (await canLaunchUrl(Uri.parse(mNewURL))) {
                          await launchUrl(Uri.parse(mNewURL));
                          return NavigationActionPolicy.CANCEL;
                        }
                      } else {
                        String id = url.substring(
                            url.indexOf('id%3D') + 5, url.indexOf('#Intent'));
                        print(id);
                        //await StoreRedirect.redirect(androidAppId: id);
                        return NavigationActionPolicy.CANCEL;
                      }
                    } else if (contains(widget.nativeApplication!, url)) {
                      print(url);
                      //url = Uri.encodeFull(url);
                      try {
                        launchUrl(Uri.parse(url));
                        return NavigationActionPolicy.CANCEL;
                      } catch (e) {
                        //launchUrl(Uri.parse(url!));
                        return NavigationActionPolicy.CANCEL;
                      }
                    } else if (![
                      "http",
                      "https",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri!.scheme)) {
                      if (await canLaunchUrl(Uri.parse(url!))) {
                        await launchUrl(Uri.parse(url!));
                        return NavigationActionPolicy.CANCEL;
                      }
                    }
                    return NavigationActionPolicy.ALLOW;
                  },
                  onDownloadStartRequest: (controller, url) async {
                    //flutter_downloader
                    print("onDownloadStart");
                    print("URLLLLLSSSSSSSSS");
                    print(url.toString());

                    await browser.open(
                        url: Uri.parse(url.url.toString()),
                        options: ChromeSafariBrowserClassOptions(
                            android: AndroidChromeCustomTabsOptions(
                                shareState: CustomTabsShareState.SHARE_STATE_ON),
                            ios: IOSSafariOptions(barCollapsingEnabled: true)));

                    /*checkPermission().then((hasGranted) async {
                      try {
                        _permissionReady = hasGranted;
                        if (_permissionReady == true) {
                          if (Platform.isIOS) {
                            _localPath =
                            await getApplicationDocumentsDirectory();
                          } else {
                            try {
                              _localPath = await AndroidPathProvider.downloadsPath;
                            } catch (err, st) {
                              print('failed to get downloads path: $err, $st');
                              final directory = await getExternalStorageDirectory();
                              //_localPath = directory?.path;
                              _localPath = await AndroidPathProvider.downloadsPath;
                            }
                          }
                          final savedDir = Directory(_localPath);
                          bool hasExisted = await savedDir.exists();
                          if (!hasExisted) {
                            savedDir.create();
                          }

                          final taskId = await FlutterDownloader.enqueue(
                              url: url.url.toString(),
                              savedDir: _localPath,
                              showNotification: true,
                              // show download progress in status bar (for Android)
                              openFileFromNotification: false,
                              // click on notification to open downloaded file (for Android)
                              requiresStorageNotLow: true,//false
                              saveInPublicStorage: true);
                          final tasks = await FlutterDownloader.loadTasks();
                          print('tasks: $tasks');
                        }
                      } catch (error) {
                        print("error------");
                        print(error);
                      }
                    });*/
                    setState(() {
                      isLoading = false;
                    });
                  },
                  onLoadError: (controller, url, code, message) {
                    pullToRefreshController.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController.endRefreshing();
                    }
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    setState(() {
                      this.url = url.toString();
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    print(consoleMessage);
                  },
                  /*androidOnGeolocationPermissionsShowPrompt:
            (InAppWebViewController controller, String origin) async {
          print("androidOnGeolocationPermissionsShowPrompt");
          await Permission.location.request();
          return Future.value(GeolocationPermissionShowPromptResponse(
              origin: origin, allow: true, retain: true));
        },*/
                  androidOnPermissionRequest:
                      (InAppWebViewController controller, String origin,
                          List<String> resources) async {
                    print("androidOnPermissionRequest");
                    if (resources.length >= 1) {
                    } else {
                      resources.forEach((element) async {
                        if (element.contains("AUDIO_CAPTURE")) {
                          await Permission.microphone.request();
                        }
                        if (element.contains("VIDEO_CAPTURE")) {
                          await Permission.camera.request();
                        }
                      });
                    }
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  },
                  onWebViewCreated: (InAppWebViewController controller) {
                    controller.addJavaScriptHandler(
                        handlerName: '_flutterGeolocation',
                        callback: (args) {
                          dynamic geolocationData;
                          // try to decode json
                          try {
                            geolocationData = json.decode(args[0]);
                            //geolocationData = json.decode(args[0].message);
                          } catch (e) {
                            // empty or what ever
                            return;
                          }
                          // Get action from JSON
                          final String action = geolocationData['action'] ?? "";

                          switch (action) {
                            case "clearWatch":
                              _geolocationClearWatch(parseInt(
                                  geolocationData['flutterGeolocationIndex'] ??
                                      0)!);
                              break;

                            case "getCurrentPosition":
                              _geolocationGetCurrentPosition(
                                  parseInt(geolocationData[
                                          'flutterGeolocationIndex'] ??
                                      0)!,
                                  PositionOptions()
                                      .from(geolocationData['option'] ?? null));
                              break;

                            case "watchPosition":
                              _geolocationWatchPosition(
                                  parseInt(geolocationData[
                                          'flutterGeolocationIndex'] ??
                                      0)!,
                                  PositionOptions()
                                      .from(geolocationData['option'] ?? null));
                              break;
                            default:
                          }
                        });
                    webViewController = controller;
                  })),
          if (_bannerAd != null)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ]),
        (isLoading && widget.loader != "empty")
            ? Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                left: 0,
                child: Loader(
                    type: widget.loader!,
                    color: themeProvider.isLightTheme
                        ? HexColor(widget.loaderColor!)
                        : themeProvider.darkTheme.primaryColor))
            : Container()
      ],
    );
  }

  int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    return int.tryParse(value) ?? null;
  }

  Future<PositionResponse> getCurrentPosition(
      PositionOptions positionOptions) async {
    Location.Location location = new Location.Location();

    bool _serviceEnabled;
    Location.PermissionStatus _permissionGranted;
    Location.LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        //return;
      }
    }

    PositionResponse positionResponse = PositionResponse();

    int timeout = 30000;
    if (positionOptions.timeout > 0) timeout = positionOptions.timeout;

    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            // Permissions are denied, next time you could try
            // requesting permissions again (this is also where
            // Android's shouldShowRequestPermissionRationale
            // returned true. According to Android guidelines
            // your App should show an explanatory UI now.
            return Future.error('Location permissions are denied');
          }
        }

        if (permission == LocationPermission.deniedForever) {
          // Permissions are denied forever, handle appropriately.
          return Future.error(
              'Location permissions are permanently denied, we cannot request permissions.');
        }

        // When we reach here, permissions are granted and we can
        // continue accessing the position of the device.
        //positionResponse.position = await Geolocator.getCurrentPosition();

        positionResponse.position = await Future.any([
          Geolocator.getCurrentPosition(
              desiredAccuracy: (positionOptions.enableHighAccuracy
                  ? LocationAccuracy.best
                  : LocationAccuracy.medium)),
          Future.delayed(Duration(milliseconds: timeout), () {
            if (positionOptions.timeout > 0) positionResponse.timedOut = true;
            return Future.error(
                'Location permissions are permanently denied, we cannot request permissions.');
          })
        ]);
      } else {
        Location.Location location = new Location.Location();
        bool _serviceEnabled;

        _serviceEnabled = await location.serviceEnabled();
        if (!_serviceEnabled) {
          _serviceEnabled = await location.requestService();
          if (!_serviceEnabled) {}
        }
      }
    } catch (e) {
      Location.Location location = new Location.Location();
      bool _serviceEnabled;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {}
      }
    }

    return positionResponse;
  }

  void _geolocationAlertFix() {
    String javascript = '''
      var _flutterGeolocationIndex = 0;
      var _flutterGeolocationSuccess = [];
      var _flutterGeolocationError = [];
      function _flutterGeolocationAlertFix() {
        navigator.geolocation = {};
        navigator.geolocation.clearWatch = function(watchId) {
          _flutterGeolocation.postMessage(JSON.stringify({ action: 'clearWatch', flutterGeolocationIndex: watchId, option: {}}));
        };
        navigator.geolocation.getCurrentPosition = function(geolocationSuccess,geolocationError = null, geolocationOptionen = null) {
          _flutterGeolocationIndex++;
          _flutterGeolocationSuccess[_flutterGeolocationIndex] = geolocationSuccess;
          _flutterGeolocationError[_flutterGeolocationIndex] = geolocationError;
          _flutterGeolocation.postMessage(JSON.stringify({ action: 'getCurrentPosition', flutterGeolocationIndex: _flutterGeolocationIndex, option: geolocationOptionen}));
        };
        navigator.geolocation.watchPosition = function(geolocationSuccess,geolocationError = null, geolocationOptionen = {}) {
          _flutterGeolocationIndex++;
          _flutterGeolocationSuccess[_flutterGeolocationIndex] = geolocationSuccess;
          _flutterGeolocationError[_flutterGeolocationIndex] = geolocationError;
          _flutterGeolocation.postMessage(JSON.stringify({ action: 'watchPosition', flutterGeolocationIndex: _flutterGeolocationIndex, option: geolocationOptionen}));
          return _flutterGeolocationIndex;
        };
        return true;
      };
      setTimeout(function(){ _flutterGeolocationAlertFix(); }, 100);
    ''';

    webViewController!.evaluateJavascript(source: javascript);

    webViewController!.evaluateJavascript(source: """
      function _flutterGeolocationAlertFix() {
        navigator.geolocation = {};
        navigator.geolocation.clearWatch = function(watchId) {
  
  window.flutter_inappwebview.callHandler('_flutterGeolocation',      JSON.stringify({ action: 'clearWatch', flutterGeolocationIndex: watchId, option: {}})      ).then(function(result) {
      //alert(result);
    }); 
        };
        navigator.geolocation.getCurrentPosition = function(geolocationSuccess,geolocationError = null, geolocationOptionen = null) {
  
     _flutterGeolocationIndex++;
          _flutterGeolocationSuccess[_flutterGeolocationIndex] = geolocationSuccess;
          _flutterGeolocationError[_flutterGeolocationIndex] = geolocationError;
       
  window.flutter_inappwebview.callHandler('_flutterGeolocation',       JSON.stringify({ action: 'getCurrentPosition', flutterGeolocationIndex: _flutterGeolocationIndex, option: geolocationOptionen})      ).then(function(result) {
     });       
    
     };
        navigator.geolocation.watchPosition = function(geolocationSuccess,geolocationError = null, geolocationOptionen = {}) {
        
         _flutterGeolocationIndex++;
          _flutterGeolocationSuccess[_flutterGeolocationIndex] = geolocationSuccess;
          _flutterGeolocationError[_flutterGeolocationIndex] = geolocationError;
          
  window.flutter_inappwebview.callHandler('_flutterGeolocation',      JSON.stringify({ action: 'watchPosition', flutterGeolocationIndex: _flutterGeolocationIndex, option: geolocationOptionen})      ).then(function(result) {
     });    
          return _flutterGeolocationIndex;
        };
        return true;
    }
          setTimeout(function(){ _flutterGeolocationAlertFix(); }, 100);
  """);
  }

  void _geolocationClearWatch(int flutterGeolocationIndex) {
    // Stop gps position stream
    webViewGPSPositionStreams[flutterGeolocationIndex].cancel();

    // remove watcher from list
    webViewGPSPositionStreams.remove(flutterGeolocationIndex);

    // Remove functions from array
    String javascript = '''
      function _flutterGeolocationResponse() {
        _flutterGeolocationSuccess[''' +
        flutterGeolocationIndex.toString() +
        '''] = null;
        _flutterGeolocationError[''' +
        flutterGeolocationIndex.toString() +
        '''] = null;
        return true;
      };
      _flutterGeolocationResponse();
    ''';

    webViewController!.evaluateJavascript(source: javascript);
  }

  void _geolocationGetCurrentPosition(
      int flutterGeolocationIndex, PositionOptions positionOptions) async {
    PositionResponse positionResponse =
        await getCurrentPosition(positionOptions);

    _geolocationResponse(
        flutterGeolocationIndex, positionOptions, positionResponse, false);
  }

  void _geolocationResponse(
      int flutterGeolocationIndex,
      PositionOptions positionOptions,
      PositionResponse positionResponse,
      bool watcher) {
    if (positionResponse.position != null) {
      String javascript = '''
        function _flutterGeolocationResponse() {
          _flutterGeolocationSuccess[''' +
          flutterGeolocationIndex.toString() +
          ''']({
            coords: { 
              accuracy: ''' +
          positionResponse.position.accuracy.toString() +
          ''', 
              altitude: ''' +
          positionResponse.position.altitude.toString() +
          ''', 
              altitudeAccuracy: null, 
              heading: null, 
              latitude: ''' +
          positionResponse.position.latitude.toString() +
          ''', 
              longitude: ''' +
          positionResponse.position.longitude.toString() +
          ''', 
              speed: ''' +
          positionResponse.position.speed.toString() +
          ''' 
            }, 
            timestamp: ''' +
          positionResponse.position.timestamp!.millisecondsSinceEpoch
              .toString() +
          '''
          });''' +
          (!watcher
              ? "  _flutterGeolocationSuccess[" +
                  flutterGeolocationIndex.toString() +
                  "] = null; "
              : "") +
          (!watcher
              ? "  _flutterGeolocationError[" +
                  flutterGeolocationIndex.toString() +
                  "] = null; "
              : "") +
          '''
          return true;
        };
        _flutterGeolocationResponse();
      ''';

      webViewController!.evaluateJavascript(source: javascript);
    } else {
      // TODO: Return correct error code
      String javascript = '''
        function _flutterGeolocationResponse() {
          if (_flutterGeolocationError[''' +
          flutterGeolocationIndex.toString() +
          '''] != null) {''' +
          (positionResponse.timedOut
              ? "_flutterGeolocationError[" +
                  flutterGeolocationIndex.toString() +
                  "]({code: 3, message: 'Request timed out', PERMISSION_DENIED: 1, POSITION_UNAVAILABLE: 2, TIMEOUT: 3}); "
              : "_flutterGeolocationError[" +
                  flutterGeolocationIndex.toString() +
                  "]({code: 1, message: 'User denied Geolocationg', PERMISSION_DENIED: 1, POSITION_UNAVAILABLE: 2, TIMEOUT: 3}); ") +
          "}" +
          (!watcher
              ? "  _flutterGeolocationSuccess[" +
                  flutterGeolocationIndex.toString() +
                  "] = null; "
              : "") +
          (!watcher
              ? "  _flutterGeolocationError[" +
                  flutterGeolocationIndex.toString() +
                  "] = null; "
              : "") +
          '''
          return true;
        };
        _flutterGeolocationResponse();
      ''';

      webViewController!.evaluateJavascript(source: javascript);
    }
  }

  void _geolocationWatchPosition(
      int flutterGeolocationIndex, PositionOptions positionOptions) {
    // init new strem
    var geolocator = Geolocator();
    /*var locationOptions = LocationOptions(
        accuracy: (positionOptions.enableHighAccuracy
            ? LocationAccuracy.best
            : LocationAccuracy.medium),
        distanceFilter: 10);*/

    final LocationSettings locationSettings = LocationSettings(
      accuracy: (positionOptions.enableHighAccuracy
          ? LocationAccuracy.best
          : LocationAccuracy.medium),
      distanceFilter: 10,
    );
    webViewGPSPositionStreams[flutterGeolocationIndex] =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      // Send data to each warcher
      PositionResponse positionResponse = PositionResponse()
        ..position = position;
      _geolocationResponse(
          flutterGeolocationIndex, positionOptions, positionResponse, true);
    });
  }

  Future<bool?> goBack() async {
    if (webViewController != null) {
      if (await webViewController!.canGoBack()) {
        webViewController!.goBack();
        return false;
      } else {
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
    }
    return false;
  }

  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory!.path;
  }
}

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad() {
    print("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() {
    print("ChromeSafari browser closed");
  }
}