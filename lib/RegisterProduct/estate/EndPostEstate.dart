import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/base.dart';
import '../../Detail.dart';
import 'package:dio/dio.dart' as dio;

class EndPostEstate extends StatefulWidget {
  EndPostEstate({Key? key, required this.image, required this.preview})
      : super(key: key);
  final List image;
  final MultipartFile preview;

  @override
  State<EndPostEstate> createState() => _EndPostEstateState();
}

enum TypePrice { buy, rent }

class _EndPostEstateState extends State<EndPostEstate> {
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerYear = TextEditingController();
  TextEditingController controllerBuildingArea = TextEditingController();
  TextEditingController controllerLanArea = TextEditingController();
  TextEditingController controllerBio = TextEditingController();
  TextEditingController controllerRoom = TextEditingController();

  TextEditingController controllerBuyType = TextEditingController();
  TextEditingController contollerRentType = TextEditingController();
  TextEditingController contollerMortgageType = TextEditingController();
  TextEditingController controlleraddress = TextEditingController();

  bool loadBackButton = true;

  bool checkIsNotEmptyText(
      {required TextEditingController textController,
      required String name,
      required String field}) {
    if (textController.text.isEmpty) {
      isAllOk = false;
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("$name وارد نشده است",
                  style: TextStyle(fontFamily: Myfont)),
              content: Text(''),
              actions: [
                OutlinedButton(
                    child: Text('ok', style: TextStyle(fontFamily: Myfont)),
                    onPressed: () => Navigator.pop(context)),
              ],
            );
          });
      return true;
    } else {
      postProduct[field] = textController.text;
      return false;
    }
  }

  TypePrice typerPrice = TypePrice.buy;
  int _valTypePrice = 0;
  bool checkRoom = false;
  bool checkWarehouse = false;
  bool checkBalcony = false;
  bool checkParking = false;
  dio.Dio _dio = dio.Dio();
  late dio.FormData formdata;

  bool isAllOk = true;

  late List images;

  @override
  void initState() {
    images = widget.image;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('rrooooommmmmm $postProduct');
    return WillPopScope(
      onWillPop: () async {
        if (loadBackButton == true) {
          return true;
        } else {
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Color(0xFFFAFAFA),
            leading: BackButton(
              color: Colors.black,
            )),
        floatingActionButton: FloatingActionButton(
          backgroundColor: flColor,
          child: Icon(Icons.done),
          onPressed: (() async {
            loadBackButton = false;
            isAllOk = true;
            if (checkIsNotEmptyText(
                textController: controllerName, name: 'عنوان', field: 'name')) {
            } else if (checkIsNotEmptyText(
                textController: controllerYear,
                name: 'سال ساخت',
                field: 'year')) {
            } else if (checkIsNotEmptyText(
                textController: controlleraddress,
                name: 'آدرس',
                field: 'address')) {
            } else if (checkIsNotEmptyText(
                textController: controllerBuildingArea,
                name: 'متراژ بنا',
                field: 'BuildingArea')) {
            } else if (checkIsNotEmptyText(
                textController: controllerLanArea,
                name: 'متراژ زمین',
                field: 'LanArea')) {
            } else if (checkRoom == true &&
                checkIsNotEmptyText(
                    textController: controllerRoom,
                    name: 'تعداد اتاق',
                    field: 'room')) {
            } else if (typerPrice == TypePrice.buy) {
              postProduct.remove('rent');
              postProduct.remove('mortgage');
              checkIsNotEmptyText(
                  textController: controllerBuyType,
                  name: 'قیمت خرید',
                  field: 'price');
            } else if (typerPrice == TypePrice.rent) {
              postProduct.remove('price');
              if (checkIsNotEmptyText(
                  textController: contollerRentType,
                  name: 'قیمت اجاره',
                  field: 'rent')) {
                print('reeeeennnntttt');
              } else if (checkIsNotEmptyText(
                  textController: contollerMortgageType,
                  name: 'قیمت رهن',
                  field: 'mortgage')) {
                print('meeeeeee');
              }
            }

            print('proddduvvvv $postProduct');

            if (isAllOk == true) {
              postProduct['parking'] = checkParking;
              postProduct['warehouse'] = checkWarehouse;
              postProduct['balcony'] = checkBalcony;
              if (controllerBio.text.isNotEmpty) {
                postProduct['description'] = controllerBio.text;
              }

              print('Estate Product $postProduct');

              EasyLoading.show(status: 'منتظر بمانید ...');
              updateToken(context);
              var boxToken = await Hive.openBox('token');
              String access = boxToken.get('access');

              postProduct['infouser'] = access;

              formdata = dio.FormData.fromMap({
                "product": json.encode(postProduct),
                "preview": widget.preview,
                "images": images
              });

              print(images);

              _dio.options.headers['content-Type'] = 'application/json';
              _dio.options.headers['Authorization'] = 'Bearer $access';

              var response = await _dio.post("$host/api/CreatePostEstate/",
                  data: formdata);

              print('post product $postProduct');
              postProduct = {};
              EasyLoading.dismiss();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: baseWidget())));
            }
          }),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
          child: Column(
            children: [
              Card(
                child: InputTextPost(
                  controllerName: controllerName,
                  name: 'عنوان',
                ),
              ),

              Card(
                child: InputTextPost(
                  controllerName: controlleraddress,
                  name: 'آدرس',
                ),
              ),

              //Type Price
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Transform.translate(
                            offset: Offset(10, 0),
                            child: Text(
                              'خرید',
                              style: TextStyle(fontFamily: Myfont),
                            ),
                          ),
                          leading: Radio(
                              value: 0,
                              groupValue: _valTypePrice,
                              onChanged: (value) {
                                setState(() {
                                  _valTypePrice = value as int;
                                  typerPrice = TypePrice.buy;
                                });
                                contollerRentType.clear();
                                contollerMortgageType.clear();
                              }),
                        ),
                      ),
                      Expanded(
                          child: ListTile(
                        title: Transform.translate(
                          offset: Offset(10, 0),
                          child: Text(
                            'اجاره',
                            style: TextStyle(fontFamily: Myfont),
                          ),
                        ),
                        leading: Radio(
                            value: 1,
                            groupValue: _valTypePrice,
                            onChanged: (value) {
                              setState(() {
                                _valTypePrice = value as int;
                                typerPrice = TypePrice.rent;
                                controllerBuyType.clear();
                              });
                            }),
                      ))
                    ],
                  ),
                  if (typerPrice == TypePrice.buy)
                    Card(
                      child: InputTextPost(
                        controllerName: controllerBuyType,
                        name: 'قیمت خرید (تومان)',
                        typeKeyboard: TextInputType.number,
                      ),
                    ),
                  if (typerPrice == TypePrice.rent)
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: InputTextPost(
                              controllerName: contollerRentType,
                              name: 'اجاره (تومان)',
                              typeKeyboard: TextInputType.number,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            child: InputTextPost(
                              controllerName: contollerMortgageType,
                              name: 'رهن (تومان)',
                              typeKeyboard: TextInputType.number,
                            ),
                          ),
                        ),
                      ],
                    )
                ],
              ),

              Card(
                child: InputTextPost(
                  controllerName: controllerYear,
                  maxlenght: 4,
                  name: 'سال ساخت',
                  typeKeyboard: TextInputType.number,
                ),
              ),
              Card(
                child: InputTextPost(
                  controllerName: controllerBuildingArea,
                  name: 'متراژ بنا',
                  typeKeyboard: TextInputType.number,
                ),
              ),
              Card(
                child: InputTextPost(
                  controllerName: controllerLanArea,
                  name: 'متراژ زمین',
                  typeKeyboard: TextInputType.number,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                        activeColor: secColor,
                        title: Text(
                          'اتاق',
                          style: TextStyle(fontFamily: Myfont),
                        ),
                        value: checkRoom,
                        onChanged: (value) {
                          setState(() {
                            checkRoom = value as bool;
                          });
                          if (value as bool == false) {
                            controllerRoom.clear();
                          }
                        }),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                        activeColor: secColor,
                        title: Text(
                          'انباری',
                          style: TextStyle(fontFamily: Myfont),
                        ),
                        value: checkWarehouse,
                        onChanged: (value) {
                          setState(() {
                            checkWarehouse = value as bool;
                          });
                        }),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                        activeColor: secColor,
                        title: Text(
                          'پارکینگ',
                          style: TextStyle(fontFamily: Myfont),
                        ),
                        value: checkParking,
                        onChanged: (value) {
                          setState(() {
                            checkParking = value as bool;
                          });
                        }),
                  ),
                  Expanded(
                    flex: 1,
                    child: CheckboxListTile(
                        activeColor: secColor,
                        title: Text(
                          'بالکن',
                          style: TextStyle(fontFamily: Myfont),
                        ),
                        value: checkBalcony,
                        onChanged: (value) {
                          setState(() {
                            checkBalcony = value as bool;
                          });
                        }),
                  ),
                ],
              ),

              if (checkRoom)
                Card(
                  child: InputTextPost(
                    controllerName: controllerRoom,
                    name: 'تعداد اتاق',
                    typeKeyboard: TextInputType.number,
                  ),
                ),

              Card(
                child: InputTextPost(
                  controllerName: controllerBio,
                  name: 'توضیخات اضافه',
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
