import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/Detail.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:varnaboomapp/FirstLogin/Register/RegisterShop/RegisterSub.dart';
import 'CategoryRegister.dart';

class RegisterCategory extends StatefulWidget {
  RegisterCategory({Key? key}) : super(key: key);

  @override
  _RegisterCategoryState createState() => _RegisterCategoryState();
}

class _RegisterCategoryState extends State<RegisterCategory> {
  List<CityModel> cityList = [];
  late int _value;

  bool is_load = false;

  Future<bool> GetCity() async {
    if (is_load == false) {
      await updateToken(context);
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');
      http.Response result = await http.get(Uri.parse('$host/api/getCity'),
          headers: <String, String>{'Authorization': 'Bearer $access'});

      await DecodenCategory(utf8.decode(result.bodyBytes));
    }

    is_load = true;

    print('jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj');

    return true;
  }

  Future<void> DecodenCategory(body) async {
    print('nnnnnnnnnnnnnnnnnnnnnnnnnnn');

    var cityItem = jsonDecode(body);
    int num = -1;

    for (var i in cityItem) {
      num += 1;
      print(i);

      cityList.add(CityModel(id: i['id'], name: i['name']));
    }
  }

  @override
  void initState() {
    _value = 5000;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: flColor,
          child: Icon(Icons.navigate_next),
          onPressed: () {
            if (_value == 5000) {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('لطفا شهر خود را انتخاب کنید'),
                        contentTextStyle: TextStyle(fontFamily: Myfont),
                      ));
            } else {
              registerInformationShop['city'] = cityList[_value].id.toString();

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: CategoryRegister())));
            }
          }),
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: GetCity(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                is_load == false) {
              return new Center(
                child: new CircularProgressIndicator(
                  color: secColor,
                ),
              );
            } else if (snapshot.hasError) {
              print('Error: ${snapshot.error}');
              return Container();
            } else {
              return Padding(
                padding:
                    EdgeInsets.only(bottom: 20, top: 20, left: 10, right: 10),
                child: Card(
                  shadowColor: secColor,
                  child: ListView(
                    children: [
                      for (int i = 0; i < cityList.length; i++)
                        ListTile(
                          title: Text(
                            cityList[i].name,
                            style: TextStyle(fontFamily: Myfont),
                          ),
                          leading: Radio(
                              focusColor: secColor,
                              activeColor: secColor,
                              value: i,
                              groupValue: _value,
                              onChanged: (value) {
                                this.setState(() {
                                  _value = value as int;
                                });
                              }),
                        )
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
