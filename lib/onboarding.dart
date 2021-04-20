import 'package:flutter/material.dart';
import 'package:reedling/onboarding/show-IoT-devices-list.dart';
import 'package:reedling/onboarding/show-home-wifi-list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dots-indicator.dart';

class OnBoardingPage extends StatefulWidget {
  static const id = "onboarding";

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _OnBoardingPageState();
  }

  String source = "addDeviceFirstTime";

//  OnBoardingPage(this.source);
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _controller = new PageController();
  final List<Widget> _pages = [];
  bool _loader = false;
  bool _appBarStatus = true;
  int page = 0;
  bool _homeWifiButtonStatus = false;
  bool _gatewayWifiButtonStatus = true;
  bool _iotDeviceButtonStatus = false;
  bool _coreConfiguring = false;
  List<String> mac = [];
  var ssid;
  @override
  void initState() {
    super.initState();
    isHomeWifiCredentialsProvided();
    addPages(widget.source);
  }

//  void _showDialog() {
//    // flutter defined function
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        // return object of type Dialog
//        return AlertDialog(
//          shape:
//              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//          title: new Text("Do you have smart iot Core Device"),
//          content: new Text("Tap on Yes or No"),
//          actions: <Widget>[
//            // usually buttons at the bottom of the dialog
//            new FlatButton(
//              child: new Text("Yes"),
//              onPressed: () {
//                print('YES');
//                // env.coreAvailable = "Yes";
//                setState(() {
//                  _coreConfiguring = true;
//                });
//                Navigator.of(context).pop();
//
//                _controller.animateToPage(page + 1,
//                    duration: Duration(milliseconds: 300),
//                    curve: Curves.easeIn);
//              },
//            ),
//            new FlatButton(
//              child: new Text("No"),
//              onPressed: () {
//                print('No');
//                // env.coreAvailable = "No";
//                Navigator.of(context).pop();
//                _controller.animateToPage(page + 2,
//                    duration: Duration(milliseconds: 300),
//                    curve: Curves.easeIn);
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }

  addPages(String source) {
    if (source == 'addDeviceFirstTime') {
      _pages.add(ShowHomeWifiList(homeWifiButtonStatus)); // 1
      _pages.add(
          ShowIoTDevicesList(iotDeviceButtonStatus, changeAppBarStatus)); // 3

    } else if (source == 'setHomeWifi') {
      _pages.add(ShowHomeWifiList(homeWifiButtonStatus)); // 1
      _pages.add(
          ShowIoTDevicesList(iotDeviceButtonStatus, changeAppBarStatus)); // 3
    }
  }

  isHomeWifiCredentialsProvided() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('wifi_ssid')) {
      var homeWifiSsid = prefs.getString('wifi_ssid');
      if (homeWifiSsid != '' && homeWifiSsid != null) {
        homeWifiButtonStatus();
      }
    }
  }

  void changeAppBarStatus(status) {
    setState(() {
      _appBarStatus = status;
    });
  }

  void _showSnackBar(message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }

  void homeWifiButtonStatus() {
    setState(() {
      _homeWifiButtonStatus = true;
    });
  }

  void iotDeviceButtonStatus(bool state) {
    print('IoT Device Configured Successfully');
    print(state);
    setState(() {
      _iotDeviceButtonStatus = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    RouteSettings settings = ModalRoute.of(context).settings;
    ssid = settings.arguments;
    print(ssid);
    bool isDone = page == _pages.length - 1;
    // TODO: implement build
    return Scaffold(
        appBar: widget.source != 'addDeviceFirstTime'
            ? _appBarStatus
                ? AppBar(
                    backgroundColor: Colors.grey[200],
                    title: InkWell(
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.arrow_back),
                          SizedBox(
                            width: 8.0,
                          ),
                          Text(
                            'Back to home',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/dashboard/0');
                      },
                    ),
                    elevation: 1.0,
                  )
                : PreferredSize(
                    child: Container(), preferredSize: Size(0.0, 0.0))
            : PreferredSize(child: Container(), preferredSize: Size(0.0, 0.0)),
        resizeToAvoidBottomPadding: false,
        key: _scaffoldKey,
        backgroundColor: Colors.grey[50],
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: PageView.builder(
                physics: NeverScrollableScrollPhysics(),
                controller: _controller,
                itemCount: _pages.length,
                itemBuilder: (BuildContext context, int index) {
                  return _pages[index % _pages.length];
                },
                onPageChanged: (int p) {
                  setState(() {
                    page = p;
                  });
                },
              ),
            ),
            isDone
                ? _iotDeviceButtonStatus
                    ? Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: SafeArea(
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  _loader
                                      ? new Theme(
                                          data: Theme.of(context).copyWith(
                                              accentColor: Colors.blue),
                                          child: Center(
                                              child:
                                                 new CircularProgressIndicator()
                                          ),
                                        )
                                      : Container(
                                          width: (300.0),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              7 /
                                              100,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color.fromARGB(
                                                    255, 0, 172, 236),
                                                Color.fromARGB(
                                                    255, 9, 243, 175),
                                                //Color(0xFF09f3af),
                                              ],
                                              begin: const FractionalOffset(
                                                  0.0, 0.0),
                                              end: const FractionalOffset(
                                                  0.9, 0.0),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                          child: Material(
                                            child: MaterialButton(
                                              padding: EdgeInsets.only(
                                                  left: 25.0, right: 25.0),
                                              child: Text(
                                                'Let’s Start',
                                                style: TextStyle(
                                                    fontFamily: 'SFUID-Medium',
                                                    fontSize: 18.0,
                                                    color: Colors.white),
                                              ),
                                              onPressed: () async {
                                                if (isDone) {
                                                  if (!_iotDeviceButtonStatus) {
                                                    _showSnackBar(
                                                        "Kindly configured alteast one IoT Device");
                                                  } else {
                                                    setState(() {
                                                      _loader = true;
                                                    });
                                                    setState(() {
                                                      _loader = false;
                                                    });

                                                    Navigator
                                                        .pushReplacementNamed(
                                                            context,
                                                            '/dashboard/0');
                                                  }
                                                } else {
                                                  if (page == 0) {
                                                    _controller.animateToPage(
                                                        page + 1,
                                                        duration: Duration(
                                                            milliseconds: 300),
                                                        curve: Curves.easeIn);
                                                  } else if (!_homeWifiButtonStatus &&
                                                      page == 1) {
                                                    _showSnackBar(
                                                        "Kindly Choose and enter password for your home network");
                                                  } else if (_homeWifiButtonStatus &&
                                                      page == 1)
                                                    _controller.animateToPage(
                                                        page + 1,
                                                        duration: Duration(
                                                            milliseconds: 300),
                                                        curve: Curves.easeIn);
                                                  else if (!_gatewayWifiButtonStatus &&
                                                      page == 2) {
                                                    _showSnackBar(
                                                        "Kindly Configure Your Gateway");
                                                  } else if (_gatewayWifiButtonStatus ||
                                                      page == 2)
                                                    _controller.animateToPage(
                                                        page + 1,
                                                        duration: Duration(
                                                            milliseconds: 300),
                                                        curve: Curves.easeIn);
                                                }
                                              },
                                              highlightColor: Colors
                                                  .lightBlueAccent
                                                  .withOpacity(0.5),
                                              splashColor: Colors
                                                  .lightGreenAccent
                                                  .withOpacity(0.5),
                                            ),
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                ],
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DotsIndicator(
                                  controller: _controller,
                                  itemCount: _pages.length,
                                  onPageSelected: (int page) {
                                    _controller.animateToPage(
                                      page,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.ease,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container()
                : !_coreConfiguring
                    ? Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: SafeArea(
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Container(
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
                                    //here//
                                    child: Material(
                                      child: MaterialButton(
                                        padding: EdgeInsets.only(
                                            left: 25.0, right: 25.0),
                                        child: Text(
                                          'CONTINUE',
                                          style: TextStyle(
                                              fontFamily: 'SFUID-Medium',
                                              fontSize: 18.0,
                                              color: Colors.white),
                                        ),
                                        onPressed: () {
                                          print(mac);
                                          if (isDone) {
                                            if (!_iotDeviceButtonStatus) {
                                              _showSnackBar(
                                                  "Kindly configured alteast one IoT Device");
                                            } else {
                                              _showSnackBar("MOVING FORWARD");
                                              Navigator.pushReplacementNamed(
                                                  context, '/dashboard/0');
                                            }
                                          } else {
                                            if (widget.source == 'addCore') {
                                              //add core usama
                                              if (page == 0 &&
                                                  !_homeWifiButtonStatus) {
                                                _showSnackBar(
                                                    "Kindly Choose and enter password for your home network");
                                              } else if (page == 0 &&
                                                  _homeWifiButtonStatus) {
                                                print('GOING HERE');

                                                _controller.animateToPage(
                                                    page + 1,
                                                    duration: Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.easeIn);
                                              }
                                            } else if (widget.source !=
                                                'setHomeWifi') {
                                              if (page == 0) {
                                                print("env.awsEndPoint");
                                                print("env.nodeJsUrl");
                                                changeAppBarStatus(false);
                                                _controller.animateToPage(
                                                    page + 1,
                                                    duration: Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.easeIn);
                                              } else if (page == 1 &&
                                                  !_homeWifiButtonStatus) {
                                                _showSnackBar(
                                                    "Kindly Choose and enter password for your home network");
                                              } else if (page == 1 &&
                                                  _homeWifiButtonStatus) {
                                                  _controller.animateToPage(
                                                      page + 1,
                                                      duration: Duration(
                                                          milliseconds: 300),
                                                      curve: Curves.easeIn);
                                              } else if (!_gatewayWifiButtonStatus &&
                                                  page == 2) {
                                                _showSnackBar(
                                                    "Kindly Configure Your Gateway");
                                              } else if (_gatewayWifiButtonStatus ||
                                                  page == 2) {
                                                _controller.animateToPage(
                                                    page + 1,
                                                    duration: Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.easeIn);
                                              }
                                            } else {
                                              if (page == 0 &&
                                                  !_homeWifiButtonStatus) {
                                                _showSnackBar(
                                                    "Kindly Choose and enter password for your home network");
                                              } else if (page == 0 &&
                                                  _homeWifiButtonStatus) {
                                                // if ()

                                                _controller.animateToPage(
                                                    page + 1,
                                                    duration: Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.easeIn);
                                              } else if (!_gatewayWifiButtonStatus &&
                                                  page == 1) {
                                                _showSnackBar(
                                                    "Kindly Configure Your Gateway");
                                              } else if (_gatewayWifiButtonStatus ||
                                                  page == 1) {
                                                _controller.animateToPage(
                                                    page + 1,
                                                    duration: Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.easeIn);
                                              }
                                            }
                                          }
                                        },
                                        highlightColor: Colors.lightBlueAccent
                                            .withOpacity(0.5),
                                        splashColor: Colors.lightGreenAccent
                                            .withOpacity(0.5),
                                      ),
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DotsIndicator(
                                  controller: _controller,
                                  itemCount: _pages.length,
                                  onPageSelected: (int page) {
                                    _controller.animateToPage(
                                      page,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.ease,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
          ],
        ));
  }
}
