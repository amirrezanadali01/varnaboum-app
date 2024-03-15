import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:varnaboomapp/ProfileUser/RetryProfile.dart';

class TransportationRetryProducts extends StatefulWidget {
  TransportationRetryProducts({Key? key, required this.id, required this.data})
      : super(key: key);

  final int id;
  final Map data;

  @override
  State<TransportationRetryProducts> createState() =>
      _TransportationRetryProductsState();
}

class _TransportationRetryProductsState
    extends State<TransportationRetryProducts> {
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
        leading: IconButton(
          icon: Icon(
            Icons.storefront,
            size: 20.sp,
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Directionality(
                        textDirection: TextDirection.rtl,
                        child: RetryProfile(
                            name: widget.data['NameUser'],
                            id: int.parse(widget.data['User'])))));
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
      ),
      bottomSheet: Card(
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
                  widget.data['price'].toString().seRagham().toPersianDigit(),
                  style: TextStyle(
                      fontSize: 17,
                      fontFamily: Myfont,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          )),
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
                          Text(
                            widget.data['name'],
                            style: TextStyle(
                                fontFamily: Myfont,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
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
                            Text(
                              'صفر',
                              style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontFamily: Myfont,
                                  fontSize: 15),
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
                            Text(
                              '${widget.data['used']} کارکرده',
                              style:
                                  TextStyle(fontFamily: Myfont, fontSize: 15),
                            )
                          ],
                        ),
                      SizedBox(height: 20),
                      if (widget.data['description'] != null)
                        Text(
                          widget.data['description'],
                          style: TextStyle(fontFamily: Myfont),
                        )
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
