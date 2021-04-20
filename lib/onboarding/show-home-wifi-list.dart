import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/wifi.dart';
//import 'package:wifi_iot/wifi_iot.dart';
import './save-home-wifi-crendentials.dart';

class ShowHomeWifiList extends StatefulWidget {
  final Function homeWifiButtonStatus;

  ShowHomeWifiList(this.homeWifiButtonStatus);

  @override
  _HomeWifiConnection createState() => _HomeWifiConnection();
}

class _HomeWifiConnection extends State<ShowHomeWifiList>
    with WidgetsBindingObserver {
  bool _emptyList = true;
  bool _loader = false;
  bool _isEnabled = false;
  String _wifiName = 'Click to know';
  bool wifiStatus = false;
  List<Map<String, dynamic>> _ssidList;
  String _ssid = '';
  String homeWifiSsid = '';
  bool validate = false;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = new Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    isEnabled();
//    testMethod();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
//      setState(() => _connectionStatus = result.toString());
    });
    //testMethod();

    loadData();
    startTimeout();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state at home wifi list');
    print(state.toString());
    /*
    *
    * App suppose to send http request, when user to go setting screen and return back to app
     */
    if (state.toString() == "AppLifecycleState.resumed") {
      print("OnResumed Called");
      if (!mounted) return;
      setState(() {
        _wifiName = 'Click to know';
      });
      isEnabled();
      //startTimeoutFor1Second();
    }
  }

