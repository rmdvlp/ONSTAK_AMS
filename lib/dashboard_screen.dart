import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reedling/detailed-view.dart';
import 'package:reedling/onboarding.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reedling/onboarding/Models/GetDevices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qrscan/qrscan.dart' as scanner;


class DashboardScreen extends StatefulWidget {
  static const String id = "DashboardScreen";

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  var icon;
  List<String> mac = [];
  List<String> clientId = [];
  List<String> securityKey = [];
  List<String> apiKey = [];

  Future<weatherdata> getWeather() async {
    print(icon);
    var url =
        'https://api.openweathermap.org/data/2.5/weather?q=Lahore&appid=a819b4ba9b6c05b0022f52df29eac856';
    final weather1 = await http.get(url);
    final _weather = weatherFromJson(weather1.body);
    icon = _weather.weather[0].icon;
    return _weather;
  }

  Future<List<Datum>> getDevices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    Map data = {
      "pageSize": 100,
      "query": [
        {"action": "\$eq", "name": "deviceTemplateId", "value": 40}
      ]
    };

    var url3 = 'https://iot.dev.onstak.io/services/core/api/v2/devices/query';
    final apiCall3 = await http
        .post(url3, body: json.encode(data), headers: <String, String>{
      "Content-Type": "application/json",
      'x-auth-token': token,
    });
    var resp3 = getDevicesFromJson(apiCall3.body);
    return resp3.data;
  }

  Future _scan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String barcode = await scanner.scan();
    if (barcode == null) {
      print('nothing return.');
    } else {

      Codec<String, String> stringToBase64 = utf8.fuse(base64);
      String decoded = stringToBase64.decode(barcode.replaceAll(' ', ''));
      var arr = decoded.split(',');
      print(arr);
      var ssid = arr[0];
      var device = arr[2];
      var macid = arr[1];
      print(macid);
      print(device);
      print(ssid);
      print(mac);
      if(mac.contains(macid))
        {
          prefs.setString('ssid', ssid);
          prefs.setString('clientId', clientId[mac.indexOf(macid)]);
          prefs.setString('apiKey', apiKey[mac.indexOf(macid)]);
          prefs.setString('securityKey', securityKey[mac.indexOf(macid)]);
          Navigator.pushNamed(context, OnBoardingPage.id, arguments: ssid);
        }
      print(barcode);

      print(decoded);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getWeather();
  }

  var selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                child: Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image(
                    image: AssetImage("assets/images/onstak-logo.png"),
                    height: 40,
                    width: 60,
                  ),
                  Text(
                    'Reedling',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.add,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
                    onTap: () async {
                      _scan();

                    },
                  )
                ],
              ),
            )),
            FutureBuilder(
              future: getWeather(),
              // ignore: missing_return
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var tem = snapshot.data.main.temp.toString();
                  var temp = double.parse(tem);
                  var temf = snapshot.data.main.feelsLike.toString();
                  var tempf = double.parse(temf);
                  tempf = tempf - 273.15;
                  temp = temp - 273.15;
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: Image.network(
                              'http://openweathermap.org/img/w/$icon.png',
                              fit: BoxFit.fill,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                          Text(
                            snapshot.data.weather[0].main.toString(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(children: [
                            Text("${temp.toStringAsFixed(1)} C",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                )),
                            Text("Temperature",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ))
                          ]),
                          Column(children: [
                            Text("${tempf.toStringAsFixed(1)} C",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                )),
                            Text("Feels Like",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ))
                          ]),
                          Column(children: [
                            Text(snapshot.data.main.humidity.toString(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                )),
                            Text("Humidity",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ))
                          ])
                        ],
                      )
                    ],
                  );
                } else {
                  print(snapshot.data);
                  return Container(
                    child: Center(
                      child: Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 25.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            Divider(),
            DefaultTabController(
              length: 5,
              child: Column(
                children: [
                  TabBar(
                    isScrollable: true,
                    indicatorColor: Colors.green,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    onTap: (index) {},
                    tabs: [
                      Tab(text: 'All Devices'),
                      Tab(text: 'EMS'),
                      Tab(text: 'AMS'),
                      Tab(text: 'AQI'),
                      Tab(text: 'GenSet'),
                    ],
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.98,
                      child: FutureBuilder(
                        future: getDevices(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.75,
                              child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 1.2),
                                  itemCount: snapshot.data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {

                                    mac.add(snapshot.data[index].mac);
                                    clientId.add(snapshot.data[index].clientId);
                                    securityKey.add(snapshot.data[index].securityKey);
                                    apiKey.add(snapshot.data[index].apiKey);

                                    return _buildDevice(
                                        'assets/images/pulse.jpeg',
                                        snapshot.data[index].name,
                                        snapshot.data[index].isActive
                                            .toString(),
                                        snapshot.data[index].clientId);
                                  }),
                            );
                          } else {
                            return Container(
                              child: Text('Loading'),
                            );
                          }
                        },
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDevice(String path, String name, String status, String clientId) {
    if (status == 'true') {
      status = 'Online';
    } else {
      status = 'Offline';
    }
    return GestureDetector(
      onTap: () {
      Navigator.pushNamed(context, detail.id, arguments: ScreenArguments(name, clientId));
      },
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.45,
            height: MediaQuery.of(context).size.width * 0.35,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
              border: Border.all(color: Colors.white),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(1, 1),
                  spreadRadius: 1,
                  blurRadius: 1,
                ),
              ],
            ),
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                Image.asset(path, width: 50, height: 50),
                SizedBox(height: 10),
                Container(
                  height: 20,
                  child: AutoSizeText(
                    name != null ? name : '',
                    style: TextStyle(
                      color: Colors.blue[500],
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    minFontSize: 10.0,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: 50,
                  height: 20,
                  decoration: BoxDecoration(
                      color: status == 'Online'?Colors.green: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20.0)
                  ),
                  child: Center(
                    child: Text(
                      status != null ? status : 'Offline',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 7),
        ],
      ),
    );
  }
}

class ScreenArguments {
  final String name;
  final String clientId;

  ScreenArguments(this.name, this.clientId);
}

weatherdata weatherFromJson(String str) =>
    weatherdata.fromJson(json.decode(str));

class weatherdata {
  Coord coord;
  List<Weather> weather;
  String base;
  Main main;
  int visibility;
  int dt;
  int timezone;
  int id;
  String name;
  int cod;

  weatherdata(
      {this.coord,
      this.weather,
      this.base,
      this.main,
      this.visibility,
      this.dt,
      this.timezone,
      this.id,
      this.name,
      this.cod});

  weatherdata.fromJson(Map<String, dynamic> json) {
    coord = json['coord'] != null ? new Coord.fromJson(json['coord']) : null;
    if (json['weather'] != null) {
      weather = new List<Weather>();
      json['weather'].forEach((v) {
        weather.add(new Weather.fromJson(v));
      });
    }
    base = json['base'];
    main = json['main'] != null ? new Main.fromJson(json['main']) : null;
    visibility = json['visibility'];
    dt = json['dt'];
    timezone = json['timezone'];
    id = json['id'];
    name = json['name'];
    cod = json['cod'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.coord != null) {
      data['coord'] = this.coord.toJson();
    }
    if (this.weather != null) {
      data['weather'] = this.weather.map((v) => v.toJson()).toList();
    }
    data['base'] = this.base;
    if (this.main != null) {
      data['main'] = this.main.toJson();
    }
    data['visibility'] = this.visibility;
    data['dt'] = this.dt;
    data['timezone'] = this.timezone;
    data['id'] = this.id;
    data['name'] = this.name;
    data['cod'] = this.cod;
    return data;
  }
}

class Coord {
  double lon;
  double lat;

  Coord({this.lon, this.lat});

  Coord.fromJson(Map<String, dynamic> json) {
    lon = json['lon'];
    lat = json['lat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lon'] = this.lon;
    data['lat'] = this.lat;
    return data;
  }
}

class Weather {
  int id;
  String main;
  String description;
  String icon;

  Weather({this.id, this.main, this.description, this.icon});

  Weather.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    main = json['main'];
    description = json['description'];
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['main'] = this.main;
    data['description'] = this.description;
    data['icon'] = this.icon;
    return data;
  }
}

class Main {
  double temp;
  var feelsLike;
  double tempMin;
  double tempMax;
  int pressure;
  int humidity;

  Main(
      {this.temp,
      this.feelsLike,
      this.tempMin,
      this.tempMax,
      this.pressure,
      this.humidity});

  Main.fromJson(Map<String, dynamic> json) {
    temp = json['temp'];
    feelsLike = json['feels_like'];
    tempMin = json['temp_min'];
    tempMax = json['temp_max'];
    pressure = json['pressure'];
    humidity = json['humidity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['temp'] = this.temp;
    data['feels_like'] = this.feelsLike;
    data['temp_min'] = this.tempMin;
    data['temp_max'] = this.tempMax;
    data['pressure'] = this.pressure;
    data['humidity'] = this.humidity;
    return data;
  }
}
