import 'dart:convert';
import 'dark_theme_script.dart' show darkThemeScript;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional_switch.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:reedling/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'onboarding/Models/GetDeviceDetail.dart';

class detail extends StatefulWidget {
  static const String id = "detail";

  @override
  _detailState createState() => _detailState();
}

class _detailState extends State<detail> {
  ScreenArguments arg;
  final double width = 15;
  String sort = 'Weekly';

  bool countv1 = true;
  bool countv2 = true;
  bool countv3 = true;
  bool countv4 = true;
  bool countv5 = true;

  List<double> v12 = [];
  List<BarChartGroupData> v1 = [];
  List<BarChartGroupData> v2 = [];
  List<BarChartGroupData> v3 = [];
  List<BarChartGroupData> v4 = [];
  List<BarChartGroupData> v5 = [];

  bool countp1 = true;
  bool countp2 = true;
  bool countp3 = true;
  bool countp4 = true;
  bool countp5 = true;

  List<BarChartGroupData> p1 = [];
  List<BarChartGroupData> p2 = [];
  List<BarChartGroupData> p3 = [];
  List<BarChartGroupData> p4 = [];
  List<BarChartGroupData> p5 = [];

  bool counti1 = true;
  bool counti2 = true;
  bool counti3 = true;
  bool counti4 = true;
  bool counti5 = true;

  List<BarChartGroupData> i1 = [];
  List<BarChartGroupData> i2 = [];
  List<BarChartGroupData> i3 = [];
  List<BarChartGroupData> i4 = [];
  List<BarChartGroupData> i5 = [];

  String to;
  String from;
  String day;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<List> getDeviceDetails(String clientId, String type, String date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    if(date == 'Weekly')
      {
        DateTime date = DateTime.now();
        to = date.toIso8601String() + 'Z';
        from = date.subtract(new Duration(days: 6)).toIso8601String() + 'Z';
        day = "day";
      }
    else if(date == 'Monthly')
    {
      DateTime date = DateTime.now();
      to = date.toIso8601String() + 'Z';
      from = date.subtract(new Duration(days: 30)).toIso8601String() + 'Z';
      day = "week";
    }
    else if(date == 'Yearly')
      {
        DateTime date = DateTime.now();
        to = date.toIso8601String() + 'Z';
        from = date.subtract(new Duration(days: 365)).toIso8601String() + 'Z';
        day = "month";
      }
    print(clientId);

    Map data = {
      "queryType": "timeseries",
      "granularity": day,
      "descending": "true",
      "filter": {
        "type": "and",
        "fields": [
          {"type": "selector", "dimension": "label", "value": type},
          {"type": "selector", "dimension": "clientId", "value": clientId}
        ]
      },
      "aggregations": [
        {"type": "doubleSum", "name": type, "fieldName": "value"},
        {"type": "count", "name": "Count", "fieldName": "value"}
      ],
      "postAggregations": [
        {
          "type": "arithmetic",
          "name": "AVG",
          "fn": "/",
          "fields": [
            {"type": "fieldAccess", "name": "total" + type, "fieldName": type},
            {"type": "fieldAccess", "name": "TotalCount", "fieldName": "Count"}
          ]
        }
      ],
      "intervals": ["$from/$to"]
    };

    var url3 = 'https://iot.dev.onstak.io/services/core/api/v2/analytics/query';
    var resp3;
    final apiCall3 = await http
        .post(url3, body: json.encode(data), headers: <String, String>{
      "Content-Type": "application/json",
      'x-auth-token': token,
    }).then((value) => {resp3 = getDeviceDetailFromJson(value.body)});
    return resp3;
  }

