import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/ProfileUser/RetryProfile.dart';

class CategoriesRetryEstate extends StatefulWidget {
  CategoriesRetryEstate({Key? key, required this.citys, required this.id})
      : super(key: key);

  final List<CityModel> citys;
  final int id;
  @override
  State<CategoriesRetryEstate> createState() => _CategoriesRetryEstateState();
}

class _CategoriesRetryEstateState extends State<CategoriesRetryEstate> {
  String url = '$host/api/GetShops/';
  String? nextUrl = '';
  List listCity = [];
  Map filter = {};
  int _valueCity = 0;
  String titleCity = 'شهر';
  bool isVillage = false;
  int _valTypeCity = 0;
  ScrollController _scrollController = ScrollController();

  List listItme = [];

  late Future<List> regionEatate;
  late Future<List> villageEstate;
  late Future<void> getItems;
  late String titleVillage;
  late String titleRegion;
  late int _valVillage;
  late int _valRegion;

  // if filter null pageinition else not

  Future<void> getItemsShop(Map? filter, bool isPageinition) async {
    if (isPageinition == false) {
      await updateToken(context);
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');
      listItme = [];
      http.Response result = await http.post(Uri.parse(url),
          headers: <String, String>{
            'Authorization': 'Bearer $access',
            'Content-Type': 'application/json'
          },
          body: filter == null ? null : jsonEncode(filter));

      filter = {'category': widget.id, 'Confirmation': true};
      nextUrl = jsonDecode(utf8.decode(result.bodyBytes))['next'];
      if (jsonDecode(utf8.decode(result.bodyBytes))['results'] == null) {
        listItme = [];
      } else {
        listItme = jsonDecode(utf8.decode(result.bodyBytes))['results'];
      }
      setState(() {});
    } else {
      print('nextnextnextnextnextnextnextnextnextnextnextnextnextnextnextnext');
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');

      http.Response result = await http.post(
        Uri.parse(nextUrl!),
        headers: <String, String>{'Authorization': 'Bearer $access'},
      );

      nextUrl = jsonDecode(utf8.decode(result.bodyBytes))['next'];
      List items = jsonDecode(utf8.decode(result.bodyBytes))['results'];
      for (var i in items) {
        listItme.add(i);
      }
      setState(() {});
    }

    // return jsonDecode(utf8.decode(result.bodyBytes));
  }

