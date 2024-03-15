import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:http/http.dart' as http;
import '../../CategoriesRetryEstate.dart';
import 'EstateProducts.dart';

class Estate extends StatefulWidget {
  Estate(
      {Key? key, required this.subtitle, required this.citys, required this.id})
      : super(key: key);

  final List subtitle;
  final List<CityModel> citys;
  final int id;

  @override
  State<Estate> createState() => _EstateState();
}

class _EstateState extends State<Estate> {
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
            EstateProducts(
              citys: widget.citys,
            ),
            // CategoryRetry(
            //   is_products: true,
            //   citys: widget.citys,
            //   id: widget.id,
            //   subtitle: widget.subtitle,
            // ),
            Directionality(
                textDirection: TextDirection.rtl,
                child: CategoriesRetryEstate(
                  citys: widget.citys,
                  id: widget.id,
                ))
          ]),
        ));
  }
}

class EstateProducts extends StatefulWidget {
  EstateProducts({Key? key, required this.citys}) : super(key: key);

  final List<CityModel> citys;

  @override
  State<EstateProducts> createState() => _EstateProductsState();
}

class _EstateProductsState extends State<EstateProducts> {
  late List<CityModel> listCity;
  List village = [];
  List regionId = [];
  List VillageId = [];

  late String titleCity;
  late String titleVillage;
  late String titleRegion;
  late int _valVillage;
  late Future<void> productsEstate;
  late Future<List> villageEstate;
  late Future<List> regionEatate;
  late Future<List> typeHomeEstate;
  late int _valCity;
  late int _valRegion;
  late int _valItemTypeHome;
  late String titleItemTypeHome;

  String? nextpageUrl = "$host/api/GetProductsEstate/";
  List listItme = [];

  Map productsFilter = {};

  List buyFilter = [];
  List rentFilter = [];
  List mortgageFilter = [];

  bool isBuy = true;
  int _valTypeCity = 0;
  int _valTypeBuy = 0;
  int _valTypeHome = 0;
  bool isVillage = false;

  TextEditingController buyTextController1 = TextEditingController();
  TextEditingController buyTextController2 = TextEditingController();

  TextEditingController mortgageTextController1 = TextEditingController();
  TextEditingController mortgageTextController2 = TextEditingController();

  TextEditingController rentTextControlle1 = TextEditingController();
  TextEditingController rentTextController2 = TextEditingController();

  ScrollController _scrollController = ScrollController();

