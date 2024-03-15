import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:dio/dio.dart' as dio;
import 'package:varnaboomapp/base.dart';

class ProductsTransportationEnd extends StatefulWidget {
  ProductsTransportationEnd(
      {Key? key, required this.image, required this.preview})
      : super(key: key);

  final List image;
  final MultipartFile preview;

  @override
  State<ProductsTransportationEnd> createState() =>
      _ProductsTransportationEndState();
}

class _ProductsTransportationEndState extends State<ProductsTransportationEnd> {
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerUsed = TextEditingController();
  TextEditingController controllerPrice = TextEditingController();
  TextEditingController controllerDescription = TextEditingController();

  int _valTypeUsed = 0;
  bool isAllOk = true;

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

  dio.Dio _dio = dio.Dio();
  late dio.FormData formdata;

  bool loadBackButton = true;

  @override
  Widget build(BuildContext context) {
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
          onPressed: () async {
            loadBackButton = false;
            isAllOk = true;
            if (checkIsNotEmptyText(
                textController: controllerName, name: 'عنوان', field: 'name')) {
            } else if (checkIsNotEmptyText(
                textController: controllerPrice,
                name: 'قیمت',
                field: 'price')) {}

            if (_valTypeUsed == 1) {
              if (checkIsNotEmptyText(
                  textController: controllerUsed,
                  name: 'کارکرد',
                  field: 'used')) {}
            }

            if (isAllOk == true) {
              print('mhmhmhhhh');
              if (controllerDescription.text.isNotEmpty) {
                postProduct['description'] = controllerDescription.text;
              }
              EasyLoading.show(status: 'منتظر بمانید ...');
              updateToken(context);
              var boxToken = await Hive.openBox('token');
              String access = boxToken.get('access');
              postProduct['infouser'] = access;

              formdata = dio.FormData.fromMap({
                "product": json.encode(postProduct),
                "preview": widget.preview,
                "images": widget.image
              });

              _dio.options.headers['content-Type'] = 'application/json';
              _dio.options.headers['Authorization'] = 'Bearer $access';

              var response = await _dio
                  .post("$host/api/CreatePostTransportation/", data: formdata);

              EasyLoading.dismiss();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: baseWidget())));
            }
          },
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
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Transform.translate(
                          offset: Offset(10, 0),
                          child: Text(
                            'صفر',
                            style: TextStyle(fontFamily: Myfont),
                          ),
                        ),
                        leading: Radio(
                            value: 0,
                            groupValue: _valTypeUsed,
                            onChanged: (value) {
                              setState(() {
                                _valTypeUsed = value as int;
                              });
                              controllerUsed.clear();
                            }),
                      ),
                    ),
                    Expanded(
                        child: ListTile(
                      title: Transform.translate(
                        offset: Offset(10, 0),
                        child: Text(
                          'کارکرده',
                          style: TextStyle(fontFamily: Myfont),
                        ),
                      ),
                      leading: Radio(
                          value: 1,
                          groupValue: _valTypeUsed,
                          onChanged: (value) {
                            setState(() {
                              _valTypeUsed = value as int;
                            });
                          }),
                    ))
                  ],
                ),
                if (_valTypeUsed == 1)
                  Card(
                    child: InputTextPost(
                      controllerName: controllerUsed,
                      name: 'چقدر کار کرده',
                      typeKeyboard: TextInputType.number,
                    ),
                  ),
                Card(
                  child: InputTextPost(
                    controllerName: controllerPrice,
                    name: 'قیمت (تومان)',
                    typeKeyboard: TextInputType.number,
                  ),
                ),
                Card(
                  child: InputTextPost(
                    controllerName: controllerDescription,
                    name: 'توضیحات',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
