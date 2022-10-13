import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CouponDetails extends StatefulWidget {
  CouponDetails({required this.couponUrl, required this.couponTitle});
  final String couponUrl;
  final String couponTitle;

  @override
  State<CouponDetails> createState() => _CouponDetailsState();
}

class _CouponDetailsState extends State<CouponDetails> {
  late Future couponData;

  @override
  void initState() {
    couponData = getCouponData(widget.couponUrl);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 233, 233, 233),
      appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          elevation: 0,
          backgroundColor: Color.fromARGB(255, 233, 233, 233),
          title: Text(
            "Detalles del cupón",
            style: TextStyle(color: Colors.black),
          )),
      body: Container(
          child: FutureBuilder(
              future: couponData,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  throw snapshot.error!;
                } else if (snapshot.hasData) {
                  Map data = snapshot.data! as Map;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                                child: Text(
                              widget.couponTitle,
                              style: TextStyle(fontSize: 16),
                            ))),
                        Container(
                            padding: EdgeInsets.all(24.0),
                            child: const Center(
                                child: Text(
                              "Este cupón es por tiempo limitado y también tiene una cantidad limitada de veces que puede ser cobrado, por lo tanto, es posible que al intentar utilizarlo ya no esté disponible.",
                              style: TextStyle(fontSize: 16),
                            ))),
                        Container(
                          padding: EdgeInsets.all(16.0),
                          child: SizedBox(
                              height: 40,
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () => _launchUrl(data['url']),
                                child: Text("Ir al curso"),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      //to set border radius to button
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                              )),
                        )
                      ],
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              })),
    );
  }
}

Future getCouponData(couponUrl) async {
  var response = await http.get(Uri.parse(
      'https://api-cursos.vercel.app/api/cursos/' +
          couponUrl)); //PARA SERVIDOR LOCAL AVD TOMA 10.0.2.2 COMO DIRECCIÓN LOCAL EN LUGAR DE 127.0.0.1 O LOCALHOST
  final dataMap = jsonDecode(utf8.decode(response.bodyBytes));
  print(dataMap['url']);
  return dataMap;
}

Future<void> _launchUrl(String url) async {
  print(url);
  if (!await launchUrl(Uri.parse(url))) {
    throw 'Could not launch $url';
  }
}