  Future<List> getRegionCity(city) async {
    // Heeeeeerrrreeeeeeeeeeerrrreeeeeeeeeeerrrreeeeeeeeeeerrrreeeeeeeeeeerrrreeeeeeeeeeerrrreeeeeeeeeeerrrreeeeeeeeeeerrrreeeeeeeeeeerrrreeeeeeeeeeerrrreeeeeeeeeeerrrreeeee
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response addcategories = await http.get(
        Uri.parse('$host/api/RegionEstate/$city/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    List result = jsonDecode(utf8.decode(addcategories.bodyBytes));
    result.insert(0, {"id": 5000, "name": "منطقه"});
    if (result.isNotEmpty) {
      titleRegion = result[0]['name'];
      _valRegion = result[0]['id'];
    }

    return result;
  }

  Future<List> getVillage(city) async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    http.Response result = await http.get(
        Uri.parse('$host/api/GetVillage/$city/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    print(result.body);

    List decodeVillage = jsonDecode(utf8.decode(result.bodyBytes));
    print(decodeVillage);

    if (decodeVillage.isNotEmpty) {
      decodeVillage.insert(0, {"id": 5000, "name": "روستا"});
      _valVillage = decodeVillage[0]['id'];
      titleVillage = decodeVillage[0]['name'];
    }

    return decodeVillage;
  }

  @override
  void initState() {
    filter['category'] = widget.id;
    filter['Confirmation'] = true;
    villageEstate = getVillage(_valueCity);
    getItems = getItemsShop(filter, false);
    listCity = widget.citys;
    regionEatate = getRegionCity(_valueCity);
    listCity.removeWhere((element) => element.id == 50000);
    listCity.insert(0, CityModel(id: 50000, name: 'شهر'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener(
        onNotification: (ScrollNotification scrollNotification) {
          if (scrollNotification is ScrollEndNotification) {
            if (nextUrl != null) {
              getItemsShop(filter, true);
            }
          }

          return true;
        },
        child: ListView(
          controller: _scrollController,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 40, right: 40, top: 20),
              child: OutlinedButton(
                child: Text(titleCity,
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: Myfont,
                    )),
                onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          content: StatefulBuilder(builder: (context, stat) {
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (int i = 0; i < listCity.length; i++)
                                    ListTile(
                                      title: Text(
                                        listCity[i].name,
                                        style: TextStyle(fontFamily: Myfont),
                                      ),
                                      leading: Radio<int>(
                                          focusColor: secColor,
                                          activeColor: secColor,
                                          value: i,
                                          groupValue: _valueCity,
                                          onChanged: (valueCity) {
                                            setState(() {
                                              _valueCity = valueCity as int;
                                              titleCity = listCity[i].name;
                                              if (_valueCity != 50000) {
                                                filter['city'] =
                                                    listCity[_valueCity].id;
                                                villageEstate =
                                                    getVillage(_valueCity);
                                                regionEatate =
                                                    getRegionCity(_valueCity);
                                              } else {
                                                filter.remove('city');
                                              }
                                            });
                                            Navigator.pop(context);
                                          }),
                                    )
                                ],
                              ),
                            );
                          }),
                        )),
              ),
            ),
            FutureBuilder<List>(
                future: villageEstate,
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
                    if (snapshot.data!.isEmpty) {
                      return Container();
                    } else {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: ListTile(
                                  title: Text(
                                    'شهر',
                                    style: TextStyle(fontFamily: Myfont),
                                  ),
                                  leading: Radio(
                                      focusColor: secColor,
                                      activeColor: secColor,
                                      value: 0,
                                      groupValue: _valTypeCity,
                                      onChanged: (value) {
                                        setState(() {
                                          _valTypeCity = value as int;
                                          isVillage = false;
                                          filter.remove('village');
                                        });
                                      }),
                                ),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: ListTile(
                                    title: Text(
                                      'روستا',
                                      style: TextStyle(fontFamily: Myfont),
                                    ),
                                    leading: Radio(
                                        focusColor: secColor,
                                        activeColor: secColor,
                                        value: 1,
                                        groupValue: _valTypeCity,
                                        onChanged: (value) {
                                          setState(() {
                                            _valTypeCity = value as int;
                                            isVillage = true;
                                            filter['village'] =
                                                snapshot.data![0]['id'];
                                          });
                                        }),
                                  ))
                            ],
                          ),
                          if (isVillage == true)
                            Container(
                              width: double.infinity,
                              child: Padding(
                                padding: EdgeInsets.only(left: 40, right: 40),
                                child: OutlinedButton(
                                  child: Text(titleVillage,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontFamily: Myfont,
                                      )),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(content:
                                                StatefulBuilder(
                                                    builder: (context, stat) {
                                              return SingleChildScrollView(
                                                  child: Column(
                                                children: [
                                                  for (int i = 0;
                                                      i < snapshot.data!.length;
                                                      i++)
                                                    ListTile(
                                                      title: Text(snapshot
                                                          .data![i]['name']),
                                                      leading: Radio<int>(
                                                          focusColor: secColor,
                                                          activeColor: secColor,
                                                          value: snapshot
                                                              .data![i]['id'],
                                                          groupValue:
                                                              _valVillage,
                                                          onChanged: (_value) {
                                                            setState(() {
                                                              _valVillage =
                                                                  _value as int;
                                                              titleVillage =
                                                                  snapshot.data![
                                                                          i]
                                                                      ['name'];
                                                            });

                                                            filter['village'] =
                                                                _value;
                                                            Navigator.pop(
                                                                context);
                                                          }),
                                                    )
                                                ],
                                              ));
                                            })));
                                  },
                                ),
                              ),
                            ),
                        ],
                      );
                    }
                  }
                }),
            if (isVillage == false && titleCity != 'شهر')
              FutureBuilder<List>(
                  future: regionEatate,
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
                      return Container(
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.only(left: 40, right: 40),
                          child: OutlinedButton(
                            child: Text(titleRegion,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontFamily: Myfont,
                                )),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(content:
                                          StatefulBuilder(
                                              builder: (context, stat) {
                                        return SingleChildScrollView(
                                            child: Column(
                                          children: [
                                            for (int i = 0;
                                                i < snapshot.data!.length;
                                                i++)
                                              ListTile(
                                                title: Text(
                                                    snapshot.data![i]['name']),
                                                leading: Radio<int>(
                                                    focusColor: secColor,
                                                    activeColor: secColor,
                                                    value: snapshot.data![i]
                                                        ['id'],
                                                    groupValue: _valRegion,
                                                    onChanged: (_value) {
                                                      setState(() {
                                                        _valRegion =
                                                            _value as int;
                                                        titleRegion = snapshot
                                                            .data![i]['name'];
                                                      });

                                                      filter['region'] = _value;
                                                      Navigator.pop(context);
                                                    }),
                                              )
                                          ],
                                        ));
                                      })));
                            },
                          ),
                        ),
                      );
                    }
                  }),
            Padding(
              padding: EdgeInsets.only(left: 40, right: 40),
              child: Container(
                width: double.infinity,
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        backgroundColor: secColor,
                        side: BorderSide(color: secColor)),
                    child: Text(
                      'جست و جو',
                      style: TextStyle(color: Colors.white, fontFamily: Myfont),
                    ),
                    onPressed: () {
                      if (isVillage == false && titleRegion == 'منطقه') {
                        filter.remove('region');
                      }
                      if (filter['city'] == 50000) {
                        filter.remove('city');
                      }
                      if (filter['village'] == 5000) {
                        filter.remove('village');
                      }
                      print(filter);
                      getItemsShop(filter, false);
                    }),
              ),
            ),
            FutureBuilder(
                future: getItems,
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
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                          //maxHeight: 13.50.h * listItme.length,
                          maxHeight: listItme.length != 0
                              ? 15.50.h * listItme.length
                              : 15.50.h,
                          minHeight: 56.0),
                      child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: listItme.length + 1,
                          controller: _scrollController,
                          itemBuilder: (context, indext) {
                            if (indext == listItme.length) {
                              if (nextUrl == null) {
                                return Container();
                              } else {
                                return Center(
                                  child: new CircularProgressIndicator(
                                    color: secColor,
                                  ),
                                );
                              }
                            } else {
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: RetryProfile(
                                                  id: listItme[indext]['user'],
                                                  name: listItme[indext]
                                                      ['name']),
                                            ))),
                                child: TemplateItem(
                                    image:
                                        "${host + listItme[indext]['profile']}",
                                    c1: listItme[indext]['name'],
                                    c2: listItme[indext]['address']),
                              );

                              // return Text(listItme.toString());
                            }
                          }),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }
}
