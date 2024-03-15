import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/Detail.dart';

class AnotherProductsRetry extends StatefulWidget {
  AnotherProductsRetry(
      {Key? key,
      required this.id,
      required this.name,
      required this.description,
      required this.price})
      : super(key: key);

  final int id;
  final String name;
  final String? description;
  final String? price;

  @override
  State<AnotherProductsRetry> createState() => _AnotherProductsRetryState();
}

class _AnotherProductsRetryState extends State<AnotherProductsRetry> {
  Future<List> GetProductsAnotherImage() async {
    await updateToken(context);

    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    http.Response result = await http.get(
        Uri.parse('$host/api/GetProductsAnotherImage/${widget.id}'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    print('$host/api/GetProductsAnotherImage/${widget.id}');

    return jsonDecode(utf8.decode(result.bodyBytes));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: widget.price != "null"
          ? Card(
              margin: EdgeInsets.only(top: 0),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Container(
                height: 10.h,
                width: double.infinity,
                color: primaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'قیمت',
                      style: TextStyle(
                          fontSize: 17,
                          fontFamily: Myfont,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(width: 200),
                    Text(
                      widget.price.toString().seRagham().toPersianDigit(),
                      style: TextStyle(
                          fontSize: 17,
                          fontFamily: Myfont,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ))
          : null,
      appBar: AppBar(
        backgroundColor: secColor,
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List>(
                future: GetProductsAnotherImage(),
                builder: (context, snapshot) {
                  return Container(
                    width: double.infinity,
                    height: 25.h,
                    child: Card(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      color: Color(0xffeeeeee),
                      child: PageView(
                        children: [
                          for (var i in snapshot.data ?? [])
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                icon: Icon(
                                                  Icons.close,
                                                  color: Colors.red,
                                                  size: 30.sp,
                                                )),
                                            Image(
                                                image:
                                                    NetworkImage(i['image'])),
                                          ],
                                        ),
                                      );
                                    });
                              },
                              child: Image(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(i['image'])),
                            )
                        ],
                      ),
                    ),
                  );
                }),
            Padding(
              padding: EdgeInsets.only(left: 10.sp, right: 10.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name,
                      style: TextStyle(
                          fontFamily: Myfont,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                      textAlign: TextAlign.right),
                  SizedBox(height: 20),
                  if (widget.description != null)
                    Text(
                      widget.description!,
                      style: TextStyle(fontFamily: Myfont),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