saveHomeWifiCredentials(ssid){
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => ConnectionScreen(
            ssid,
            currentWifi: _wifiName)),
  ).then((v) async {
    if (v == true) {
      widget.homeWifiButtonStatus();
      loadData();
    }
  });
}

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<Null> initConnectivity() async {
    
    String connectionStatus;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
    print('\n\n\n\n\connect\n\n\n\n\n\n');
      
    } on PlatformException catch (e) {
      print(e.toString());
      connectionStatus = 'Failed to get connectivity.';
      
    print('\n\n\n\n\failed\n\n\n\n\n\n');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    setState(() {
      _connectionStatus = connectionStatus;
    });
  }

  Widget itemSSID(index) {
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
                fontSize:
                    MediaQuery.of(context).size.width <= 380.0 ? 15.0 : 16.0,
                color: Color(0xFF43484d),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.width <= 380.0 ? 25.0 : 30.0,
            child: _ssidList[index]["name"] == homeWifiSsid
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
                        'Saved',
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
                      onPressed: () {
                        saveHomeWifiCredentials(_ssidList[index]['name']);
                      },
                    ),
                  )
                : OutlineButton(
                    child: Text(
                      'Save',
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
                      saveHomeWifiCredentials(_ssidList[index]['name']);
                    },
                    highlightColor: Colors.lightBlueAccent.withOpacity(0.5),
                    splashColor: Colors.green.withOpacity(0.5),
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

  @override
  void dispose() {
//    _connectivitySubscription.cancel();
    
    super.dispose();
    
  }

  void loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    homeWifiSsid = prefs.getString('wifi_ssid');
    
    print('\n\n\n\n\nloaddata\n\n\n\n\n\n');

    print('loadData');
    _ssidList = [];
//    await WiFiForIoTPlugin.loadWifiList().then((list) {
    await Wifi.list('').then((list) {
      print(list);
      if (list.isEmpty) {
        print('empty???');
        _emptyList = true;
      }
      setState(() {
        list.forEach((member) {
          print(member.ssid);
          if(homeWifiSsid == null || member.ssid != homeWifiSsid && !_ssidList.contains(member.ssid))
            _ssidList.add({"name": member.ssid});
        });
        if(homeWifiSsid != null)
        _ssidList.insert(0, {"name": homeWifiSsid});
      });

    });
    print(_ssidList);
  }

  Future<Null> _getWifiName() async {
    try {
      String wifiName = await Wifi.ssid;
      if (mounted) {

        setState(() {
          _wifiName = wifiName;
          if (_wifiName == '<unknown ssid>') {
            _wifiName = "Not Found";
            isEnabled();
          } else if (_wifiName != "'Click to know'" &&
              _ssidList.isEmpty &&
              _wifiName != "Not Found") {
            //_ssidList.add({"name": _wifiName, "status": false});
            _emptyList = true;
          } else if (_ssidList[0]['name'] != _wifiName && _emptyList) {
            _emptyList = true;
          }
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _wifiName = "Not Found";
      });
    }
  }

  startTimeoutFor1Second() {
    var duration = const Duration(seconds: 1);
    return new Timer(duration, _getWifiName);
  }

  startTimeout() {
    var duration = const Duration(seconds: 5);
    return new Timer(duration, _getWifiName);
  }

  checkEnableStatus() {
    var duration = const Duration(seconds: 3);
    return new Timer(duration, isEnabled);
  }

  isEnabled() async {
    bool isEnabled;
    try {
//      isEnabled = await WiFiForIoTPlugin.isEnabled();
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

  Widget wifiModule() {
    if (_isEnabled != null && _isEnabled == false) {
      print('wifi module off');
      return whenWifiOff();
    } else if (_connectionStatus == "ConnectivityResult.mobile") {
      _loader = false;
      return mobileDataOn();
    } else {
      _loader = false;
      startTimeout();
      return whenWifiOn();
    }
  }

  Widget whenWifiOn() {
    return Container(
      child: Column(
        children: <Widget>[
          ////////////////////////// if wifi on and data off /////////////////////////

          Container(
            margin: EdgeInsets.only(top: 30.0),
            padding: EdgeInsets.only(left: 30.0, right: 30.0),
            height: MediaQuery.of(context).size.width <= 400.0 ? 160.0 : 180.0,
            alignment: Alignment(0.0, 0.0),
            child: Image(
              image: AssetImage('assets/images/onboarding-slide2-logo.png'),
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 12.0,
          ),
          Container(
            alignment: Alignment(-1.0, 0.0),
            child: Text(
              'Provide your home WiFi credentials',
              style: TextStyle(
                fontFamily: 'SFUID-Medium',
                fontSize:
                    MediaQuery.of(context).size.width <= 380.0 ? 20.0 : 22.0,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(
            height: 12.0,
          ),
          _ssidList.isEmpty
              ? Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        'Sorry, we are unable to locate networks around you. If network shown below is your Home WiFi network then please provide credentials else please goto settings and connect to  your home WiFi  network. ',
                        style: TextStyle(
                            fontFamily: 'SFUID-Medium',
                            fontSize: MediaQuery.of(context).size.width <= 380.0
                                ? 14.0
                                : 16.5,
                            color: Colors.grey[500]),
                        textAlign: TextAlign.justify,
                      ),
                    ),
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
                    ),
                  ],
                )
              : Column(
                  children: <Widget>[
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Available Networks',
                            style: TextStyle(
                                fontFamily: 'SFUID-Medium',
                                fontSize: 19.0,
                                color: Color(0xff1c252c),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.0),
                            textAlign: TextAlign.left,
                          ),
                          FlatButton(
                            child: Text(
                              'Scan',
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500),
                            ),
                            onPressed: loadData,
                            highlightColor: Colors.white.withOpacity(0.0),
                            color: Colors.white.withOpacity(0.0),
                            splashColor: Colors.white.withOpacity(0.0),
                            padding: EdgeInsets.all(0.0),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 100.0,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        padding: EdgeInsets.only(top: 2.0),
                        itemCount: _ssidList.length,
                        itemBuilder: (context, index) {
                          return itemSSID(index);
                        },
                      ),
                    ),
                  ],
                ),

          Container(
            margin: EdgeInsets.only(top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Currently Connected to',
                  style: TextStyle(
                      fontFamily: 'SFUID-Medium',
                      fontSize: 19.0,
                      color: Color(0xff1c252c),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20.0,
          ),

          _wifiName == 'Click to know'
              ? Container(
                  margin: EdgeInsets.only(top: 20.0),
                  child: Theme(
                    data: Theme.of(context).copyWith(accentColor: Colors.blue),
                    child: Center(child: new CircularProgressIndicator()),
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _wifiName,
                          style: TextStyle(
                            fontFamily: 'SFUID-Medium',
                            fontSize: MediaQuery.of(context).size.width <= 380.0
                                ? 15.0
                                : 16.0,
                            color: Color(0xFF43484d),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width <= 380.0
                            ? 25.0
                            : 30.0,
                        child: _wifiName == homeWifiSsid
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
                                    'Saved',
                                    style: TextStyle(
                                      fontFamily: 'SFUID-Medium',
                                      fontSize:
                                          MediaQuery.of(context).size.width <=
                                                  380.0
                                              ? 13.0
                                              : 15.0,
                                      color: Color(0xffffffff),
                                      letterSpacing: 1.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  borderSide: BorderSide(
                                      width: 1.0,
                                      color:
                                          Color(0xff00afe9).withOpacity(0.0)),
                                  padding: EdgeInsets.only(
                                      top: 0.0,
                                      right: 5.0,
                                      left: 5.0,
                                      bottom: 0.0),
                                  onPressed: () {
                                    saveHomeWifiCredentials(_wifiName);
                                  },
                                ),
                              )
                            : OutlineButton(
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    fontFamily: 'SFUID-Medium',
                                    fontSize:
                                        MediaQuery.of(context).size.width <=
                                                380.0
                                            ? 13.0
                                            : 15.0,
                                    color: Color(0xFF43484d),
                                    letterSpacing: 1.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () {
                                  saveHomeWifiCredentials(_wifiName);
                                },
                                highlightColor:
                                    Colors.lightBlueAccent.withOpacity(0.5),
                                splashColor:
                                    Colors.lightGreenAccent.withOpacity(0.5),
                                borderSide: BorderSide(
                                    width: 1.0, color: Color(0xFF999da0)),
                                padding: EdgeInsets.only(
                                    top: 0.0,
                                    right: 5.0,
                                    left: 5.0,
                                    bottom: 0.0),
                                color: Color(0xFF43484d),
                              ),
                      ),
                    ],
                  ),
                )
        ],
      ),
    );
  }

  Widget whenWifiOff() {
    return Column(
      children: <Widget>[
        ////////////////////////// if wifi off /////////////////////////
        Container(
          margin: EdgeInsets.only(top: 30.0),
          padding: EdgeInsets.only(left: 30.0, right: 30.0),
          height: MediaQuery.of(context).size.width <= 400.0 ? 160.0 : 180.0,
          alignment: Alignment(0.0, 0.0),
          child: Image(
            image: AssetImage('assets/images/onboarding-slide2-logo.png'),
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          height: 12.0,
        ),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _loader
                  ? Theme(
                      data:
                          Theme.of(context).copyWith(accentColor: Colors.blue),
                      child: Center(child: new CircularProgressIndicator()),
                    )
                  : InkWell(
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
                        _loader = true;
                        setState(() {
                          _wifiName = 'Click to know';
                        });
//                        WiFiForIoTPlugin.setEnabled(true);
                        Fluttertoast.showToast(
                            msg: "Wifi Turned On",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIos: 1,
                            backgroundColor: Color(0xff25d178),
                            textColor: Color(0xffffffff));
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

  Widget mobileDataOn() {
    ////////////////////////// if wifi is off and mobile data in on /////////////////////////

    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 30.0),
          padding: EdgeInsets.only(left: 30.0, right: 30.0),
          height: MediaQuery.of(context).size.width <= 400.0 ? 160.0 : 180.0,
          alignment: Alignment(0.0, 0.0),
          child: Image(
            image: AssetImage('assets/images/onboarding-slide2-logo.png'),
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          height: 12.0,
        ),
        Container(
          child: Text(
            'Connect to your home WiFi you are connected to mobile data',
            style: TextStyle(fontFamily: 'SFUID-Medium', fontSize: 15.0),
            textAlign: TextAlign.justify,
          ),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Available Networks',
                style: TextStyle(
                    fontFamily: 'SFUID-Medium',
                    fontSize: 19.0,
                    color: Color(0xff1c252c),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0),
                textAlign: TextAlign.left,
              ),
              FlatButton(
                child: Text(
                  'Scan',
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500),
                ),
                onPressed: loadData,
                highlightColor: Colors.white.withOpacity(0.0),
                color: Colors.white.withOpacity(0.0),
                splashColor: Colors.white.withOpacity(0.0),
                padding: EdgeInsets.all(0.0),
              ),
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            padding: EdgeInsets.only(top: 2.0),
            itemCount: _ssidList.length,
            itemBuilder: (context, index) {
              return itemSSID(index);
            },
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return new Container(
      height: double.infinity,
      width: double.infinity,
//      padding: EdgeInsets.only(top: 5.0),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  height: MediaQuery.of(context).size.height * 80 / 100,
                  child: ListView(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.all(0.0),
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      wifiModule(),
                    ],
                  ),
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
