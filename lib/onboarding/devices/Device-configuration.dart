import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:reedling/onboarding.dart';
import 'package:reedling/onboarding/save-home-wifi-crendentials.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:wifi/wifi.dart';

import '../../dashboard_screen.dart';
import '../show-error.dart';
//import 'package:wifi_iot/wifi_iot.dart';

import 'package:percent_indicator/percent_indicator.dart';

class DevicesConfiguration extends StatefulWidget {
  // store connected device SSID
  final String connectedDeviceSsid;

  //Store connected Device Ip
  String ip;

  //Store connected device mac
  String mac;

  // Display only received gangs to user
  int totalGangsNumber;

  DevicesConfiguration(this.connectedDeviceSsid, this.totalGangsNumber);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DevicesConfiguration();
  }
}

class ArbitrarySuggestionType {
  //For the mock data type we will use review (perhaps this could represent a restaurant);
  num stars;
  String name, imgURL;

  ArbitrarySuggestionType(this.stars, this.name, this.imgURL);
}

class _DevicesConfiguration extends State<DevicesConfiguration> {
  ArbitrarySuggestionType selected;

  final GlobalKey<FormState> _gangForm = GlobalKey<FormState>();

  TextEditingController _applianceSwapController = TextEditingController();
  final TextEditingController _firstApplianceController =
      TextEditingController();
  final TextEditingController _secondApplianceController =
      TextEditingController();
  final TextEditingController _thirdApplianceController =
      TextEditingController();
  final TextEditingController _fourthApplianceController =
      TextEditingController();

  String _homeNetworkSsid = '';
  String _homePassword = '';
  String _hostIp = '192.168.4.1';
  bool _loader = true;
  var _connection;
  var resp;
  double percentage = 0.0;
  double percentageTextRepresentation = 0.0;
  double maxPercentage = 0.9;
  Timer initialTimer;
  bool connected = false;
  List gangErrors = [];
  dynamic response1;
  int _verifyConnectivityRequestAttempts = 0;
  bool isGangConfigure = false;
  Map _deviceData = {};

  // json object would sent to hardware device to leave AP mode
  Map _restartDevice = {'status': 'restart'};

  List<Map<dynamic, dynamic>> dropdownItems;

  Future _leaveApModeRequest(Map deviceData) async {
    try {
      String currentWiFiName = await Wifi.ssid;
      print("Current WiFi is:\t" + currentWiFiName);

      var bytes = utf8.encode(currentWiFiName);
      var digest = sha1.convert(bytes).toString();

      Map data = {
        "authKey": digest,
      };

      final http.Response response = await http.post(
          'http://$_hostIp/api/v1/actions/restart',
          body: json.encode(data));
      print(response.body);
    } catch (e) {
      print('exception at ap mode');
    }
  }

  @override
  void initState() {
    print("\n\n\ndevice configuration");
    super.initState();
    calculatePercentAfterDelay();
    _sendCredentials();
  }

  calculatePercentAfterDelay() {
    const duration = const Duration(milliseconds: 200);
    initialTimer =
        new Timer.periodic(duration, (Timer t) => calculatePercentage());
  }

  afterErrorCalculatePercentAfterDelay() {
    const duration = const Duration(milliseconds: 172);
    initialTimer =
        new Timer.periodic(duration, (Timer t) => calculatePercentage());
  }

  calculatePercentage() {
    if (percentage <= maxPercentage) {
      setState(() {
        percentage = percentage + 0.01;
        percentageTextRepresentation = percentageTextRepresentation + 1;
      });
    }
  }

