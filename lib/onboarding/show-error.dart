import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reedling/onboarding.dart';

class ShowError extends StatelessWidget {
  final String errorType;

  ShowError(this.errorType);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//Usama Start Show Error Screen
        appBar: AppBar(
          title: Text(
            'Connection Error',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Color(0XFF1c252c), fontSize: 17.0),
          ),
          elevation: 0.0,
          backgroundColor: Color(0XFFf9f9f9),

          //drawer: DrawerWidget(4),
        ),
        body: ListView(children: <Widget>[
//Previous code
          // body:
          Container(
            padding: EdgeInsets.only(right: 20.0, left: 20.0, top: 30.0),
            //added

            // margin: EdgeInsets.symmetric(vertical: 40.0),         //removed
            child: Column(
              children: <Widget>[
                Container(
                  // padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(
                    'Home Wifi Connection Failed',
                    style:
                        TextStyle(fontFamily: 'SFUID-Medium', fontSize: 22.0),
                    textAlign: TextAlign.left,
                  ),
                ),

                // Container(child: Text(errorType),),   //removed
                SizedBox(
                  height: 30.0,
                ),

                Container(
                    padding: EdgeInsets.only(top: 135.0),
                    height: 350.0,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage('assets/images/error.png'),
                    )),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 15.0,
                        ),
                      ],
                    )),

                Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 50.0),
                      alignment: Alignment(0.0, 1.1),
                      width: (300.0),
                      height: 50.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 0, 172, 236),
                            Color.fromARGB(255, 9, 243, 175),
                          ],
                          begin: const FractionalOffset(0.0, 0.0),
                          end: const FractionalOffset(0.9, 0.0),
                        ),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0))),
                        child: Material(
                          child: MaterialButton(
                            child: Text(
                              "Retry",
                              style: TextStyle(
                                  fontFamily: 'SFUID-Medium',
                                  fontSize: 18.0,
                                  color: Colors.white),
                            ),
                            onPressed: () {
//                              Navigator.popUntil(
//                                context,
//                                ModalRoute.withName('/onboarding/setHomeWifi'),
//                              );
//                              Navigator.pushNamed(
//                                  context, OnBoardingPage.id);
                            Navigator.of(context).pop();
                            },
                            highlightColor:
                                Colors.lightBlueAccent.withOpacity(0.5),
                            splashColor:
                                Colors.lightGreenAccent.withOpacity(0.5),
                          ),
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(60.0),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10.0),
                      width: 300.0,
                    )
                  ],
                )),
              ],
            ),
          ),
        ]));
  }
}
