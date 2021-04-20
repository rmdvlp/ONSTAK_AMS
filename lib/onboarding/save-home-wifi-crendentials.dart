import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionScreen extends StatefulWidget {
  final String ssid;
  bool wrong;
  final String currentWifi;

  ConnectionScreen(this.ssid,  {this.currentWifi = '', this.wrong = false});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ConnectionScreen();
  }
}

class _ConnectionScreen extends State<ConnectionScreen> {
  final TextEditingController _ssidTextController = TextEditingController();
  final TextEditingController _wifiPasswordController = TextEditingController();

  bool _obscureText = true;

  void initState() {
    super.initState();
    _ssidTextController.text = widget.ssid;
    checkHomeWifiConnectionStatus();
  }

  void checkHomeWifiConnectionStatus() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var homeWifi  = prefs.getString('wifi_ssid');
    print(homeWifi);

    if(widget.ssid == homeWifi)
      _wifiPasswordController.text = prefs.getString('wifi_password');
  }

  void saveData() async {
    if (_wifiPasswordController.text.length >= 8) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('wifi_ssid', widget.ssid.trim());
      prefs.setString('wifi_password', _wifiPasswordController.text.trim());
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(
          msg: "Password must be atleast 8 characters long",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 5,
          backgroundColor: Color(0xffea4444),
          textColor: Color(0xffffffff));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Connect to your home network',
          style: TextStyle(
            fontSize: 14.0,
          ),
        ),
        elevation: 0.0,
        backgroundColor: Color(0XFFf9f9f9),
      ),
      body: Center(
        child: Container(
          color: Color(0XFFf9f9f9),
          alignment: AlignmentDirectional(0.0, 0.0),
          margin: new EdgeInsets.only(
              top: 0.0, right: 20.0, left: 20.0, bottom: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Connect to',
                      style: TextStyle(
                        fontFamily: 'SFUID-Medium',
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      widget.ssid,
                      style: TextStyle(
                        fontFamily: 'SFUID-Medium',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Name (ssid):',
                            style: TextStyle(
                                fontFamily: 'SFUID-Medium', fontSize: 15.0),
                            textAlign: TextAlign.left,
                          ),
                          flex: 2,
                        ),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _ssidTextController,
                            enabled: false,
                            decoration: new InputDecoration(
                              hintText: 'WiFi',
                              contentPadding: EdgeInsets.only(
                                  top: 2.0, right: 10.0, bottom: 7.0),
                            ),
                            style: TextStyle(
                                color: Color(0XFF1c252c), fontSize: 15.0),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 11.0),
                            child: Text(
                              'Password:',
                              style: TextStyle(
                                  fontFamily: 'SFUID-Medium', fontSize: 15.0),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          flex: 2,
                        ),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _wifiPasswordController,
                            decoration: InputDecoration(
                              hintText: "Password",
                              contentPadding:
                                  EdgeInsets.only(bottom: 0.0, top: 6.0),
                              suffixIcon: IconButton(
                                  padding:
                                      EdgeInsets.only(bottom: 0.0, top: 15.0),
                                  color: Color(0XFF1c252c),
                                  // use "solidEye" if show password
                                  icon: _obscureText == true
                                      ? Icon(FontAwesomeIcons.eyeSlash)
                                      : Icon(FontAwesomeIcons.solidEye),
                                  iconSize: 16.0,
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  }),
                            ),
                            //controller: _passwordController,
                            obscureText: _obscureText,
                            style: TextStyle(
                              color: Color(0XFF1c252c),
                              fontSize: 15.0,
                              height: 2.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: <Widget>[
                        widget.wrong
                            ? Expanded(
                                child: Text(
                                  'Password is incorrect. Please enter correct password',
                                  style: TextStyle(
                                    fontFamily: 'SFUID-Medium',
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0XFFdd4b39).withOpacity(.7),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              )
                            : Expanded(
                                child: Text(
                                  'Make sure this is your home WiFi network.',
                                  style: TextStyle(
                                    fontFamily: 'SFUID-Medium',
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0XFF1c252c).withOpacity(.7),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment(0.0, 1.1),
                width: (300.0),
                height: MediaQuery.of(context).size.height * 7 / 100,
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
                      "Save",
                      style: TextStyle(
                          fontFamily: 'SFUID-Medium',
                          fontSize: 18.0,
                          color: Colors.white),
                    ),
                    onPressed: () {
                      saveData();
                    },
                    highlightColor: Colors.lightBlueAccent.withOpacity(0.5),
                    splashColor: Colors.lightGreenAccent.withOpacity(0.5),
                  ),
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
