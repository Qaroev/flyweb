import 'dart:async';

import 'package:flutter/services.dart';

abstract class Deeplink {
  void dispose();
}

class DeepLinkBloc extends Deeplink {

  //Event Channel creation
  static const stream = const EventChannel('app.flyweb.scheme');

  //Method channel creation
  static const platform = const MethodChannel('app.flyweb.scheme');

  StreamController<String> _stateController = StreamController();

  Stream<String> get state => _stateController.stream;

  Sink<String> get stateSink => _stateController.sink;


  //Adding the listener into contructor
  DeepLinkBloc() {
    //Checking application start by deep link
    startUri().then(_onRedirected);
    //Checking broadcast stream, if deep link was clicked in opened appication
    //stream.receiveBroadcastStream().listen((d) => _onRedirected(d));
  }


  _onRedirected(String uri) {
    // Here can be any uri analysis, checking tokens etc, if it’s necessary
    // Throw deep link URI into the BloC's stream
    stateSink.add(uri);
  }


  @override
  void dispose() {
    _stateController.close();
  }


  Future<String> startUri() async {
    try {
      return " ";
     // return platform.invokeMethod('initialLink');
    } on PlatformException catch (e) {
      return "Failed to Invoke: '${e.message}'.";
    }
  }
}