import 'dart:convert';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:scraping_coupons/coupon-details.dart';
import 'package:scraping_coupons/notification-api.dart';

final NotificationApi notification = NotificationApi();
late Future data;
String lastResponse = "";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color.fromARGB(255, 43, 43, 43), // status bar color
  ));
  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Easy Coupons',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Últimos cupones'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    notification.initialize(refreshData);
    AndroidAlarmManager.initialize();
    int alarmId = 1;
    AndroidAlarmManager.periodic(
        const Duration(minutes: 3), alarmId, checkCoupons);
    data = getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 43, 43, 43),
      appBar: AppBar(
        toolbarHeight: 50,
        title: Center(child: Text("Últimos Cupones", style: TextStyle(color: Colors.white),)),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 43, 43, 43), //233
      ),
      body: Center(
        child: RefreshIndicator(
          onRefresh: refreshData,
          child: FutureBuilder(
            future: data,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                throw snapshot.error!;
              } else if (snapshot.hasData) {
                return Container(
                  margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: ListView(
                      //CUANDO SE USA LISTVIEW NO SE PUEDE UTILIZAR UN SINGLECHILDSCROLLVIEW
                      children: buildTiles(snapshot.data)),
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }

  List<Widget> buildTiles(data) {
    List<Widget> tilesList = [];
    for (var i = 0; i < data.length; i++) {
      tilesList.add(InkWell(
        splashColor: Colors.red,
        child: Container(
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 250, 246, 25),
                  Color.fromARGB(255, 250, 123, 113),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 7, 7, 7).withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          margin: const EdgeInsets.only(
              top: 8.0, bottom: 8.0, right: 12.0, left: 12.0),
          padding: const EdgeInsets.all(16),
          child: ListTile(
            title: Text(data[i]['title'], style: TextStyle(fontWeight: FontWeight.w700)),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CouponDetails(
                          couponUrl: data[i]['url'].substring(26),
                          couponTitle: data[i]['title'],
                        ))),
          ),
        ),
      ));
    }
    return tilesList;
  }

  Future refreshData() async {    
    setState(() {
      data = getData();
    });
    Fluttertoast.showToast(
        msg: "Lista actualizada",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color.fromARGB(255, 78, 78, 78),
        textColor: Colors.white,
        fontSize: 16.0);
  }
}

checkCoupons() async {
  var response =
      await http.get(Uri.parse("https://api-cursos.vercel.app/api/cursos"));

  if (response.statusCode == 200) {
    if (lastResponse != "") {
      if (utf8.decode(response.bodyBytes).compareTo(lastResponse) != 0) {
        notification.showNotification(
            id: 0,
            title: "¡Nuevos cupones!",
            body: "Hay nuevos cupones disponibles para canjear",
            payload: "Cupones",
            bigText: jsonDecode(response.body)[0]["title"]);
      }
    }
  }

  lastResponse = utf8.decode(response.bodyBytes);
  print(utf8.decode(response.bodyBytes));
}

Future<List<dynamic>> getData() async {
  var response = await http.get(Uri.parse(
      'https://api-cursos.vercel.app/api/cursos')); //PARA SERVIDOR LOCAL AVD TOMA 10.0.2.2 COMO DIRECCIÓN LOCAL EN LUGAR DE 127.0.0.1 O LOCALHOST
  final dataMap = jsonDecode(utf8.decode(response.bodyBytes));
  print("actualizado");
  return dataMap;
}