  void bottomSheet() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                decoration:
                    BoxDecoration(color: Color(0xffffffff).withOpacity(0.4)),
                child: Text(
                  'Kindly follow below steps to  Device configure ',
                  style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: 1.0,
                            color: Color(0xffcccccc).withOpacity(0.7))),
                    color: Color(0xffffffff).withOpacity(0.4)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '1- ',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                        child: Text(
                      'Select your room where you want to add device.',
                      softWrap: true,
                    ))
                  ],
                ),
              ),
              SizedBox(
                height: 2.0,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: 1.0,
                            color: Color(0xffcccccc).withOpacity(0.7))),
                    color: Color(0xffffffff).withOpacity(0.4)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '2- ',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                        child: Text(
                      'Tap circle button to configure appliance.',
                      softWrap: true,
                    ))
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: 1.0,
                            color: Color(0xffcccccc).withOpacity(0.7))),
                    color: Color(0xffffffff).withOpacity(0.4)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '3- ',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                        child: Text(
                      'Enter you appliance name.',
                      softWrap: true,
                    ))
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: 1.0,
                            color: Color(0xffcccccc).withOpacity(0.7))),
                    color: Color(0xffffffff).withOpacity(0.4)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '4- ',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                        child: Text(
                      'If you have more than 1 appliance then follow the 2,3 steps again.',
                      softWrap: true,
                    ))
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: 1.0,
                            color: Color(0xffcccccc).withOpacity(0.7))),
                    color: Color(0xffffffff).withOpacity(0.4)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '5- ',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                        child: Text(
                      'Tap proceed button to complete the process.',
                      softWrap: true,
                    ))
                  ],
                ),
              ),
            ],
          );
        });
  }

  startTimeOutForDelayRequest() {
    var duration = const Duration(seconds: 5);
    return new Timer(duration, _sendCredentials);
  }

  checkNetwork() async {
    setState(() {
      percentage = 0.0;
      percentageTextRepresentation = 0.0;
    });
    afterErrorCalculatePercentAfterDelay();
    String _name;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _name = _deviceData['homeWifi'] = prefs.getString('wifi_ssid');
    _deviceData['password'] = prefs.getString('wifi_password');
    _deviceData["serverAddress"] = "event-hub.dev.onstak.io";
    print(_name);
    print(_deviceData['password']);
    String currentWiFiName = await Wifi.ssid;
    print("Current WiFi is:\t" + currentWiFiName);

    var bytes = utf8.encode(currentWiFiName);
    var digest = sha1.convert(bytes).toString();

    Map data = {
      "authKey": digest,
    };
    try {
      List<String> string;
      String ip = await Wifi.ip;
      string = ip.split('.');
      ip = '${string[0]}.${string[1]}.${string[2]}.1';
      print(ip);
      try {
        /*
        * Asking hardware device to start communication
         */
        print("aiwe aiwe");
        final http.Response networkResponse =
            await http.post('http://$ip/api/v1/check/network', body: data);
        Map result = new Map();
        result = json.decode(networkResponse.body);

        if (result["status"] == "success") {
          print('into success');

          startTimeOutForDelayRequest();
        } else {}
      } catch (e) {}
    } on PlatformException catch (e) {}
  }

