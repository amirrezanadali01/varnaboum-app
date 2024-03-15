import 'dart:convert';
import 'package:varnaboomapp/Detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/Detail.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:varnaboomapp/FirstLogin/Register/RegisterShop/RegisterShopEstate/RegisterBetweenEstate.dart';
import 'package:varnaboomapp/FirstLogin/Register/RegisterShop/RegisterSub.dart';
import 'end/RequiredRegisterPage.dart';

class CategoryRegister extends StatefulWidget {
  @override
  _CategoryRegisterState createState() => _CategoryRegisterState();
}

class _CategoryRegisterState extends State<CategoryRegister> {
  List<CategoryModel> CategoryList = [];

  late int _value;
  bool is_load = false;

  Future<bool> GetCategory() async {
    if (is_load == false) {
      await updateToken(context);
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');
      http.Response result = await http.get(
          Uri.parse('$host/api/getcategoriesToday'),
          headers: <String, String>{'Authorization': 'Bearer $access'});

      DecodenCategory(utf8.decode(result.bodyBytes));
    }

    is_load = true;

    return true;
  }

  void DecodenCategory(body) {
    var categoryItem = jsonDecode(body);
    int num = -1;

    for (var i in categoryItem.keys) {
      num += 1;
      int id = categoryItem[i]['id'];
      String image = categoryItem[i]['image'];
      String title = i;
      List subtitle = categoryItem[i]['subtitle'];
      print('subbbbbbbbbbbbbbbbbcattttttttttttttttttttt');
      print(subtitle);
      print('------------------------------------------------------');

      CategoryList.add(CategoryModel(
          id: id, image: image, subtitle: subtitle, title: title, number: num));
    }
  }

  @override
  void initState() {
    _value = 5000;

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
                          title: Text('لطفا مجموعه خود را انتخاب کنید'),
                          contentTextStyle: TextStyle(fontFamily: Myfont),
                        ));
              } else {
                registerInformationShop['category'] =
                    CategoryList[_value].id.toString();

                print('yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy');
                print(CategoryList[_value].title);

                print(registerInformationShop['category']);

                if (CategoryList[_value].title == 'املاک') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        if (CategoryList[_value].subtitle.isNotEmpty) {
                          return Directionality(
                            textDirection: TextDirection.rtl,
                            child: RegiseterForm(
                              subtitle: CategoryList[_value].subtitle,
                            ),
                          );
                        } else {
                          print('nnnnnnnnnnnnnnnnnnnnnn');
                          //registerInformationShop["subcategory"] = [];
                          return Directionality(
                              textDirection: TextDirection.rtl,
                              child: RegisterBetweenCityVillageEstate());
                        }
                      },
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        if (CategoryList[_value].subtitle.isNotEmpty) {
                          return Directionality(
                            textDirection: TextDirection.rtl,
                            child: RegiseterForm(
                              subtitle: CategoryList[_value].subtitle,
                            ),
                          );
                        } else {
                          print('nnnnnnnnnnnnnnnnnnnnnn');
                          //registerInformationShop["subcategory"] = [];
                          return Directionality(
                              textDirection: TextDirection.rtl,
                              child: endregister());
                        }
                      },
                    ),
                  );
                }
              }
            }),
        body: FutureBuilder(
            future: GetCategory(),
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
                return SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: 20, top: 20, left: 10, right: 10),
                    child: Card(
                      shadowColor: secColor,
                      child: ListView(
                        children: [
                          for (var i in CategoryList)
                            ListTile(
                              title: Text(
                                i.title,
                                style: TextStyle(fontFamily: Myfont),
                              ),
                              leading: Radio(
                                  focusColor: secColor,
                                  activeColor: secColor,
                                  value: i.number,
                                  groupValue: _value,
                                  onChanged: (value) {
                                    setState(() {
                                      _value = value as int;
                                    });
                                  }),
                            )
                        ],
                      ),
                    ),
                  ),
                );
              }
            }));
  }
}

class CategoryModel {
  CategoryModel(
      {required this.id,
      required this.image,
      required this.subtitle,
      required this.number,
      required this.title});

  final int id;
  final int number;
  final String image;
  final String title;
  final List subtitle;
}
