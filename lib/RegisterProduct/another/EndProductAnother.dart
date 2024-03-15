import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:varnaboomapp/Detail.dart';

import 'package:dio/dio.dart' as dio;
import 'package:varnaboomapp/base.dart';

class EndProductAnother extends StatefulWidget {
  EndProductAnother(
      {Key? key,
      required this.images,
      required this.is_price,
      required this.preview})
      : super(key: key);

  final List images;
  final bool is_price;

  final MultipartFile preview;

  @override
  State<EndProductAnother> createState() => _EndProductAnotherState();
}

class _EndProductAnotherState extends State<EndProductAnother> {
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerDescription = TextEditingController();
  TextEditingController controllerPrice = TextEditingController();

  bool isAllOk = true;
  dio.Dio _dio = dio.Dio();

  late dio.FormData formdata;

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
              if (checkIsNotEmptyText(
                  textController: controllerName,
                  name: 'عنوان',
                  field: 'name')) {
              } else if (widget.is_price == true) {
                if (checkIsNotEmptyText(
                    textController: controllerPrice,
                    name: 'قیمت',
                    field: 'price')) {}
              }

              if (isAllOk == true) {
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
                  "images": widget.images
                });

                _dio.options.headers['content-Type'] = 'application/json';
                _dio.options.headers['Authorization'] = 'Bearer $access';

                var response = await _dio.post("$host/api/CreatePostAnother/",
                    data: formdata);

                EasyLoading.dismiss();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Directionality(
                            textDirection: TextDirection.rtl,
                            child: baseWidget())));
              }
            }),
        body: Column(
          children: [
            Card(
                child: InputTextPost(
                    controllerName: controllerName, name: 'عنوان')),
            Card(
                child: InputTextPost(
                    controllerName: controllerDescription, name: 'توضیحات')),
            if (widget.is_price == true)
              Card(
                  child: InputTextPost(
                controllerName: controllerPrice,
                name: 'قیمت (تومان)',
                typeKeyboard: TextInputType.number,
              )),
          ],
        ),
      ),
    );
  }
}