  @override
  Widget build(BuildContext context) {
    RouteSettings settings = ModalRoute.of(context).settings;
    arg = settings.arguments;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue[400],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        arg.name.replaceAll('_', ' '),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(6)),
                    onPressed: ()
                    {
                      setState(() {
                        sort = 'Weekly';
                      });
                    },
                    child: Text('Weekly'),
                  ),
                  RaisedButton(shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(6)),
                    onPressed: ()
                    {
                      setState(() {
                        sort = 'Monthly';
                      });
                    },
                    child: Text('Monthly'),
                  ),
                  RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(6)),
                    onPressed: ()
                    {
                      setState(() {
                        sort = 'Yearly';
                      });
                    },
                    child: Text('Yearly'),
                  )
                ],
              ),
              ConditionalSwitch.single<String>(
                context: context,
                valueBuilder: (BuildContext context) => sort,
                caseBuilders: {
                  'Weekly': (BuildContext context) => DefaultTabController(
                    length: 3,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TabBar(
                          isScrollable: true,
                          indicatorColor: Colors.green,
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          onTap: (index) {},
                          tabs: [
                            Tab(text: 'Voltage'),
                            Tab(text: 'Current'),
                            Tab(text: 'Power'),
//                        Tab(text: 'Units'),
                          ],
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.35,
                          child: TabBarView(children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.35,
                              child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.all(5),
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'V1','Weekly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (countv1) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  v1.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                  v12.add(snapshot.data[i].result.avg);
                                                }
                                                countv1 = false;
                                              }
                                              print("v12 : $v12");

                                              return Container(
                                                width: MediaQuery.of(context).size.width*0.7,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: Echarts(
                                                    extensions: [darkThemeScript],
                                                    theme: 'dark',
                                                    option: '''
                                                    {
                                                      xAxis: {
                                                            type: 'category',
                                                            data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                                                        },
                                                        yAxis: {
                                                            type: 'value'
                                                        },
                                                        series: [{
                                                            data: $v12,
                                                            type: 'bar',
                                                            showBackground: true,
                                                            backgroundStyle: {
                                                                color: 'rgba(180, 180, 180, 0.2)'
                                                            }
                                                        }]
                                                    }
                                                    ''',

                                                  )
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'V2', 'Weekly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (countv2) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  v2.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                countv2 = false;
                                              }
                                              print(v2);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Mn';
                                                              case 1:
                                                                return 'Tu';
                                                              case 2:
                                                                return 'Wd';
                                                              case 3:
                                                                return 'Th';
                                                              case 4:
                                                                return 'Fr';
                                                              case 5:
                                                                return 'St';
                                                              case 6:
                                                                return 'Sn';
                                                              default:
                                                                return '';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,
//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: v2,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'V3', 'Weekly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (countv3) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  v3.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                countv3 = false;
                                              }
                                              print(v3);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Mn';
                                                              case 1:
                                                                return 'Tu';
                                                              case 2:
                                                                return 'Wd';
                                                              case 3:
                                                                return 'Th';
                                                              case 4:
                                                                return 'Fr';
                                                              case 5:
                                                                return 'St';
                                                              case 6:
                                                                return 'Sn';
                                                              default:
                                                                return '';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,
//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: v3,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'V4', 'Weekly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (countv4) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  v4.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                countv4 = false;
                                              }
                                              print(v4);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Mn';
                                                              case 1:
                                                                return 'Tu';
                                                              case 2:
                                                                return 'Wd';
                                                              case 3:
                                                                return 'Th';
                                                              case 4:
                                                                return 'Fr';
                                                              case 5:
                                                                return 'St';
                                                              case 6:
                                                                return 'Sn';
                                                              default:
                                                                return '';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,
//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: v4,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'V5', 'Weekly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (countv5) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  v5.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                countv5 = false;
                                              }
                                              print(v5);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Mn';
                                                              case 1:
                                                                return 'Tu';
                                                              case 2:
                                                                return 'Wd';
                                                              case 3:
                                                                return 'Th';
                                                              case 4:
                                                                return 'Fr';
                                                              case 5:
                                                                return 'St';
                                                              case 6:
                                                                return 'Sn';
                                                              default:
                                                                return '';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,
//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: v5,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                  ]),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.35,
                              child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.all(5),
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'I1', 'Weekly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (counti1) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  i1.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                counti1 = false;
                                              }

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Mn';
                                                              case 1:
                                                                return 'Tu';
                                                              case 2:
                                                                return 'Wd';
                                                              case 3:
                                                                return 'Th';
                                                              case 4:
                                                                return 'Fr';
                                                              case 5:
                                                                return 'St';
                                                              case 6:
                                                                return 'Sn';
                                                              default:
                                                                return '';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,
//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: i1,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'I2', 'Weekly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (counti2) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  i2.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                counti2 = false;
                                              }
                                              print(i2);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Mn';
                                                              case 1:
                                                                return 'Tu';
                                                              case 2:
                                                                return 'Wd';
                                                              case 3:
                                                                return 'Th';
                                                              case 4:
                                                                return 'Fr';
                                                              case 5:
                                                                return 'St';
                                                              case 6:
                                                                return 'Sn';
                                                              default:
                                                                return '';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,

