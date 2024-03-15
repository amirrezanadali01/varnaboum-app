import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/Category/Products/Transportation/UpdateProductTransportationText.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:varnaboomapp/base.dart';

class TransportationRetryUpdate extends StatefulWidget {
  TransportationRetryUpdate({Key? key, required this.id, required this.data})
      : super(key: key);

  final int id;
  final Map data;

  @override
  State<TransportationRetryUpdate> createState() =>
      _TransportationRetryUpdatesState();
}

class _TransportationRetryUpdatesState
    extends State<TransportationRetryUpdate> {
  Future<void> removeProductsAnother() async {
    EasyLoading.show(status: 'منتظر بمانید ...');
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    http.Response result = await http.delete(
        Uri.parse('$host/api/RemoveProductsTransportation/${widget.id}/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    print(result.statusCode);

    EasyLoading.dismiss();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Directionality(
                textDirection: TextDirection.rtl, child: baseWidget())));
  }

  Future<List> getImageProduct() async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    print(widget.id);
    http.Response result = await http.get(
        Uri.parse(
            '$host/api/GetRetrieveImageProductsTransportation/${widget.id}/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    print('imagesss ${widget.id}');

    return jsonDecode(result.body);
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
          children: [
            FutureBuilder<List>(
                future: getImageProduct(),
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
                      height: 30.h,
                      child: Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: PageView(
                          children: [
                            for (var i in snapshot.data!)
                              Image(
                                image: NetworkImage(i['image']),
                                fit: BoxFit.cover,
                              )
                          ],
                        ),
                      ),
                    );
                  }
                }),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10.sp, right: 10.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Card(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: UpdateProductTransportation(
                                          id: widget.id,
                                          name: 'نام',
                                          field: 'name',
                                          text: widget.data['name'],
                                        ))),
                              ),
                              child: Text(
                                widget.data['name'],
                                style: TextStyle(
                                    fontFamily: Myfont,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      if (widget.data['used'] == null)
                        Row(
                          children: [
                            Icon(Icons.done),
                            SizedBox(
                              width: 5,
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: UpdateProductTransportation(
                                            id: widget.id,
                                            name: 'چقدر کار کرده',
                                            field: 'used',
                                            text: widget.data['used'],
                                          )))),
                              child: Card(
                                child: Text(
                                  'صفر',
                                  style: TextStyle(
                                      color: Colors.greenAccent,
                                      fontFamily: Myfont,
                                      fontSize: 15),
                                ),
                              ),
                            )
                          ],
                        ),
                      if (widget.data['used'] != null)
                        Row(
                          children: [
                            Icon(
                              Icons.directions_car,
                              size: 30,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: UpdateProductTransportation(
                                            id: widget.id,
                                            name: 'چقدر کار کرده',
                                            field: 'used',
                                            isNumber: true,
                                            text:
                                                widget.data['used'].toString(),
                                          )))),
                              child: Card(
                                child: Text(
                                  '${widget.data['used']} کارکرده',
                                  style: TextStyle(
                                      fontFamily: Myfont, fontSize: 15),
                                ),
                              ),
                            )
                          ],
                        ),
                      SizedBox(height: 20),
                      if (widget.data['description'] != null)
                        Card(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: UpdateProductTransportation(
                                          id: widget.id,
                                          name: 'توضیحات',
                                          field: 'description',
                                          text: widget.data['description'],
                                        )))),
                            child: Text(
                              widget.data['description'],
                              style: TextStyle(fontFamily: Myfont),
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: UpdateProductTransportation(
                                      id: widget.id,
                                      name: 'قیمت (تومان)',
                                      field: 'price',
                                      isNumber: true,
                                      text: widget.data['price'].toString(),
                                    )))),
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
                                widget.data['price']
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
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}



//                             child: GestureDetector(
//                               onTap: () => Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => Directionality(
//                                         textDirection: TextDirection.rtl,
//                                         child: UpdateProductTransportation(
//                                           id: widget.id,
//                                           name: 'نام',
//                                           field: 'name',
//                                           text: widget.data['name'],
//                                         ))),
//                               ),
//                               child: Text(
//                                 widget.data['name'],
//                                 style: TextStyle(
//                                     fontFamily: Myfont,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 20),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),




// GestureDetector(
//                           onTap: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => Directionality(
//                                       textDirection: TextDirection.rtl,
//                                       child: UpdateProductTransportation(
//                                         id: widget.id,
//                                         name: 'توضیحات',
//                                         field: 'description',
//                                         text: widget.data['description'],
//                                       )))),
//                           child: Card(
//                             child: Text(
//                               widget.data['description'],
//                               style: TextStyle(fontFamily: Myfont),
//                             ),
//                           ),
//                         ),


