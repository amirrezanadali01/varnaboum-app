import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/Category/Products/UpdateProductAnotherText.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:varnaboomapp/base.dart';

class AnotherProductsRetryUpdate extends StatefulWidget {
  AnotherProductsRetryUpdate(
      {Key? key,
      required this.id,
      required this.name,
      required this.description,
      required this.price})
      : super(key: key);

  final int id;
  final String name;
  final String? description, price;

  @override
  State<AnotherProductsRetryUpdate> createState() =>
      _AnotherProductsRetryUpdateState();
}

class _AnotherProductsRetryUpdateState
    extends State<AnotherProductsRetryUpdate> {
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

  Future<void> removeProductsAnother() async {
    EasyLoading.show(status: 'منتظر بمانید ...');
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    http.Response result = await http.delete(
        Uri.parse('$host/api/RemoveProductsAnother/${widget.id}/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    print(result.statusCode);

    EasyLoading.dismiss();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Directionality(
                textDirection: TextDirection.rtl, child: baseWidget())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secColor,
        leading: IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: AlertDialog(
                        title: Text('میخواهید این محصول کامل حذف کنید؟'),
                        actions: [
                          TextButton(
                              onPressed: () async {
                                removeProductsAnother();
                              },
                              child: Text(
                                'حذف',
                                style: TextStyle(fontFamily: Myfont),
                              )),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'انصراف',
                                style: TextStyle(fontFamily: Myfont),
                              ))
                        ],
                      ),
                    );
                  });
            },
            icon: Icon(
              Icons.delete,
              size: 29,
              color: Colors.redAccent,
            )),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
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
                            Image(
                                fit: BoxFit.cover,
                                image: NetworkImage(i['image']))
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
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: UpdateproductAnotherText(
                                      field: 'name',
                                      text: widget.name,
                                      id: widget.id,
                                      name: 'عنوان'),
                                ))),
                    child: Card(
                      child: Text(widget.name,
                          style: TextStyle(
                              fontFamily: Myfont,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                          textAlign: TextAlign.right),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (widget.description != null)
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: UpdateproductAnotherText(
                                        field: 'description',
                                        text: widget.description,
                                        id: widget.id,
                                        name: 'توضیحات'),
                                  ))),
                      child: Card(
                        child: Text(
                          widget.description!,
                          style: TextStyle(fontFamily: Myfont),
                        ),
                      ),
                    ),
                  if (widget.description == null)
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: UpdateproductAnotherText(
                                        field: 'description',
                                        text: widget.description,
                                        id: widget.id,
                                        name: 'توضیحات'),
                                  ))),
                      child: Card(
                        child: Text(
                          'توضیحات',
                          style: TextStyle(fontFamily: Myfont),
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  if (widget.price != "null")
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: UpdateproductAnotherText(
                                        field: 'price',
                                        isNumber: true,
                                        text: widget.price,
                                        id: widget.id,
                                        name: 'قیمت (تومان)'),
                                  ))),
                      child: Card(
                        child: Row(
                          children: [
                            Text('قیمت',
                                style: TextStyle(
                                    fontFamily: Myfont,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                                child: Text(
                              widget.price
                                  .toString()
                                  .seRagham()
                                  .toPersianDigit(),
                              style: TextStyle(fontFamily: Myfont),
                            )),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                      ),
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
