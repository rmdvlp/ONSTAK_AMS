import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:reedling/onboarding.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class Token {
  final String token;
  Token({this.token});
  Token.fromJson(Map<String, dynamic> data)
      : token = data['token'];
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  var token;
  bool showSpinner = false;

  sendRequest() async {

    Map data ={
      "tenant": "onstak",
      "email": "admin@onstak.com",
      "password": "Onstak123\$\$!"
    };

    var url = 'https://iot.dev.onstak.io/services/identity/api/v2/accounts/user/authentication';
    final login = await http.post(url, body: data);
    var resp = json.decode(login.body);
    var tok = Token.fromJson(resp);
    token = tok.token;
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      duration: const Duration(seconds: 5),
    ));
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: ModalProgressHUD(
            inAsyncCall: showSpinner,
            child: Container(

              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg2.png'),
                  fit: BoxFit.cover,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 100.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height/2,
                  ),
                  Material(
                    child: MaterialButton(
                      padding: EdgeInsets.only(
                          left: 25.0, right: 25.0),
                      child: Text(
                        'Login',
                        style: TextStyle(
                            fontFamily: 'SFUID-Medium',
                            fontSize: 18.0,
                            color: Colors.white),
                      ),
                      onPressed: () async {
                          setState(() {
                            showSpinner = true;
                          });
                          try {
                            await sendRequest();
                            if (token != null) {
                              Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.setString('token', token);
                              prefs.setInt('id', decodedToken["personId"]);
                              prefs.setString('sub', decodedToken["sub"]);
                              Navigator.pushNamed(context, DashboardScreen.id, arguments: token);
                            }
                            else{
                              showInSnackBar("You've Entered Wrong Email or Password, Please Try Again");
                            }
                            setState(() {
                              showSpinner = false;
                            });
                          } catch (e) {
                            print(e);
                            showInSnackBar("Check your network and try again");
                            setState(() {
                              showSpinner = false;
                            });
                            return null;
                          }
                        }
                    ),
                    color: Colors.blue[500],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Material(
                    child: MaterialButton(
                      padding: EdgeInsets.only(
                          left: 25.0, right: 25.0),
                      child: Text(
                        'Register',
                        style: TextStyle(
                            fontFamily: 'SFUID-Medium',
                            fontSize: 18.0,
                            color: Colors.white),
                      ),
                      onPressed: () {
                      },
                    ),
                    color: Colors.green[400],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