//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: i2,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'I3', 'Weekly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (counti3) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  i3.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                counti3 = false;
                                              }
                                              print(i3);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Mn';
                                                              case 1:
                                                                return 'Tu';
                                                              case 2:
                                                                return 'Wd';
                                                              case 3:
                                                                return 'Th';
                                                              case 4:
                                                                return 'Fr';
                                                              case 5:
                                                                return 'St';
                                                              case 6:
                                                                return 'Sn';
                                                              default:
                                                                return '';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,

//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: i3,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'I4', 'Weekly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (counti4) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  i4.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                counti4 = false;
                                              }

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Mn';
                                                              case 1:
                                                                return 'Tu';
                                                              case 2:
                                                                return 'Wd';
                                                              case 3:
                                                                return 'Th';
                                                              case 4:
                                                                return 'Fr';
                                                              case 5:
                                                                return 'St';
                                                              case 6:
                                                                return 'Sn';
                                                              default:
                                                                return '';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,

//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: i4,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'I5', 'Weekly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (counti5) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  i5.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                counti5 = false;
                                              }
                                              print(i5);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Mn';
                                                              case 1:
                                                                return 'Tu';
                                                              case 2:
                                                                return 'Wd';
                                                              case 3:
                                                                return 'Th';
                                                              case 4:
                                                                return 'Fr';
                                                              case 5:
                                                                return 'St';
                                                              case 6:
                                                                return 'Sn';
                                                              default:
                                                                return '';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,
//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: i5,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                  ]),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.35,
                              child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.all(5),
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'P1', 'Weekly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (countp1) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  p1.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                countp1 = false;
                                              }

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Mn';
                                                              case 1:
                                                                return 'Tu';
                                                              case 2:
                                                                return 'Wd';
                                                              case 3:
                                                                return 'Th';
                                                              case 4:
                                                                return 'Fr';
                                                              case 5:
                                                                return 'St';
                                                              case 6:
                                                                return 'Sn';
                                                              default:
                                                                return '';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,

//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: p1,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'P2', 'Weekly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (countp2) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  p2.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                countp2 = false;
                                              }
                                              print(p2);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Mn';
                                                              case 1:
                                                                return 'Tu';
                                                              case 2:
                                                                return 'Wd';
                                                              case 3:
                                                                return 'Th';
                                                              case 4:
                                                                return 'Fr';
                                                              case 5:
                                                                return 'St';
                                                              case 6:
                                                                return 'Sn';
                                                              default:
                                                                return '';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,

//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: p2,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'P3', 'Weekly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (countp3) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  p3.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                countp3 = false;
                                              }
                                              print(p3);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Mn';
                                                              case 1:
                                                                return 'Tu';
                                                              case 2:
                                                                return 'Wd';
                                                              case 3:
                                                                return 'Th';
                                                              case 4:
                                                                return 'Fr';
                                                              case 5:
                                                                return 'St';
                                                              case 6:
                                                                return 'Sn';
                                                              default:
                                                                return '';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,

//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: p3,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'P4', 'Weekly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (countp4) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  p4.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                countp4 = false;
                                              }

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Mn';
                                                              case 1:
                                                                return 'Tu';
                                                              case 2:
                                                                return 'Wd';
                                                              case 3:
                                                                return 'Th';
                                                              case 4:
                                                                return 'Fr';
                                                              case 5:
                                                                return 'St';
                                                              case 6:
                                                                return 'Sn';
                                                              default:
                                                                return '';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,

//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: p4,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'P5', 'Weekly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (countp5) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  p5.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                countp5 = false;
                                              }
                                              print(p5);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Mn';
                                                              case 1:
                                                                return 'Tu';
                                                              case 2:
                                                                return 'Wd';
                                                              case 3:
                                                                return 'Th';
                                                              case 4:
                                                                return 'Fr';
                                                              case 5:
                                                                return 'St';
                                                              case 6:
                                                                return 'Sn';
                                                              default:
                                                                return '';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,
