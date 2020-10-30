import 'package:flutter_google_ad_manager/flutter_google_ad_manager.dart';

class MyTestDevices extends TestDevices {
  static MyTestDevices _instance;

  factory MyTestDevices() {
    if (_instance == null) _instance = new MyTestDevices._internal();
    return _instance;
  }

  MyTestDevices._internal();

  @override
  // Set deviceIds here.
  List<String> get values => List()..add("15ede32ba338ae73")
                                ..add("6447074BF18586D178E7C687FE8CA5E8");
}
