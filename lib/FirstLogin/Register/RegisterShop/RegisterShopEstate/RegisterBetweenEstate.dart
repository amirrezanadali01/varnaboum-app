import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:varnaboomapp/FirstLogin/Register/RegisterShop/RegisterShopEstate/RegisterRegion.dart';
import 'package:varnaboomapp/FirstLogin/Register/RegisterShop/RegisterShopEstate/RegisterVillage.dart';
import 'package:varnaboomapp/RegisterProduct/estate/PostRegionEstate.dart';
import 'package:varnaboomapp/RegisterProduct/estate/PostVillageEstate.dart';
import 'package:varnaboomapp/RegisterProduct/estate/TypeEstate/PostBetweenTypeEstate.dart';
import 'package:http/http.dart' as http;

class RegisterBetweenCityVillageEstate extends StatefulWidget {
  RegisterBetweenCityVillageEstate({Key? key}) : super(key: key);

  @override
  State<RegisterBetweenCityVillageEstate> createState() =>
      _RegisterBetweenCityVillageEstateState();
}

class _RegisterBetweenCityVillageEstateState
    extends State<RegisterBetweenCityVillageEstate> {
  int _val = 0;

  late Future<List?> villages;
  int city = int.parse(registerInformationShop['city']);

  Future<List?> getVillage() async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response addcategories = await http.get(
        Uri.parse('$host/api/GetVillage/$city/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    List result = jsonDecode(utf8.decode(addcategories.bodyBytes));
    return result;
  }

  @override
  void initState() {
    villages = getVillage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.navigate_next),
        backgroundColor: flColor,
        onPressed: () {
          if (_val == 0) {
            // Region
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Directionality(
                        textDirection: TextDirection.rtl,
                        child: RegisterRegion())));
          } else {
            // Village
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Directionality(
                        textDirection: TextDirection.rtl,
                        child: RegisterVillage())));
          }
        },
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFFFAFAFA),
        actions: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'ملکتون کجاست؟',
                  style: TextStyle(
                      fontFamily: Myfont, fontWeight: FontWeight.bold),
                ),
              ),
              flex: 0,
            ),
            FutureBuilder<List?>(
                future: villages,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return new Center(
                      child: new CircularProgressIndicator(
                        color: secColor,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    print('Error: ${snapshot.error}');
                    return Container();
                  } else {
                    return Expanded(
                      child: Card(
                        shadowColor: secColor,
                        child: Column(
                          children: [
                            ListTile(
                              title: Text('شهر',
                                  style: TextStyle(fontFamily: Myfont)),
                              leading: Radio(
                                focusColor: secColor,
                                activeColor: secColor,
                                value: 0,
                                groupValue: _val,
                                onChanged: (value) {
                                  setState(() {
                                    _val = value as int;
                                  });
                                },
                              ),
                            ),
                            if (snapshot.data!.isNotEmpty)
                              ListTile(
                                title: Text('روستا',
                                    style: TextStyle(fontFamily: Myfont)),
                                leading: Radio(
                                  focusColor: secColor,
                                  activeColor: secColor,
                                  value: 1,
                                  groupValue: _val,
                                  onChanged: (value) {
                                    setState(() {
                                      _val = value as int;
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }
                })
          ],
        ),
      ),
    );
  }
}
