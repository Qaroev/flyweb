import 'package:geolocator/geolocator.dart';

class PositionResponse {
  late Position position;
  bool timedOut = false;
}