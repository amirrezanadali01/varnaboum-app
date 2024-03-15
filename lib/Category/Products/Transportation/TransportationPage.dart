import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/Category/CategoriesRetryPage.dart';
import 'package:varnaboomapp/Category/Products/Transportation/TransportationProducts.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:http/http.dart' as http;

class Transportation extends StatefulWidget {
  Transportation(
      {Key? key, required this.subtitle, required this.citys, required this.id})
      : super(key: key);

  final List subtitle;
  final List<CityModel> citys;
  final int id;

  @override
  State<Transportation> createState() => _TransportationState();
}

class _TransportationState extends State<Transportation> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: 1,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColor,
            bottom: const TabBar(tabs: [
              Tab(
                icon: Text(
                  'محصولات',
                  style: TextStyle(
                    fontFamily: Myfont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Tab(
                icon: Text(
                  'اصناف',
                  style: TextStyle(
                    fontFamily: Myfont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ]),
          ),
          body: TabBarView(children: [
            TransportationProducts(),
            CategoryRetry(
              is_products: true,
              citys: widget.citys,
              id: widget.id,
              subtitle: widget.subtitle,
            ),
          ]),
        ));
  }
}

class TransportationProducts extends StatefulWidget {
  TransportationProducts({Key? key}) : super(key: key);

  @override
  State<TransportationProducts> createState() => _TransportationProductsState();
}

class _TransportationProductsState extends State<TransportationProducts> {
  late int _valITypeTransportation;
  late String titleItemTypeTransportation;
  late Future<void> productsTransportation;
  late int _valISubTypeTransportation;
  late String titleItemSubTypeTransportation;

  String? nextpageUrl = "$host/api/GetProductsTransportation/";

  List listItme = [];
  ScrollController _scrollController = ScrollController();
  TextEditingController usedTextController1 = TextEditingController();
  TextEditingController usedTextController2 = TextEditingController();

  TextEditingController priceTextController1 = TextEditingController();
  TextEditingController priceTextController2 = TextEditingController();

  int _valTypeUsed = 0;
  bool isUsed = false;
  Map productsFilter = {};

  List priceFilter = [];
  List usedFilter = [];

  Future<void> getProductsTransportatione(Map? filter) async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    print(filter);
    if (nextpageUrl != null) {
      print('fillllllltttter');
      if (filter != null) {
        print('filter is $filter');
        listItme = [];
        http.Response result = await http.post(Uri.parse(nextpageUrl!),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $access',
            },
            body: jsonEncode(filter));

        print(nextpageUrl);

        nextpageUrl = jsonDecode(utf8.decode(result.bodyBytes))['next'];
        if (jsonDecode(utf8.decode(result.bodyBytes))['results'] == null) {
          listItme = [];
        } else {
          listItme = jsonDecode(utf8.decode(result.bodyBytes))['results'];
        }

        setState(() {});
      } else {
        http.Response result =
            await http.post(Uri.parse(nextpageUrl!), headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $access',
        });

        nextpageUrl = jsonDecode(utf8.decode(result.bodyBytes))['next'];
        List newData = jsonDecode(utf8.decode(result.bodyBytes))['results'];

        for (var i in newData) {
          listItme.add(i);
        }

        setState(() {});
        //append

      }
    }
  }

  Future<List> getCategorys(name) async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response result = await http.get(
        Uri.parse('$host/api/GetTypeTransportation/$name/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    List json = jsonDecode(utf8.decode(result.bodyBytes));

    json.insert(0, {'name': 'انتخاب کنید', 'id': 0});
    if (json.isNotEmpty) {
      _valITypeTransportation = json[0]['id'];
      titleItemTypeTransportation = json[0]['name'];
    }

    return json;
  }

  Future<List> getSubTypeCategorys(type) async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response result = await http.get(
        Uri.parse('$host/api/GetSubTypeTransportation/$type/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    print('$host/api/GetSubTypeTransportation/$type/');

    List json = jsonDecode(utf8.decode(result.bodyBytes));

    if (json.isNotEmpty) {
      json.insert(0, {'name': 'انتخاب کنید', 'id': 0});
      _valISubTypeTransportation = json[0]['id'];
      titleItemSubTypeTransportation = json[0]['name'];
    }

    return json;
  }

  int _valType = 2;
  String _nameType = 'car';
  late Future<List> getCategory;
  late Future<List> getSubType;

  @override
  void initState() {
    productsTransportation = getProductsTransportatione(productsFilter);
    getCategory = getCategorys(_nameType);
    getSubType = getSubTypeCategorys(10000);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height - 20.h,
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height - 20.h,
        child: NotificationListener(
          onNotification: (ScrollNotification scrollNotification) {
            if (scrollNotification is ScrollEndNotification) {
              print(scrollNotification);
              if (nextpageUrl != null) {
                getProductsTransportatione(null);
              }
            }
            return true;
          },
          child: ListView(
            controller: _scrollController,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(
                        'موتور',
                        style: TextStyle(fontFamily: Myfont, fontSize: 8.sp),
                      ),
                      leading: Radio(
                          focusColor: secColor,
                          activeColor: secColor,
                          value: 1,
                          groupValue: _valType,
                          onChanged: (_value) {
                            setState(() {
                              _valType = _value as int;
                              _nameType = 'motorcycle';
                              getCategory = getCategorys(_nameType);
                            });
                          }),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text('دوچرخه',
                          style: TextStyle(fontFamily: Myfont, fontSize: 8.sp)),
                      leading: Radio(
                          focusColor: secColor,
                          activeColor: secColor,
                          value: 0,
                          groupValue: _valType,
                          onChanged: (_value) {
                            setState(() {
                              _valType = _value as int;
                              _nameType = 'bycecle';
                              getCategory = getCategorys(_nameType);
                            });
                          }),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text('ماشین',
                          style: TextStyle(fontFamily: Myfont, fontSize: 8.sp)),
                      leading: Radio(
                          focusColor: secColor,
                          activeColor: secColor,
                          value: 2,
                          groupValue: _valType,
                          onChanged: (_value) {
                            setState(() {
                              _valType = _value as int;
                              _nameType = 'car';
                              getCategory = getCategorys(_nameType);
                            });
                          }),
                    ),
                  ),
                ],
              ),
              FutureBuilder<List>(
                  future: getCategory,
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
                        return Padding(
                            padding: EdgeInsets.only(
                                left: 40, right: 40, bottom: 10),
                            child: Container(
                                width: double.infinity,
                                child: OutlinedButton(
                                  child: Text(titleItemTypeTransportation,
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
                                                              _valITypeTransportation,
                                                          onChanged: (_value) {
                                                            setState(() {
                                                              _valITypeTransportation =
                                                                  _value as int;
                                                              titleItemTypeTransportation =
                                                                  snapshot.data![
                                                                          i]
                                                                      ['name'];
                                                            });
                                                            if (_valITypeTransportation ==
                                                                0) {
                                                              productsFilter.remove(
                                                                  'TypeTransportation');
                                                            } else {
                                                              productsFilter[
                                                                      'TypeTransportation'] =
                                                                  _valITypeTransportation;

                                                              getSubType =
                                                                  getSubTypeCategorys(
                                                                      _valITypeTransportation);
                                                            }
                                                            Navigator.pop(
                                                                context);
                                                          }),
                                                    )
                                                ],
                                              ));
                                            })));
                                  },
                                )));
                      }
                    }
                  }),
              FutureBuilder<List>(
                  future: getSubType,
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
                        return Padding(
                            padding: EdgeInsets.only(
                                left: 40, right: 40, bottom: 10),
                            child: Container(
                                width: double.infinity,
                                child: OutlinedButton(
                                  child: Text(titleItemSubTypeTransportation,
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
                                                              _valISubTypeTransportation,
                                                          onChanged: (_value) {
                                                            setState(() {
                                                              _valISubTypeTransportation =
                                                                  _value as int;
                                                              titleItemSubTypeTransportation =
                                                                  snapshot.data![
                                                                          i]
                                                                      ['name'];
                                                            });
                                                            if (_valISubTypeTransportation ==
                                                                0) {
                                                              productsFilter.remove(
                                                                  'SubTypeTransportation');
                                                            } else {
                                                              productsFilter[
                                                                      'SubTypeTransportation'] =
                                                                  _valISubTypeTransportation;
                                                            }
                                                            Navigator.pop(
                                                                context);
                                                          }),
                                                    )
                                                ],
                                              ));
                                            })));
                                  },
                                )));
                      }
                    }
                  }),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(
                            'صفر',
                            style: TextStyle(fontFamily: Myfont),
                          ),
                          leading: Radio(
                              focusColor: secColor,
                              activeColor: secColor,
                              value: 0,
                              groupValue: _valTypeUsed,
                              onChanged: (value) {
                                setState(() {
                                  _valTypeUsed = value as int;
                                  isUsed = false;
                                  productsFilter.remove('village');
                                });
                              }),
                        ),
                      ),
                      Expanded(
                          child: ListTile(
                        title: Text(
                          'کار کرده',
                          style: TextStyle(fontFamily: Myfont),
                        ),
                        leading: Radio(
                            focusColor: secColor,
                            activeColor: secColor,
                            value: 1,
                            groupValue: _valTypeUsed,
                            onChanged: (value) {
                              setState(() {
                                _valTypeUsed = value as int;
                                isUsed = true;
                              });
                            }),
                      ))
                    ],
                  ),
                  if (isUsed == true)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 70,
                            child: Card(
                              child: InputTextPost(
                                  controllerName: usedTextController2,
                                  name: 'تا',
                                  typeKeyboard: TextInputType.number),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 70,
                            child: Card(
                              child: InputTextPost(
                                  controllerName: usedTextController1,
                                  name: 'از',
                                  typeKeyboard: TextInputType.number),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 70,
                      child: Card(
                        child: InputTextPost(
                            controllerName: priceTextController2,
                            name: '(تومان) تا',
                            typeKeyboard: TextInputType.number),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 70,
                      child: Card(
                        child: InputTextPost(
                            controllerName: priceTextController1,
                            name: '(تومان) قیمت از',
                            typeKeyboard: TextInputType.number),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 40, right: 40, top: 10),
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
                      if (isUsed == true) {
                        if (usedTextController1.text.isEmpty) {
                          usedFilter.insert(0, 0);
                        } else {
                          usedFilter.insert(0, usedTextController1.text);
                        }
                        if (usedTextController2.text.isEmpty) {
                          usedFilter.insert(1, 1000000000000000000);
                        } else {
                          usedFilter.insert(1, usedTextController2.text);
                        }

                        usedFilter.length = 2;

                        productsFilter['used__range'] = usedFilter;
                      }

                      if (priceTextController1.text.isEmpty) {
                        priceFilter.insert(0, 0);
                      } else {
                        priceFilter.insert(0, priceTextController1.text);
                      }
                      if (priceTextController2.text.isEmpty) {
                        priceFilter.insert(1, 1000000000000000000);
                      } else {
                        priceFilter.insert(1, priceTextController2.text);
                      }

                      priceFilter.length = 2;

                      productsFilter['price__range'] = priceFilter;

                      setState(() {
                        print(productsFilter);
                        nextpageUrl = "$host/api/GetProductsTransportation/";
                        productsTransportation =
                            getProductsTransportatione(productsFilter);
                      });
                    },
                  ),
                ),
              ),
              FutureBuilder(
                  future: productsTransportation,
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
                            maxHeight: listItme.length != 0
                                ? 13.50.h * listItme.length
                                : 13.50.h,
                            minHeight: 56.0),
                        child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: listItme.length + 1,
                            controller: _scrollController,
                            itemBuilder: (context, indext) {
                              if (indext == listItme.length) {
                                if (nextpageUrl == null) {
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
                                  onTap: () {
                                    print(listItme[indext]);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Directionality(
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  child:
                                                      TransportationRetryProducts(
                                                          data:
                                                              listItme[indext],
                                                          id: listItme[indext]
                                                              ['id']),
                                                )));
                                  },
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: TemplateItem(
                                        image:
                                            "${host + listItme[indext]['image']}",
                                        c1: listItme[indext]['name'],
                                        c2: listItme[indext]['address']),
                                  ),
                                );
                              }
                            }),
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
