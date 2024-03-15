import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/ProfileUser/RetryProfile.dart';
import '../../../Detail.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

import 'package:persian_number_utility/persian_number_utility.dart';

class EstateProduct extends StatefulWidget {
  EstateProduct({Key? key, required this.id, required this.data})
      : super(key: key);

  final int id;
  final Map data;

  @override
  State<EstateProduct> createState() => _EstateProductState();
}

class _EstateProductState extends State<EstateProduct> {
  Future<List> getImageProduct() async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    print(widget.id);
    http.Response result = await http.get(
        Uri.parse('$host/api/GetRetrieveImageProductsEatate/${widget.id}/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    return jsonDecode(result.body);
  }

  late Map data;
  late List<Expanded> iconsEstate = [];

  @override
  void initState() {
    data = widget.data;

    if (data['parking'] == true) {
      iconsEstate.add(Expanded(
          child: Column(
        children: [
          LineIcon(
            LineIcons.parking,
            size: 50,
          ),
          Text(
            'پارکینگ',
            style: TextStyle(fontFamily: Myfont),
          )
        ],
      )));
    }

    if (data['warehouse'] == true) {
      iconsEstate.add(
        Expanded(
            child: Column(
          children: [
            LineIcon(
              LineIcons.warehouse,
              size: 50,
            ),
            Text(
              'انباری',
              style: TextStyle(fontFamily: Myfont),
            )
          ],
        )),
      );
    }

    if (data['balcony'] == true) {
      iconsEstate.add(
        Expanded(
            child: Column(
          children: [
            Icon(
              Icons.balcony_outlined,
              size: 50,
            ),
            Text(
              'بالکن',
              style: TextStyle(fontFamily: Myfont),
            )
          ],
        )),
      );
    }

    if (data['room'] != null) {
      iconsEstate.add(
        Expanded(
            child: Column(
          children: [
            Icon(
              Icons.meeting_room_outlined,
              size: 50,
            ),
            Text(
              '${data['room']} اتاق',
              style: TextStyle(fontFamily: Myfont),
            )
          ],
        )),
      );
    }

    super.initState();
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
                            name: data['NameUser'],
                            id: int.parse(data['User'])))));
          },
        ),
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      bottomSheet: Card(
        margin: EdgeInsets.only(top: 0),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
          height: 10.h,
          width: double.infinity,
          color: primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data['price'] != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'خرید',
                        style: TextStyle(
                            fontSize: 17,
                            fontFamily: Myfont,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(width: 200),
                      Text(
                        data['price'].toString().seRagham().toPersianDigit(),
                        style: TextStyle(
                            fontSize: 17,
                            fontFamily: Myfont,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                if (data['price'] == null)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'رهن',
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: Myfont,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(width: 200),
                          Text(
                            data['mortgage']
                                .toString()
                                .seRagham()
                                .toPersianDigit(),
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: Myfont,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اجاره',
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: Myfont,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(width: 200),
                          Text(
                            data['rent'].toString().seRagham().toPersianDigit(),
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: Myfont,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Padding(
                padding: EdgeInsets.only(left: 10.sp, right: 10.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['name'],
                          style: TextStyle(
                              fontFamily: Myfont,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'متراژ زمین ${data['LanArea']}'.toPersianDigit(),
                          style: TextStyle(
                              fontFamily: Myfont,
                              fontSize: 15,
                              color: Colors.grey),
                        ),
                        SizedBox(width: 10),
                        VerticalDivider(),
                        Text(
                          'متراژ بنا ${data['BuildingArea']}'.toPersianDigit(),
                          style: TextStyle(
                              fontFamily: Myfont,
                              fontSize: 15,
                              color: Colors.grey),
                        ),
                        VerticalDivider(),
                        SizedBox(width: 10),
                        Text(
                          'سال ساخت ${data['year']}'.toPersianDigit(),
                          style: TextStyle(
                              fontFamily: Myfont,
                              fontSize: 15,
                              color: Colors.grey),
                        ),
                      ],
                    ),
                    Divider(
                      color: Color.fromARGB(255, 172, 162, 162),
                      thickness: 1.0,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(LineIcons.city),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          data['CityName'],
                          style: TextStyle(
                              fontFamily: Myfont,
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.italic,
                              color: Color.fromARGB(255, 75, 75, 75)),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        // if (data['village'] != null) Text(','),
                        // SizedBox(
                        //   width: 5,
                        // ),
                        // if (data['village'] != null)
                        //   Text(
                        //     data['village'].toString(),
                        //     style: TextStyle(
                        //         fontFamily: Myfont,
                        //         fontWeight: FontWeight.w300,
                        //         fontStyle: FontStyle.italic,
                        //         color: Color.fromARGB(255, 75, 75, 75)),
                        //   ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                            child: Text(
                          data['address'],
                          style: TextStyle(fontFamily: Myfont),
                        )),
                        SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Row(
                      children: iconsEstate,
                    ),
                    SizedBox(height: 30),
                    if (data['description'] != null)
                      Text(
                        data['description'],
                        style: TextStyle(fontFamily: Myfont),
                      ),
                    SizedBox(height: 15.h),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