  Future<List> getRegionCity(city) async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response addcategories = await http.get(
        Uri.parse('$host/api/RegionEstate/$city/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    List result = jsonDecode(utf8.decode(addcategories.bodyBytes));
    if (result.isNotEmpty) {
      titleRegion = result[0]['name'];
      _valRegion = result[0]['id'];
    }

    result.forEach((element) => element['check'] = false);

    print('hhdhdhdhdhdhdhdhd');

    return result;
  }

  Future<void> getProductsEstate(Map? filter) async {
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

        print(result.body);

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

  Future<List> getVillage(city) async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    http.Response result = await http.get(
        Uri.parse('$host/api/GetVillage/$city/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    print(result.body);

    List decodeVillage = jsonDecode(utf8.decode(result.bodyBytes));
    decodeVillage.forEach((element) => element['check'] = false);
    print(decodeVillage);
    if (decodeVillage.isNotEmpty) {
      _valVillage = decodeVillage[0]['id'];
      titleVillage = decodeVillage[0]['name'];
    }

    return decodeVillage;
  }

  Future<List> getTypeHome(name) async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    http.Response result = await http.get(
        Uri.parse('$host/api/GetTypeEstate/$name/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    print(result.body);

    List decodeVillage = jsonDecode(utf8.decode(result.bodyBytes));
    decodeVillage.insert(0, {'name': 'انتخاب کنید', 'id': 0});
    if (decodeVillage.isNotEmpty) {
      _valItemTypeHome = decodeVillage[0]['id'];
      titleItemTypeHome = decodeVillage[0]['name'];
    }

    return decodeVillage;
  }

  @override
  void initState() {
    listCity = widget.citys;
    titleCity = listCity[0].name;
    _valCity = listCity[0].id;
    productsEstate = getProductsEstate(productsFilter);
    villageEstate = getVillage(_valCity);
    regionEatate = getRegionCity(_valCity);
    typeHomeEstate = getTypeHome('masconi');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height - 20.h,
      child: NotificationListener(
        onNotification: (ScrollNotification scrollNotification) {
          if (scrollNotification is ScrollEndNotification) {
            print(scrollNotification);
            if (nextpageUrl != null) {
              getProductsEstate(null);
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
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(content:
                              StatefulBuilder(builder: (context, stat) {
                            return SingleChildScrollView(
                                child: Column(
                              children: [
                                for (int i = 0; i < listCity.length; i++)
                                  ListTile(
                                    title: Text(listCity[i].name),
                                    leading: Radio(
                                        focusColor: secColor,
                                        activeColor: secColor,
                                        value: listCity[i].id,
                                        groupValue: _valCity,
                                        onChanged: (_value) {
                                          setState(() {
                                            print('hiiiiiiiidididiididiiii');
                                            _valCity = _value as int;
                                            titleCity = listCity[i].name;
                                            villageEstate =
                                                getVillage(_valCity);

                                            regionEatate =
                                                getRegionCity(_valCity);
                                          });
                                          if (titleCity == 'شهر') {
                                            productsFilter.remove('city');
                                          } else {
                                            productsFilter['city'] = _valCity;
                                          }
                                          Navigator.pop(context);
                                        }),
                                  )
                              ],
                            ));
                          })));
                },
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
                                flex: 2,
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
                                          productsFilter.remove('village');
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
                                            productsFilter['village'] =
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
                                        builder: (context) => StatefulBuilder(
                                            builder: (context, setState) =>
                                                AlertDialog(content:
                                                    StatefulBuilder(builder:
                                                        (context, stat) {
                                                  return SingleChildScrollView(
                                                      child: Column(
                                                    children: [
                                                      for (int i = 0;
                                                          i <
                                                              snapshot
                                                                  .data!.length;
                                                          i++)
                                                        // ListTile(
                                                        //   title: Text(
                                                        //       snapshot.data![i]['name']),
                                                        //   leading: Radio<int>(
                                                        //       focusColor:
                                                        //           secColor,
                                                        //       activeColor:
                                                        //           secColor,
                                                        //       value: snapshot.data![i]
                                                        //           ['id'],
                                                        //       groupValue: _valRegion,
                                                        //       onChanged: (_value) {
                                                        //         setState(() {
                                                        //           _valRegion =
                                                        //               _value as int;
                                                        //           titleRegion = snapshot
                                                        //               .data![i]['name'];
                                                        //         });

                                                        //         productsFilter['region'] =
                                                        //             _valVillage;
                                                        //         Navigator.pop(context);
                                                        //       }),
                                                        // )
                                                        CheckboxListTile(
                                                          value:
                                                              snapshot.data![i]
                                                                  ['check'],
                                                          title: Text(
                                                              snapshot.data![i]
                                                                  ['name']),
                                                          onChanged:
                                                              (valueCheck) {
                                                            setState(() {
                                                              snapshot.data![i][
                                                                      'check'] =
                                                                  valueCheck!;

                                                              if (snapshot.data![
                                                                          i][
                                                                      'check'] ==
                                                                  true) {
                                                                VillageId.add(
                                                                    snapshot.data![
                                                                            i]
                                                                        ['id']);
                                                              } else {
                                                                VillageId.remove(
                                                                    snapshot.data![
                                                                            i]
                                                                        ['id']);
                                                              }

                                                              print(regionId);
                                                            });
                                                          },
                                                        )
                                                    ],
                                                  ));
                                                }))));
                                    // showDialog(
                                    //     context: context,
                                    //     builder: (_) => AlertDialog(content:
                                    //             StatefulBuilder(
                                    //                 builder: (context, stat) {
                                    //           return SingleChildScrollView(
                                    //               child: Column(
                                    //             children: [
                                    //               for (int i = 0;
                                    //                   i < snapshot.data!.length;
                                    //                   i++)
                                    //                 ListTile(
                                    //                   title: Text(snapshot
                                    //                       .data![i]['name']),
                                    //                   leading: Radio<int>(
                                    //                       focusColor:
                                    //                           secColor,
                                    //                       activeColor:
                                    //                           secColor,
                                    //                       value: snapshot
                                    //                           .data![i]['id'],
                                    //                       groupValue:
                                    //                           _valVillage,
                                    //                       onChanged: (_value) {
                                    //                         setState(() {
                                    //                           _valVillage =
                                    //                               _value as int;
                                    //                           titleVillage =
                                    //                               snapshot.data![
                                    //                                       i]
                                    //                                   ['name'];
                                    //                         });

                                    //                         productsFilter[
                                    //                                 'village'] =
                                    //                             _valVillage;
                                    //                         Navigator.pop(
                                    //                             context);
                                    //                       }),
                                    //                 )
                                    //             ],
                                    //           ));
                                    //         })));
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
                                  builder: (context) => StatefulBuilder(
                                      builder: (context, setState) =>
                                          AlertDialog(content: StatefulBuilder(
                                              builder: (context, stat) {
                                            return SingleChildScrollView(
                                                child: Column(
                                              children: [
                                                for (int i = 0;
                                                    i < snapshot.data!.length;
                                                    i++)
                                                  // ListTile(
                                                  //   title: Text(
                                                  //       snapshot.data![i]['name']),
                                                  //   leading: Radio<int>(
                                                  //       focusColor:
                                                  //           secColor,
                                                  //       activeColor:
                                                  //           secColor,
                                                  //       value: snapshot.data![i]
                                                  //           ['id'],
                                                  //       groupValue: _valRegion,
                                                  //       onChanged: (_value) {
                                                  //         setState(() {
                                                  //           _valRegion =
                                                  //               _value as int;
                                                  //           titleRegion = snapshot
                                                  //               .data![i]['name'];
                                                  //         });

                                                  //         productsFilter['region'] =
                                                  //             _valVillage;
                                                  //         Navigator.pop(context);
                                                  //       }),
                                                  // )
                                                  CheckboxListTile(
                                                    value: snapshot.data![i]
                                                        ['check'],
                                                    title: Text(snapshot
                                                        .data![i]['name']),
                                                    onChanged: (valueCheck) {
                                                      setState(() {
                                                        snapshot.data![i]
                                                                ['check'] =
                                                            valueCheck!;

                                                        if (snapshot.data![i]
                                                                ['check'] ==
                                                            true) {
                                                          regionId.add(snapshot
                                                              .data![i]['id']);
                                                        } else {
                                                          regionId.remove(
                                                              snapshot.data![i]
                                                                  ['id']);
                                                        }

                                                        print(regionId);
                                                      });
                                                    },
                                                  )
                                              ],
                                            ));
                                          }))));

                              // showDialog(
                              //     context: context,
                              //     builder: (_) => AlertDialog(content:
                              //             StatefulBuilder(
                              //                 builder: (context, stat) {
                              //           return SingleChildScrollView(
                              //               child: Column(
                              //             children: [
                              //               Text(snapshot.data.toString()),
                              //               for (int i = 0;
                              //                   i < snapshot.data!.length;
                              //                   i++)
                              //                 // ListTile(
                              //                 //   title: Text(
                              //                 //       snapshot.data![i]['name']),
                              //                 //   leading: Radio<int>(
                              //                 //       focusColor:
                              //                 //           secColor,
                              //                 //       activeColor:
                              //                 //           secColor,
                              //                 //       value: snapshot.data![i]
                              //                 //           ['id'],
                              //                 //       groupValue: _valRegion,
                              //                 //       onChanged: (_value) {
                              //                 //         setState(() {
                              //                 //           _valRegion =
                              //                 //               _value as int;
                              //                 //           titleRegion = snapshot
                              //                 //               .data![i]['name'];
                              //                 //         });

                              //                 //         productsFilter['region'] =
                              //                 //             _valVillage;
                              //                 //         Navigator.pop(context);
                              //                 //       }),
                              //                 // )
                              //                 CheckboxListTile(
                              //                   value: snapshot.data![i]
                              //                       ['check'],
                              //                   title: Text(
                              //                       snapshot.data![i]['name']),
                              //                   onChanged: (valueCheck) {
                              //                     setState(() {
                              //                       snapshot.data![i]['check'] =
                              //                           valueCheck!;

                              //                       print(snapshot.data![i]
                              //                           ['check']);
                              //                     });
                              //                   },
                              //                 )
                              //             ],
                              //           ));
                              //         })));
                            },
                          ),
                        ),
                      );
                    }
                  }),

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ListTile(
                        title: Text(
                          'خرید',
                          style: TextStyle(fontFamily: Myfont),
                        ),
                        leading: Radio(
                            focusColor: secColor,
                            activeColor: secColor,
                            value: 0,
                            groupValue: _valTypeBuy,
                            onChanged: (value) {
                              setState(() {
                                isBuy = true;
                                _valTypeBuy = value as int;
                              });
                            }),
                      ),
                    ),
                    Expanded(
                        flex: 2,
                        child: ListTile(
                          title: Text(
                            'اجاره',
                            style: TextStyle(fontFamily: Myfont),
                          ),
                          leading: Radio(
                              focusColor: secColor,
                              activeColor: secColor,
                              value: 1,
                              groupValue: _valTypeBuy,
                              onChanged: (value) {
                                setState(() {
                                  _valTypeBuy = value as int;
                                  isBuy = false;
                                });
                              }),
                        ))
                  ],
                ),
              ],
            ),

            if (isBuy)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 70,
                      child: Card(
                        child: InputTextPost(
                            controllerName: buyTextController2,
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
                            controllerName: buyTextController1,
                            name: 'خرید از (تومان)',
                            typeKeyboard: TextInputType.number),
                      ),
                    ),
                  ),
                ],
              ),

            if (isBuy == false)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 70,
                          child: Card(
                            child: InputTextPost(
                                controllerName: mortgageTextController2,
                                name: 'تا (تومان)',
                                typeKeyboard: TextInputType.number),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 70,
                          child: Card(
                            child: InputTextPost(
                                controllerName: mortgageTextController1,
                                name: 'رهن از (تومان)',
                                typeKeyboard: TextInputType.number),
                          ),
                        ),
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
                                controllerName: rentTextController2,
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
                                controllerName: rentTextControlle1,
                                name: 'اجاره از (تومان)',
                                typeKeyboard: TextInputType.number),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ListTile(
                        title: Text(
                          'مسکونی',
                          style: TextStyle(fontFamily: Myfont),
                        ),
                        leading: Radio(
                            focusColor: secColor,
                            activeColor: secColor,
                            value: 0,
                            groupValue: _valTypeHome,
                            onChanged: (value) {
                              setState(() {
                                _valTypeHome = value as int;
                                typeHomeEstate = getTypeHome('masconi');
                              });
                            }),
                      ),
                    ),
                    Expanded(
                        flex: 2,
                        child: ListTile(
                          title: Text(
                            'تجاری',
                            style: TextStyle(fontFamily: Myfont),
                          ),
                          leading: Radio(
                              focusColor: secColor,
                              activeColor: secColor,
                              value: 1,
                              groupValue: _valTypeHome,
                              onChanged: (value) {
                                setState(() {
                                  _valTypeHome = value as int;
                                  typeHomeEstate =
                                      getTypeHome('edareAndTejari');
                                });
                              }),
                        ))
                  ],
                ),
                FutureBuilder<List>(
                    future: typeHomeEstate,
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
                      }

                      // HeHHHHHEHEHEHEHEHEHEHEHEHEHEHEHEHEHHEEHHEHEHEEHEHEHHEHEHHHEHEHEHHEHEHEHEHEH

                      else {
                        return Padding(
                          padding:
                              EdgeInsets.only(left: 40, right: 40, bottom: 10),
                          child: Container(
                            width: double.infinity,
                            child: OutlinedButton(
                              child: Text(titleItemTypeHome,
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
                                                  title: Text(snapshot.data![i]
                                                      ['name']),
                                                  leading: Radio<int>(
                                                      focusColor: secColor,
                                                      activeColor: secColor,
                                                      value: snapshot.data![i]
                                                          ['id'],
                                                      groupValue:
                                                          _valItemTypeHome,
                                                      onChanged: (_value) {
                                                        setState(() {
                                                          _valItemTypeHome =
                                                              _value as int;
                                                          titleItemTypeHome =
                                                              snapshot.data![i]
                                                                  ['name'];
                                                        });
                                                        if (_valItemTypeHome ==
                                                            0) {
                                                          productsFilter.remove(
                                                              'TypeEstate');
                                                        } else {
                                                          productsFilter[
                                                                  'TypeEstate'] =
                                                              _valItemTypeHome;
                                                        }
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
                        style:
                            TextStyle(color: Colors.white, fontFamily: Myfont),
                      ),
                      onPressed: () {
                        if (_valTypeBuy == 0) {
                          if (buyTextController1.text.isEmpty) {
                            buyFilter.insert(0, 0);
                          } else {
                            buyFilter.insert(0, buyTextController1.text);
                          }
                          if (buyTextController2.text.isEmpty) {
                            buyFilter.insert(1, 1000000000000000000);
                          } else {
                            buyFilter.insert(1, buyTextController2.text);
                          }

                          buyFilter.length = 2;
                          mortgageFilter.clear();
                          rentFilter.clear();

                          productsFilter.remove('rent__range');
                          productsFilter.remove('mortgage__range');

                          productsFilter['price__range'] = buyFilter;
                        }
                        // Rent
                        if (_valTypeBuy == 1) {
                          if (rentTextControlle1.text.isEmpty) {
                            rentFilter.insert(0, 0);
                          } else {
                            rentFilter.insert(0, rentTextControlle1.text);
                          }

                          if (rentTextController2.text.isEmpty) {
                            rentFilter.insert(1, 1000000000000000000);
                          } else {
                            rentFilter.insert(1, rentTextController2.text);
                          }

                          if (mortgageTextController1.text.isEmpty) {
                            mortgageFilter.insert(0, 0);
                          } else {
                            mortgageFilter.insert(
                                0, mortgageTextController1.text);
                          }

                          if (mortgageTextController2.text.isEmpty) {
                            mortgageFilter.insert(1, 1000000000000000000);
                          } else {
                            mortgageFilter.insert(
                                1, mortgageTextController2.text);
                          }

                          rentFilter.length = 2;
                          mortgageFilter.length = 2;
                          buyFilter.clear();
                          productsFilter.remove('price__range');

                          productsFilter['rent__range'] = rentFilter;
                          productsFilter['mortgage__range'] = mortgageFilter;
                        }

                        if (regionId.isNotEmpty) {
                          productsFilter['region__in'] = regionId;
                        }
                        if (VillageId.isNotEmpty) {
                          productsFilter['village__in'] = VillageId;
                        }

                        setState(() {
                          print(productsFilter);
                          nextpageUrl = "$host/api/GetProductsEstate/";
                          productsEstate = getProductsEstate(productsFilter);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),

            //FUTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
            // FutureBuilder<List>(
            //     future: productsEstate,
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return new Center(
            //           child: new CircularProgressIndicator(
            //             color: secColor,
            //           ),
            //         );
            //       } else if (snapshot.hasError) {
            //       } else {
            //         return Container(
            //           width: double.infinity,
            //           height: MediaQuery.of(context).size.height - 30.h,
            //           child: ListView.builder(
            //               itemCount: snapshot.data!.length,
            //               itemBuilder: (context, indext) {
            //                 return GestureDetector(
            //                   onTap: () {
            //                     print(snapshot.data![indext]);

            //                     Navigator.push(
            //                         context,
            //                         MaterialPageRoute(
            //                             builder: (context) => Directionality(
            //                                   textDirection: TextDirection.rtl,
            //                                   child: EstateProduct(
            //                                       data: snapshot.data![indext],
            //                                       id: snapshot.data![indext]
            //                                           ['id']),
            //                                 )));
            //                   },
            //                   child: TemplateItem(
            //                       image:
            //                           "${host + snapshot.data![indext]['image']}",
            //                       c1: snapshot.data![indext]['name'],
            //                       c2: snapshot.data![indext]['address']),
            //                 );
            //               }),
            //         );
            //       }
            //     }),
            FutureBuilder(
                future: productsEstate,
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
                                          builder: (context) => Directionality(
                                                textDirection:
                                                    TextDirection.rtl,
                                                child: EstateProduct(
                                                    data: listItme[indext],
                                                    id: listItme[indext]['id']),
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
    ));
  }
}


  //                     Navigator.push(
            //                         context,
            //                         MaterialPageRoute(
            //                             builder: (context) => Directionality(
            //                                   textDirection: TextDirection.rtl,
            //                                   child: EstateProduct(
            //                                       data: snapshot.data![indext],
            //                                       id: snapshot.data![indext]
            //                                           ['id']),
            //                                 )));
            //                   },
            //                   child: TemplateItem(
            //                       image:
            //                           "${host + snapshot.data![indext]['image']}",
            //                       c1: snapshot.data![indext]['name'],
            //                       c2: snapshot.data![indext]['address']),
            //                 );
            //               }),