//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: p5,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                  ]),
                            ),
                          ]),
                        )
                      ],
                    ),
                  ),
                  'Monthly': (BuildContext context) => DefaultTabController(
                    length: 3,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TabBar(
                          isScrollable: true,
                          indicatorColor: Colors.green,
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          onTap: (index) {},
                          tabs: [
                            Tab(text: 'Voltage'),
                            Tab(text: 'Current'),
                            Tab(text: 'Power'),
//                        Tab(text: 'Units'),
                          ],
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.35,
                          child: TabBarView(children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.35,
                              child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.all(5),
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'V1','Monthly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (countv1) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  v1.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                countv1 = false;
                                              }
                                              print(v1);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Week 1';
                                                              case 1:
                                                                return 'Week 2';
                                                              case 2:
                                                                return 'Week 3';
                                                              case 3:
                                                                return 'Week 4';
                                                              case 4:
                                                                return 'Week 5';
                                                              default:
                                                                return 'Week';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,
//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: v1,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'V2', 'Monthly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (countv2) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  v2.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                countv2 = false;
                                              }
                                              print(v2);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Week 1';
                                                              case 1:
                                                                return 'Week 2';
                                                              case 2:
                                                                return 'Week 3';
                                                              case 3:
                                                                return 'Week 4';
                                                              case 4:
                                                                return 'Week 5';
                                                              default:
                                                                return 'Week';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,
//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: v2,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'V3', 'Monthly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (countv3) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  v3.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                countv3 = false;
                                              }
                                              print(v3);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Week 1';
                                                              case 1:
                                                                return 'Week 2';
                                                              case 2:
                                                                return 'Week 3';
                                                              case 3:
                                                                return 'Week 4';
                                                              case 4:
                                                                return 'Week 5';
                                                              default:
                                                                return 'Week';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,
//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: v3,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'V4', 'Monthly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (countv4) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  v4.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                countv4 = false;
                                              }
                                              print(v4);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Week 1';
                                                              case 1:
                                                                return 'Week 2';
                                                              case 2:
                                                                return 'Week 3';
                                                              case 3:
                                                                return 'Week 4';
                                                              case 4:
                                                                return 'Week 5';
                                                              default:
                                                                return 'Week';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,
//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: v4,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'V5', 'Monthly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (countv5) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  v5.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                countv5 = false;
                                              }
                                              print(v5);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Week 1';
                                                              case 1:
                                                                return 'Week 2';
                                                              case 2:
                                                                return 'Week 3';
                                                              case 3:
                                                                return 'Week 4';
                                                              case 4:
                                                                return 'Week 5';
                                                              default:
                                                                return 'Week';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,
//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: v5,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                  ]),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.35,
                              child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.all(5),
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'I1', 'Monthly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (counti1) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  i1.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                counti1 = false;
                                              }

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Week 1';
                                                              case 1:
                                                                return 'Week 2';
                                                              case 2:
                                                                return 'Week 3';
                                                              case 3:
                                                                return 'Week 4';
                                                              case 4:
                                                                return 'Week 5';
                                                              default:
                                                                return 'Week';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,
//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: i1,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'I2', 'Monthly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (counti2) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  i2.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                counti2 = false;
                                              }
                                              print(i2);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Week 1';
                                                              case 1:
                                                                return 'Week 2';
                                                              case 2:
                                                                return 'Week 3';
                                                              case 3:
                                                                return 'Week 4';
                                                              case 4:
                                                                return 'Week 5';
                                                              default:
                                                                return 'Week';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,

//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: i2,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'I3', 'Monthly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (counti3) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  i3.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                counti3 = false;
                                              }
                                              print(i3);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Week 1';
                                                              case 1:
                                                                return 'Week 2';
                                                              case 2:
                                                                return 'Week 3';
                                                              case 3:
                                                                return 'Week 4';
                                                              case 4:
                                                                return 'Week 5';
                                                              default:
                                                                return 'Week';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,

//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: i3,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'I4', 'Monthly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (counti4) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  i4.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                counti4 = false;
                                              }

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Week 1';
                                                              case 1:
                                                                return 'Week 2';
                                                              case 2:
                                                                return 'Week 3';
                                                              case 3:
                                                                return 'Week 4';
                                                              case 4:
                                                                return 'Week 5';
                                                              default:
                                                                return 'Week';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,

