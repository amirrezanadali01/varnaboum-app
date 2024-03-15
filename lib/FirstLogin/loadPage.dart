import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/Detail.dart';
import 'dart:convert';
import 'Register/RegisterShop/RegisterSub.dart';

class Loading extends StatefulWidget {
  const Loading({
    Key? key,
    required this.type,
  });

  final String type;

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Future<void> typeUser() async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    http.Response types = await http.get(Uri.parse('$host/api/RegisterFirest/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});
    var result = jsonDecode(utf8.decode(types.bodyBytes));

    readyRegister(result);
  }

  void readyRegister(result) {
    for (var i in result[0].keys) {
      for (var j in result[0][i]) {
        print(j['status'] = false);
      }
    }

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Directionality(
                textDirection: TextDirection.rtl,
                child: RegiseterForm(subtitle: result))));
  }

  @override
  void initState() {
    if (widget.type == 'register') {
      typeUser();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