/*
  _sendCredentials perform action in this order

  Step # 1:
  fetch home network ssid & password

  Step # 2:
  Get connected device IP

  Step # 3:
  Send http request to connected device

  Step # 4:
  Parse received data and store in _configuredDeviceData variable

  *
   */
  Future<Null> _sendCredentials() async {
    // fetching ssid & password
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var client = prefs.getString('clientId');
    var apikey = prefs.getString('apiKey');
    var security = prefs.getString('securityKey');

    _homeNetworkSsid = _deviceData['homeWifi'] = prefs.getString('wifi_ssid');
    _homePassword = _deviceData['password'] = prefs.getString('wifi_password');
    final String myCurrentWifi = await Wifi.ssid;
    print("Current WiFi");
    print(myCurrentWifi);
    var bytes = utf8.encode(myCurrentWifi);
    var digest = sha1.convert(bytes).toString();

    Map data = {
      "ssid": _homeNetworkSsid,
      "password": _homePassword,
      "serverAddress": 'event-hub.dev.onstak.io',
      "authKey": digest,
      "clientId": client,
      "apiKey": apikey,
      "securityKey": security,
    };

    // fetching ip address
    List<String> string;
    _hostIp = await Wifi.ip;
    print("$_hostIp\n\n\n\n");

    string = _hostIp.split('.');
    _hostIp = '${string[0]}.${string[1]}.${string[2]}.1';

    //sending http request
    try {
      print(_deviceData);
      print('amjad is here');
      print("data is:\t" + data.toString());
      String myString = data.toString();
      int length = myString.length;
      final http.Response response = await http.post(
          'http://$_hostIp/api/v1/update/credentials',
          body: json.encode(data));
      var jsonResponse = json.decode(response.body);
      print(response.statusCode.toString());
      print(jsonResponse);
      if (jsonResponse['status'] == 'success') {
        const twentyMillis = const Duration(seconds: 20);
        new Timer(twentyMillis, () async {
          await verifyConnectivity();
        });
      } else {}
    } catch (e) {
      initialTimer.cancel();
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ConnectionScreen(_homeNetworkSsid, wrong: true)))
          .then((onValue) {
        checkNetwork();
        setState(() {
          _loader = true;
        });
      });
    }
  }

  Future verifyConnectivity() async {
    //connected = true;
    print('Junaid is here');
    var _name;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _name = _deviceData['homeWifi'] = prefs.getString('wifi_ssid');
    var ssid = prefs.getString('ssid');

    String wifiName = await Wifi.ssid;
    var bytes = utf8.encode(wifiName);
    var digest = sha1.convert(bytes).toString();

    Map data = {
      "authKey": digest,
    };

    try {
      print('muneeb is here');
      print(_hostIp);
      final http.Response response = await http
          .post('http://$_hostIp/api/v1/check/connectivity', body: data);
      var result = json.decode(response.body);
      print("\n\n\n\n$result");
      print(response.statusCode);
      if (result['status'] == 'success') {
        // await _leaveApModeRequest(_configuredDeviceData);

        setState(() {
          percentage = 1.0;
          percentageTextRepresentation = 100;
          connected = true;
        });
        //store device data

        response1 = result;

        const twentyMillis = const Duration(seconds: 1);
        new Timer(twentyMillis, () {
          initialTimer.cancel();
          resetDevice();
          setState(() {
            //hiding loader
            _loader = false;
          });
        });
      } else if (result['status'] == 'wrongPassword') {
        initialTimer.cancel();
        print('muneeb is here');
        Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ConnectionScreen(_homeNetworkSsid, wrong: true)))
            .then((onValue) {
          checkNetwork();
          setState(() {
            _loader = true;
          });
        });
      } else if (result['status'] == 'unavailable' ||
          result['status'] == 'failure') {
        await verifyConnectivity();
        initialTimer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ShowError(result['status'])),
        );
      }
    } catch (e) {
      print(e);
      _verifyConnectivityRequestAttempts++;
      if (_verifyConnectivityRequestAttempts >= 3) {
        String currentSsid = await Wifi.ssid;
        if (currentSsid.contains(ssid)) {
          var duration = const Duration(seconds: 3);
          return new Timer(duration, verifyConnectivity);
        } else {
          var duration = const Duration(seconds: 5);
          new Timer(duration, () async {
            String currentSsid = await Wifi.ssid;
            if (currentSsid.contains(ssid)) {
              var duration = const Duration(seconds: 3);
              new Timer(duration, verifyConnectivity);
            } else {
              initialTimer.cancel();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ShowError('failure')),
              );
            }
          });
        }
      } else {
        initialTimer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ShowError('failure')),
        );
      }
    }
  }

  resetDevice() async {
    await _leaveApModeRequest(_restartDevice);

    // else {
    //Navigator.popUntil(
    //context,
    // ModalRoute.withName('/onboarding/setHomeWifi'),
    // );
    // Navigator.pushNamed(context, OnBoardingPage.id);
    //}
  }

  startTimeoutWifi() {
    var duration = const Duration(seconds: 2);
    return new Timer(duration, _moveBack);
  }

  _moveBack() {
    _loader = false;
    Navigator.pop(context, false);
  }

  /*
  * _configureGang will configure selected gang at once
  * This method perform action in this way
  *
  * Step # 1
  * Send http request
  *
  * Step # 2
  * If gang configure successfully
  * marked gang configure
   */
  /*void backButton(){
    Navigator.pop(context);
  }*/

  Widget build(BuildContext context) {
    // TODO: implement build
    return _loader
        ? Scaffold(
            body: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 55.0),
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    height: MediaQuery.of(context).size.width <= 400.0
                        ? 160.0
                        : 180.0,
                    alignment: Alignment(0.0, 0.0),
                    child: Image(
                      image: AssetImage(
                          'assets/images/adding-device-to-home-network.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(
                    height: 12.0,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    alignment: Alignment(-1.0, 0.0),
                    child: Text(
                      'Adding device to home network',
                      style: TextStyle(
                        fontFamily: 'SFUID-Medium',
                        fontSize: MediaQuery.of(context).size.width <= 380.0
                            ? 20.0
                            : 22.0,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 3 / 100,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Text(
                      ' We are adding ' +
                          widget.connectedDeviceSsid +
                          ' to your home network to help control device with smart phone.',
                      style: TextStyle(
                          fontFamily: 'SFUID-Medium',
                          fontSize: MediaQuery.of(context).size.width <= 380.0
                              ? 14.0
                              : 16.5,
                          color: Colors.grey[500]),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 7 / 100,
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(
                        accentColor: Colors.blue,
                        backgroundColor: Colors.white.withOpacity(0.5)),
                    child: Center(
                      child: new CircularPercentIndicator(
                        radius: 120.0,
                        lineWidth: 13.0,
                        animation: true,
                        animationDuration: 0,
                        progressColor: Color(0xff00aee6),
                        percent: percentage,
                        addAutomaticKeepAlive: true,
                        center: new Text(
                          "$percentageTextRepresentation%",
                          style: new TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                          accentColor: Colors.blue,
                          backgroundColor: Colors.white.withOpacity(0.5)),
                      child: Center(
                          child: new StepProgressIndicator(
                        totalSteps: 3,
                        currentStep: 3,
                        size: 5,
                        selectedColor: Colors.green,
                        unselectedColor: Colors.white,
                      )),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Step 3 of 3',
                      style: TextStyle(
                          fontFamily: 'SFUID-Medium',
                          fontSize: MediaQuery.of(context).size.width <= 380.0
                              ? 14.0
                              : 16.5,
                          color: Colors.grey[500]),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
          )
        : WillPopScope(
            onWillPop: null,
            child: Scaffold(
                body: Center(
              child: _loader
                  ? Theme(
                      data: Theme.of(context).copyWith(
                          accentColor: Colors.blue,
                          backgroundColor: Colors.white.withOpacity(0.5)),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Container(
                        color: Color(0XFFf9f9f9),
                        alignment: AlignmentDirectional(0.0, 0.0),
                        padding: EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 18.0),
                              child: Center(
                                child: Text(
                                  'Device Added Successfully',
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 30.0),
                              padding: EdgeInsets.only(left: 30.0, right: 30.0),
                              height: MediaQuery.of(context).size.width <= 400.0
                                  ? 160.0
                                  : 180.0,
                              alignment: Alignment(0.0, 0.0),
                              child: Image(
                                image: AssetImage('assets/images/tick.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 8.0,
                                  ),
                                  Container(
                                    alignment: Alignment(0.0, 1.1),
                                    width: (300.0),
                                    height: MediaQuery.of(context).size.height *
                                        7 /
                                        100,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 0, 172, 236),
                                          Color.fromARGB(255, 9, 243, 175),
                                          //Color(0xFF09f3af),
                                        ],
                                        begin: const FractionalOffset(0.0, 0.0),
                                        end: const FractionalOffset(0.9, 0.0),
                                      ),
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    child: Material(
                                      child: MaterialButton(
                                        child: Text(
                                          "Proceed",
                                          style: TextStyle(
                                              fontFamily: 'SFUID-Medium',
                                              fontSize: 18.0,
                                              color: Colors.white),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).popUntil(
                                              ModalRoute.withName(
                                                  OnBoardingPage.id));
                                          Navigator.pushNamed(
                                              context, DashboardScreen.id);
                                        },
                                        highlightColor: Colors.lightBlueAccent
                                            .withOpacity(0.5),
                                        splashColor:
                                            Colors.green.withOpacity(0.5),
                                      ),
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
            )),
          );
  }
}
