import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:varnaboomapp/base.dart';
import 'package:varnaboomapp/FirstLogin/loginpage.dart';
import 'package:http/http.dart' as http;

class info extends StatefulWidget {
  @override
  _infoState createState() => _infoState();
}

class _infoState extends State<info> {
  bool status = false;

  Future<void> decied() async {
    await Hive.initFlutter();
    var bb = await Hive.openBox('token');

    var subregister = await Hive.openBox("SubRegister");
    subregister.clear();

    if (!bb.containsKey('access')) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return Directionality(
              textDirection: TextDirection.ltr, child: login());
        }),
      );
    } else {
      await updateToken(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return Directionality(
              textDirection: TextDirection.rtl, child: baseWidget());
        }),
      );
    }
  }

  @override
  void initState() {
    decied();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image(image: AssetImage('assets/image/logo1.png')),
          ),
        ],
      ),
    );
  }
}
