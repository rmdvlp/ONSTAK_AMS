import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reedling/onboarding/devices/Device-configuration.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:wifi/wifi.dart';
//import 'package:wifi_iot/wifi_iot.dart';
import 'package:percent_indicator/percent_indicator.dart';


class ShowIoTDevicesList extends StatefulWidget {
  final Function gatewayWifiButtonStatus;
  final Function changeAppbarStatus;

  State<StatefulWidget> createState() {
    return _DevicesDiscovery();
  }

  ShowIoTDevicesList(this.gatewayWifiButtonStatus, this.changeAppbarStatus);
}

class _DevicesDiscovery extends State<ShowIoTDevicesList>
    with WidgetsBindingObserver {
  final TextEditingController _devicePasswordController =
      TextEditingController();
  bool _emptyList = true;
  String _wifiName = 'Click to know';
final _controller = new PageController();
  Map _deviceData = {

  };
  List<Map<String, dynamic>> _ssidList = [];
  List<Map<String, dynamic>> _configuredDevicesList = [];
  bool isDeviceConfigured = false;
  String _ssid, _password = '', _ip;
  bool _isEnabled = false;
  bool _loader = false;
  bool findingDevicesInProcess = true;
  bool getWifiName = false;
  List wifiList = [];
  int currentDeviceIndex = -1;
  double percentage = 0.0;
  double percentageTextRepresentation = 0.0;
  double maxPercentage = 0.9;
  Timer initialTimer = null;
  int counter = 0;
  var ssid;

  Future<SharedPreferences> _sharedPreference = SharedPreferences.getInstance();

  @override
  void initState() {
    print("\n\n\n in iot devices");
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    findDevice();
    isEnabled();
    _getWifiName();
  }

  findDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ssid = prefs.getString('ssid');


    print('findingDevicesInProcess' + findingDevicesInProcess.toString());
    calculatePercentForFindingDevice();

    wifiList = await Wifi.list('');
    String currentSsid = await Wifi.ssid;
    print(wifiList);
    wifiList.retainWhere((singleResult) {
      print('ssid:' + singleResult.ssid);
      if (singleResult.ssid.toString().contains("REEDLING_EMS_AP_4427")) return true;
      return false;
    });

    if (wifiList.length >= 1) {
      if (currentSsid == wifiList[0].ssid) {
        print('already connected to ' + currentSsid);
        var duration = const Duration(seconds: 15);
        new Timer(duration, () async {
          setState(() {
            _ssid = wifiList[0].ssid;
            widget.gatewayWifiButtonStatus(false);
            initialTimer.cancel();
            percentage = 0.0;
            percentageTextRepresentation = 0.0;
            maxPercentage = 0.9;
            _loader = true;
            findingDevicesInProcess = false;
          });
          calculatePercentAfterDelay();
          _getIP();
        });
      } else {
        print('connecting with : ' + wifiList[0].ssid);
        await connectWithSsid("REEDLING_EMS_AP_4427", 'R33dling@12153\$\$!')
            .then((isConnected) {
          print('is connected : ' + isConnected.toString());

          if (isConnected) {
            //SHOW SNACKBAR HERE
              final snackBar = SnackBar(
                                     backgroundColor: Colors.lightBlue[700],
                                     content: Text('Connected to '+wifiList[0].ssid),
                                     duration: Duration(seconds: 20),
                                   );
                                   Scaffold.of(context).showSnackBar(snackBar);
            //END
            var duration = const Duration(seconds: 20);
            new Timer(duration, () async {
              String currentSsid = await Wifi.ssid;
              print('currentSsid : ' + currentSsid);
              if (currentSsid == wifiList[0].ssid) {
                setState(() {
                  _ssid = wifiList[0].ssid;
                  widget.gatewayWifiButtonStatus(false);
                  initialTimer.cancel();
                  percentage = 0.0;
                  percentageTextRepresentation = 0.0;
                  maxPercentage = 0.9;
                  _loader = true;
                  findingDevicesInProcess = false;
                });
                calculatePercentAfterDelay();
                _getIP();
              } else {
                whenNoListingIsAvailable();

                setState(() {
                  findingDevicesInProcess = false;
                  _ssid = wifiList[0].ssid;
                  wifiList = [];
                  widget.gatewayWifiButtonStatus(false);
                  initialTimer.cancel();
                  percentage = 0.0;
                  percentageTextRepresentation = 0.0;
                  maxPercentage = 0.9;
                });
                _getWifiName();
              }
            });
          } else {
            counter++;
            if (counter <= 1) {
              setState(() {
                percentage = 0.0;
                percentageTextRepresentation = 0.0;
                maxPercentage = 0.9;
              });
              initialTimer.cancel();
              findDevice();
            } else {
              whenNoListingIsAvailable();
            }
          }
        });
      }
    } else {
      if(currentSsid.contains(ssid)){
        var duration = const Duration(seconds: 15);
        new Timer(duration, () async {
          setState(() {
            _ssid = wifiList[0].ssid;
            widget.gatewayWifiButtonStatus(false);
            initialTimer.cancel();
            percentage = 0.0;
            percentageTextRepresentation = 0.0;
            maxPercentage = 0.9;
            _loader = true;
            findingDevicesInProcess = false;
          });
          calculatePercentAfterDelay();
          _getIP();
        });
      }else{
        whenNoListingIsAvailable();
      }
    }
  }

  // calling function when wifi listing is not available or when connecting to specific ssid in not successful
  whenNoListingIsAvailable() {
    var duration = const Duration(seconds: 5);
    var duration2 = const Duration(seconds: 2);
    return new Timer(duration, () {
      setState(() {
        initialTimer.cancel();
        percentage = 1.0;
        percentageTextRepresentation = 100;
      });
      return new Timer(duration2, () {
        setState(() {
          percentage = 0.0;
          percentageTextRepresentation = 0.0;
          maxPercentage = 0.9;
          findingDevicesInProcess = false;
        });
      });
    });
  }

  Future connectWithSsid(ssid, password) async {
    var timeout = false;
//    await WiFiForIoTPlugin.disconnect();

    return Wifi.connection(ssid,
            password)
        .then((value) async {
      print('after connect');
      print('conection status : ' + value.toString());
      if (value == false && timeout == false) {
        bool isConnected = await connectWithSsidAfterError(ssid, password);

        if (isConnected) return true;
      }

      return true;
    }).timeout(const Duration(seconds: 12), onTimeout: () async {
      print('from timeout');
      timeout = true;
      bool isConnected = await connectWithSsidAfterError(ssid, password);

      if (isConnected) return true;
      return false;
    });
  }

  Future<bool> connectWithSsidAfterError(ssid, password) async {
//    await WiFiForIoTPlugin.setEnabled(false);

    return Wifi.connection(ssid, password).then((value) {
      print('Value of connection $value');
      if (value == false) {
        print('After error, connection atttempt');
        print(value);
        return false;
      }
      return true;
    }).timeout(const Duration(seconds: 15), onTimeout: () {
      print('from timeout');
      return false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state.toString());
    if (state.toString() == "AppLifecycleState.resumed") {
      print("OnResumed Called");
      if (!mounted) return;
      setState(() {
        _wifiName = 'Click to know';
      });
      _getWifiName();
    }
  }

  isEnabled() async {
    bool isEnabled;
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      print(connectivityResult);
    } on PlatformException {
      isEnabled = false;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _isEnabled = isEnabled;
    });
  }

  Future<Null> _getWifiName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var ssid = prefs.getString('ssid');
    try {
      String wifiName = await Wifi.ssid;
      print('getting wifi name : ' + wifiName);
      print('wifi list status : ' + wifiList.isNotEmpty.toString());
      if(mounted){
      setState(() {
        _wifiName = wifiName;
        if (_wifiName == '<unknown ssid>') {
          _wifiName = "Not Found";
        }
        _ssidList = [];
        _ssidList.insert(0, {"name": _wifiName, "status": false});

        if (_wifiName.contains(ssid)) {
          print('yes');
          setState(() {
            getWifiName = true;
          });
        } else {
          setState(() {
            getWifiName = false;
          });
          if (!findingDevicesInProcess && !_loader && wifiList.isEmpty) {
            final snackBar = SnackBar(
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 3),
              content: Text('Please select smart iot device'),
            );
            Scaffold.of(context).showSnackBar(snackBar);
          }
        }
        print('getWifiName' + getWifiName.toString());
      }

      );
      }

    } on PlatformException catch (e) {
      setState(() {
        _wifiName = "Not Found";
      });
    }
  }

  calculatePercentForFindingDevice() {
    const duration = const Duration(milliseconds: 200);
    initialTimer =
        new Timer.periodic(duration, (Timer t) => calculatePercentage());
  }

  calculatePercentAfterDelay() {
    const duration = const Duration(milliseconds: 65);
    initialTimer =
        new Timer.periodic(duration, (Timer t) => calculatePercentage());
  }

  calculatePercentage() {
    if (percentage <= maxPercentage) {
      setState(() {
        percentage = percentage + 0.01;
        percentageTextRepresentation = percentageTextRepresentation + 1;
      });
    } else if (maxPercentage == 0.9) {
      if (mounted) {
        setState(() {
          percentage = 1.0;
          percentageTextRepresentation = 100;
        });
      }
    }
  }
  dispose() async {
    super.dispose();
    if (initialTimer != null) initialTimer.cancel();
    print('dispose');
  }

  Widget itemSSID(index) {

    _devicePasswordController.text = 'ONSTAK';
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Text(
              _ssidList[index]["name"],
              style: TextStyle(
                fontFamily: 'SFUID-Medium',
                fontSize: 15.0,
                color: Color(0xFF43484d),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.width <= 380.0 ? 25.0 : 30.0,
            child: _ssidList[index]["status"]
                ? Container(
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
                    ),
                    child: OutlineButton(
                      child: Text(
                        'Connected',
                        style: TextStyle(
                          fontFamily: 'SFUID-Medium',
                          fontSize: MediaQuery.of(context).size.width <= 380.0
                              ? 13.0
                              : 15.0,
                          color: Color(0xffffffff),
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      borderSide: BorderSide(
                          width: 1.0,
                          color: Color(0xff00afe9).withOpacity(0.0)),
                      padding: EdgeInsets.only(
                          top: 0.0, right: 5.0, left: 5.0, bottom: 0.0),
                      onPressed: () {},
                    ),
                  )
                : OutlineButton(
                    child: Text(
                      'Connect',
                      style: TextStyle(
                        fontFamily: 'SFUID-Medium',
                        fontSize: MediaQuery.of(context).size.width <= 380.0
                            ? 13.0
                            : 15.0,
                        color: Color(0xFF43484d),
                        letterSpacing: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                      String _temp = _ssidList[index]["name"];
                      currentDeviceIndex = index;
                      print('current index is $currentDeviceIndex');
                      setState(() {
                        _ssid = _temp;

                        _password = _devicePasswordController.text;
                        _temp = _temp.toLowerCase();
                        // now only tmfacility devices are allowed to configured.

//                        if (_temp.length < 22) {
//                          final snackeBar = SnackBar(
//                            backgroundColor: Colors.redAccent,
//                            duration: Duration(seconds: 3),
//                            content: Text('Please select smart iot device'),
//                          );
//                          Scaffold.of(context).showSnackBar(snackeBar);
//                          return;
//                        }
//
//                        if (_temp.substring(0, 10) != 'ONSTAK' &&
//                            _temp.substring(11, 21) != 'wallswitch') {
//                          print('Please select smart iot device');
//                          final snakeBar = SnackBar(
//                            backgroundColor: Colors.redAccent,
//                            duration: Duration(seconds: 3),
//                            content: Text('Please select smart iot device'),
//                          );
//                          Scaffold.of(context).showSnackBar(snakeBar);
//                          return;
//                        }
//
//                        if (_temp.substring(0, 10) != 'ONSTAK' &&
//                            _temp.substring(11, 21) != 'esocket') {
//                          print('');
//                          final snackBar = SnackBar(
//                            backgroundColor: Colors.redAccent,
//                            duration: Duration(seconds: 3),
//                            content: Text('Please select smart iot device'),
//                          );
//                          Scaffold.of(context).showSnackBar(snackBar);
//                          return;
//                        }
                        if (!isDeviceConfigured) {
                          // hiding lets start button
                          widget.gatewayWifiButtonStatus(false);
                        }
                        _loader = true;
                        widget.changeAppbarStatus(false);
                        calculatePercentAfterDelay();
                        _getIP();
                      });
                    },
                    highlightColor: Colors.lightBlueAccent.withOpacity(0.5),
                    splashColor: Colors.lightGreenAccent.withOpacity(0.5),
                    borderSide:
                        BorderSide(width: 1.0, color: Color(0xFF999da0)),
                    padding: EdgeInsets.only(
                        top: 0.0, right: 5.0, left: 5.0, bottom: 0.0),
                    color: Color(0xFF43484d),
                  ),
          ),
        ],
      ),
    );
  }

  void loadData() {
    _ssidList = [];
    Wifi.list('').then((list) {
      if (list.isEmpty) {
        print('empty???');
        _emptyList = true;
      }
      print(list);
      setState(() {
        list.forEach((member) {
          if (member.toString().length >= 4) {
            _ssidList.add({"name": member, "status": false});
          }
        });
      });
    });
  }

  Future<Null> connection() async {
    try {
      await Wifi.connection(_ssid, _password).then((v) {
        startTimeout();
      });
    } on PlatformException catch (e) {
      print(e.message);
      if (e.message == 'network status disable') {
        print(e.message);
      }
    }
  }

  startTimeoutWifi() {
    var duration = const Duration(seconds: 5);
    return new Timer(duration, _getWifiName);
  }

  startTimeout() {
    var duration = const Duration(seconds: 12);
    return new Timer(duration, _getIP);
  }

  var result;

  Future<Null> _getIP() async {
    String _name;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _name = _deviceData['homeWifi'] = prefs.getString('wifi_ssid');
    _deviceData['password'] = prefs.getString('wifi_password');
    print(_name);
    print(_deviceData['password']);
    _ip = '192.168.4.1';
    final String wifiName = await Wifi.ssid;
    var bytes = utf8.encode(wifiName);
    var digest = sha1.convert(bytes).toString();

    Map data ={
      "authKey": digest,
    };

    print(_ip);
    try {
      /*
        * Asking hardware device to start communication
         */
      final http.Response networkResponse = await http
          .post('http://$_ip/api/v1/check/network', body: data)
          .timeout(Duration(seconds: 15), onTimeout: () async {
//        await WiFiForIoTPlugin.disconnect();
        for (int index = 0; index < _configuredDevicesList.length; index++) {
          print('iot device status is');
          print(_configuredDevicesList[index]);

          if (_configuredDevicesList[index]['status']) {
            widget.gatewayWifiButtonStatus(true);
          }
        }
        initialTimer.cancel();
        setState(() {
          percentage = 0.0;
          percentageTextRepresentation = 0.0;
          maxPercentage = 0.9;
        });
        print('$_ssid is unreachable');
        setState(() {
          wifiList = [];
        });
        _displayErrorMsg();
        var duration = const Duration(seconds: 3);
        new Timer(duration, _getWifiName);

        return;
      });
      // if device is busy or not ready to start communication. Try again
      result = json.decode(networkResponse.body);
      print('result is');
      print(result);
      if (result["status"] == "success") {
        print('into success');

        startTimeOutForDelayRequest();

      } else {
        // if device is busy or not ready to start communication. Try again
        for (int index = 0; index < _configuredDevicesList.length; index++) {
          print('iot device status is');
          print(_configuredDevicesList[index]);

          if (_configuredDevicesList[index]['status']) {
            widget.gatewayWifiButtonStatus(true);
          }
        }
        initialTimer.cancel();
        setState(() {
          percentage = 0.0;
          percentageTextRepresentation = 0.0;
          maxPercentage = 0.9;
        });
        print('$_ssid is unreachable');
        setState(() {
          wifiList = [];
        });
        _getWifiName();
        _displayErrorMsg();
      }
    } catch (e) {
//      await WiFiForIoTPlugin.disconnect();
      for (int index = 0; index < _configuredDevicesList.length; index++) {
        print('iot device status is');
        print(_configuredDevicesList[index]);

        if (_configuredDevicesList[index]['status']) {
          widget.gatewayWifiButtonStatus(true);
        }
      }
      print(e.toString());
      initialTimer.cancel();
      setState(() {
        percentage = 0.0;
        percentageTextRepresentation = 0.0;
        maxPercentage = 0.9;
      });
      setState(() {
        wifiList = [];
      });
      _displayErrorMsg();
      var duration = const Duration(seconds: 3);
      new Timer(duration, _getWifiName);

    }
  }

  loadIoTDevicePage() {
    setState(() {
      maxPercentage = 0.9;
    });

    print('device type');
    print(result["deviceType"]);

    const twentyMillis = const Duration(seconds: 1);
    new Timer(twentyMillis, () {
      initialTimer.cancel();
      if (result["deviceType"] == "esp8266") {
        print('into wallswitch');
        // If wall switch device is configuring

        /*
            * Device send its gang numbers
            * Flutter app will display only received gangs in next page
             */
        int _gangNumber = 1;//int.parse(result["gangNumbers"]);
        print('gang number ');

        /*
            * Showing next page
            * Sending two variables to next page
            * 1) Device SSID
            * 2) Gangs number
             */
        Navigator.push(
          context,
          MaterialPageRoute(        //changing for test,, put DeviceConfiguration after .. usama edit
              builder: (context) => DevicesConfiguration(_ssid, _gangNumber)),
        ).then((value) async {
          _getWifiName();

          setState(() {
            // hiding loader
            percentage = 0.0;
            percentageTextRepresentation = 0.0;
            _loader = false;

            for (int index = 0;
                index < _configuredDevicesList.length;
                index++) {
              print('iot device status is');
              print(_configuredDevicesList[index]);

              if (_configuredDevicesList[index]['status']) {
                widget.gatewayWifiButtonStatus(true);
              }
            }
          }); //end of setState()

          if (value != null && value == true) {
            // if device configured successfully

            /*
                * Setting _ssidList[currentDeviceIndex]["status"] to true
                * because now it is configured
                 */

            setState(() {
              widget.gatewayWifiButtonStatus(true);

              if (_configuredDevicesList.isEmpty)
                _configuredDevicesList.add({"name": _ssid, "status": true});
              else {
                bool deviceAlreadyConfigured = false;
                _configuredDevicesList.forEach((device) {
                  if (device['name'] == _ssid) deviceAlreadyConfigured = true;
                });

                if (!deviceAlreadyConfigured)
                  _configuredDevicesList.add({"name": _ssid, "status": true});
              }

              isDeviceConfigured = true;
            });
          }
          else if (value == null || value == false) {
            // if some error occoured to configuring device
            // this device need to configure again
            //_ssidList[currentDeviceIndex]["status"] = false;
            setState(() {
              wifiList = [];
            });
            print('wifiList' + wifiList.toString());
            _getWifiName();
            final snackBar = SnackBar(
              backgroundColor: Colors.redAccent,
              content:
                  Text('Looks like, there is a problem, Please TRY AGAIN.'),
              duration: Duration(seconds: 3),
            );
            Scaffold.of(context).showSnackBar(snackBar);
          }
        });
      }
    });
  }

  startTimeOutForDelayRequest() {
    var duration = const Duration(seconds: 5);
    return new Timer(duration, loadIoTDevicePage);
  }

  startTimeOutForException() {
    var duration = const Duration(seconds: 2);
    return new Timer(duration, _displayErrorMsg);
  }

  _displayErrorMsg() {
    setState(() {
      _loader = false;
    });
    widget.changeAppbarStatus(true);
    // Looks like, there is a problem, Please TRY AGAIN.
    final snackBar = SnackBar(
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 3),
      content: Text('Looks like, there is a problem, Please TRY AGAIN.'),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Widget whenWifiOff() {
    return Column(
      children: <Widget>[
        ////////////////////////// if wifi off /////////////////////////
        Container(
          child: Text(
            'Turn on your WiFi',
            style: TextStyle(
              fontFamily: 'SFUID-Medium',
              fontSize:
                  MediaQuery.of(context).size.width <= 380.0 ? 20.0 : 22.0,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 3 / 100,
        ),
        Container(
          child: Text(
            'Please make sure your WiFi is turned on so that we can easily manage things for you.',
            style: TextStyle(
                fontFamily: 'SFUID-Medium',
                fontSize:
                    MediaQuery.of(context).size.width <= 380.0 ? 15.0 : 18.0,
                color: Colors.grey[500]),
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 3 / 100,
        ),
        Container(
          padding: EdgeInsets.only(left: 30.0, right: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                child: Text(
                  'Turn On',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 16.0,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
//                  WiFiForIoTPlugin.setEnabled(true);

                  checkEnableStatus();
                  // Snack Bar for turing on Wifi
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget wifiModule() {
    if (_isEnabled != null && _isEnabled == false) {
      return whenWifiOff();
    } else {
      return whenWifiOn();
    }
  }

  bool isConfiguredAndWifiListingAvailable() {
    print('in condition');
    print(wifiList.isNotEmpty);
    print(isDeviceConfigured);
    if (wifiList.isNotEmpty && isDeviceConfigured) return true;
    return false;
  }

  Widget whenWifiOn() {
    return isConfiguredAndWifiListingAvailable()
        ? Column(children: <Widget>[
            Container(
              child: Text(
                'Please connect to your device',
                style: TextStyle(
                  fontFamily: 'SFUID-Medium',
                  fontSize:
                      MediaQuery.of(context).size.width <= 380.0 ? 20.0 : 22.0,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width <= 380.0 ? 10.0 : 15.0,
            ),
            Container(
              margin: EdgeInsets.only(top: 15.0),
              child: InkWell(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                    top: BorderSide(width: 1.0, color: Color(0xffeeeeee)),
                    bottom: BorderSide(width: 1.0, color: Color(0xffeeeeee)),
                  )),
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.plus,
                        size: 16.0,
                        color: Colors.blueAccent,
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      Container(
                        child: Text(
                          'Add new Device',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                onTap: () {
                  setState(() {
                    findingDevicesInProcess = true;
                    widget.gatewayWifiButtonStatus(false);
                  });
                  findDevice();
                },
              ),
            )
          ])
        : Column(
            children: <Widget>[
              Container(
                child: Text(
                  'Please connect to your $ssid device',
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
                height:
                    MediaQuery.of(context).size.width <= 380.0 ? 10.0 : 15.0,
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    Text(
                      'Sorry, we are unable to locate devices around you. Please go to settings and connect to device having SSID : $ssid with Password: R33dling@12153\$\$!',
                      style: TextStyle(
                          fontFamily: 'SFUID-Medium',
                          fontSize: MediaQuery.of(context).size.width <= 380.0
                              ? 14.0
                              : 16.5,
                          color: Colors.grey[500]),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      'Connection with at least 1 device is necessary to start.',
                      style: TextStyle(
                          fontFamily: 'SFUID-Medium',
                          fontSize: MediaQuery.of(context).size.width <= 380.0
                              ? 15.0
                              : 18.0,
                          color: Colors.grey[500]),
                      textAlign: TextAlign.left,
                    )
                  ],
                ),
              ),
//        SizedBox(
//          height: 5.0,
//        ),

              Container(
                alignment: Alignment(-1.0, 0.0),
                margin: EdgeInsets.only(top: 5.0),
                child: FlatButton(
                  padding: EdgeInsets.all(0.0),
                  child: Text(
                    'Go to Settings',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: Settings.openWiFiSettings,
                  highlightColor: Colors.white.withOpacity(0.0),
                  color: Colors.white.withOpacity(0.0),
                  splashColor: Colors.white.withOpacity(0.0),
//                padding: EdgeInsets.only(right: 0.0, left: 50.0),
                ),
              )
            ],
          );
  }

  checkEnableStatus() {
    var duration = const Duration(seconds: 2);
    return new Timer(duration, isEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return _loader
        ? Scaffold(
            body: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(0.0),
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 30.0),
                        padding: EdgeInsets.only(left: 30.0, right: 30.0),
                        height: MediaQuery.of(context).size.width <= 400.0
                            ? 160.0
                            : 180.0,
                        alignment: Alignment(0.0, 0.0),
                        child: Image(
                          image: AssetImage(
                              'assets/images/communicating-with-device.png'),
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
                          'Communicating with device',
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
                        child: _ssid.length > 5
                            ? Text(
                                'Please wait for a while, we are communicating with ' +
                                    _ssid +
                                    ' to start device configuration process.',
                                style: TextStyle(
                                    fontFamily: 'SFUID-Medium',
                                    fontSize:
                                        MediaQuery.of(context).size.width <=
                                                380.0
                                            ? 14.0
                                            : 16.5,
                                    color: Colors.grey[500]),
                                textAlign: TextAlign.justify,
                              )
                            : Text(
                                'Please wait for a while, we are communicating with Smart Device'
                                ' to start device configuration process.',
                                style: TextStyle(
                                    fontFamily: 'SFUID-Medium',
                                    fontSize:
                                        MediaQuery.of(context).size.width <=
                                                380.0
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
                              "${percentageTextRepresentation}%",
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
                                currentStep: 2,
                                size: 5,
                                selectedColor: Colors.green,
                                unselectedColor: Colors.white,
                              )
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'Step 2 of 3',
                          style: TextStyle(
                              fontFamily: 'SFUID-Medium',
                              fontSize:
                              MediaQuery.of(context).size.width <=
                                  380.0
                                  ? 14.0
                                  : 16.5,
                              color: Colors.grey[500]),
                          textAlign: TextAlign.justify,
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          )
        : findingDevicesInProcess
         //first container for finding device
            ? Scaffold(
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(0.0),
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 30.0),
                  padding: EdgeInsets.only(left: 30.0, right: 30.0),
                  height: MediaQuery.of(context).size.width <= 400.0
                      ? 160.0
                      : 180.0,
                  alignment: Alignment(0.0, 0.0),
                  child: Image(
                    image: AssetImage('assets/images/finding-device.png'),
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
                    'Finding the device',
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
                    'Please wait for a while, we are finding the Smart Device'
                        ' to start communication',
                    style: TextStyle(
                        fontFamily: 'SFUID-Medium',
                        fontSize:
                        MediaQuery.of(context).size.width <=
                            380.0
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
                        "${percentageTextRepresentation}%",
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
                          currentStep: 1,
                          size: 5,
                          selectedColor: Colors.green,
                          unselectedColor: Colors.white,
                        )
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Step 1 of 3',
                    style: TextStyle(
                        fontFamily: 'SFUID-Medium',
                        fontSize:
                        MediaQuery.of(context).size.width <=
                            380.0
                            ? 14.0
                            : 16.5,
                        color: Colors.grey[500]),
                    textAlign: TextAlign.justify,
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    )
            : Container(
                height: double.infinity,
                width: double.infinity,
                padding: EdgeInsets.only(top: 30.0, bottom: 100.0),
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 15.0, right: 15.0),
                      child: ListView(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    20 /
                                    100,
                                width: 300.0,
                                child: FittedBox(
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        27 /
                                        100,
                                    alignment: Alignment(0.0, 0.0),
                                    child: Image(
                                      image: AssetImage(
                                          'assets/images/onboarding-slide3-logo.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              whenWifiOn(),
                              SizedBox(
                                height: 10.0,
                              ),
                              wifiList.isNotEmpty
                                  ? Container()
                                  : getWifiName
                                      ? Container(
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  'Currently Connected to',
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'SFUID-Medium',
                                                      fontSize: 19.0,
                                                      color: Color(0xff1c252c),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      letterSpacing: 1.0),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ]),
                                        )
                                      : Container(),
                              wifiList.isNotEmpty
                                  ? Container()
                                  : getWifiName
                                      ? Container(
                                          margin: EdgeInsets.only(top: 15.0),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics: ScrollPhysics(),
                                            padding: EdgeInsets.only(top: 2.0),
                                            itemCount: _ssidList.length,
                                            itemBuilder: (context, index) {
                                              return itemSSID(index);
                                            },
                                          ),
                                        )
                                      : Container(),

                              //Configured Devices
                              Container(
                                margin: EdgeInsets.only(top: 25.0),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        'Configured Devices',
                                        style: TextStyle(
                                            fontFamily: 'SFUID-Medium',
                                            fontSize: 16.0,
                                            color: Color(0xff1c252c),
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 1.0),
                                        textAlign: TextAlign.left,
                                      ),
                                    ]),
                              ),
                              _configuredDevicesList.length > 0
                                  ? Container(
                                      margin: EdgeInsets.only(top: 15.0),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: ScrollPhysics(),
                                        padding: EdgeInsets.only(top: 2.0),
                                        itemCount:
                                            _configuredDevicesList.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            margin:
                                                EdgeInsets.only(bottom: 10.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Text(
                                                    _configuredDevicesList[
                                                        index]['name'],
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'SFUID-Medium',
                                                      fontSize: 15.0,
                                                      color: Color(0xFF43484d),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                              .size
                                                              .width <=
                                                          380.0
                                                      ? 25.0
                                                      : 30.0,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Color.fromARGB(
                                                              255, 0, 172, 236),
                                                          Color.fromARGB(
                                                              255, 9, 243, 175),
                                                          //Color(0xFF09f3af),
                                                        ],
                                                        begin:
                                                            const FractionalOffset(
                                                                0.0, 0.0),
                                                        end:
                                                            const FractionalOffset(
                                                                0.9, 0.0),
                                                      ),
                                                    ),
                                                    child: OutlineButton(
                                                      child: Row(
                                                        children: <Widget>[
                                                          Icon(
                                                            FontAwesomeIcons
                                                                .check,
                                                            size: 13.0,
                                                            color: Color(
                                                                0xffffffff),
                                                          ),
                                                          SizedBox(
                                                            width: 5.0,
                                                          ),
                                                          Text(
                                                            'Configured',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'SFUID-Medium',
                                                              fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width <=
                                                                      380.0
                                                                  ? 13.0
                                                                  : 15.0,
                                                              color: Color(
                                                                  0xffffffff),
                                                              letterSpacing:
                                                                  1.0,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                      borderSide: BorderSide(
                                                          width: 1.0,
                                                          color:
                                                              Color(0xff00afe9)
                                                                  .withOpacity(
                                                                      0.0)),
                                                      padding: EdgeInsets.only(
                                                          top: 0.0,
                                                          right: 5.0,
                                                          left: 5.0,
                                                          bottom: 0.0),
                                                      onPressed: () {
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  alignment: FractionalOffset.center,
                ),
              );
  }
}