//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: i4,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'I5', 'Monthly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (counti5) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  i5.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                counti5 = false;
                                              }
                                              print(i5);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Week 1';
                                                              case 1:
                                                                return 'Week 2';
                                                              case 2:
                                                                return 'Week 3';
                                                              case 3:
                                                                return 'Week 4';
                                                              case 4:
                                                                return 'Week 5';
                                                              default:
                                                                return 'Week';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,
//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: i5,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                  ]),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.35,
                              child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.all(5),
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'P1', 'Monthly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (countp1) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  p1.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                countp1 = false;
                                              }

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Week 1';
                                                              case 1:
                                                                return 'Week 2';
                                                              case 2:
                                                                return 'Week 3';
                                                              case 3:
                                                                return 'Week 4';
                                                              case 4:
                                                                return 'Week 5';
                                                              default:
                                                                return 'Week';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,

//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: p1,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'P2', 'Monthly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (countp2) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  p2.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                countp2 = false;
                                              }
                                              print(p2);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Week 1';
                                                              case 1:
                                                                return 'Week 2';
                                                              case 2:
                                                                return 'Week 3';
                                                              case 3:
                                                                return 'Week 4';
                                                              case 4:
                                                                return 'Week 5';
                                                              default:
                                                                return 'Week';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,

//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: p2,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'P3', 'Monthly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (countp3) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  p3.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                countp3 = false;
                                              }
                                              print(p3);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Week 1';
                                                              case 1:
                                                                return 'Week 2';
                                                              case 2:
                                                                return 'Week 3';
                                                              case 3:
                                                                return 'Week 4';
                                                              case 4:
                                                                return 'Week 5';
                                                              default:
                                                                return 'Week';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,

//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: p3,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'P4', 'Monthly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (countp4) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  p4.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                countp4 = false;
                                              }

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Week 1';
                                                              case 1:
                                                                return 'Week 2';
                                                              case 2:
                                                                return 'Week 3';
                                                              case 3:
                                                                return 'Week 4';
                                                              case 4:
                                                                return 'Week 5';
                                                              default:
                                                                return 'Week';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,

//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: p4,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: FutureBuilder(
                                          future:
                                          getDeviceDetails(arg.clientId, 'P5', 'Monthly'),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (countp5) {
                                                int length = snapshot.data.length;
                                                print(length);
                                                for (int i = 0; i < length; i++) {
                                                  p5.add(getData(i,
                                                      snapshot.data[i].result.avg));
                                                }
                                                countp5 = false;
                                              }
                                              print(p5);

                                              return Card(
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(6)),
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16.0),
                                                  child: BarChart(
                                                    BarChartData(
                                                      alignment: BarChartAlignment
                                                          .spaceEvenly,
                                                      barTouchData: BarTouchData(
                                                        enabled: false,
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        bottomTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                  0xff939393),
                                                              fontSize: 11),
                                                          margin: 15,
                                                          getTitles:
                                                              (double value) {
                                                            switch (value.toInt()) {
                                                              case 0:
                                                                return 'Week 1';
                                                              case 1:
                                                                return 'Week 2';
                                                              case 2:
                                                                return 'Week 3';
                                                              case 3:
                                                                return 'Week 4';
                                                              case 4:
                                                                return 'Week 5';
                                                              default:
                                                                return 'Week';
                                                            }
                                                          },
                                                        ),
                                                        leftTitles: SideTitles(
                                                          showTitles: true,
                                                          getTextStyles: (value) =>
                                                          const TextStyle(
                                                              color: Color(
                                                                0xff939393,
                                                              ),
                                                              fontSize: 9),
                                                          margin: 15,
                                                          interval: null,
                                                        ),
                                                      ),
                                                      gridData: FlGridData(
                                                        show: true,
                                                        horizontalInterval: null,
//                                                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: const Color(
                                                              0xffe7e8ec),
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      groupsSpace: 5,
                                                      barGroups: p5,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Text('Loading');
                                            }
                                          }),
                                    ),
                                  ]),
                            ),
                          ]),
                        )
                      ],
                    ),
                  ),
                  'Yearly': (BuildContext context) => Text('Yearly!'),
                },
                fallbackBuilder: (BuildContext context) => null,
              ),

            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData getData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barsSpace: 4,
      barRods: [
        BarChartRodData(
            y: y,
            width: width,
            colors: [Colors.blue[400]],
            borderRadius: const BorderRadius.all(Radius.zero)),
      ],
    );
  }
}
